//
//  PinListPresenter.swift
//  MapSmartObjects
//
//  Created by Максим Шалашников on 17.12.2019.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import Foundation

protocol IPinListPresenter
{
	func getSmartObjectsCount(with isFiltering: Bool) -> Int
	func getSmartObject(at index: Int, with isFiltering: Bool) -> SmartObject
	func removeSmartObject(at index: Int, with isFiltering: Bool)
	func getSmartObjects(with isFiltering: Bool) -> [SmartObject]
	func showDetails(at index: Int)
	func filterContentForSearchText(_ searchText: String)
}

final class PinListPresenter
{
	weak var pinListViewController: PinListViewController?
	private let repository: IRepository
	private let router: IPinListRouter
	private var smartObjects: [SmartObject] {
		get {
			repository.loadSmartObjects()
		}
		set {
			repository.saveSmartObjects(newValue)
		}
	}

	private var filtredPins = [SmartObject]()

	init(repository: IRepository, router: IPinListRouter) {
		self.repository = repository
		self.router = router
	}
}

extension PinListPresenter: IPinListPresenter
{
	func filterContentForSearchText(_ searchText: String) {
		filtredPins = smartObjects.filter { (smartObject: SmartObject) -> Bool in
			return smartObject.name.lowercased().contains(searchText.lowercased())
		}
		pinListViewController?.updateTableView()
		pinListViewController?.checkEditMode()
	}

	func showDetails(at index: Int) {
		router.showDetails(smartObjects[index], type: .edit)
	}

	func getSmartObjectsCount(with isFiltering: Bool) -> Int {
		return isFiltering ? filtredPins.count : smartObjects.count
	}

	func getSmartObject(at index: Int, with isFiltering: Bool) -> SmartObject {
		return isFiltering ? filtredPins[index] : smartObjects[index]
	}

	func getSmartObjects(with isFiltering: Bool) -> [SmartObject] {
		return isFiltering ? filtredPins : smartObjects
	}

	func removeSmartObject(at index: Int, with isFiltering: Bool) {
		let currentSmartObject = getSmartObject(at: index, with: isFiltering)
		filtredPins = filtredPins.filter { filtredPins[index].identifier != $0.identifier }
		smartObjects.removeAll { $0.identifier == currentSmartObject.identifier }
	}
}
