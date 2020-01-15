//
//  MapViewController.swift
//  MapSmartObjects
//
//  Created by Максим Шалашников on 17.12.2019.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import MapKit
import UserNotifications

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
		presenter.checkLocationEnabled(mapScreen)
		setupMapScreen()
		addTargets()
		presenter.setSmartObjectsOnMap(mapScreen)
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationController?.setNavigationBarHidden(true, animated: true)
		presenter.updateSmartObjects(mapScreen)
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
		presenter.showCurrentLocation(presenter.getCurrentLocation(), mapScreen: mapScreen)
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
}

extension MapViewController: MKMapViewDelegate
{
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
		let reuseIdentifier = Constants.annotationID
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
}

extension MapViewController: CLLocationManagerDelegate
{
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		presenter.checkLocationEnabled(mapScreen)
	}
	func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
		presenter.getDate()
		presenter.handleEvent(for: region)
		presenter.saveToDB()
	}
	func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
		guard let currentSmartObject = presenter.getSmartObject(from: region) else { return }
		guard let entryDate = presenter.getEntryDate() else { return }
		let insideTime = Date().timeIntervalSince(entryDate)
		currentSmartObject.insideTime += insideTime
		currentSmartObject.visitCount += 1
		presenter.saveToDB()
	}
}
