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
	func changeSmartObjects(from smartObject: SmartObject, name: String, radius: Double)
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
}

extension DetailsPresenter: IDetailsPresenter
{
	func changeSmartObjects(from smartObject: SmartObject, name: String, radius: Double) {
		repository.removeSmartObject(with: smartObject.identifier)
		createSmartObject(old: smartObject, name: name, radius: radius, address: smartObject.address)
	}

	func createSmartObject(old smartObject: SmartObject, name: String, radius: Double, address: String) {
		let smartObject = SmartObject(name: name, address: address, coordinate: smartObject.coordinate, circleRadius: radius)
		repository.addSmartObject(object: smartObject)
	}

	func getSmartObject() -> SmartObject {
		return smartObject
	}
}
