//
//  Repository.swift
//  MapSmartObjects
//
//  Created by Kirill Fedorov on 18.12.2019.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import MapKit

protocol IRepository
{
	func getSmartObjects() -> [SmartObject]
	func saveSmartObjects(_ smartObjects: [SmartObject])
}

final class Repository
{
	private let dataService: IDataService
	private(set) var smartObjects = [SmartObject]()

	init(dataService: DataService) {
		self.dataService = dataService
	}
}

extension Repository: IRepository
{
	func saveSmartObjects(_ smartObjects: [SmartObject]) {
		self.smartObjects = smartObjects
	}

	func getSmartObjects() -> [SmartObject] {
		return self.smartObjects
	}

	func saveSmartObjectsToDB() {
		guard let data = try? PropertyListEncoder().encode(smartObjects) else { return }
		dataService.saveData(data)
	}

	func loadSmartObjectsFromDB() {
		guard let data = dataService.loadData(),
			let smartObjects = try? PropertyListDecoder().decode([SmartObject].self, from: data) else { return }
		self.smartObjects = smartObjects
	}
}
