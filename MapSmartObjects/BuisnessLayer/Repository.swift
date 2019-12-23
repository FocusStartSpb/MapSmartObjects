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
	func loadSmartObjects() -> [SmartObject]
	func saveSmartObjects(objects: [SmartObject])
	func getGeoposition(coordinates: CLLocationCoordinate2D, completionHandler: @escaping (GeocoderResponseResult) -> Void)
}

final class Repository
{
	private let geocoder: IYandexGeocoder
	private let dataService: IDataService

	init(geocoder: YandexGeocoder, dataService: DataService) {
		self.geocoder = geocoder
		self.dataService = dataService
	}
}

extension Repository: IRepository
{
	func loadSmartObjects() -> [SmartObject] {
		guard let data = dataService.loadData(),
			let smartObjects = try? PropertyListDecoder().decode([SmartObject].self, from: data)
			else { return [] }
		return smartObjects
	}

	func saveSmartObjects(objects: [SmartObject]) {
		guard let data = try? PropertyListEncoder().encode(objects) else { return }
		dataService.saveData(data)
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
				print(message.localizedDescription)// Сюда - алерт
			}
		}
	}
}
