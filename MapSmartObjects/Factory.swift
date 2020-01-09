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
	private let repository: Repository

	init() {
		repository = Repository(geocoder: geocoder, dataService: dataService)
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

	//create pinlist module
	func createDetailsModule(with smartObject: SmartObject, type: DetailVCTypes) -> DetailsViewController {
		let presenter = DetailsPresenter(repository: repository, smartObject: smartObject)
		let detailsVC = DetailsViewController(presenter: presenter, type: type)
		presenter.viewController = detailsVC
		return detailsVC
	}
}
