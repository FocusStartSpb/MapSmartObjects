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

	let backgroundView: UIView = {
		let view = UIView()
		view.backgroundColor = Colors.complementary
		return view
	}()

	let timerView: InfoBadge = {
		let info = InfoBadge()
		let imageView = info.imageView
		imageView.image = UIImage(named: "time")
		imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
		imageView.tintColor = Colors.mainStyle
		info.title.textColor = Colors.mainStyle
		info.backgroundColor = Colors.complementary
		return info
	}()

	let counterView: InfoBadge = {
		let info = InfoBadge()
		let imageView = info.imageView
		imageView.image = UIImage(named: "counter")
		imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
		imageView.tintColor = Colors.mainStyle
		info.title.textColor = Colors.mainStyle
		info.backgroundColor = Colors.complementary
		return info
	}()

	//private let counter = InfoBadge()

	private let nameLabel: UILabel = {
		let label = UILabel()
		label.text = "Name"
		label.textAlignment = .left
		label.font = UIFont(name: "HelveticaNeue", size: 16.0)
		return label
	}()

	private let radiusLabel: UILabel = {
		let label = UILabel()
		label.text = "Radius (meters)"
		label.font = UIFont(name: "HelveticaNeue", size: 16.0)
		return label
	}()

	private let addressLabel: UILabel = {
		let label = UILabel()
		label.text = "Address:"
		label.font = UIFont(name: "HelveticaNeue", size: 16.0)
		return label
	}()

	let addressInfoLabel: UILabel = {
		let label = UILabel()
		label.numberOfLines = 0
		label.font = UIFont(name: "HelveticaNeue", size: 14.0)
		return label
	}()

	let visitsCountInfoLabel: UILabel = {
		let label = UILabel()
		label.textAlignment = .left
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
		self.addSubview(visitsCountLabel)
		self.addSubview(visitsCountInfoLabel)
		self.addSubview(backgroundView)
		scrollView.addSubview(mapView)
		scrollView.addSubview(timerView)
		scrollView.addSubview(counterView)
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
		timerView.translatesAutoresizingMaskIntoConstraints = false
		counterView.translatesAutoresizingMaskIntoConstraints = false
		mapView.translatesAutoresizingMaskIntoConstraints = false
		nameLabel.translatesAutoresizingMaskIntoConstraints = false
		radiusLabel.translatesAutoresizingMaskIntoConstraints = false
		addressLabel.translatesAutoresizingMaskIntoConstraints = false
		addressInfoLabel.translatesAutoresizingMaskIntoConstraints = false
		nameTextField.translatesAutoresizingMaskIntoConstraints = false
		radiusTextField.translatesAutoresizingMaskIntoConstraints = false
		visitsCountLabel.translatesAutoresizingMaskIntoConstraints = false
		visitsCountInfoLabel.translatesAutoresizingMaskIntoConstraints = false
		backgroundView.translatesAutoresizingMaskIntoConstraints = false
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

			timerView.leadingAnchor.constraint(equalTo: mapView.leadingAnchor),
			timerView.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 8),
			timerView.heightAnchor.constraint(equalTo: mapView.heightAnchor, multiplier: 1 / 5),

			counterView.trailingAnchor.constraint(equalTo: mapView.trailingAnchor),
			counterView.topAnchor.constraint(equalTo: timerView.topAnchor),
			counterView.heightAnchor.constraint(equalTo: timerView.heightAnchor),

			backgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			backgroundView.topAnchor.constraint(equalTo: self.topAnchor),
			backgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			backgroundView.bottomAnchor.constraint(equalTo: counterView.bottomAnchor, constant: 8),

			nameLabel.topAnchor.constraint(equalTo: timerView.bottomAnchor, constant: 8),
			nameLabel.trailingAnchor.constraint(equalTo: radiusLabel.trailingAnchor),
			nameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
			nameLabel.heightAnchor.constraint(equalToConstant: 31),

			nameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
			nameTextField.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
			nameTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
			nameTextField.heightAnchor.constraint(equalToConstant: 31),

			radiusLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor),
			radiusLabel.widthAnchor.constraint(greaterThanOrEqualTo: nameLabel.widthAnchor),
			radiusLabel.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
			radiusLabel.heightAnchor.constraint(equalTo: nameLabel.heightAnchor),

			radiusTextField.topAnchor.constraint(equalTo: radiusLabel.bottomAnchor),
			radiusTextField.leadingAnchor.constraint(equalTo: radiusLabel.leadingAnchor),
			radiusTextField.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
			radiusTextField.heightAnchor.constraint(equalTo: nameTextField.heightAnchor),

			addressLabel.topAnchor.constraint(equalTo: radiusTextField.bottomAnchor),
			addressLabel.leadingAnchor.constraint(equalTo: radiusTextField.leadingAnchor),
			addressLabel.widthAnchor.constraint(greaterThanOrEqualTo: radiusLabel.widthAnchor),
			addressLabel.heightAnchor.constraint(equalTo: radiusLabel.heightAnchor),

			addressInfoLabel.topAnchor.constraint(equalTo: addressLabel.bottomAnchor),
			addressInfoLabel.leadingAnchor.constraint(equalTo: addressLabel.leadingAnchor),
			addressInfoLabel.trailingAnchor.constraint(equalTo: radiusTextField.trailingAnchor),
			addressInfoLabel.heightAnchor.constraint(greaterThanOrEqualTo: addressLabel.heightAnchor),

//			visitsCountLabel.topAnchor.constraint(equalTo: radiusLabel.bottomAnchor, constant: 16),
//			visitsCountLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -38),
//			visitsCountLabel.widthAnchor.constraint(greaterThanOrEqualTo: nameLabel.widthAnchor),
//			visitsCountLabel.leadingAnchor.constraint(equalTo: addressLabel.leadingAnchor),
//			visitsCountLabel.heightAnchor.constraint(equalToConstant: 31),
//
////			insideTimeLabel.topAnchor.constraint(equalTo: visitsCountLabel.bottomAnchor, constant: 16),
//			insideTimeLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -38),
////			insideTimeLabel.leadingAnchor.constraint(equalTo: visitsCountLabel.leadingAnchor),
//			insideTimeLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 8),
//			insideTimeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
//			insideTimeLabel.heightAnchor.constraint(equalToConstant: 31),
//
//			visitsCountInfoLabel.topAnchor.constraint(equalTo: visitsCountLabel.topAnchor),
//			visitsCountInfoLabel.leadingAnchor.constraint(lessThanOrEqualTo: nameTextField.leadingAnchor, constant: 5),
//			visitsCountInfoLabel.trailingAnchor.constraint(equalTo: radiusTextField.trailingAnchor),
//			visitsCountInfoLabel.heightAnchor.constraint(equalToConstant: 31),

//			insideTimeInfoLabel.topAnchor.constraint(equalTo: insideTimeLabel.topAnchor),
//			insideTimeInfoLabel.leadingAnchor.constraint(equalTo: radiusTextField.leadingAnchor, constant: 5),
//			insideTimeInfoLabel.trailingAnchor.constraint(equalTo: visitsCountInfoLabel.trailingAnchor),
//			insideTimeInfoLabel.heightAnchor.constraint(equalToConstant: 31),
			])
	}
}
