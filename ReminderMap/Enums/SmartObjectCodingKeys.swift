//
//  CodingKeys.swift
//  MapSmartObjects
//
//  Created by Kirill Fedorov on 28.12.2019.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import Foundation

enum SmartObjectCodingKeys: String, CodingKey
{
	case latitude
	case longitude
	case circleRadius
	case name
	case address
	case identifier
	case visitCount
	case insideTime
	case entryDate
}
