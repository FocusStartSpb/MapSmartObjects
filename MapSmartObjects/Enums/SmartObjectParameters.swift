//
//  CodingKeys.swift
//  MapSmartObjects
//
//  Created by Kirill Fedorov on 28.12.2019.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import Foundation

enum SmartObjectParameters: String, CodingKey
{
	case latitude, longitude, circleRadius, name, address, identifier, visitCount, insideTime
}
