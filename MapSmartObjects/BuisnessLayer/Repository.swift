//
//  Repository.swift
//  MapSmartObjects
//
//  Created by Kirill Fedorov on 18.12.2019.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import Foundation

protocol IRepository
{
}

final class Repository
{
	let geocoder: YandexGeocoder

	init(geocoder: YandexGeocoder) {
		self.geocoder = geocoder
	}
}

extension Repository: IRepository
{
}
