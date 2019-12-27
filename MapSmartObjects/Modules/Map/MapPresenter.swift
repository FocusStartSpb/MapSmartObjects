//
//  MapPresenter.swift
//  MapSmartObjects
//
//  Created by Максим Шалашников on 17.12.2019.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import Foundation
import CoreLocation

protocol IMapPresenter
{
	func addSmartObject(name: String,
						radius: Double,
						coordinate: CLLocationCoordinate2D)
	func getSmartObjects() -> [SmartObject]
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
					self.startMonitoring(with: smartObject)
				}
			case .failure(let error):
				print(error.localizedDescription)
			}
		}
	}
	// метод для начала мониторинга зоны когда пользователь добавляет ее(надо добавить когда пин добавляется)
	private func startMonitoring(with smartObject: SmartObject) {
		let smartregion = region(with: smartObject)
		mapViewController?.locationManeger.startMonitoring(for: smartregion)
	}
	// Инициализация геозоны как CLCyrcularRadius
	private func region(with smartObject: SmartObject) -> CLCircularRegion {
		let region = CLCircularRegion(center: smartObject.coordinate,
									  radius: smartObject.circleRadius,
									  identifier: smartObject.name)
		region.notifyOnEntry = true
		region.notifyOnExit = false
		return region
	}
}
