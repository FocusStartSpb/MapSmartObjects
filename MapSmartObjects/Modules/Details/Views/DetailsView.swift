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
	private let visitsCountLabel: UILabel = {
		let label = UILabel()
		label.text = "Visits:"
		label.textAlignment = .left
		label.font = UIFont(name: "HelveticaNeue-Bold", size: 18.0)
		return label
	}()

	private let insideTimeLabel: UILabel = {
		let label = UILabel()
		label.text = "Inside time:"
		label.textAlignment = .left
		label.font = UIFont(name: "HelveticaNeue-Bold", size: 18.0)
		return label
	}()

	private let nameLabel: UILabel = {
		let label = UILabel()
		label.text = "Name:"
		label.textAlignment = .left
		label.font = UIFont(name: "HelveticaNeue-Bold", size: 18.0)
		return label
	}()

	private let radiusLabel: UILabel = {
		let label = UILabel()
		label.text = "Radius:"
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

	let visitsCountInfoLabel: UILabel = {
		let label = UILabel()
		label.textAlignment = .left
		label.text = "0"
		return label
	}()

	let insideTimeInfoLabel: UILabel = {
		let label = UILabel()
		label.textAlignment = .left
		DateFormatter().dateFormat = "mm:ss"
		label.text = "0"
		return label
	}()

	let nameTextField: UITextField = {
		let textField = UITextField()
		textField.tag = 1
		textField.placeholder = "Enter place name"
		textField.borderStyle = .roundedRect
		return textField
	}()

	let radiusTextField: UITextField = {
		let textField = UITextField()
		textField.tag = 2
		textField.placeholder = "Enter monitoring radius"
		textField.borderStyle = .roundedRect
		textField.keyboardType = .numberPad
		return textField
	}()

	let scrollView = UIScrollView()
	let mapView = MKMapView()

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
		self.addSubview(scrollView)
		scrollView.addSubview(visitsCountLabel)
		scrollView.addSubview(visitsCountInfoLabel)
		scrollView.addSubview(insideTimeLabel)
		scrollView.addSubview(insideTimeInfoLabel)
		scrollView.addSubview(mapView)
		scrollView.addSubview(nameLabel)
		scrollView.addSubview(radiusLabel)
		scrollView.addSubview(addressLabel)
		scrollView.addSubview(addressInfoLabel)
		scrollView.addSubview(nameTextField)
		scrollView.addSubview(radiusTextField)
	}

	private func configureViews() {
		self.backgroundColor = .white
		mapView.isUserInteractionEnabled = false
		mapView.layer.cornerRadius = 16
	}

	private func setTranslatesAutoresizingMaskIntoConstraints() {
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		mapView.translatesAutoresizingMaskIntoConstraints = false
		nameLabel.translatesAutoresizingMaskIntoConstraints = false
		radiusLabel.translatesAutoresizingMaskIntoConstraints = false
		addressLabel.translatesAutoresizingMaskIntoConstraints = false
		addressInfoLabel.translatesAutoresizingMaskIntoConstraints = false
		nameTextField.translatesAutoresizingMaskIntoConstraints = false
		radiusTextField.translatesAutoresizingMaskIntoConstraints = false
		visitsCountLabel.translatesAutoresizingMaskIntoConstraints = false
		visitsCountInfoLabel.translatesAutoresizingMaskIntoConstraints = false
		insideTimeLabel.translatesAutoresizingMaskIntoConstraints = false
		insideTimeInfoLabel.translatesAutoresizingMaskIntoConstraints = false
	}

	// swiftlint:disable:next function_body_length
	private func setConstraints() {
		setTranslatesAutoresizingMaskIntoConstraints()
		NSLayoutConstraint.activate([
			scrollView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
			scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

			mapView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
			mapView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
			mapView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
			mapView.heightAnchor.constraint(equalTo: self.mapView.widthAnchor, multiplier: 1 / 2),

			nameLabel.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 16),
			nameLabel.trailingAnchor.constraint(equalTo: radiusLabel.trailingAnchor),
			nameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
			nameLabel.heightAnchor.constraint(equalToConstant: 31),

			visitsCountLabel.topAnchor.constraint(equalTo: radiusLabel.bottomAnchor, constant: 16),
			visitsCountLabel.widthAnchor.constraint(greaterThanOrEqualTo: nameLabel.widthAnchor),
			visitsCountLabel.leadingAnchor.constraint(equalTo: radiusLabel.leadingAnchor),
			visitsCountLabel.heightAnchor.constraint(equalToConstant: 31),

			radiusLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 16),
			radiusLabel.widthAnchor.constraint(greaterThanOrEqualTo: insideTimeLabel.widthAnchor),
			radiusLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
			radiusLabel.heightAnchor.constraint(equalTo: nameLabel.heightAnchor),

			insideTimeLabel.topAnchor.constraint(equalTo: visitsCountLabel.bottomAnchor, constant: 16),
			insideTimeLabel.leadingAnchor.constraint(equalTo: visitsCountLabel.leadingAnchor),
			insideTimeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
			insideTimeLabel.heightAnchor.constraint(equalToConstant: 31),

			addressLabel.topAnchor.constraint(equalTo: insideTimeLabel.bottomAnchor, constant: 16),
			addressLabel.leadingAnchor.constraint(equalTo: insideTimeLabel.leadingAnchor),
			addressLabel.widthAnchor.constraint(greaterThanOrEqualTo: insideTimeLabel.widthAnchor),
			addressLabel.heightAnchor.constraint(equalTo: insideTimeLabel.heightAnchor),

			nameTextField.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 16),
			nameTextField.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 16),
			nameTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
			nameTextField.heightAnchor.constraint(equalToConstant: 31),

			radiusTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 16),
			radiusTextField.leadingAnchor.constraint(equalTo: radiusLabel.trailingAnchor, constant: 16),
			radiusTextField.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
			radiusTextField.heightAnchor.constraint(equalTo: nameTextField.heightAnchor),

			visitsCountInfoLabel.topAnchor.constraint(equalTo: visitsCountLabel.topAnchor),
			visitsCountInfoLabel.leadingAnchor.constraint(lessThanOrEqualTo: nameTextField.leadingAnchor, constant: 5),
			visitsCountInfoLabel.trailingAnchor.constraint(equalTo: radiusTextField.trailingAnchor),
			visitsCountInfoLabel.heightAnchor.constraint(equalToConstant: 31),

			insideTimeInfoLabel.topAnchor.constraint(equalTo: insideTimeLabel.topAnchor),
			insideTimeInfoLabel.leadingAnchor.constraint(equalTo: radiusTextField.leadingAnchor, constant: 5),
			insideTimeInfoLabel.trailingAnchor.constraint(equalTo: visitsCountInfoLabel.trailingAnchor),
			insideTimeInfoLabel.heightAnchor.constraint(equalToConstant: 31),

			addressInfoLabel.topAnchor.constraint(equalTo: addressLabel.topAnchor),
			addressInfoLabel.leadingAnchor.constraint(equalTo: insideTimeInfoLabel.leadingAnchor, constant: 5),
			addressInfoLabel.trailingAnchor.constraint(equalTo: insideTimeInfoLabel.trailingAnchor),
			addressInfoLabel.heightAnchor.constraint(greaterThanOrEqualTo: addressLabel.heightAnchor),
			])
	}
}
