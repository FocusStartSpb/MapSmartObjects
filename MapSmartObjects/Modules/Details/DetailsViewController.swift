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
	private var saveBarButton = UIBarButtonItem()

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
		self.navigationController?.setNavigationBarHidden(false, animated: true)
		setActions()
		setupView()
		setNotifycations()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.navigationBar.barStyle = .black
	}

	private func setActions() {
		saveBarButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveBarButtonPressed))
		navigationItem.rightBarButtonItem = saveBarButton
		saveBarButton.isEnabled = (self.type == .edit)
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
		self.view.addGestureRecognizer(tapGesture)
		detailsView.radiusTextField.addTarget(self, action: #selector(radiusChanged), for: .editingDidEnd)
		detailsView.radiusTextField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
		detailsView.nameTextField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
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
		let offset: Double = max(radius / 3, 500)
		let region = MKCoordinateRegion(center: center,
										latitudinalMeters: radius * 2 + offset,
										longitudinalMeters: radius * 2 + offset)
		detailsView.mapView.setRegion(region, animated: true)
	}

	private func setupView() {
		navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
		navigationController?.navigationBar.barTintColor = Colors.mainStyle
		navigationController?.navigationBar.tintColor = Colors.complementary
		switch type {
		case .create:
			self.navigationItem.title = "Create"
		case .edit:
			self.navigationItem.title = "Edit"
			detailsView.nameTextField.text = currentSmartObject.name
			detailsView.radiusTextField.text = String(Int(currentSmartObject.circleRadius))
		}
		detailsView.counterView.title.text = String(currentSmartObject.visitCount)
		detailsView.timerView.title.text = currentSmartObject.insideTime.toString()
		detailsView.mapView.delegate = self
		detailsView.radiusTextField.delegate = self
		detailsView.nameTextField.delegate = self
		detailsView.mapView.addAnnotation(currentSmartObject)
		detailsView.addressInfoLabel.text = currentSmartObject.address
		showOnMap(radius: currentSmartObject.circleRadius, center: currentSmartObject.coordinate)
	}

	@objc
	private func saveBarButtonPressed() {
		let oldSmartObject = presenter.getSmartObject()
		if oldSmartObject.name != detailsView.nameTextField.text
			|| oldSmartObject.circleRadius != Double(detailsView.radiusTextField.text ?? "") {
			presenter.changeSmartObjects(from: oldSmartObject,
										 name: detailsView.nameTextField.text ?? "",
										 radius: Double(detailsView.radiusTextField.text ?? "") ?? 0)
		}
		self.navigationController?.popToRootViewController(animated: true)
	}

	@objc
	private func textFieldEditingChanged(sender: UITextField) {
		guard let textFromNameFiled = detailsView.nameTextField.text else { return }
		guard let textFromRadiusFiled = detailsView.radiusTextField.text else { return }
		saveBarButton.isEnabled = (textFromNameFiled.isEmpty == false) && (textFromRadiusFiled.isEmpty == false)
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
		// проверка текущего textField (если radius - ограничение 5 символов, если name - нет ограничения)
		guard let textFieldType = TextFieldType(rawValue: textField.tag) else { return true }
		switch textFieldType {
		case .name:
			return true
		case .radius:
			return newLength <= 5
		}
	}
}
