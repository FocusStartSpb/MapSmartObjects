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
	func getSmartObject(index: Int) -> SmartObject
	func showSmartObject(index: Int)
	func setupView()
}

final class PinListPresenter
{
	weak var pinListViewController: PinListViewController?
	private let repository: IRepository
	private let router: IPinListRouter
	private var smartObjects = [SmartObject]()

	init(repository: IRepository, router: IPinListRouter) {
		self.repository = repository
		self.router = router
		setupView()
	}
}

extension PinListPresenter: IPinListPresenter
{
	func setupView() {
		smartObjects = repository.loadSmartObjects()
		pinListViewController?.updateTableView()
	}

	func getSmartObjectsCount() -> Int {
		return smartObjects.count
	}

	func getSmartObject(index: Int) -> SmartObject {
		return smartObjects[index]
	}

	func showSmartObject(index: Int) {
		print("Show smartObject \(smartObjects[index].name)") //пока заглушка
	}
}
