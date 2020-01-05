//
//  MapPresenter.swift
//  MapSmartObjects
//
//  Created by Максим Шалашников on 17.12.2019.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import Foundation
import CoreLocation
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
	func getMonitoringRegions() -> [CLRegion]
	func checkMonitoringRegions()
	func handleEvent(for region: CLRegion)
}

final class MapPresenter
{
	weak var mapViewController: MapViewController?
	private let repository: IRepository
	private let router: IMapRouter
	private let locationManeger = CLLocationManager()

	init(repository: IRepository, router: IMapRouter) {
		self.repository = repository
		self.router = router
	}
}

extension MapPresenter: IMapPresenter
{
	func getMonitoringRegions() -> [CLRegion] { //Проверить нужен ли этот метод
		return Array(locationManeger.monitoredRegions)
	}

	func handleEvent(for region: CLRegion) {
		// показать алерт, если приложение активно
		if UIApplication.shared.applicationState == .active {
			mapViewController?.showAlert(withTitle: "Внимание!", message: region.identifier)
		}
		else {
			// отправить нотификацию, если приложение не активно
			let notificationContent = UNMutableNotificationContent()
			notificationContent.body = region.identifier
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

	func checkMonitoringRegions() {
		print(locationManeger.monitoredRegions.count)
		locationManeger.monitoredRegions.forEach { locationManeger.stopMonitoring(for: $0) }
		for smartObject in repository.getSmartObjects() {
			self.startMonitoring(smartObject)
		}
	}

	func getCurrentLocation() -> CLLocationCoordinate2D? {
		guard let location = locationManeger.location?.coordinate else { return nil }
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
				let smartObject = SmartObject(name: name, address: position, coordinate: coordinate, circleRadius: radius)
				self.repository.addSmartObject(object: smartObject)
				DispatchQueue.main.async {
					self.mapViewController?.updateSmartObjects(self.repository.getSmartObjects())
					self.mapViewController?.addCircle(smartObject)
					self.startMonitoring(smartObject)
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
		locationManeger.startMonitoring(for: getRegion(with: smartObject))
	}

	func stopMonitoring(_ smartObject: SmartObject) {
		for region in locationManeger.monitoredRegions where smartObject.identifier == region.identifier {
			locationManeger.stopMonitoring(for: region)
		}
	}

	//проверяем включина ли служба геолокации
	func checkLocationEnabled() {
		if CLLocationManager.locationServicesEnabled() {
			setupLocationManager()
			ckeckAutorization()
		}
		else {
			mapViewController?.showAlertLocation(title: "Your geolocation service is turned off",
												 message: "Want to turn it on?",
												 url: URL(string: Constants.locationServicesString))
		}
	}

	private func setupLocationManager() {
		locationManeger.delegate = mapViewController
		locationManeger.desiredAccuracy = kCLLocationAccuracyBest
	}

	private func ckeckAutorization() {
		switch CLLocationManager.authorizationStatus() {
		case .authorizedAlways, .authorizedWhenInUse:
			locationManeger.startUpdatingLocation()
			//			showCurrentLocation()
			setupLocationManager()
		case .denied, .restricted:
			mapViewController?.showAlertLocation(title: "You have banned the use of location",
												 message: "Want to allow?",
												 url: URL(string: UIApplication.openSettingsURLString))
		case .notDetermined:
			locationManeger.requestAlwaysAuthorization()
		default:
			break
		}
	}

	func addPinWithAlert(_ location: CLLocationCoordinate2D?) {
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
				if let longTaplocation = location {
					self.addSmartObject(name: name, radius: radius, coordinate: longTaplocation)
				}
				else {
					guard let currentUserLocation = self.locationManeger.location?.coordinate else { return }
					self.addSmartObject(name: name, radius: radius, coordinate: currentUserLocation)
				}
			}
		}))
		mapViewController?.present(alert, animated: true)
	}
}
