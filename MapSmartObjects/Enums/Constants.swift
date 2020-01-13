//
//  Constants.swift
//  MapSmartObjects
//
//  Created by Kirill Fedorov on 18.12.2019.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import Foundation

enum Constants
{
	static let apiKey = "0bd25207-2244-4998-a106-6125d7b85900"
	static let baseUrl = "https://geocode-maps.yandex.ru/1.x"
	static let locationServicesString = "App-Prefs:root=LOCATION_SERVICES"
	static let fatalError = "init(coder:) has not been implemented"
	static let locationImageName = "location"
	static let addButtonImagename = "add"
	static let imageViewPin = "regionPin"
	static let annotationID = "Annotation"
	static let gothicFont = "AppleSDGothicNeo-Light"
	static let helveticaFont = "HelveticaNeue"
	static let enterMessage = "Вы вошли в зону: "
	static let attention = "Внимание!"
	static let changeLocationID = "location_change"
	static let errorText = "Ошибка: "
	static let okTitle = "OK"
	static let settingsTitle = "Settings"
	static let cancelTitle = "Cancel"
	static let warningTitle = "Warning!"
	static let turnOffServiceTitle = "Your geolocation service is turned off"
	static let turnOnMessage = "Want to turn it on?"
	static let bunnedTitle = "You have banned the use of location"
	static let allowMessage = "Want to allow?"
	static let cellID = "pin"
	static let emptyImageName = "emptyIcon"
	static let searchImageName = "searchIcon"
	static let searchFieldKey = "searchField"
	static let searchPlaceholderName = "Enter pin name"
	static let objectPlaceholderName = "Enter place name"
	static let radiusPlaceholderName = "Enter monitoring radius"
	static let pinsTitle = "My Pins"
	static let editTitle = "Edit"
	static let doneTitle = "Done"
	static let createTitle = "Create"
	static let emptyListText = "The list is empty now. Add new pin on the map!"
	static let nothingOnQueryText = "Nothing found on query: "
	static let timeImageName = "time"
	static let timerImageName = "timer"
	static let counterImageName = "counter"
	static let nameLabelText = "Name"
	static let radiusLabelText = "Radius (meters)"
	static let adressLabelText = "Address"
	static let timeFormat = "%0.2d:%0.2d:%0.2d"
}
