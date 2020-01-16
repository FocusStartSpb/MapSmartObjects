//
//  AppDelegate.swift
//  MapSmartObjects
//
//  Created by Максим Шалашников on 15.12.2019.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate
{
	var window: UIWindow?
	private(set) var factory: Factory?

	func application(_ application: UIApplication,
					 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		let mainTabBarController = MainTabBarController()
		self.window = UIWindow(frame: UIScreen.main.bounds)
		self.window?.rootViewController = mainTabBarController
		self.factory = mainTabBarController.factory
		self.window?.makeKeyAndVisible()
		factory?.getRepository().loadSmartObjectsFromDB()
		UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
		return true
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		application.applicationIconBadgeNumber = 0
		UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
		UNUserNotificationCenter.current().removeAllDeliveredNotifications()
	}

	func applicationWillResignActive(_ application: UIApplication) {
		factory?.getRepository().saveSmartObjectsToDB()
	}
}
