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
	private let type: DetailVCTypes

	init(presenter: IDetailsPresenter, type: DetailVCTypes) {
		self.presenter = presenter
		self.type = type
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
		setActions()
		setupView()
		setNotifycations()
	}

	private func setActions() {
		let saveBarButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveBarButtonPressed))
		navigationItem.rightBarButtonItem = saveBarButton
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
		self.view.addGestureRecognizer(tapGesture)
		detailsView.radiusTextField.addTarget(self, action: #selector(radiusChanged), for: .editingDidEnd)
	}

	private func setNotifycations() {
		let notificationCenter = NotificationCenter.default
		notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard),
									   name: UIResponder.keyboardWillHideNotification, object: nil)
		notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard),
									   name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
	}

	@objc
	private func dismissKeyboard(_ sender: UITapGestureRecognizer) {
		detailsView.radiusTextField.resignFirstResponder()
		detailsView.nameTextField.resignFirstResponder()
	}

	@objc
	private func adjustForKeyboard(notification: Notification) {
		if notification.name == UIResponder.keyboardWillHideNotification {
			detailsView.frame.origin.y = .zero
		}
		else {
			detailsView.frame.origin.y = -100
		}
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
		switch type {
		case .create:
			self.navigationItem.title = "Create"
		case .edit:
			self.navigationItem.title = "Edit"
			detailsView.nameTextField.text = currentSmartObject.name
			detailsView.radiusTextField.text = String(Int(currentSmartObject.circleRadius))
		}
		detailsView.mapView.delegate = self
		detailsView.radiusTextField.delegate = self
		detailsView.nameTextField.delegate = self
		detailsView.mapView.addAnnotation(currentSmartObject)
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
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		return textField.resignFirstResponder()
	}

	func textField(_ textField: UITextField,
				   shouldChangeCharactersIn range: NSRange,
				   replacementString string: String) -> Bool {
		guard let text = textField.text else { return true }
		let newLength = text.count + string.count - range.length
		guard let textFieldType = TextFieldType(rawValue: textField.tag) else { return true }
		switch textFieldType {
		case .name:
			return true
		case .radius:
			return newLength <= 5
		}
	}
}
