//
//  SmartObject.swift
//  MapSmartObjects
//
//  Created by Kirill Fedorov on 19.12.2019.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import Foundation
import MapKit

final class SmartObject
{
	var name: String
	var address: String
	var coordinate: CLLocationCoordinate2D
	var circleRadius: Double

	init(name: String, address: String, coordinate: CLLocationCoordinate2D, circleRadius: Double) {
		self.name = name
		self.address = address
		self.coordinate = coordinate
		self.circleRadius = circleRadius
	}
}
