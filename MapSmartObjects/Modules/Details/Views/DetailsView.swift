//
//  DetailsView.swift
//  MapSmartObjects
//
//  Created by Kirill Fedorov on 07.01.2020.
//  Copyright © 2020 Максим Шалашников. All rights reserved.
//

import MapKit

final class DetailsView: UIView
{
	let mapView = MKMapView()
	private let nameLabel: UILabel = {
		let label = UILabel()
		label.text = "Name:"
		label.font = UIFont(name: "HelveticaNeue-Bold", size: 18.0)
		return label
	}()

	private let radiusLabel: UILabel = {
		let label = UILabel()
		label.text = "Radius (meters):"
		label.font = UIFont(name: "HelveticaNeue-Bold", size: 18.0)
		return label
	}()

	private let addressLabel: UILabel = {
		let label = UILabel()
		label.text = "Address:"
		label.font = UIFont(name: "HelveticaNeue-Bold", size: 18.0)
		return label
	}()

	let addressInfoLabel: UILabel = {
		let label = UILabel()
		label.numberOfLines = 0
		return label
	}()

	let nameTextField: UITextField = {
		let textField = UITextField()
		textField.placeholder = "Enter place name"
		textField.borderStyle = .roundedRect
		return textField
	}()

	let radiusTextField: UITextField = {
		let textField = UITextField()
		textField.placeholder = "Enter monitoring radius"
		textField.borderStyle = .roundedRect
		return textField
	}()

	init() {
		super.init(frame: .zero)
		addSubviews()
		configureViews()
		setConstraints()
	}

	@available(*, unavailable)
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func addSubviews() {
		self.addSubview(mapView)
		self.addSubview(nameLabel)
		self.addSubview(radiusLabel)
		self.addSubview(addressLabel)
		self.addSubview(addressInfoLabel)
		self.addSubview(nameTextField)
		self.addSubview(radiusTextField)
	}

	private func configureViews() {
		self.backgroundColor = .white
		mapView.isUserInteractionEnabled = false
		mapView.layer.cornerRadius = 16
		radiusTextField.keyboardType = .numberPad
	}

	private func setTranslatesAutoresizingMaskIntoConstraints() {
		mapView.translatesAutoresizingMaskIntoConstraints = false
		nameLabel.translatesAutoresizingMaskIntoConstraints = false
		radiusLabel.translatesAutoresizingMaskIntoConstraints = false
		addressLabel.translatesAutoresizingMaskIntoConstraints = false
		addressInfoLabel.translatesAutoresizingMaskIntoConstraints = false
		nameTextField.translatesAutoresizingMaskIntoConstraints = false
		radiusTextField.translatesAutoresizingMaskIntoConstraints = false
	}

	private func setConstraints() {
		setTranslatesAutoresizingMaskIntoConstraints()

		NSLayoutConstraint.activate([
			mapView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 16),
			mapView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 16),
			mapView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -16),
			mapView.heightAnchor.constraint(equalTo: self.mapView.widthAnchor, multiplier: 1 / 2),

			nameLabel.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 16),
			nameLabel.widthAnchor.constraint(equalTo: mapView.widthAnchor, multiplier: 1 / 4),
			nameLabel.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 16),
			nameLabel.heightAnchor.constraint(equalToConstant: 31),

			nameTextField.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 16),
			nameTextField.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 16),
			nameTextField.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -16),
			nameTextField.heightAnchor.constraint(equalToConstant: 31),

			radiusLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 16),
			radiusLabel.widthAnchor.constraint(equalTo: nameLabel.widthAnchor, constant: 60),
			radiusLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
			radiusLabel.heightAnchor.constraint(equalTo: nameLabel.heightAnchor),

			radiusTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 16),
			radiusTextField.leadingAnchor.constraint(equalTo: radiusLabel.trailingAnchor, constant: 16),
			radiusTextField.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
			radiusTextField.heightAnchor.constraint(equalTo: nameTextField.heightAnchor),

			addressLabel.topAnchor.constraint(equalTo: radiusLabel.bottomAnchor, constant: 16),
			addressLabel.leadingAnchor.constraint(equalTo: radiusLabel.leadingAnchor),
			addressLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
			addressLabel.heightAnchor.constraint(equalTo: radiusLabel.heightAnchor),

			addressInfoLabel.topAnchor.constraint(equalTo: radiusTextField.bottomAnchor, constant: 16),
			addressInfoLabel.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
			addressInfoLabel.trailingAnchor.constraint(equalTo: radiusTextField.trailingAnchor),
			addressInfoLabel.heightAnchor.constraint(greaterThanOrEqualTo: radiusTextField.heightAnchor),
			])
	}
}
