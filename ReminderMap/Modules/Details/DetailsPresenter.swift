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

	private func createSmartObject(old smartObject: SmartObject, name: String, radius: Double, address: String) {
		let newObject = SmartObject(name: name, address: address, coordinate: smartObject.coordinate, circleRadius: radius)
		newObject.insideTime = smartObject.insideTime
		newObject.visitCount = smartObject.visitCount
		let newSmartObjects = repository.getSmartObjects() + [newObject]
		repository.saveSmartObjects(newSmartObjects)
	}
}

extension DetailsPresenter: IDetailsPresenter
{
	func changeSmartObjects(from smartObject: SmartObject, name: String, radius: Double) {
		repository.saveSmartObjects(repository.getSmartObjects().filter { $0.identifier != smartObject.identifier })
		createSmartObject(old: smartObject, name: name, radius: radius, address: smartObject.address)
	}

	func getSmartObject() -> SmartObject {
		return smartObject
	}
}
