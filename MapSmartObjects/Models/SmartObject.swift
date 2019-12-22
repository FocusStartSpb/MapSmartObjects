//
//  SmartObject.swift
//  MapSmartObjects
//
//  Created by Kirill Fedorov on 19.12.2019.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import Foundation
import MapKit

final class SmartObject: NSObject
{
	var name: String
	var address: String
	var latitude: Double
	var longitude: Double
	var circleRadius: Double

	init(name: String, address: String, coordinate: CLLocationCoordinate2D, circleRadius: Double) {
		self.name = name
		self.address = address
		self.latitude = coordinate.latitude
		self.longitude = coordinate.longitude
		self.circleRadius = circleRadius
	}
}

extension SmartObject: Codable
{
}

extension SmartObject: MKAnnotation
{
	var coordinate: CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
	}
}
