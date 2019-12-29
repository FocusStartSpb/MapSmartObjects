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
	func addSmartObject(name: String,
						radius: Double,
						coordinate: CLLocationCoordinate2D)
	func getSmartObjects() -> [SmartObject]
	func updateSmartObjects(on mapView: MKMapView)
}

final class MapPresenter
{
	weak var mapViewController: MapViewController?
	private let repository: IRepository
	private let router: IMapRouter

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
					self.mapViewController?.showSmartObjectsOnMap()
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
}
