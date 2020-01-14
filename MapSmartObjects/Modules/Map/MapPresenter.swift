//
//  MapPresenter.swift
//  MapSmartObjects
//
//  Created by Максим Шалашников on 17.12.2019.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import Foundation
import MapKit
import UserNotifications

protocol IMapPresenter
{
	func getSmartObjects() -> [SmartObject]
	func checkLocationEnabled(_ controller: UIViewController, mapScreen: MapView)
	func getCurrentLocation() -> CLLocationCoordinate2D?
	func addPinWithAlert(_ location: CLLocationCoordinate2D?, controller: UIViewController)
	func startMonitoring(_ smartObject: SmartObject)
	func stopMonitoring(_ smartObject: SmartObject)
	func getMonitoringRegionsCount() -> Int
	func handleEvent(for region: CLRegion, controller: UIViewController)
	func showPinDetails(_ smartObject: SmartObject)
	func saveToDB()
	func setMonitoringPlacesCount(for mapScreen: MapView, number: Int)
	func showCurrentLocation(_ location: CLLocationCoordinate2D?, mapScreen: MapView)
}

final class MapPresenter
{
	weak var mapViewController: MapViewController?
	private let repository: IRepository
	private let router: IMapRouter
	private let locationManager = CLLocationManager()

	init(repository: IRepository, router: IMapRouter) {
		self.repository = repository
		self.router = router
	}

	private func showAlertRequestLocation(title: String, message: String?, url: URL?, controller: UIViewController) {
		let alert = UIAlertController(title: title,
									  message: message,
									  preferredStyle: .alert)
		let settingsAction = UIAlertAction(title: Constants.settingsTitle, style: .default) { _ in
			if let url = url {
				UIApplication.shared.open(url, options: [:], completionHandler: nil)
			}
		}
		let cancelAction = UIAlertAction(title: Constants.cancelTitle, style: .cancel, handler: nil)
		alert.addAction(settingsAction)
		alert.addAction(cancelAction)
		controller.present(alert, animated: true, completion: nil)
	}
	private func showAlert(withTitle title: String?, message: String?, controller: UIViewController) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let action = UIAlertAction(title: Constants.okTitle, style: .cancel, handler: nil)
		alert.addAction(action)
		controller.present(alert, animated: true, completion: nil)
	}
	private func addSmartObject(name: String,
						radius: Double,
						coordinate: CLLocationCoordinate2D,
						controller: UIViewController) {
		repository.getGeoposition(coordinates: coordinate) { [weak self] geocoderResult in
			guard let self = self else { return }
			switch geocoderResult {
			case .success(let position):
				let maxRadius = radius > self.locationManager.maximumRegionMonitoringDistance
					? self.locationManager.maximumRegionMonitoringDistance
					: radius
				let smartObject = SmartObject(name: name, address: position, coordinate: coordinate, circleRadius: maxRadius)
				DispatchQueue.main.async {
					self.router.showDetails(smartObject: smartObject, type: .create)
				}
			case .failure(let error):
				DispatchQueue.main.async {
					self.showAlert(withTitle: Constants.warningTitle, message: error.localizedDescription, controller: controller)
				}
			}
		}
	}
	private func ckeckAutorization(_ controller: UIViewController, mapScreen: MapView) {
		switch CLLocationManager.authorizationStatus() {
		case .authorizedWhenInUse, .authorizedAlways, .notDetermined:
			locationManager.requestAlwaysAuthorization()
			showCurrentLocation(getCurrentLocation(), mapScreen: mapScreen)
		case .denied, .restricted:
			showAlertRequestLocation(title: Constants.bunnedTitle,
														message: Constants.allowMessage,
														url: URL(string: UIApplication.openSettingsURLString),
														controller: controller)
		default:
			break
		}
	}
	private func setupLocationManager() {
		locationManager.delegate = mapViewController
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.startUpdatingLocation()
	}
}

extension MapPresenter: IMapPresenter
{
	func showCurrentLocation(_ location: CLLocationCoordinate2D?, mapScreen: MapView) {
		guard let location = location else { return }
		let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
		mapScreen.mapView.setRegion(region, animated: true)
	}

	func setMonitoringPlacesCount(for mapScreen: MapView, number: Int) {
		mapScreen.pinCounterView.title.text = "\(number)"
	}

	func getMonitoringRegionsCount() -> Int {
		return locationManager.monitoredRegions.count
	}

	func saveToDB() {
		repository.saveSmartObjects()
	}

	func showPinDetails(_ smartObject: SmartObject) {
		router.showDetails(smartObject: smartObject, type: .edit)
	}

	func handleEvent(for region: CLRegion, controller: UIViewController) {
		guard let currentObject = repository.getSmartObject(with: region.identifier) else { return }
		let message = Constants.enterMessage + "\(currentObject.name)"
		// показать алерт, если приложение активно
		if UIApplication.shared.applicationState == .active {
			showAlert(withTitle: Constants.attention, message: message, controller: controller)
		}
		else {
			// отправить нотификацию, если приложение не активно
			let notificationContent = UNMutableNotificationContent()
			notificationContent.body = message
			notificationContent.sound = UNNotificationSound.default
			notificationContent.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber
			let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
			let request = UNNotificationRequest(identifier: Constants.changeLocationID,
												content: notificationContent,
												trigger: trigger)
			UNUserNotificationCenter.current().add(request) { error in
				if let error = error {
					print(Constants.errorText + "\(error)")
				}
			}
		}
	}

	func getCurrentLocation() -> CLLocationCoordinate2D? {
		guard let location = locationManager.location?.coordinate else { return nil }
		return location
	}

	func getSmartObjects() -> [SmartObject] {
		return repository.getSmartObjects()
	}

	func startMonitoring(_ smartObject: SmartObject) {
		locationManager.startMonitoring(for: smartObject.toCircularRegion())
	}

	func stopMonitoring(_ smartObject: SmartObject) {
		for region in locationManager.monitoredRegions {
			guard let circularRegion = region as? CLCircularRegion,
				circularRegion.identifier == smartObject.identifier else { continue }
			locationManager.stopMonitoring(for: circularRegion)
		}
	}

	//проверяем включена ли служба геолокации
	func checkLocationEnabled(_ controller: UIViewController, mapScreen: MapView) {
		if CLLocationManager.locationServicesEnabled() {
			ckeckAutorization(controller, mapScreen: mapScreen)
			setupLocationManager()
		}
		else {
			showAlertRequestLocation(title: Constants.turnOffServiceTitle,
														message: Constants.turnOnMessage,
														url: URL(string: Constants.locationServicesString),
														controller: controller)
		}
	}

	func addPinWithAlert(_ location: CLLocationCoordinate2D?, controller: UIViewController) {
		if let currentUserLocation = location {
			addSmartObject(name: "", radius: 0, coordinate: currentUserLocation, controller: controller)
		}
		else {
			guard let currentUserLocation = getCurrentLocation() else { return }
			addSmartObject(name: "", radius: 0, coordinate: currentUserLocation, controller: controller)
		}
	}
}
