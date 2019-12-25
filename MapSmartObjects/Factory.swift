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
	private let geocoder = YandexGeocoder()
	private let dataService = DataService()
	private var repository: Repository

	init() {
		repository = Repository(geocoder: geocoder, dataService: dataService)
		print(Unmanaged.passUnretained(repository).toOpaque())
	}
	//create map module
	func createMapModule() -> MapViewController {
		let mapRouter = MapRouter(factory: self)
		let mapPresenter = MapPresenter(repository: repository, router: mapRouter)
		let mapVC = MapViewController(presenter: mapPresenter)
		mapPresenter.mapViewController = mapVC
		mapRouter.mapViewController = mapVC
		return mapVC
	}

	//create pinlist module
	func createPinListModule() -> PinListViewController {
		let pinListRouter = PinListRouter(factory: self)
		let pinListPresenter = PinListPresenter(repository: repository, router: pinListRouter)
		let pinListVC = PinListViewController(presenter: pinListPresenter)
		pinListPresenter.pinListViewController = pinListVC
		pinListRouter.pinListViewController = pinListVC
		return pinListVC
	}
}
