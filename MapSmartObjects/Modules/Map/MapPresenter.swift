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

protocol IMapPresenter
{
	func addSmartObject(name: String, radius: Double, coordinate: CLLocationCoordinate2D)
	func getSmartObjects() -> [SmartObject]
	func updateSmartObjects(on mapView: MKMapView)
	func checkLocationEnabled()
	func showCurrentLocation()
	func addPinWithAlert(_ location: CLLocationCoordinate2D?)
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

	//берем объекты с карты, исключаем userLocation и кастим в SmartObject
	private func getSmartObjectsFromMap(annotations: [MKAnnotation]) -> [SmartObject] {
		var result = [SmartObject]()
		annotations.forEach { annotaion in
			if let smartObject = annotaion as? SmartObject  {
				result.append(smartObject)
			}
		}
		return result
	}
}

extension MapPresenter: IMapPresenter
{
	func getSmartObjects() -> [SmartObject] {
		return repository.getSmartObjects()
	}
	func addSmartObject(name: String,
						radius: Double,
						coordinate: CLLocationCoordinate2D) {
		repository.getGeoposition(coordinates: coordinate) { geocoderResult in
			switch geocoderResult {
			case .success(let position):
				let smartObject = SmartObject(name: name, address: position, coordinate: coordinate, circleRadius: radius)
				self.repository.addSmartObject(object: smartObject)
				DispatchQueue.main.async {
					guard let mapVC = self.mapViewController else { return }
					self.updateSmartObjects(on: mapVC.getMapView())
				}
			case .failure(let error):
				self.mapViewController?.showAlert(withTitle: "Внимание!", message: error.localizedDescription)
			}
		}
	}

	func updateSmartObjects(on mapView: MKMapView) {
		let smartObjectsFromDB = repository.getSmartObjects() // получаем данные из базы данных
		let smartObjectsFromMap = getSmartObjectsFromMap(annotations: mapView.annotations) // получаем данные с карты
		let difference = smartObjectsFromMap.difference(from: smartObjectsFromDB) //находим разницу между 2 массивами
		//вот тут можно отписывать difference от мониторинга (но дальше это надо будет переносить в презентер)
		mapView.removeAnnotations(difference) // убираем разницу с карты
		mapView.overlays.forEach { mapView.removeOverlay($0) } //убираем круги с карты
		repository.getSmartObjects().forEach { smartObject in
			//отрисовка области вокруг пин
			mapView.addOverlay(MKCircle(center: smartObject.coordinate, radius: smartObject.circleRadius))
			DispatchQueue.main.async {
				mapView.addAnnotation(smartObject)
			}
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

	func showCurrentLocation() {
		guard let location = locationManeger.location?.coordinate else { return }
		let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
		guard let mapVC = self.mapViewController else { return }
		mapVC.getMapView().setRegion(region, animated: true)
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
