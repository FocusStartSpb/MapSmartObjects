//
//  MapRouter.swift
//  MapSmartObjects
//
//  Created by Максим Шалашников on 17.12.2019.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import Foundation

protocol IMapRouter
{
	func showDetails(smartObject: SmartObject, type: DetailVCTypes)
}

final class MapRouter
{
	weak var mapViewController: MapViewController?
	private let factory: Factory

	init(factory: Factory) {
		self.factory = factory
	}
}

extension MapRouter: IMapRouter
{
	func showDetails(smartObject: SmartObject, type: DetailVCTypes) {
		let detailVC = factory.createDetailsModule(with: smartObject, type: type)
		mapViewController?.navigationController?.pushViewController(detailVC, animated: true)
	}
}
