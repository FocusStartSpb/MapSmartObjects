//
//  MapRouter.swift
//  MapSmartObjects
//
//  Created by Максим Шалашников on 17.12.2019.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import UIKit

protocol IMapRouter
{
	func showDetails(smartObject: SmartObject, type: DetailVCTypes)
	func showAlertRequestLocation(title: String, message: String?, url: URL?)
	func showAlert(withTitle title: String?, message: String?)
}

final class MapRouter
{
	weak var mapViewController: MapViewController?
	private let factory: Factory

	init(factory: Factory) {
		self.factory = factory
	}
}

extension MapRouter: IMapRouter
{
	func showDetails(smartObject: SmartObject, type: DetailVCTypes) {
		let detailVC = factory.createDetailsModule(with: smartObject, type: type)
		mapViewController?.navigationController?.pushViewController(detailVC, animated: true)
	}

	func showAlertRequestLocation(title: String, message: String?, url: URL?) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let settingsAction = UIAlertAction(title: Constants.settingsTitle, style: .default) { _ in
			if let url = url {
				UIApplication.shared.open(url, options: [:], completionHandler: nil)
			}
		}
		let cancelAction = UIAlertAction(title: Constants.cancelTitle, style: .cancel, handler: nil)
		alert.addAction(settingsAction)
		alert.addAction(cancelAction)
		mapViewController?.present(alert, animated: true, completion: nil)
	}

	func showAlert(withTitle title: String?, message: String?) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let action = UIAlertAction(title: Constants.okTitle, style: .cancel, handler: nil)
		alert.addAction(action)
		mapViewController?.present(alert, animated: true, completion: nil)
	}
}
