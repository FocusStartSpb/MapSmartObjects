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
	private(set) var name: String
	private(set) var latitude: Double
	private(set) var longitude: Double
	private(set) var circleRadius: Double
	var address: String

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

	var title: String? {
		return name
	}

	var subtitle: String? {
		return address
	}
}
