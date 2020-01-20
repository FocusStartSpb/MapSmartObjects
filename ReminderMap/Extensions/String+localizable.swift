//
//  String+localizable.swift
//  ReminderMap
//
//  Created by Максим Шалашников on 20.01.2020.
//  Copyright © 2020 Максим Шалашников. All rights reserved.
//

import Foundation
extension String
{
	var localized: String {
		return NSLocalizedString(self, comment: "")
	}
}
