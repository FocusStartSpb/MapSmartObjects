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
	private(set) var coordinate: CLLocationCoordinate2D
	private(set) var circleRadius: Double
	private(set) var address: String
	private(set) var identifier: String

	init(name: String, address: String, coordinate: CLLocationCoordinate2D, circleRadius: Double) {
		self.name = name
		self.address = address
		self.coordinate = coordinate
		self.circleRadius = circleRadius
		self.identifier = UUID().uuidString
	}

	// MARK: Codable
	required init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		let latitude = try values.decode(Double.self, forKey: .latitude)
		let longitude = try values.decode(Double.self, forKey: .longitude)
		coordinate = CLLocationCoordinate2DMake(latitude, longitude)
		circleRadius = try values.decode(Double.self, forKey: .circleRadius)
		name = try values.decode(String.self, forKey: .name)
		address = try values.decode(String.self, forKey: .address)
		identifier = try values.decode(String.self, forKey: .identifier)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(coordinate.latitude, forKey: .latitude)
		try container.encode(coordinate.longitude, forKey: .longitude)
		try container.encode(circleRadius, forKey: .circleRadius)
		try container.encode(name, forKey: .name)
		try container.encode(address, forKey: .address)
		try container.encode(identifier, forKey: .identifier)
	}
	func toCircularRegion() -> CLCircularRegion {
		let region = CLCircularRegion(center: self.coordinate,
									  radius: self.circleRadius,
									  identifier: self.identifier)
		region.notifyOnEntry = true
		region.notifyOnExit = false
		return region
	}
}

extension SmartObject: Codable
{
}

extension SmartObject: MKAnnotation
{
	var title: String? {
		return name
	}

	var subtitle: String? {
		return address
	}
}
