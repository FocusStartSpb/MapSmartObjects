//
//  Repository.swift
//  MapSmartObjects
//
//  Created by Kirill Fedorov on 18.12.2019.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import Foundation
import CoreLocation

protocol IRepository
{
	func loadSmartObjects() -> [SmartObject]
	func saveSmartObjects(objects: [SmartObject])

	var geocored: YandexGeocoder { get }
}

final class Repository
{
	let geocoder: YandexGeocoder
	let dataService: DataService

	init(geocoder: YandexGeocoder, dataService: DataService) {
		self.geocoder = geocoder
		self.dataService = dataService
	}
}

extension Repository: IRepository
{
	var geocored: YandexGeocoder {
		return geocoder
	}

	func loadSmartObjects() -> [SmartObject] {
		return dataService.loadSmartObjects()
	}

	func saveSmartObjects(objects: [SmartObject]) {
		dataService.saveSmartObjects(objects)
	}
}
