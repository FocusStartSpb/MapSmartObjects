//
//  MapViewController.swift
//  MapSmartObjects
//
//  Created by Максим Шалашников on 17.12.2019.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import UIKit
import MapKit

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
		showSmartObjectsOnMap()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		checkLocationEnabled()
		buttonsView.layer.cornerRadius = buttonsView.frame.size.height / 10
	}

	private func showSmartObjectsOnMap() {
		presenter.getSmartObjects().forEach { smartObject in
			addPinCircle(to: smartObject.coordinate, radius: smartObject.circleRadius)
			mapView.addAnnotation(smartObject)
		}
	}

	//проверяем включина ли служба геолокации
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
		self.mapView.delegate = self
		let circle = MKCircle(center: location, radius: radius)
		self.mapView.addOverlay(circle)
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
	private func showAddPinAlert() {
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
				guard let location = self.locationManeger.location?.coordinate else { return }
				if let name = alert.textFields?.first?.text,
					let radius = Double(alert.textFields?[1].text ?? "0") {
					self.addPinCircle(to: location, radius: CLLocationDistance(integerLiteral: radius))
					self.presenter.addSmartObject(name: name, radius: radius, coordinate: location)
					let annotation = MKPointAnnotation()
					annotation.coordinate = location
					self.mapView.addAnnotation(annotation)
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
}

extension MapViewController: MKMapViewDelegate
{
	//метод для отрисовки круга - красный цвет, прозрачность, ширина и цвет канта
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
		guard annotation is MKPointAnnotation else { return nil }
		let reuseIdentifier = "Annotation"
		let pin = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? MKMarkerAnnotationView
			?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)

		//настройка пина
		pin.canShowCallout = true
		pin.animatesWhenAdded = true
		pin.isDraggable = true
		return pin
	}
}

extension MapViewController: CLLocationManagerDelegate
{
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		checkLocationEnabled()
	}
}
