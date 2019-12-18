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
}
