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
	func updateSmartObject(_ smartObject: SmartObject)
}

final class Repository
{
	private let dataService: IDataService

	init(dataService: DataService) {
		self.dataService = dataService
	}
}

extension Repository: IRepository
{
	func saveSmartObjects(_ smartObjects: [SmartObject]) {
		guard let data = try? PropertyListEncoder().encode(smartObjects) else { return }
		dataService.saveData(data)
	}

	func getSmartObjects() -> [SmartObject] {
		guard let data = dataService.loadData(),
			let smartObjects = try? PropertyListDecoder().decode([SmartObject].self, from: data) else { return [] }
		return smartObjects
	}

	func updateSmartObject(_ smartObject: SmartObject) {
		let filtredObjects = getSmartObjects().filter { $0.identifier != smartObject.identifier }
		let updatesSmartObjects = filtredObjects + [smartObject]
		saveSmartObjects(updatesSmartObjects)
	}
}
