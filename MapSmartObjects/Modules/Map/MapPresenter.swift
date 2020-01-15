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
	func checkLocationEnabled(_ mapScreen: MapView)
	func getCurrentLocation() -> CLLocationCoordinate2D?
	func addNewPin(_ location: CLLocationCoordinate2D?)
	func handleEvent(for region: CLRegion)
	func showPinDetails(_ smartObject: SmartObject)
	func saveToDB()
	func getSmartObject(from: CLRegion) -> SmartObject?
	func getSmartObjects() -> [SmartObject]
	func updateSmartObjects(on mapView: MKMapView)
	func getMonitoringRegionsCount() -> Int
	func checkUserInCircle(_ smartObject: SmartObject) -> Date?
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

	private func showAlertRequestLocation(title: String, message: String?, url: URL?) {
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
		mapViewController?.present(alert, animated: true, completion: nil)
	}
	private func showAlert(withTitle title: String?, message: String?) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let action = UIAlertAction(title: Constants.okTitle, style: .cancel, handler: nil)
		alert.addAction(action)
		mapViewController?.present(alert, animated: true, completion: nil)
	}
	private func addSmartObject(name: String,
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
					self.showAlert(withTitle: Constants.warningTitle, message: error.localizedDescription)
				}
			}
		}
	}
	private func ckeckAutorization(_ mapScreen: MapView) {
		switch CLLocationManager.authorizationStatus() {
		case .authorizedWhenInUse, .authorizedAlways, .notDetermined:
			locationManager.requestAlwaysAuthorization()
			mapViewController?.showCurrentLocation(getCurrentLocation())
		case .denied, .restricted:
			showAlertRequestLocation(title: Constants.bunnedTitle,
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

	func getSmartObject(from: CLRegion) -> SmartObject? {
		return getSmartObjects().first(where: { $0.identifier == from.identifier })
	}
	private func startMonitoring(_ smartObject: SmartObject) {
		locationManager.startMonitoring(for: smartObject.toCircularRegion())
	}
	private func stopMonitoring(_ smartObject: SmartObject) {
		for region in locationManager.monitoredRegions {
			guard let circularRegion = region as? CLCircularRegion,
				circularRegion.identifier == smartObject.identifier else { continue }
			locationManager.stopMonitoring(for: circularRegion)
		}
	}
	//берем объекты с карты, исключаем userLocation, кастим в SmartObject
	private func getSmartObjectsFromMap(annotations: [MKAnnotation]) -> [SmartObject] {
		var result = [SmartObject]()
		annotations.forEach { annotaion in
			if let smartObject = annotaion as? SmartObject  {
				result.append(smartObject)
			}
		}
		return result
	}
	// Находит один радиус с одинаковыми координатами и радиусом
	private func removeRadiusOverlay(forPin pin: SmartObject, mapView: MKMapView) {
		let overlays = mapView.overlays
		for overlay in overlays {
			guard let circleOverlay = overlay as? MKCircle else { continue }
			let coord = circleOverlay.coordinate
			if coord.latitude == pin.coordinate.latitude &&
				coord.longitude == pin.coordinate.longitude &&
				circleOverlay.radius == pin.circleRadius {
				mapView.removeOverlay(circleOverlay)
				break
			}
		}
	}
}

extension MapPresenter: IMapPresenter
{
	func getMonitoringRegionsCount() -> Int {
		return locationManager.monitoredRegions.count
	}

	//Проверка внутри ли пользователь при создании объекта, если внутри дата входа == дата создания объекта
	func checkUserInCircle(_ smartObject: SmartObject) -> Date? {
		guard let userCoordinate = getCurrentLocation() else { return nil }
		let userLocation = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
		let circleCenter = CLLocation(latitude: smartObject.coordinate.latitude,
									  longitude: smartObject.coordinate.longitude)
		if userLocation.distance(from: circleCenter) < smartObject.circleRadius {
			return Date()
		}
		return nil
	}

	// Обновление объектов и кругов на карте при удалении или добавлении
	func updateSmartObjects(on mapView: MKMapView) {
		let smartObjectsFromDB = getSmartObjects() // получаем данные из базы данных
		let smartObjectsFromMap = getSmartObjectsFromMap(annotations: mapView.annotations)
		let objectsToAdd = smartObjectsFromDB.filter { smartObjectsFromMap.contains($0) == false }
		let objectsToRemove = smartObjectsFromMap.filter { smartObjectsFromDB.contains($0) == false }
		objectsToRemove.forEach { smartObject in
			mapView.removeAnnotation(smartObject)
			stopMonitoring(smartObject)
			removeRadiusOverlay(forPin: smartObject, mapView: mapView)
			mapViewController?.setMonitoringPlacesCount()
		}
		objectsToAdd.forEach { smartObject in
			mapView.addAnnotation(smartObject)
			startMonitoring(smartObject)
			mapViewController?.addCircle(smartObject)
			mapViewController?.setMonitoringPlacesCount()
		}
		mapViewController?.setMonitoringPlacesCount()
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
			showAlert(withTitle: Constants.attention, message: message)
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
	//проверяем включена ли служба геолокации
	func checkLocationEnabled(_ mapScreen: MapView) {
		if CLLocationManager.locationServicesEnabled() {
			ckeckAutorization(mapScreen)
			setupLocationManager()
		}
		else {
			showAlertRequestLocation(title: Constants.turnOffServiceTitle,
									 message: Constants.turnOnMessage,
									 url: URL(string: Constants.locationServicesString))
		}
	}
	func addNewPin(_ location: CLLocationCoordinate2D?) {
		if let currentUserLocation = location {
			addSmartObject(name: "", radius: 0, coordinate: currentUserLocation)
		}
		else {
			guard let currentUserLocation = getCurrentLocation() else { return }
			addSmartObject(name: "", radius: 0, coordinate: currentUserLocation)
		}
	}
}
