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
	func showPinDetails(_ smartObject: SmartObject)
	func saveToDB()
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
	func getMonitoringRegionsCount() -> Int {
		return locationManager.monitoredRegions.count
	}

	func saveToDB() {
		repository.saveSmartObjects()
	}

	func showPinDetails(_ smartObject: SmartObject) {
		router.showDetails(smartObject: smartObject, type: .edit)
	}

	func handleEvent(for region: CLRegion) {
		guard let currentObject = repository.getSmartObject(with: region.identifier) else { return }
		let message = Constants.enterMessage + "\(currentObject.name)"
		// показать алерт, если приложение активно
		if UIApplication.shared.applicationState == .active {
			mapViewController?.showAlert(withTitle: Constants.attention, message: message)
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
				DispatchQueue.main.async {
					self.mapViewController?.showAlert(withTitle: Constants.warningTitle, message: error.localizedDescription)
				}
			}
		}
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

	//проверяем включина ли служба геолокации
	func checkLocationEnabled() {
		if CLLocationManager.locationServicesEnabled() {
			ckeckAutorization()
			setupLocationManager()
		}
		else {
			mapViewController?.showAlertRequestLocation(title: Constants.turnOffServiceTitle,
														message: Constants.turnOnMessage,
												 url: URL(string: Constants.locationServicesString))
		}
	}

	private func ckeckAutorization() {
		switch CLLocationManager.authorizationStatus() {
		case .authorizedWhenInUse, .authorizedAlways, .notDetermined:
			locationManager.requestAlwaysAuthorization()
			mapViewController?.showCurrentLocation(getCurrentLocation())
		case .denied, .restricted:
			mapViewController?.showAlertRequestLocation(title: Constants.bunnedTitle,
														message: Constants.allowMessage,
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
