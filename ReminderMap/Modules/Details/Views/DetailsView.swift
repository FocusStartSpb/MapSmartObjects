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
	let timerView: InfoBadge = {
		let info = InfoBadge()
		let imageView = info.imageView
		imageView.image = UIImage(named: Constants.timeImageName)
		imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
		imageView.tintColor = Colors.complementary
		info.title.textColor = Colors.complementary
		info.backgroundColor = Colors.mainStyle
		return info
	}()

	let counterView: InfoBadge = {
		let info = InfoBadge()
		let imageView = info.imageView
		imageView.image = UIImage(named: Constants.counterImageName)
		imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
		imageView.tintColor = Colors.complementary
		info.title.textColor = Colors.complementary
		info.backgroundColor = Colors.mainStyle
		return info
	}()

	private let nameLabel: UILabel = {
		let label = UILabel()
		label.text = Constants.reminderLabelText
		label.textAlignment = .left
		label.font = UIFont(name: Constants.helveticaFont, size: 16.0)
		return label
	}()

	private let radiusLabel: UILabel = {
		let label = UILabel()
		label.text = Constants.radiusLabelText
		label.font = UIFont(name: Constants.helveticaFont, size: 16.0)
		return label
	}()

	private let addressLabel: UILabel = {
		let label = UILabel()
		label.text = Constants.adressLabelText
		label.font = UIFont(name: Constants.helveticaFont, size: 16.0)
		return label
	}()

	let addressInfoLabel: UILabel = {
		let label = UILabel()
		label.numberOfLines = 0
		label.font = UIFont(name: Constants.helveticaFont, size: 14.0)
		return label
	}()

	let nameTextField: UITextField = {
		let textField = UITextField()
		textField.tag = 1
		textField.placeholder = Constants.objectPlaceholderName
		textField.borderStyle = .roundedRect
		return textField
	}()

	let radiusTextField: UITextField = {
		let textField = UITextField()
		textField.tag = 2
		textField.placeholder = Constants.radiusPlaceholderName
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
		fatalError(Constants.fatalError)
	}

	private func addSubviews() {
		self.addSubview(scrollView)
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
	}

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
			timerView.heightAnchor.constraint(equalTo: mapView.heightAnchor, multiplier: 1 / 4),

			counterView.trailingAnchor.constraint(equalTo: mapView.trailingAnchor),
			counterView.topAnchor.constraint(equalTo: timerView.topAnchor),
			counterView.heightAnchor.constraint(equalTo: timerView.heightAnchor),

			nameLabel.topAnchor.constraint(equalTo: timerView.bottomAnchor),
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
			])
	}
}
