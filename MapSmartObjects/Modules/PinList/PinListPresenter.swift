//
//  PinListPresenter.swift
//  MapSmartObjects
//
//  Created by Максим Шалашников on 17.12.2019.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import Foundation
import CoreLocation

protocol IPinListPresenter
{
	func getSmartObjectsCount() -> Int
	func getSmartObject(at index: Int) -> SmartObject
	func removeSmartObject(at index: Int)
	func getSmartObjects() -> [SmartObject]
}

final class PinListPresenter
{
	weak var pinListViewController: PinListViewController?
	weak var mapViewController: MapViewController?
	private let repository: IRepository
	private let router: IPinListRouter

	init(repository: IRepository, router: IPinListRouter) {
		self.repository = repository
		self.router = router
	}
	// метод для остановки мониторинга зоны когда пользователь его удаляет(надо добавить когда удаляется пин)
	private func stopMonitoring(smartObject: SmartObject) {
		guard let regions = mapViewController?.locationManeger.monitoredRegions else { return }
		for region in regions {
			guard let circusRegion = region as? CLCircularRegion, circusRegion.identifier == smartObject.name else { continue }
			mapViewController?.locationManeger.stopMonitoring(for: circusRegion)
		}
	}
}

extension PinListPresenter: IPinListPresenter
{
	func getSmartObjectsCount() -> Int {
		return repository.smartObjectsCount
	}

	func getSmartObject(at index: Int) -> SmartObject {
		return repository.getSmartObjects()[index]
	}

	func getSmartObjects() -> [SmartObject] {
		return repository.getSmartObjects()
	}

	func removeSmartObject(at index: Int) {
		stopMonitoring(smartObject: repository.getSmartObjects()[index])
		repository.removeSmartObject(at: index)
	}
}
