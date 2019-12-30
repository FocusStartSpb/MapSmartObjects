//
//  MapViewController.swift
//  MapSmartObjects
//
//  Created by Максим Шалашников on 17.12.2019.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import UIKit
import MapKit
import UserNotifications

protocol IMapViewController
{
	func showAlert(withTitle title: String?, message: String?)
	func getMapView() -> MKMapView
	func showAlertLocation(title: String, message: String?, url: URL?)
}

final class MapViewController: UIViewController
{
	private let presenter: IMapPresenter
	private let mapScreen = MapView()

	init(presenter: IMapPresenter) {
		self.presenter = presenter
		super.init(nibName: nil, bundle: nil)
	}

	@available (*, unavailable)
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func loadView() {
		self.view = mapScreen
	}
	override func viewDidLoad() {
		super.viewDidLoad()
		mapScreen.mapView.delegate = self
		mapScreen.mapView.showsUserLocation = true
		addTargets()
		showCurrentLocation(presenter.getCurrentLocation())
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateSmartObjects(presenter.getSmartObjects())
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		presenter.checkLocationEnabled()
		mapScreen.buttonsView.layer.cornerRadius = mapScreen.buttonsView.frame.size.height / 10
		mapScreen.layoutSubviews()
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
		if gestureReconizer.state == UIGestureRecognizer.State.began {
			let location = gestureReconizer.location(in: mapScreen.mapView)
			let coordinate = mapScreen.mapView.convert(location, toCoordinateFrom: mapScreen.mapView)
			presenter.addPinWithAlert(coordinate)
		}
	}
	//берем объекты с карты, исключаем userLocation и кастим в SmartObject
	private func getSmartObjectsFromMap(annotations: [MKAnnotation]) -> [SmartObject] {
		var result = [SmartObject]()
		annotations.forEach { annotaion in
			if let smartObject = annotaion as? SmartObject  {
				result.append(smartObject)
			}
		}
		return result
	}

	private func showCurrentLocation(_ location: CLLocationCoordinate2D?) {
		guard let location = location else { return }
		let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
		mapScreen.mapView.setRegion(region, animated: true)
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
		pin.isDraggable = true
		return pin
	}
}

extension MapViewController: CLLocationManagerDelegate
{
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		presenter.checkLocationEnabled()
	}
}

extension MapViewController: IMapViewController
{
	func showAlert(withTitle title: String?, message: String?) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
		alert.addAction(action)
		present(alert, animated: true, completion: nil)
	}

	func getMapView() -> MKMapView {
		return mapScreen.mapView
	}

	func updateSmartObjects(_ smartObjects: [SmartObject]) {
		let smartObjectsFromDB = presenter.getSmartObjects() // получаем данные из базы данных
		let smartObjectsFromMap = getSmartObjectsFromMap(annotations: mapScreen.mapView.annotations)
		let difference = smartObjectsFromMap.difference(from: smartObjectsFromDB) //находим разницу между 2 массивами
		//вот тут можно отписывать difference от мониторинга (но дальше это надо будет переносить в презентер)
		mapScreen.mapView.removeAnnotations(difference) // убираем разницу с карты
		mapScreen.mapView.overlays.forEach { mapScreen.mapView.removeOverlay($0) } //убираем круги с карты
		presenter.getSmartObjects().forEach { [weak self] smartObject in
			guard let self = self else { return }
			//отрисовка области вокруг пин
			mapScreen.mapView.addOverlay(MKCircle(center: smartObject.coordinate, radius: smartObject.circleRadius))
			DispatchQueue.main.async {
				self.mapScreen.mapView.addAnnotation(smartObject)
			}
		}
	}

	func showAlertLocation(title: String, message: String?, url: URL?) {
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
}
