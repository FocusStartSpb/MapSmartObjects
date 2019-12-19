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
	//необходимо брать данные из репозитория
	var pins = [SmartObject]()

	func saveFile() {
		let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
		let archiveURL = documentDirectory?.appendingPathComponent("data").appendingPathExtension("plist") ??
			documentDirectory.unsafelyUnwrapped
		let pinListEncoder = PropertyListEncoder()
		let encodedPins = try? pinListEncoder.encode(pins)
		try? encodedPins?.write(to: archiveURL, options: .noFileProtection)
	}

	func loadFile() {
		let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
		let archiveURL = documentDirectory?.appendingPathComponent("data").appendingPathExtension("plist") ??
			documentDirectory.unsafelyUnwrapped
		guard let data = try? Data(contentsOf: archiveURL) else { return }
		let pinListDecoder = PropertyListDecoder()
		guard let pins = try? pinListDecoder.decode([SmartObject].self, from: data) else { return }
		self.pins = pins
	}
}
