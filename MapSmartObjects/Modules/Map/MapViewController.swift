//
//  MapViewController.swift
//  MapSmartObjects
//
//  Created by Максим Шалашников on 17.12.2019.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import MapKit

protocol IMapViewController
{
	func getLocationManager() -> CLLocationManager
}

final class MapViewController: UIViewController
{
	private let presenter: IMapPresenter
	private let mapView = MKMapView()
	private let buttonsView = UIView()
	private let addButton = UIButton(type: .contactAdd)
	private let currentLocationButton = UIButton()
	private let locationManeger = CLLocationManager()

	init(presenter: IMapPresenter) {
		self.presenter = presenter
		super.init(nibName: nil, bundle: nil)
	}

	@available (*, unavailable)
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		addSubviews()
		configureViews()
		setConstraints()
		showCurrentLocation()
		addTargets()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		checkLocationEnabled()
		showSmartObjectsOnMap()
		buttonsView.layer.cornerRadius = buttonsView.frame.size.height / 10
	}

	func showSmartObjectsOnMap() {
		for annotation in mapView.annotations {
			mapView.removeAnnotation(annotation)
		}
		for overlay in mapView.overlays {
			mapView.removeOverlay(overlay)
		}
		let smartObjects = presenter.getSmartObjects()
		smartObjects.forEach { smartObject in
			addPinCircle(to: smartObject.coordinate, radius: smartObject.circleRadius)
			mapView.addAnnotation(smartObject)
		}
	}

	//проверяем включена ли служба геолокации
	private func checkLocationEnabled() {
		if CLLocationManager.locationServicesEnabled() {
			setupLocationManager()
			ckeckAutorization()
		}
		else {
			showAlertLocation(title: "Your geolocation service is turned off",
							  message: "Want to turn it on?",
							  url: URL(string: Constants.locationServicesString))
		}
	}

	private func setupLocationManager() {
		locationManeger.delegate = self
		mapView.delegate = self
		locationManeger.desiredAccuracy = kCLLocationAccuracyBest
	}

	private func ckeckAutorization() {
		switch CLLocationManager.authorizationStatus() {
		case .authorizedAlways, .authorizedWhenInUse:
			mapView.showsUserLocation = true
			locationManeger.startUpdatingLocation()
			showCurrentLocation()
			setupLocationManager()
		case .denied, .restricted:
			showAlertLocation(title: "You have banned the use of location",
							  message: "Want to allow?",
							  url: URL(string: UIApplication.openSettingsURLString))
		case .notDetermined:
			locationManeger.requestAlwaysAuthorization()
		default:
			break
		}
		let options: UNAuthorizationOptions = [.badge, .sound, .alert]
		UNUserNotificationCenter.current().requestAuthorization(options: options){ _, error in
			if let error = error {
				print("Error: \(error)")
			}
		}
	}
	private func showAlertLocation(title: String, message: String?, url: URL?) {
		let alert = UIAlertController(title: title,
									  message: message,
									  preferredStyle: .alert)
		let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
			if let url = url {
				UIApplication.shared.open(url, options: [:], completionHandler: nil)
			}
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		alert.addAction(settingsAction)
		alert.addAction(cancelAction)
		present(alert, animated: true, completion: nil)
	}

	//отрисовка области вокруг пин
	private func addPinCircle(to location: CLLocationCoordinate2D, radius: CLLocationDistance) {
			let circle = MKCircle(center: location, radius: radius)
			mapView.addOverlay(circle)
	}
	private func addSubviews() {
		view.addSubview(mapView)
		mapView.addSubview(buttonsView)
		buttonsView.addSubview(addButton)
		buttonsView.addSubview(currentLocationButton)
	}
	private func configureViews() {
		currentLocationButton.setImage(UIImage(named: "location"), for: .normal)
		buttonsView.isOpaque = false
		buttonsView.backgroundColor = .white
		buttonsView.alpha = 0.95
		mapView.showsCompass = false
		setCustomCompass()
	}
	private func addTargets() {
		currentLocationButton.addTarget(self, action: #selector(showCurrentLocation), for: .touchUpInside)
		addButton.addTarget(self, action: #selector(showAddPinAlert), for: .touchUpInside)
		mapView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longTap)))
	}
	private func setCustomCompass() {
		let compassButton = MKCompassButton(mapView: mapView)
		compassButton.compassVisibility = .visible
		mapView.addSubview(compassButton)
		compassButton.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			compassButton.leadingAnchor.constraint(equalTo: buttonsView.leadingAnchor),
			compassButton.topAnchor.constraint(equalTo: buttonsView.bottomAnchor, constant: 8),
			compassButton.widthAnchor.constraint(equalTo: buttonsView.widthAnchor),
			compassButton.heightAnchor.constraint(equalTo: buttonsView.heightAnchor, multiplier: 1 / 2),
		])
	}
	@objc
	private func showCurrentLocation() {
		guard let location = locationManeger.location?.coordinate else { return }
		let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
		mapView.setRegion(region, animated: true)
	}

	@objc
	private func longTap(gestureReconizer: UILongPressGestureRecognizer) {
		if gestureReconizer.state == UIGestureRecognizer.State.began {
			print("LONGTAP")
			let location = gestureReconizer.location(in: mapView)
			let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
			addPinWithAlert(coordinate)
		}
	}

	@objc
	private func showAddPinAlert() {
		if let location = self.locationManeger.location?.coordinate {
			addPinWithAlert(location)
		}
	}

	private func addPinWithAlert(_ location: CLLocationCoordinate2D) {
		let alert = UIAlertController(title: "Add Pin", message: nil, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		alert.addTextField { nameTextField in
			nameTextField.placeholder = "Name"
		}
		alert.addTextField { radiusTextField in
			radiusTextField.placeholder = "Radius"
		}
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
			guard let self = self else { return }
			if let name = alert.textFields?.first?.text,
				let radius = Double(alert.textFields?[1].text ?? "0") {
				self.presenter.addSmartObject(name: name, radius: radius, coordinate: location)
			}
		}))
		present(alert, animated: true)
	}

	private func setConstraints() {
		mapView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			mapView.topAnchor.constraint(equalTo: view.topAnchor),
			mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
		])
		buttonsView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			buttonsView.heightAnchor.constraint(equalToConstant: 90),
			buttonsView.widthAnchor.constraint(equalToConstant: 45),
			buttonsView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 8),
			buttonsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
		])

		mapView.layoutSubviews()

		addButton.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			addButton.leadingAnchor.constraint(equalTo: buttonsView.leadingAnchor),
			addButton.topAnchor.constraint(equalTo: buttonsView.topAnchor),
			addButton.trailingAnchor.constraint(equalTo: buttonsView.trailingAnchor),
			addButton.heightAnchor.constraint(equalTo: buttonsView.heightAnchor, multiplier: 1 / 2),
		])

		currentLocationButton.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			currentLocationButton.leadingAnchor.constraint(equalTo: buttonsView.leadingAnchor),
			currentLocationButton.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor),
			currentLocationButton.trailingAnchor.constraint(equalTo: buttonsView.trailingAnchor),
			currentLocationButton.heightAnchor.constraint(equalTo: addButton.heightAnchor),
		])

		buttonsView.layoutSubviews()
	}
	//метод для уведомлений входа и выхода из зоны
	func notifyEvent(for region: CLRegion) {
		let startMessage = "Вы вошли в зону: "
		// Уведомление если приложение запущено
		if UIApplication.shared.applicationState == .active {
			guard let message = getName(from: region.identifier) else { return }
			self.showAlert(withTitle: "Внимание!", message: startMessage + "\n" + message)
		}
		else {
			// Пуш если фоновый режим или на телефоне включен блок
			guard let body = getName(from: region.identifier) else { return }
			let notificationContent = UNMutableNotificationContent()
			notificationContent.body = startMessage + body
			notificationContent.sound = UNNotificationSound.default
			notificationContent.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber
			let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
			let request = UNNotificationRequest(identifier: "location_change",
												content: notificationContent,
												trigger: trigger)
			UNUserNotificationCenter.current().add(request) { error in
				if let error = error {
					print("Ошибка: \(error)")
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
}

extension MapViewController: MKMapViewDelegate
{
	//метод для отрисовки круга - цвет, прозрачность, ширина и цвет канта
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		var circle = MKOverlayRenderer()
		if overlay is MKCircle {
			let circleRender = MKCircleRenderer(overlay: overlay)
			circleRender.strokeColor = .blue
			circleRender.fillColor = UIColor.green.withAlphaComponent(0.3)
			circleRender.lineWidth = 1
			circle = circleRender
		}
		return circle
	}

	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		guard annotation is SmartObject else { return nil }
		let reuseIdentifier = "Annotation"
		let pin = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? MKMarkerAnnotationView
			?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)

		//настройка пина
		pin.displayPriority = .required
		pin.canShowCallout = true
		pin.animatesWhenAdded = true
		return pin
	}
}

extension MapViewController: CLLocationManagerDelegate
{
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		checkLocationEnabled()
		mapView.showsUserLocation = (status == .authorizedAlways) // проверка на включение службы определения местоположения
	}
	func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
		if region is CLCircularRegion {
			notifyEvent(for: region)
		}
	}
	func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
		if region is CLCircularRegion {
			//notifyEvent(for: region)
		}
	}
}
extension UIViewController
{
	func showAlert(withTitle title: String?, message: String?) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
		alert.addAction(action)
		present(alert, animated: true, completion: nil)
	}
}
extension MapViewController: IMapViewController
{
	func getLocationManager() -> CLLocationManager {
		return self.locationManeger
	}
}
