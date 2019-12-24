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
	func getSmartObjectsCount() -> Int {
		return repository.getSmartObjects().count
	}

	func getSmartObject(at index: Int) -> SmartObject {
		return repository.getSmartObjects()[index]
	}

	func removeSmartObject(at index: Int) {
		repository.removeSmartObject(at: index)
	}
}
