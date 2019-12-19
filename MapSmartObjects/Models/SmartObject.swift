//
//  SmartObject.swift
//  MapSmartObjects
//
//  Created by Kirill Fedorov on 19.12.2019.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import Foundation

final class SmartObject: Codable
{
	var name: String
	var address: String
	var latitude: Double
	var longitude: Double
	var circleRadius: Double

	init(name: String, address: String, latitude: Double, longitude: Double, circleRadius: Double) {
		self.name = name
		self.address = address
		self.latitude = latitude
		self.longitude = longitude
		self.circleRadius = circleRadius
	}
}
