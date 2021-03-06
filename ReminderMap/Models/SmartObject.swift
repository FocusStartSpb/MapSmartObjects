//
//  SmartObject.swift
//  MapSmartObjects
//
//  Created by Kirill Fedorov on 19.12.2019.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import MapKit

final class SmartObject: NSObject
{
	private var timer: Timer?
	private(set) var name: String
	private(set) var coordinate: CLLocationCoordinate2D
	private(set) var circleRadius: Double
	private(set) var address: String
	private(set) var identifier: String
	var entryDate: Date?
	var visitCount: Int
	var insideTime: TimeInterval

	init(name: String, address: String, coordinate: CLLocationCoordinate2D, circleRadius: Double) {
		self.name = name
		self.address = address
		self.coordinate = coordinate
		self.circleRadius = circleRadius
		self.identifier = UUID().uuidString
		self.visitCount = 0
		self.insideTime = 0
	}

	// MARK: Codable
	required init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: SmartObjectCodingKeys.self)
		let latitude = try values.decode(Double.self, forKey: .latitude)
		let longitude = try values.decode(Double.self, forKey: .longitude)
		coordinate = CLLocationCoordinate2DMake(latitude, longitude)
		circleRadius = try values.decode(Double.self, forKey: .circleRadius)
		name = try values.decode(String.self, forKey: .name)
		address = try values.decode(String.self, forKey: .address)
		identifier = try values.decode(String.self, forKey: .identifier)
		visitCount = try values.decode(Int.self, forKey: .visitCount)
		insideTime = try values.decode(TimeInterval.self, forKey: .insideTime)
		entryDate = try values.decode(Date?.self, forKey: .entryDate)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: SmartObjectCodingKeys.self)
		try container.encode(coordinate.latitude, forKey: .latitude)
		try container.encode(coordinate.longitude, forKey: .longitude)
		try container.encode(circleRadius, forKey: .circleRadius)
		try container.encode(name, forKey: .name)
		try container.encode(address, forKey: .address)
		try container.encode(identifier, forKey: .identifier)
		try container.encode(visitCount, forKey: .visitCount)
		try container.encode(insideTime, forKey: .insideTime)
		try container.encode(entryDate, forKey: .entryDate)
	}

	func toCircularRegion() -> CLCircularRegion {
		let region = CLCircularRegion(center: self.coordinate, radius: self.circleRadius, identifier: self.identifier)
		region.notifyOnEntry = true
		region.notifyOnExit = true
		return region
	}

	// сравниваем объекты по identifier
	override func isEqual(_ object: Any?) -> Bool {
		if let object = object as? SmartObject {
			return identifier == object.identifier
		}
		else {
			return false
		}
	}
}

extension SmartObject: MKAnnotation, Codable
{
	var title: String? {
		return name
	}

	var subtitle: String? {
		return address
	}
}
