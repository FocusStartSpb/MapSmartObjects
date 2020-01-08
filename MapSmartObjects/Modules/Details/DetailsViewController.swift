//
//  DetailsViewController.swift
//  MapSmartObjects
//
//  Created by Kirill Fedorov on 07.01.2020.
//  Copyright © 2020 Максим Шалашников. All rights reserved.
//

import MapKit

final class DetailsViewController: UIViewController
{
	private let detailsView = DetailsView()
	private let presenter: IDetailsPresenter

	init(presenter: IDetailsPresenter) {
		self.presenter = presenter
		super.init(nibName: nil, bundle: nil)
	}

	@available (*, unavailable)
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func loadView() {
		self.view = detailsView
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		let saveBarButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveBarButtonPressed))
		navigationItem.rightBarButtonItem = saveBarButton
		setupView(presenter.getSmartObject())
	}

	private func setupView(_ selectedSmartObject: SmartObject) {
		self.navigationItem.title = selectedSmartObject.name
		detailsView.mapView.addAnnotation(selectedSmartObject)
		detailsView.nameTextField.text = selectedSmartObject.name
		detailsView.radiusTextField.text = String(selectedSmartObject.circleRadius)
		detailsView.addressInfoLabel.text = selectedSmartObject.address
		detailsView.mapView.centerCoordinate = selectedSmartObject.coordinate
		let coordinate = selectedSmartObject.coordinate
		let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
		detailsView.mapView.setRegion(region, animated: true)
	}

	@objc private func saveBarButtonPressed() {
		let oldSmartObject = presenter.getSmartObject()
		if oldSmartObject.name != detailsView.nameTextField.text
			|| oldSmartObject.circleRadius != Double(detailsView.radiusTextField.text ?? "") {
			presenter.changeSmartObjects(from: oldSmartObject,
										 name: detailsView.nameTextField.text ?? "",
										 radius: Double(detailsView.radiusTextField.text ?? "") ?? 0)
		}
		self.navigationController?.popToRootViewController(animated: true)
	}
}
