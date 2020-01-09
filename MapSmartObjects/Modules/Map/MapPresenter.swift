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
	func addSmartObject(name: String, radius: Double, coordinate: CLLocationCoordinate2D)
	func getSmartObjects() -> [SmartObject]
	func checkLocationEnabled()
	func getCurrentLocation() -> CLLocationCoordinate2D?
	func addPinWithAlert(_ location: CLLocationCoordinate2D?)
	func startMonitoring(_ smartObject: SmartObject)
	func stopMonitoring(_ smartObject: SmartObject)
	func getMonitoringRegionsCount() -> Int
	func handleEvent(for region: CLRegion)
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
}

extension MapPresenter: IMapPresenter
{
	func getMonitoringRegionsCount() -> Int { //Проверить нужен ли этот метод
		return locationManager.monitoredRegions.count
	}

	func handleEvent(for region: CLRegion) {
		guard let currentObject = repository.getSmartObject(with: region.identifier) else { return }
		let message = "Вы вошли в зону \(currentObject.name)"
		// показать алерт, если приложение активно
		if UIApplication.shared.applicationState == .active {
			mapViewController?.showAlert(withTitle: "Внимание!", message: message)
		}
		else {
			// отправить нотификацию, если приложение не активно
			let notificationContent = UNMutableNotificationContent()
			notificationContent.body = message
			notificationContent.sound = UNNotificationSound.default
			notificationContent.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber
			let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
			let request = UNNotificationRequest(identifier: "location_change",
												content: notificationContent,
												trigger: trigger)
			UNUserNotificationCenter.current().add(request) { error in
				if let error = error {
					print("Error: \(error)")
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
	func addSmartObject(name: String,
						radius: Double,
						coordinate: CLLocationCoordinate2D) {
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
				self.mapViewController?.showAlert(withTitle: "Внимание!", message: error.localizedDescription)
			}
		}
	}

	private func getRegion(with smartObject: SmartObject) -> CLCircularRegion {
		let region = CLCircularRegion(center: smartObject.coordinate,
									  radius: smartObject.circleRadius,
									  identifier: smartObject.identifier)
		region.notifyOnEntry = true
		region.notifyOnExit = false
		return region
	}

	func startMonitoring(_ smartObject: SmartObject) {
		let fenceRegion = getRegion(with: smartObject)
		locationManager.startMonitoring(for: fenceRegion)
	}

	func stopMonitoring(_ smartObject: SmartObject) {
		for region in locationManager.monitoredRegions {
			guard let circularRegion = region as? CLCircularRegion,
				circularRegion.identifier == smartObject.identifier else { continue }
			locationManager.stopMonitoring(for: circularRegion)
		}
	}

	//проверяем включина ли служба геолокации
	func checkLocationEnabled() {
		if CLLocationManager.locationServicesEnabled() {
			ckeckAutorization()
			setupLocationManager()
		}
		else {
			mapViewController?.showAlertRequestLocation(title: "Your geolocation service is turned off",
												 message: "Want to turn it on?",
												 url: URL(string: Constants.locationServicesString))
		}
	}

	private func ckeckAutorization() {
		switch CLLocationManager.authorizationStatus() {
		case .authorizedWhenInUse, .authorizedAlways, .notDetermined:
			locationManager.requestAlwaysAuthorization()
		case .denied, .restricted:
			mapViewController?.showAlertRequestLocation(title: "You have banned the use of location",
												 message: "Want to allow?",
												 url: URL(string: UIApplication.openSettingsURLString))
		default:
			break
		}
	}

	private func setupLocationManager() {
		locationManager.delegate = mapViewController
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.startUpdatingLocation()
	}

	func addPinWithAlert(_ location: CLLocationCoordinate2D?) {
		if let currentUserLocation = location {
			self.addSmartObject(name: "", radius: 0, coordinate: currentUserLocation)
		}
		else {
			guard let currentUserLocation = getCurrentLocation() else { return }
			self.addSmartObject(name: "", radius: 0, coordinate: currentUserLocation)
		}
	}
}
