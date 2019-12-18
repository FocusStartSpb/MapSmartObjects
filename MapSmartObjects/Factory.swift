//
//  Factory.swift
//  MapSmartObjects
//
//  Created by Kirill Fedorov on 16.12.2019.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import Foundation

final class Factory
{
	//create map module
	func createMapModule() -> MapViewController {
		let repository = Repository()
		let mapRouter = MapRouter(factory: self)
		let geoCoder = YandexGeocoder()
		let mapPresenter = MapPresenter(repository: repository, router: mapRouter, geoCoder: geoCoder)
		let mapVC = MapViewController(presenter: mapPresenter)
		mapPresenter.mapViewController = mapVC
		mapRouter.mapView = mapVC
		return mapVC
	}
}
