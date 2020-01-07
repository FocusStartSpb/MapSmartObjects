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
	func changeSmartObjects(from old: SmartObject, coordinate: CLLocationCoordinate2D, name: String, radius: Double) {
		repository.changeSmartObjects(from: old, coordinate: coordinate, name: name, radius: radius)
	}

	func getSmartObject() -> SmartObject {
		return smartObject
	}
}
