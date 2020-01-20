//
//  DataService.swift
//  MapSmartObjects
//
//  Created by Igor Shelginskiy on 12/19/19.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import Foundation

protocol IDataService
{
	func saveData(_ data: Data)
	func loadData() -> Data?
}

final class DataService
{
	private let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
	private var archiveURL: URL {
		return documentDirectory?.appendingPathComponent("data").appendingPathExtension("plist") ??
		documentDirectory.unsafelyUnwrapped
	}
}

extension DataService: IDataService
{
	func saveData(_ data: Data) {
		try? data.write(to: archiveURL, options: .noFileProtection)
	}

	func loadData() -> Data? {
		return try? Data(contentsOf: archiveURL)
	}
}
