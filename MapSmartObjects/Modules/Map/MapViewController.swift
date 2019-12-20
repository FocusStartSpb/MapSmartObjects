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
	//пока заглушка, потом надо будет получать координаты и радиус из пина
	private let pinLocation = CLLocation()
	private let pinRadius = CLLocationDistance()
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
		checkLocationEnabled()
		showCurrentLocation()
		addTargets()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		buttonsView.layer.cornerRadius = buttonsView.frame.size.height / 10
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
		case .authorizedAlways:
			mapView.showsUserLocation = true
			locationManeger.startUpdatingLocation()
		case .authorizedWhenInUse:
			mapView.showsUserLocation = true
			locationManeger.startUpdatingLocation()
		case .denied:
			showAlertLocation(title: "you have banned the use of location",
							  message: "want to allow?",
							  url: URL(string: UIApplication.openSettingsURLString))
		case .restricted:
			break
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
		let settingsAction = UIAlertAction(title: "Settings", style: .default) { alert in
			print(alert) //FIX IT
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
	private func addPinCircle(to location: CLLocation, radius: CLLocationDistance) {
		self.mapView.delegate = self
		let circle = MKCircle(center: location.coordinate, radius: radius)
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

			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
				guard let location = self.locationManeger.location?.coordinate else { return }
				if let name = alert.textFields?.first?.text, let radius = alert.textFields?[1].text {
					print("Pin name: \(name)")
					print("Radius = \(radius)")
					print("Location: \(location)")
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
			circleRender.fillColor = UIColor(red: 0, green: 0, blue: 255, alpha: 0.1)
			circleRender.lineWidth = 1
			circle = circleRender
		}
		return circle
	}
}

extension MapViewController: CLLocationManagerDelegate
{
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		ckeckAutorization()
	}
}
