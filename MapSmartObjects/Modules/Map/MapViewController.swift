//
//  MapViewController.swift
//  MapSmartObjects
//
//  Created by Максим Шалашников on 17.12.2019.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import MapKit
import UserNotifications

protocol IMapViewController
{
	func showAlert(withTitle title: String?, message: String?)
	func showAlertRequestLocation(title: String, message: String?, url: URL?)
	func addCircle(_ smartObject: SmartObject)
	func setMonitoringPlacesCount(number: Int)
	func showCurrentLocation(_ location: CLLocationCoordinate2D?)
	func updateSmartObjects()
}

final class MapViewController: UIViewController
{
	private let presenter: IMapPresenter
	private let mapScreen = MapView()
	private let effectFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)

	init(presenter: IMapPresenter) {
		self.presenter = presenter
		super.init(nibName: nil, bundle: nil)
	}

	@available (*, unavailable)
	required init?(coder aDecoder: NSCoder) {
		fatalError(Constants.fatalError)
	}

	override func loadView() {
		self.view = mapScreen
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		presenter.checkLocationEnabled()
		setupMapScreen()
		addTargets()
		setSmartObjectsOnMap()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationController?.setNavigationBarHidden(true, animated: true)
		updateSmartObjects()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		mapScreen.buttonsView.layer.cornerRadius = mapScreen.buttonsView.frame.size.height / 10
		mapScreen.layoutSubviews()
	}
	private func setupMapScreen() {
		mapScreen.mapView.delegate = self
		mapScreen.mapView.showsUserLocation = true
	}

	private func addTargets() {
		mapScreen.currentLocationButton.addTarget(self, action: #selector(currentLocationButtonPressed), for: .touchUpInside)
		mapScreen.addButton.addTarget(self, action: #selector(addTargetButtonPressed), for: .touchUpInside)
		mapScreen.mapView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longTapped)))
	}

	@objc private func currentLocationButtonPressed() {
		showCurrentLocation(presenter.getCurrentLocation())
	}

	@objc private func addTargetButtonPressed() {
		presenter.addPinWithAlert(nil)
	}

	@objc private func longTapped(gestureReconizer: UILongPressGestureRecognizer) {
		effectFeedbackgenerator.prepare()
		effectFeedbackgenerator.impactOccurred()
		if gestureReconizer.state == UIGestureRecognizer.State.began {
			let location = gestureReconizer.location(in: mapScreen.mapView)
			let coordinate = mapScreen.mapView.convert(location, toCoordinateFrom: mapScreen.mapView)
			presenter.addPinWithAlert(coordinate)
		}
	}
	//берем объекты с карты, исключаем userLocation, кастим в SmartObject
	private func getSmartObjectsFromMap(annotations: [MKAnnotation]) -> [SmartObject] {
		var result = [SmartObject]()
		annotations.forEach { annotaion in
			if let smartObject = annotaion as? SmartObject  {
				result.append(smartObject)
			}
		}
		return result
	}

	// Находит один радиус с одинаковыми координатами и радиусом
	private func removeRadiusOverlay(forPin pin: SmartObject) {
		let overlays = mapScreen.mapView.overlays
		for overlay in overlays {
			guard let circleOverlay = overlay as? MKCircle else { continue }
			let coord = circleOverlay.coordinate
			if coord.latitude == pin.coordinate.latitude &&
				coord.longitude == pin.coordinate.longitude &&
				circleOverlay.radius == pin.circleRadius {
				mapScreen.mapView.removeOverlay(circleOverlay)
				break
			}
		}
	}
	// Установка объектов и кругов на карте из базы при первом запуске
	private func setSmartObjectsOnMap() {
		presenter.getSmartObjects().forEach { smartObject in
			mapScreen.mapView.addAnnotation(smartObject)
			addCircle(smartObject)
		}
	}
}

extension MapViewController: MKMapViewDelegate
{
	func addCircle(_ smartObject: SmartObject) {
		self.mapScreen.mapView.addOverlay(MKCircle(center: smartObject.coordinate, radius: smartObject.circleRadius))
	}
	//метод для отрисовки круга - цвет, прозрачность, ширина и цвет канта
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		var circle = MKOverlayRenderer()
		if overlay is MKCircle {
			let circleRender = MKCircleRenderer(overlay: overlay)
			circleRender.strokeColor = Colors.mainStyle
			circleRender.fillColor = Colors.radiusFill
			circleRender.lineWidth = 1
			circle = circleRender
		}
		return circle
	}

	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		guard annotation is SmartObject else { return nil }
		let reuseIdentifier = Constants.anno
		let pin = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? MKMarkerAnnotationView
			?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)

		//настройка пина
		pin.displayPriority = .required
		pin.canShowCallout = true
		pin.animatesWhenAdded = true
		pin.isDraggable = false // заглушка, круг не перетаскивается и остается постоянно на карте

		//настройка detailCalloutAccessoryView
		let detailLabel = UILabel()
		detailLabel.text = annotation.subtitle ?? ""
		detailLabel.font = UIFont(name: Constants.gothicFont, size: 14.0)
		detailLabel.numberOfLines = 0
		pin.detailCalloutAccessoryView = detailLabel

		//кнопка на пине
		pin.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
		return pin
	}

	func mapView(_ mapView: MKMapView,
				 annotationView view: MKAnnotationView,
				 calloutAccessoryControlTapped control: UIControl) {
		guard let smartObject = view.annotation as? SmartObject else { return }
		presenter.showPinDetails(smartObject)
	}

	//метод для уведомлений входа в зоны
	func notifyEvent(for region: CLRegion) {
		// Уведомление если приложение запущено
		if UIApplication.shared.applicationState == .active {
			guard let message = getName(from: region.identifier) else { return }
			self.showAlert(withTitle: Constants.attention, message: Constants.enterMessage + "\n" + message)
		}
		else {
			// Пуш если фоновый режим или на телефоне включен блок
			guard let body = getName(from: region.identifier) else { return }
			let notificationContent = UNMutableNotificationContent()
			notificationContent.body = Constants.enterMessage + body
			notificationContent.sound = UNNotificationSound.default
			notificationContent.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber
			let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
			let request = UNNotificationRequest(identifier: Constants.changeLocation,
												content: notificationContent,
												trigger: trigger)
			UNUserNotificationCenter.current().add(request) { error in
				if let error = error {
					print(Constants.error + "\(error)")
				}
			}
		}
	}
	func getName(from identifier: String) -> String? {
		let smartObjects = presenter.getSmartObjects()
		guard let matchedPin = smartObjects.first(where: { object in
			object.name == identifier
		}) else { return nil }
		return matchedPin.name
	}

	private func getSmartObject(from: CLRegion) -> SmartObject? {
		return presenter.getSmartObjects().first(where: { $0.identifier == from.identifier })
	}
}

extension MapViewController: CLLocationManagerDelegate
{
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		presenter.checkLocationEnabled()
	}

	func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
		guard let currentSmartObject = getSmartObject(from: region) else { return }
		currentSmartObject.updateVisitCount()
		currentSmartObject.startTimer()
		presenter.handleEvent(for: region)
		presenter.saveToDB()
	}

	func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
		guard let currentSmartObject = getSmartObject(from: region) else { return }
		currentSmartObject.stopTimer()
		presenter.saveToDB()
	}
}

extension MapViewController: IMapViewController
{
	func setMonitoringPlacesCount(number: Int) {
		mapScreen.pinCounterView.title.text = "\(number)"
	}

	func showCurrentLocation(_ location: CLLocationCoordinate2D?) {
		guard let location = location else { return }
		let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
		mapScreen.mapView.setRegion(region, animated: true)
	}

	func showAlert(withTitle title: String?, message: String?) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let action = UIAlertAction(title: Constants.okTitle, style: .cancel, handler: nil)
		alert.addAction(action)
		present(alert, animated: true, completion: nil)
	}
	// Обновление объектов и кругов на карте при удалении или добавлении
	func updateSmartObjects() {
		let smartObjectsFromDB = presenter.getSmartObjects() // получаем данные из базы данных
		let smartObjectsFromMap = getSmartObjectsFromMap(annotations: mapScreen.mapView.annotations)
		let objectsToAdd = smartObjectsFromDB.filter { smartObjectsFromMap.contains($0) == false }
		let objectsToRemove = smartObjectsFromMap.filter { smartObjectsFromDB.contains($0) == false }
		objectsToRemove.forEach { smartObject in
			mapScreen.mapView.removeAnnotation(smartObject)
			presenter.stopMonitoring(smartObject)
			removeRadiusOverlay(forPin: smartObject)
			setMonitoringPlacesCount(number: presenter.getMonitoringRegionsCount())
		}
		objectsToAdd.forEach { smartObject in
			mapScreen.mapView.addAnnotation(smartObject)
			presenter.startMonitoring(smartObject)
			addCircle(smartObject)
			setMonitoringPlacesCount(number: presenter.getMonitoringRegionsCount())
		}
		setMonitoringPlacesCount(number: presenter.getMonitoringRegionsCount())
	}

	func showAlertRequestLocation(title: String, message: String?, url: URL?) {
		let alert = UIAlertController(title: title,
									  message: message,
									  preferredStyle: .alert)
		let settingsAction = UIAlertAction(title: Constants.settings, style: .default) { _ in
			if let url = url {
				UIApplication.shared.open(url, options: [:], completionHandler: nil)
			}
		}
		let cancelAction = UIAlertAction(title: Constants.cancel, style: .cancel, handler: nil)
		alert.addAction(settingsAction)
		alert.addAction(cancelAction)
		present(alert, animated: true, completion: nil)
	}
}
