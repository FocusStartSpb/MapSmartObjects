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
	let factory = Factory()
	private let imageInset = UIEdgeInsets(top: 30.0, left: 30.0, bottom: 30.0, right: 30.0)

	override func viewDidLoad() {
		super.viewDidLoad()
		UITabBar.appearance().tintColor = Colors.mainStyle
		let mapController = UINavigationController(rootViewController: factory.createMapModule())
		let pinListController = UINavigationController(rootViewController: factory.createPinListModule())

		self.addChild(mapController)
		self.addChild(pinListController)

		mapController.tabBarItem = UITabBarItem(title: Constants.mapTitle,
												image: UIImage(named: Constants.mapImageName),
												tag: 1)
		mapController.tabBarItem.badgeColor = Colors.mainStyle
		mapController.tabBarItem.imageInsets = imageInset

		pinListController.tabBarItem = UITabBarItem(title: Constants.pinsTitle,
													image: UIImage(named: Constants.menuImageName),
													tag: 2)
		pinListController.tabBarItem.badgeColor = Colors.mainStyle
		pinListController.tabBarItem.imageInsets = imageInset
	}

	init() {
		super.init(nibName: nil, bundle: nil)
	}

	@available (*, unavailable)
	required init?(coder aDecoder: NSCoder) {
		fatalError(Constants.fatalError)
	}
}
