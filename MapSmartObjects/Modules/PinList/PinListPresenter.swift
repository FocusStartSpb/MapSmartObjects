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
	private var filtredPins = [SmartObject]()

	init(repository: IRepository, router: IPinListRouter) {
		self.repository = repository
		self.router = router
	}
}

extension PinListPresenter: IPinListPresenter
{
	func filterContentForSearchText(_ searchText: String) {
		filtredPins = repository.getSmartObjects().filter { (smartObject: SmartObject) -> Bool in
			return smartObject.name.lowercased().contains(searchText.lowercased())
		}
		pinListViewController?.updateTableView()
		pinListViewController?.checkEditMode()
	}

	func showDetails(at index: Int) {
		router.showDetails(repository.getSmartObjects()[index], type: .edit)
	}

	func getSmartObjectsCount(with isFiltering: Bool) -> Int {
		return isFiltering ? filtredPins.count : repository.smartObjectsCount
	}

	func getSmartObject(at index: Int, with isFiltering: Bool) -> SmartObject {
		return isFiltering ? filtredPins[index] : repository.getSmartObjects()[index]
	}

	func getSmartObjects(with isFiltering: Bool) -> [SmartObject] {
		return isFiltering ? filtredPins : repository.getSmartObjects()
	}

	func removeSmartObject(at index: Int, with isFiltering: Bool) {
		let currentSmartObject = getSmartObject(at: index, with: isFiltering)
		filtredPins = filtredPins.filter { filtredPins[index].identifier != $0.identifier }
		repository.removeSmartObject(with: currentSmartObject.identifier)
	}
}
