//
//  MapPresenter.swift
//  MapSmartObjects
//
//  Created by Максим Шалашников on 17.12.2019.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import Foundation
import CoreLocation

protocol IMapPresenter
{
	func addSmartObject(name: String, radius: Double, coordinate: CLLocationCoordinate2D)
	func getSmartObjects() -> [SmartObject]
}

final class MapPresenter
{
	weak var mapViewController: MapViewController?
	private let repository: IRepository
	private let router: IMapRouter
	private var smartObjects = [SmartObject]()

	init(repository: IRepository, router: IMapRouter) {
		self.repository = repository
		self.router = router
		smartObjects = repository.loadSmartObjects()
	}
}

extension MapPresenter: IMapPresenter
{
	func getSmartObjects() -> [SmartObject] {
		return smartObjects
	}

	func addSmartObject(name: String, radius: Double, coordinate: CLLocationCoordinate2D) {
		repository.geocoder.getGeocoderRequest(coordinates: coordinate) { geocoderResult in
			switch geocoderResult {
			case .success(let response):
				let address = response.response.geoObjectCollection.featureMember
					.first?.geoObject.metaDataProperty?.geocoderMetaData?.text ?? ""
				let smartObject = SmartObject(name: name, address: address, coordinate: coordinate, circleRadius: radius)
				self.smartObjects.append(smartObject)
				self.repository.saveSmartObjects(objects: self.smartObjects)
			case .failure(let error):
				print(error.localizedDescription)
			}
		}
	}
}
