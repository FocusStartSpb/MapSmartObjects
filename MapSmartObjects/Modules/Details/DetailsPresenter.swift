//
//  DetailsPresenter.swift
//  MapSmartObjects
//
//  Created by Kirill Fedorov on 07.01.2020.
//  Copyright © 2020 Максим Шалашников. All rights reserved.
//

import MapKit

protocol IDetailsPresenter
{
	func getSmartObject() -> SmartObject
	func changeSmartObjects(from old: SmartObject, coordinate: CLLocationCoordinate2D, name: String, radius: Double)
}

final class DetailsPresenter
{
	weak var viewController: DetailsViewController?
	private let repository: IRepository
	private let smartObject: SmartObject

	init(repository: IRepository, smartObject: SmartObject) {
		self.smartObject = smartObject
		self.repository = repository
	}
	deinit {
		print("Presenter deinited")
	}
}

extension DetailsPresenter: IDetailsPresenter
{
//	func changeSmartObjects(from old: SmartObject, coordinate: CLLocationCoordinate2D, name: String, radius: Double) {
//		repository.changeSmartObjects(from: old, coordinate: coordinate, name: name, radius: radius)
//		if let vc = viewController?.navigationController?.viewControllers[0] as? PinListViewController {
//			vc.updateTableView()
//		}
//	}
	func changeSmartObjects(from old: SmartObject, coordinate: CLLocationCoordinate2D, name: String, radius: Double) {
		repository.removeSmartObject(with: old.identifier)
		createSmartObject(coordinate: coordinate, name: name, radius: radius)
	}

	func createSmartObject(coordinate: CLLocationCoordinate2D, name: String, radius: Double) {
		repository.getGeoposition(coordinates: coordinate) { geocoderResult in
			switch geocoderResult {
			case .success(let position):
				DispatchQueue.main.async {
					let smartObject = SmartObject(name: name, address: position, coordinate: coordinate, circleRadius: radius)
					self.repository.addSmartObject(object: smartObject)
					self.repository.updatePinList()
					print("CHANGES SAVED")
				}
			case .failure(let error):
				print(error.localizedDescription)
			}
		}
	}

	func getSmartObject() -> SmartObject {
		return smartObject
	}
}
