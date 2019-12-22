//
//  DataService.swift
//  MapSmartObjects
//
//  Created by Igor Shelginskiy on 12/19/19.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import Foundation

final class DataService
{
	func saveSmartObjects(_ objects: [SmartObject]) {
		let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
		let archiveURL = documentDirectory?.appendingPathComponent("data").appendingPathExtension("plist") ??
			documentDirectory.unsafelyUnwrapped
		let pinListEncoder = PropertyListEncoder()
		let encodedPins = try? pinListEncoder.encode(objects)
		try? encodedPins?.write(to: archiveURL, options: .noFileProtection)
	}

	func loadSmartObjects() -> [SmartObject] {
		let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
		let archiveURL = documentDirectory?.appendingPathComponent("data").appendingPathExtension("plist") ??
			documentDirectory.unsafelyUnwrapped
		guard let data = try? Data(contentsOf: archiveURL) else { return [] }
		let pinListDecoder = PropertyListDecoder()
		guard let smartObjects = try? pinListDecoder.decode([SmartObject].self, from: data) else { return [] }
		return smartObjects
	}
}
