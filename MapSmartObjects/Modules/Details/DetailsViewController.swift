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

	private func setupView(_ currentSmartObject: SmartObject) {
		self.navigationItem.title = currentSmartObject.name
		detailsView.mapView.delegate = self
		let circle = MKCircle(center: currentSmartObject.coordinate, radius: currentSmartObject.circleRadius)
		detailsView.mapView.addOverlay(circle)
		detailsView.mapView.addAnnotation(currentSmartObject)
		detailsView.nameTextField.text = currentSmartObject.name
		detailsView.radiusTextField.text = String(currentSmartObject.circleRadius)
		detailsView.addressInfoLabel.text = currentSmartObject.address
		detailsView.mapView.centerCoordinate = currentSmartObject.coordinate
		let coordinate = currentSmartObject.coordinate
		let offset: Double = 500
		let region = MKCoordinateRegion(center: coordinate,
										latitudinalMeters: currentSmartObject.circleRadius * 2 + offset,
										longitudinalMeters: currentSmartObject.circleRadius * 2 + offset)
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

extension DetailsViewController: MKMapViewDelegate
{
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		var circle = MKOverlayRenderer()
		if overlay is MKCircle {
			let circleRender = MKCircleRenderer(overlay: overlay)
			circleRender.strokeColor = .blue
			circleRender.fillColor = UIColor.green.withAlphaComponent(0.3)
			circleRender.lineWidth = 1
			circle = circleRender
		}
		return circle
	}
}
