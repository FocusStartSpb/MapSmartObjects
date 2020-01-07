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
	func updateSmartObject(with identifier: String, coordinate: CLLocationCoordinate2D, name: String, radius: Double)
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
	func updateSmartObject(with identifier: String, coordinate: CLLocationCoordinate2D, name: String, radius: Double) {
		repository.updateSmartObject(with: identifier, coordinate: coordinate, name: name, radius: radius)
	}

	func getSmartObject() -> SmartObject {
		return smartObject
	}
}
