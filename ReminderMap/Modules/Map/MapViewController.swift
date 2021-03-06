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
		UNUserNotificationCenter.current().delegate = self
		presenter.checkLocationEnabled()
		setupMapScreen()
		addTargets()
		setSmartObjectsOnMap()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationController?.setNavigationBarHidden(true, animated: true)
		presenter.updateSmartObjects(on: mapScreen.mapView)
		setMonitoringPlacesCount()
	}

	func showActivityIndicator() {
		mapScreen.loadHUD.show()
		mapScreen.mapView.gestureRecognizers?.first?.isEnabled = false
		mapScreen.addButton.isEnabled = false
	}

	func hideActivityIndicator() {
		mapScreen.loadHUD.hide()
		mapScreen.mapView.gestureRecognizers?.first?.isEnabled = true
		mapScreen.addButton.isEnabled = true
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

	func setMonitoringPlacesCount() {
		mapScreen.pinCounterView.title.text = "\(presenter.getMonitoringRegionsCount())"
	}

	func addCircle(_ smartObject: SmartObject) {
		mapScreen.mapView.addOverlay(MKCircle(center: smartObject.coordinate, radius: smartObject.circleRadius))
		smartObject.entryDate = presenter.checkUserInCircle(smartObject)
		presenter.updateSmartObject(smartObject)
	}

	func showCurrentLocation(_ location: CLLocationCoordinate2D?) {
		guard let location = location else { return }
		let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
		mapScreen.mapView.setRegion(region, animated: true)
	}

	func setMonitoringCountLable(color: UIColor) {
		mapScreen.pinCounterView.backgroundColor = color
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
		let currentSmartObject = presenter.getSmartObjects().first { $0.identifier == smartObject.identifier }
		guard let tappedSmartObject = currentSmartObject else { return }
		presenter.showPinDetails(with: tappedSmartObject)
	}
}
