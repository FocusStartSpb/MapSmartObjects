//
//  Repository.swift
//  MapSmartObjects
//
//  Created by Kirill Fedorov on 18.12.2019.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import Foundation
import MapKit

typealias GeocoderResponseResult = Result<String, Error>
protocol IRepository
{
	var smartObjectsCount: Int { get }

	func getSmartObjects() -> [SmartObject]
	func removeSmartObject(at index: Int)
	func removeSmartObject(with identifier: String)
	func addSmartObject(object: SmartObject)
	func getSmartObject(at index: Int) -> SmartObject
	func getSmartObject(with identifier: String) -> SmartObject?
	func saveSmartObjects()
	func updateSmartObject(with identifier: String,
						   coordinate: CLLocationCoordinate2D,
						   name: String,
						   radius: Double)
	func getGeoposition(coordinates: CLLocationCoordinate2D,
						completionHandler: @escaping (GeocoderResponseResult) -> Void)
}

final class Repository
{
	private let geocoder: IYandexGeocoder
	private let dataService: IDataService
	private var smartObjects = [SmartObject]() {
		didSet {
			saveSmartObjects()
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

	func updateSmartObject(with identifier: String,
						   coordinate: CLLocationCoordinate2D,
						   name: String,
						   radius: Double) {
		guard let smartObject = smartObjects.first(where: { $0.identifier == identifier }) else { return }
		smartObject.name = name
		smartObject.coordinate = coordinate
		smartObject.circleRadius = radius
		getGeoposition(coordinates: coordinate) { geocoderResult in
			switch geocoderResult {
			case .success(let position):
				DispatchQueue.main.async {
					smartObject.address = position
					self.saveSmartObjects()
					print("CHANGES SAVED")
				}
			case .failure(let error):
				print(error.localizedDescription)
			}
		}
	}

	func removeSmartObject(with identifier: String) {
		smartObjects = smartObjects.filter { $0.identifier != identifier }
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
	func saveSmartObjects() {
		guard let data = try? PropertyListEncoder().encode(smartObjects) else { return }
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
