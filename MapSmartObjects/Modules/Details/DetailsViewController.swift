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
	private let currentSmartObject: SmartObject

	init(presenter: IDetailsPresenter) {
		self.presenter = presenter
		currentSmartObject = presenter.getSmartObject()
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
		detailsView.radiusTextField.addTarget(self, action: #selector(radiusChanged), for: .editingChanged)
		setupView()
	}

	@objc
	private func radiusChanged() {
		detailsView.mapView.removeOverlays(detailsView.mapView.overlays)
		let radius = Double(detailsView.radiusTextField.text ?? "0") ?? 0.0
		guard radius < CLLocationManager().maximumRegionMonitoringDistance else { return }
		showOnMap(radius: radius, center: currentSmartObject.coordinate)
	}

	private func showOnMap(radius: Double, center: CLLocationCoordinate2D) {
		let circle = MKCircle(center: center, radius: radius)
		detailsView.mapView.addOverlay(circle)
		detailsView.mapView.centerCoordinate = center
		let offset: Double = radius / 3
		let region = MKCoordinateRegion(center: center,
										latitudinalMeters: radius * 2 + offset,
										longitudinalMeters: radius * 2 + offset)
		detailsView.mapView.setRegion(region, animated: true)
	}

	private func setupView() {
		self.navigationItem.title = currentSmartObject.name
		detailsView.mapView.delegate = self
		detailsView.radiusTextField.delegate = self
		detailsView.mapView.addAnnotation(currentSmartObject)
		detailsView.nameTextField.text = currentSmartObject.name
		detailsView.radiusTextField.text = String(currentSmartObject.circleRadius)
		detailsView.addressInfoLabel.text = currentSmartObject.address
		showOnMap(radius: currentSmartObject.circleRadius, center: currentSmartObject.coordinate)
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

extension DetailsViewController: UITextFieldDelegate
{
	func textField(_ textField: UITextField,
				   shouldChangeCharactersIn range: NSRange,
				   replacementString string: String) -> Bool {
		guard let text = textField.text else { return true }
		let newLength = text.count + string.count - range.length
		return newLength <= 5
	}
}
