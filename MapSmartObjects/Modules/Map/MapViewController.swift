//
//  MapViewController.swift
//  MapSmartObjects
//
//  Created by Максим Шалашников on 17.12.2019.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import MapKit

final class MapViewController: UIViewController
{
	private let presenter: IMapPresenter
	private let mapScreen = MapView()
	private let effectFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
	private var entryDate: Date?

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
		presenter.updateSmartObjects(on: mapScreen.mapView)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
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

	// Установка объектов и кругов на карте из базы при первом запуске
	private func setSmartObjectsOnMap() {
		presenter.getSmartObjects().forEach { smartObject in
			mapScreen.mapView.addAnnotation(smartObject)
			addCircle(smartObject)
		}
	}

	@objc private func currentLocationButtonPressed() {
		showCurrentLocation(presenter.getCurrentLocation())
	}

	@objc private func addTargetButtonPressed() {
		presenter.addNewPin(on: nil)
	}

	@objc private func longTapped(gestureReconizer: UILongPressGestureRecognizer) {
		effectFeedbackgenerator.prepare()
		effectFeedbackgenerator.impactOccurred()
		if gestureReconizer.state == UIGestureRecognizer.State.began {
			let location = gestureReconizer.location(in: mapScreen.mapView)
			let coordinate = mapScreen.mapView.convert(location, toCoordinateFrom: mapScreen.mapView)
			presenter.addNewPin(on: coordinate)
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
		presenter.showPinDetails(with: smartObject)
	}
}

extension MapViewController
{
	func setMonitoringPlacesCount() {
		mapScreen.pinCounterView.title.text = "\(presenter.getMonitoringRegionsCount())"
	}

	func addCircle(_ smartObject: SmartObject) {
		mapScreen.mapView.addOverlay(MKCircle(center: smartObject.coordinate, radius: smartObject.circleRadius))
		entryDate = presenter.checkUserInCircle(smartObject)
	}

	func showCurrentLocation(_ location: CLLocationCoordinate2D?) {
		guard let location = location else { return }
		let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
		mapScreen.mapView.setRegion(region, animated: true)
	}
}

extension MapViewController: CLLocationManagerDelegate
{
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		presenter.checkLocationEnabled()
	}

	func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
		entryDate = Date()
		presenter.handleEvent(for: region)
		presenter.saveToDB()
	}

	func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
		guard let currentSmartObject = presenter.getSmartObject(from: region) else { return }
		guard let entryDate = entryDate else { return }
		let insideTime = Date().timeIntervalSince(entryDate)
		currentSmartObject.insideTime += insideTime
		currentSmartObject.visitCount += 1
		presenter.saveToDB()
	}
}
