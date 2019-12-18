//
//  AppDelegate.swift
//  MapSmartObjects
//
//  Created by Максим Шалашников on 15.12.2019.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate
{
	var window: UIWindow?

	func application(_ application: UIApplication,
					 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		self.window = UIWindow(frame: UIScreen.main.bounds)
		self.window?.rootViewController = MainTabBarController()
		self.window?.makeKeyAndVisible()
		return true
	}
}
