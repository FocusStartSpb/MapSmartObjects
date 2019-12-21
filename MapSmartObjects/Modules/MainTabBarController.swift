//
//  MainTabBarController.swift
//  MapSmartObjects
//
//  Created by Kirill Fedorov on 18.12.2019.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import UIKit

final class MainTabBarController: UITabBarController
{
	override func viewDidLoad() {
		super.viewDidLoad()
		let mapController = Factory().createMapModule()
		let pinListController = UINavigationController(rootViewController: Factory().createPinListModule())

		self.addChild(mapController)
		self.addChild(pinListController)

		mapController.tabBarItem = UITabBarItem(title: "Map", image: nil, tag: 1)
		pinListController.tabBarItem = UITabBarItem(title: "My Pins", image: nil, tag: 2)
	}

	init() {
		super.init(nibName: nil, bundle: nil)
	}
	@available (*, unavailable)
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
