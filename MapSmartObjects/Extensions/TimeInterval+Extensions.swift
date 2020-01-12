//
//  TimeInterval+Extensions.swift
//  MapSmartObjects
//
//  Created by Kirill Fedorov on 11.01.2020.
//  Copyright © 2020 Максим Шалашников. All rights reserved.
//

import Foundation

extension TimeInterval
{
	func toString() -> String {
		let time = Int(self)
		let seconds = time % 60
		let minutes = (time / 60) % 60
		let hours = (time / 3600)
		return String(format: "%0.2d:%0.2d:%0.2d", hours, minutes, seconds)
	}
}
