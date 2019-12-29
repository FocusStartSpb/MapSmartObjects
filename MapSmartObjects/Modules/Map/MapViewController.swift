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
		presenter.showCurrentLocation()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		presenter.checkLocationEnabled()
		mapScreen.buttonsView.layer.cornerRadius = mapScreen.buttonsView.frame.size.height / 10
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		presenter.updateSmartObjects(on: mapScreen.mapView)
	}

	private func addTargets() {
		mapScreen.currentLocationButton.addTarget(self, action: #selector(currentLocationButtonPressed), for: .touchUpInside)
		mapScreen.addButton.addTarget(self, action: #selector(addTargetButtonPressed), for: .touchUpInside)
		mapScreen.mapView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longTapPressed)))
	}

	@objc private func currentLocationButtonPressed() {
		presenter.showCurrentLocation()
	}

	@objc private func addTargetButtonPressed() {
		presenter.addPinWithAlert(nil)
	}

	@objc private func longTapPressed(gestureReconizer: UILongPressGestureRecognizer) {
		if gestureReconizer.state == UIGestureRecognizer.State.began {
			let location = gestureReconizer.location(in: mapScreen.mapView)
			let coordinate = mapScreen.mapView.convert(location, toCoordinateFrom: mapScreen.mapView)
			presenter.addPinWithAlert(coordinate)
		}
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
