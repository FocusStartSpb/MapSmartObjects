//
//  Mapswift
//  MapSmartObjects
//
//  Created by Максим Шалашников on 17.12.2019.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import MapKit
import UserNotifications

protocol IMapPresenter
{
	func checkLocationEnabled()
	func getCurrentLocation() -> CLLocationCoordinate2D?
	func addNewPin(on location: CLLocationCoordinate2D?)
	func handleEvent(for region: CLRegion)
	func showPinDetails(with smartObject: SmartObject)
	func getSmartObject(from: CLRegion) -> SmartObject?
	func getSmartObjects() -> [SmartObject]
	func updateSmartObjects(on mapView: MKMapView)
	func updateSmartObject(_ smartObject: SmartObject)
	func getMonitoringRegionsCount() -> Int
	func checkUserInCircle(_ smartObject: SmartObject) -> Date?
}

final class MapPresenter: NSObject
{
	weak var mapViewController: MapViewController?
	private let repository: IRepository
	private let router: IMapRouter
	private let locationManager = CLLocationManager()
	private var smartObjects: [SmartObject] {
		get {
			repository.getSmartObjects()
		}
		set {
			repository.saveSmartObjects(newValue)
		}
	}

	init(repository: IRepository, router: IMapRouter) {
		self.repository = repository
		self.router = router
	}

	private func addSmartObject(name: String,
								radius: Double,
								coordinate: CLLocationCoordinate2D) {
		mapViewController?.showActivityIndicator()
		YandexGeocoder.getGeoposition(coordinates: coordinate) { [weak self] geocoderResult in
			guard let self = self else { return }
			switch geocoderResult {
			case .success(let position):
				let maxRadius = radius > self.locationManager.maximumRegionMonitoringDistance
					? self.locationManager.maximumRegionMonitoringDistance
					: radius
				let smartObject = SmartObject(name: name, address: position, coordinate: coordinate, circleRadius: maxRadius)
				DispatchQueue.main.async {
					self.mapViewController?.hideActivityIndicator()
					self.router.showDetails(smartObject: smartObject, type: .create)
				}
			case .failure(let error):
				DispatchQueue.main.async {
					self.mapViewController?.hideActivityIndicator()
					self.router.showAlert(withTitle: Constants.warningTitle, message: error.localizedDescription)
				}
			}
		}
	}

	private func ckeckAutorization() {
		switch CLLocationManager.authorizationStatus() {
		case .authorizedWhenInUse, .authorizedAlways, .notDetermined:
			locationManager.requestAlwaysAuthorization()
			mapViewController?.showCurrentLocation(getCurrentLocation())
		case .denied, .restricted:
			self.router.showAlertRequestLocation(title: Constants.bunnedTitle,
									 message: Constants.allowMessage,
									 url: URL(string: UIApplication.openSettingsURLString))
		default:
			break
		}
	}

	private func setupLocationManager() {
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.startUpdatingLocation()
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
	func getSmartObject(from: CLRegion) -> SmartObject? {
		return smartObjects.first(where: { $0.identifier == from.identifier })
	}

	func getMonitoringRegionsCount() -> Int {
		return locationManager.monitoredRegions.count
	}

	func updateSmartObject(_ smartObject: SmartObject) {
		let filtredObjects = smartObjects.filter { $0.identifier != smartObject.identifier }
		let updatesSmartObjects = filtredObjects + [smartObject]
		repository.saveSmartObjects(updatesSmartObjects)
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
		let currentColor = (locationManager.monitoredRegions.count == 20) ? Colors.pinsLimit : Colors.mainStyle
		mapViewController?.setMonitoringCountLable(color: currentColor)
	}

	func showPinDetails(with smartObject: SmartObject) {
		router.showDetails(smartObject: smartObject, type: .edit)
	}

	private func showNotification(with notificationContent: UNMutableNotificationContent) {
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

	func handleEvent(for region: CLRegion) {
		let smartObject = repository.getSmartObjects().first { $0.identifier == region.identifier }
		guard let currentObject = smartObject else { return }
		let message = Constants.enterMessage + "\(currentObject.name)"
		// показать алерт, если приложение активно
		if UIApplication.shared.applicationState == .active {
			let notificationContent = UNMutableNotificationContent()
			notificationContent.body = message
			showNotification(with: notificationContent)
		}
		else {
			// отправить нотификацию, если приложение не активно
			let notificationContent = UNMutableNotificationContent()
			notificationContent.body = message
			notificationContent.sound = UNNotificationSound.default
			notificationContent.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber
			showNotification(with: notificationContent)
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
	func checkLocationEnabled() {
		if CLLocationManager.locationServicesEnabled() {
			ckeckAutorization()
			setupLocationManager()
		}
		else {
			self.router.showAlertRequestLocation(title: Constants.turnOffServiceTitle,
									 message: Constants.turnOnMessage,
									 url: URL(string: Constants.locationServicesString))
		}
	}

	func addNewPin(on location: CLLocationCoordinate2D?) {
		guard locationManager.monitoredRegions.count != 20 else {
			router.showAlert(withTitle: Constants.warningTitle, message: Constants.maxPinsMessage)
			return
		}
		if let currentUserLocation = location {
			addSmartObject(name: "", radius: 0, coordinate: currentUserLocation)
		}
		else {
			guard let currentUserLocation = getCurrentLocation() else { return }
			addSmartObject(name: "", radius: 0, coordinate: currentUserLocation)
		}
	}
}

extension MapPresenter: CLLocationManagerDelegate
{
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		checkLocationEnabled()
	}

	func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
		guard let currentSmartObject = getSmartObject(from: region) else { return }
		currentSmartObject.entryDate = Date()
		handleEvent(for: region)
		updateSmartObject(currentSmartObject)
	}

	func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
		guard let currentSmartObject = getSmartObject(from: region) else { return }
		guard let entryDate = currentSmartObject.entryDate else { return }
		let insideTime = Date().timeIntervalSince(entryDate)
		currentSmartObject.insideTime += insideTime
		currentSmartObject.visitCount += 1
		currentSmartObject.entryDate = nil
		updateSmartObject(currentSmartObject)
	}
}

extension MapViewController: UNUserNotificationCenterDelegate
{
	func userNotificationCenter(_ center: UNUserNotificationCenter,
								willPresent notification: UNNotification,
								withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		completionHandler([.alert])
	}
}
