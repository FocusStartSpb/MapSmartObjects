//
//  Array+Extensions.swift
//  MapSmartObjects
//
//  Created by Kirill Fedorov on 28.12.2019.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import Foundation

extension Array where Element: Hashable
{
	func difference(from other: [Element]) -> [Element] {
		let thisSet = Set(self)
		let otherSet = Set(other)
		return Array(thisSet.symmetricDifference(otherSet))
	}
}
