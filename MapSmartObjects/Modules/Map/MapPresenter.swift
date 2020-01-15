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
	func checkLocationEnabled(_ controller: UIViewController, mapScreen: MapView)
	func getCurrentLocation() -> CLLocationCoordinate2D?
	func addPinWithAlert(_ location: CLLocationCoordinate2D?, controller: UIViewController)
	func handleEvent(for region: CLRegion, controller: UIViewController)
	func showPinDetails(_ smartObject: SmartObject)
	func saveToDB()
	func showCurrentLocation(_ location: CLLocationCoordinate2D?, mapScreen: MapView)
	func setSmartObjectsOnMap(_ mapScreen: MapView)
	func getSmartObject(from: CLRegion) -> SmartObject?
	func updateSmartObjects(_ mapScreen: MapView)
	func getDate()
	func getEntryDate() -> Date?
}

final class MapPresenter
{
	weak var mapViewController: MapViewController?
	private let repository: IRepository
	private let router: IMapRouter
	private let locationManager = CLLocationManager()
	private var entryDate: Date?

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

	internal func getSmartObject(from: CLRegion) -> SmartObject? {
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
	private func getMonitoringRegionsCount() -> Int {
		return locationManager.monitoredRegions.count
	}
	private func setMonitoringPlacesCount(for mapScreen: MapView, number: Int) {
		mapScreen.pinCounterView.title.text = "\(number)"
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
	private func removeRadiusOverlay(forPin pin: SmartObject, mapScreen: MapView) {
		let overlays = mapScreen.mapView.overlays
		for overlay in overlays {
			guard let circleOverlay = overlay as? MKCircle else { continue }
			let coord = circleOverlay.coordinate
			if coord.latitude == pin.coordinate.latitude &&
				coord.longitude == pin.coordinate.longitude &&
				circleOverlay.radius == pin.circleRadius {
				mapScreen.mapView.removeOverlay(circleOverlay)
				break
			}
		}
	}
	private func addCircle(_ smartObject: SmartObject, mapScreen: MapView) {
		mapScreen.mapView.addOverlay(MKCircle(center: smartObject.coordinate, radius: smartObject.circleRadius))
		checkUserInCircle(userCoordinate: getCurrentLocation(), smartObject)
	}
	//Проверка внутри ли пользователь при создании объекта, если внутри дата входа == дата создания объекта
	private func checkUserInCircle(userCoordinate: CLLocationCoordinate2D?, _ smartObject: SmartObject) {
		guard let userCoordinate = userCoordinate else { return }
		let userLocation = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
		let circleCenter = CLLocation(latitude: smartObject.coordinate.latitude,
									  longitude: smartObject.coordinate.longitude)
		if userLocation.distance(from: circleCenter) < smartObject.circleRadius {
			entryDate = Date()
		}
	}
}

extension MapPresenter: IMapPresenter
{
	func getEntryDate() -> Date? {
		return entryDate
	}
	func getDate() {
		entryDate = Date()
	}
	// Обновление объектов и кругов на карте при удалении или добавлении
	func updateSmartObjects(_ mapScreen: MapView) {
		let smartObjectsFromDB = getSmartObjects() // получаем данные из базы данных
		let smartObjectsFromMap = getSmartObjectsFromMap(annotations: mapScreen.mapView.annotations)
		let objectsToAdd = smartObjectsFromDB.filter { smartObjectsFromMap.contains($0) == false }
		let objectsToRemove = smartObjectsFromMap.filter { smartObjectsFromDB.contains($0) == false }
		objectsToRemove.forEach { smartObject in
			mapScreen.mapView.removeAnnotation(smartObject)
			stopMonitoring(smartObject)
			removeRadiusOverlay(forPin: smartObject, mapScreen: mapScreen)
			setMonitoringPlacesCount(for: mapScreen, number: getMonitoringRegionsCount())
		}
		objectsToAdd.forEach { smartObject in
			mapScreen.mapView.addAnnotation(smartObject)
			startMonitoring(smartObject)
			addCircle(smartObject, mapScreen: mapScreen)
			setMonitoringPlacesCount(for: mapScreen, number: getMonitoringRegionsCount())
		}
		setMonitoringPlacesCount(for: mapScreen, number: getMonitoringRegionsCount())
	}
	// Установка объектов и кругов на карте из базы при первом запуске
	func setSmartObjectsOnMap(_ mapScreen: MapView) {
		getSmartObjects().forEach { smartObject in
			mapScreen.mapView.addAnnotation(smartObject)
			addCircle(smartObject, mapScreen: mapScreen)
		}
	}
	func showCurrentLocation(_ location: CLLocationCoordinate2D?, mapScreen: MapView) {
		guard let location = location else { return }
		let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
		mapScreen.mapView.setRegion(region, animated: true)
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
