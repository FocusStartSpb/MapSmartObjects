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
	var pins = [GeocoderResponse]()

	func saveFile() {
		let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
		let archURL = documentDir?.appendingPathComponent("data").appendingPathExtension("plist") ??
			documentDir.unsafelyUnwrapped
		let propListEnc = PropertyListEncoder()
		let encodedCars = try? propListEnc.encode(pins)
		try? encodedCars?.write(to: archURL, options: .noFileProtection)
	}

	func loadFile() {
		let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
		let archURL = documentDir?.appendingPathComponent("data").appendingPathExtension("plist") ??
			documentDir.unsafelyUnwrapped
		guard let data = try? Data(contentsOf: archURL) else { return }
		let propListDec = PropertyListDecoder()
		guard let pins = try? propListDec.decode([GeocoderResponse].self, from: data) else { return }
		self.pins = pins
	}
}
