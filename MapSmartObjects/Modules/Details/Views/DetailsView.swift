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
	private let nameLabel = UILabel()
	private let radiusLabel = UILabel()
	private let addressLabel = UILabel()
	let mapView = MKMapView()
	let addressInfoLabel = UILabel()
	let nameTextField = UITextField()
	let radiusTextField = UITextField()
	let pinImage = UIImageView(image: #imageLiteral(resourceName: "LocationPin"))

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
		self.mapView.addSubview(pinImage)
//		self.subviews.map { $0.backgroundColor = .lightGray } // для тестирования
	}
	private func configureViews() {
		self.backgroundColor = .white
		nameLabel.text = "Name"
		radiusLabel.text = "Radius"
		addressLabel.text = "Address"
		nameTextField.placeholder = "Enter place name"
		radiusTextField.placeholder = "Enter moitoring radius"
		addressInfoLabel.numberOfLines = 0
	}

	private func setTranslatesAutoresizingMaskIntoConstraints() {
		mapView.translatesAutoresizingMaskIntoConstraints = false
		nameLabel.translatesAutoresizingMaskIntoConstraints = false
		radiusLabel.translatesAutoresizingMaskIntoConstraints = false
		addressLabel.translatesAutoresizingMaskIntoConstraints = false
		addressInfoLabel.translatesAutoresizingMaskIntoConstraints = false
		nameTextField.translatesAutoresizingMaskIntoConstraints = false
		radiusTextField.translatesAutoresizingMaskIntoConstraints = false
		pinImage.translatesAutoresizingMaskIntoConstraints = false
	}

	private func setConstraints() {
		setTranslatesAutoresizingMaskIntoConstraints()

		NSLayoutConstraint.activate([
			mapView.topAnchor.constraint(equalTo: self.topAnchor),
			mapView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
			mapView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
			mapView.heightAnchor.constraint(equalTo: self.mapView.widthAnchor),

			pinImage.heightAnchor.constraint(equalToConstant: 100),
			pinImage.widthAnchor.constraint(equalToConstant: 100),
			pinImage.centerXAnchor.constraint(equalTo: mapView.centerXAnchor),
			pinImage.centerYAnchor.constraint(equalTo: mapView.centerYAnchor),

			nameLabel.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 16),
			nameLabel.widthAnchor.constraint(equalTo: mapView.widthAnchor, multiplier: 1 / 4),
			nameLabel.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 16),
			nameLabel.heightAnchor.constraint(equalToConstant: 31),

			nameTextField.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 16),
			nameTextField.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 16),
			nameTextField.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -16),
			nameTextField.heightAnchor.constraint(equalToConstant: 31),

			radiusLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 16),
			radiusLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
			radiusLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
			radiusLabel.heightAnchor.constraint(equalTo: nameLabel.heightAnchor),

			radiusTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 16),
			radiusTextField.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
			radiusTextField.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
			radiusTextField.heightAnchor.constraint(equalTo: nameTextField.heightAnchor),

			addressLabel.topAnchor.constraint(equalTo: radiusLabel.bottomAnchor, constant: 16),
			addressLabel.leadingAnchor.constraint(equalTo: radiusLabel.leadingAnchor),
			addressLabel.trailingAnchor.constraint(equalTo: radiusLabel.trailingAnchor),
			addressLabel.heightAnchor.constraint(equalTo: radiusLabel.heightAnchor),

			addressInfoLabel.topAnchor.constraint(equalTo: radiusTextField.bottomAnchor, constant: 16),
			addressInfoLabel.leadingAnchor.constraint(equalTo: radiusTextField.leadingAnchor),
			addressInfoLabel.trailingAnchor.constraint(equalTo: radiusTextField.trailingAnchor),
			addressInfoLabel.heightAnchor.constraint(greaterThanOrEqualTo: radiusTextField.heightAnchor),
			])
	}
}
