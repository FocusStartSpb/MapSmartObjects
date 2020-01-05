//
//  Repository.swift
//  MapSmartObjects
//
//  Created by Kirill Fedorov on 18.12.2019.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

typealias GeocoderResponseResult = Result<String, Error>
protocol IRepository
{
	var smartObjectsCount: Int { get }

	func getSmartObjects() -> [SmartObject]
	func removeSmartObject(at index: Int)
	func addSmartObject(object: SmartObject)
	func getSmartObject(at index: Int) -> SmartObject
	func getSmartObject(with identifier: String) -> SmartObject?
	func getGeoposition(coordinates: CLLocationCoordinate2D,
						completionHandler: @escaping (GeocoderResponseResult) -> Void)
}

final class Repository
{
	private let geocoder: IYandexGeocoder
	private let dataService: IDataService
	private var smartObjects = [SmartObject]() {
		didSet {
			saveSmartObjects(objects: smartObjects)
		}
	}

	init(geocoder: YandexGeocoder, dataService: DataService) {
		self.geocoder = geocoder
		self.dataService = dataService
		smartObjects = loadSmartObjects()
	}

	func loadSmartObjects() -> [SmartObject] {
		guard let data = dataService.loadData(),
			let smartObjects = try? PropertyListDecoder().decode([SmartObject].self, from: data)
			else { return [] }
		return smartObjects
	}
}

extension Repository: IRepository
{
	var smartObjectsCount: Int {
		return smartObjects.count
	}

	func getSmartObject(with identifier: String) -> SmartObject? {
		if let index = smartObjects.firstIndex(where: { $0.identifier == identifier }) {
			return smartObjects[index]
		}
		return nil
	}

	func addSmartObject(object: SmartObject) {
		smartObjects.append(object)
	}
	func removeSmartObject(at index: Int) {
		guard index < smartObjects.count else { return }
		smartObjects.remove(at: index)
	}
	func saveSmartObjects(objects: [SmartObject]) {
		guard let data = try? PropertyListEncoder().encode(objects) else { return }
		dataService.saveData(data)
	}
	func getSmartObjects() -> [SmartObject] {
		return smartObjects
	}
	func getSmartObject(at index: Int) -> SmartObject {
		return smartObjects[index]
	}
	func getGeoposition(coordinates: CLLocationCoordinate2D,
						completionHandler: @escaping (GeocoderResponseResult) -> Void) {
		geocoder.getGeocoderRequest(coordinates: coordinates) { result in
			switch result {
			case .success(let data):
				do {
					let geocoderResponseResult = try JSONDecoder().decode(GeocoderResponse.self, from: data)
					let geocoderResult = geocoderResponseResult.response.geoObjectCollection.featureMember
					.first?.geoObject.metaDataProperty?.geocoderMetaData?.text ?? ""
					completionHandler(.success(geocoderResult))
				}
				catch {
					completionHandler(.failure(error))
				}
			case .failure(let message):
				completionHandler(.failure(message))
			}
		}
	}
}
