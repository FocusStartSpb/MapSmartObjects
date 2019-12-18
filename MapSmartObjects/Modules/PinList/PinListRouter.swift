//
//  PinListRouter.swift
//  MapSmartObjects
//
//  Created by Максим Шалашников on 17.12.2019.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import Foundation

protocol IPinListRouter
{
}

final class PinListRouter
{
	weak var pinListViewController: PinListViewController?
	private let factory: Factory

	init(factory: Factory) {
		self.factory = factory
	}
}

extension PinListRouter: IPinListRouter
{
}
