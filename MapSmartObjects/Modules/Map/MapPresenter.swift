//
//  MapPresenter.swift
//  MapSmartObjects
//
//  Created by Максим Шалашников on 17.12.2019.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import Foundation

protocol IMapPresenter
{
}

final class MapPresenter
{
	weak var mapViewController: MapViewController?
	private let repository: IRepository
	private let router: IMapRouter
	private let geoCoder: YandexGeocoder

	init(repository: IRepository, router: IMapRouter, geoCoder: YandexGeocoder) {
		self.repository = repository
		self.router = router
		self.geoCoder = geoCoder
	}
}

extension MapPresenter: IMapPresenter
{
}
