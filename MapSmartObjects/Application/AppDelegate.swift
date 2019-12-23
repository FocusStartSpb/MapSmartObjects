//
//  AppDelegate.swift
//  MapSmartObjects
//
//  Created by Максим Шалашников on 15.12.2019.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import UserNotifications

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate
{
	var window: UIWindow?
	let locationManager = CLLocationManager()
	let presenter: IMapPresenter

	init(presenter: IMapPresenter) {
		self.presenter = presenter
	}

	@available (*, unavailable)
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func application(_ application: UIApplication,
					 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		locationManager.delegate = self
		locationManager.requestAlwaysAuthorization()
		let options: UNAuthorizationOptions = [.badge, .sound, .alert]
		UNUserNotificationCenter.current().requestAuthorization(options: options){ _, error in
				if let error = error {
					print("Error: \(error)")
				}
		}
		self.window = UIWindow(frame: UIScreen.main.bounds)
		self.window?.rootViewController = MainTabBarController()
		self.window?.makeKeyAndVisible()
		return true
	}
	func applicationDidBecomeActive(_ application: UIApplication) {
		application.applicationIconBadgeNumber = 0
		UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
		UNUserNotificationCenter.current().removeAllDeliveredNotifications()
	}
	func handleEvent(for region: CLRegion) {
		// Уведомление если приложение запущено
		if UIApplication.shared.applicationState == .active {
			guard let message = note(from: region.identifier) else { return }
			window?.rootViewController?.showAlert(withTitle: nil, message: message)
		}
		else {
			// Пуш если фоновы режим или блок телефона
			guard let body = note(from: region.identifier) else { return }
			let notificationContent = UNMutableNotificationContent()
			notificationContent.body = body
			notificationContent.sound = UNNotificationSound.default
			notificationContent.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber
			let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
			let request = UNNotificationRequest(identifier: "location_change",
												content: notificationContent,
												trigger: trigger)
			UNUserNotificationCenter.current().add(request) { error in
				if let error = error {
					print("Ошибка: \(error)")
				}
			}
		}
	}
	func note(from identifier: String) -> String? {
		let smartObjects = presenter.getSmartObjects()
		guard let matched = smartObjects.first else { return nil }
		return matched.address
	}
}

extension AppDelegate: CLLocationManagerDelegate
{
	func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
		if region is CLCircularRegion {
			handleEvent(for: region)
		}
	}
	func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
		if region is CLCircularRegion {
			handleEvent(for: region)
		}
	}
}
