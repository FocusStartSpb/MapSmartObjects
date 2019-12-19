//
//  Repository.swift
//  MapSmartObjects
//
//  Created by Kirill Fedorov on 18.12.2019.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import Foundation

protocol IRepository
{
}

final class Repository
{
	let geoСoder: YandexGeocoder
	let dataService: DataService

	init(geocoder: YandexGeocoder, dataService: DataService) {
		self.geoСoder = geocoder
		self.dataService = dataService
	}
}

extension Repository: IRepository
{
}
