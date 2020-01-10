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
	func getSmartObjectsCount() -> Int
	func getSmartObject(at index: Int) -> SmartObject
	func removeSmartObject(at index: Int)
	func getSmartObjects() -> [SmartObject]
	func showDetails(at index: Int)
}

final class PinListPresenter
{
	weak var pinListViewController: PinListViewController?
	private let repository: IRepository
	private let router: IPinListRouter

	init(repository: IRepository, router: IPinListRouter) {
		self.repository = repository
		self.router = router
	}
}

extension PinListPresenter: IPinListPresenter
{
	func showDetails(at index: Int) {
		router.showDetails(repository.getSmartObjects()[index], type: .edit)
	}

	func getSmartObjectsCount() -> Int {
		return repository.smartObjectsCount
	}

	func getSmartObject(at index: Int) -> SmartObject {
		return repository.getSmartObjects()[index]
	}

	func getSmartObjects() -> [SmartObject] {
		return repository.getSmartObjects()
	}

	func removeSmartObject(at index: Int) {
		repository.removeSmartObject(at: index)
	}
}
