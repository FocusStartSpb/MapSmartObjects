//
//  MapView.swift
//  MapSmartObjects
//
//  Created by Kirill Fedorov on 29.12.2019.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import UIKit
import MapKit

final class MapView: UIView
{
	let mapView = MKMapView()
	let buttonsView = UIView()
	let addButton = UIButton()
	let currentLocationButton = UIButton()
	private let imageInset = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)

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
		self.addSubview(buttonsView)
		buttonsView.addSubview(addButton)
		buttonsView.addSubview(currentLocationButton)
	}
	private func configureViews() {
		currentLocationButton.setImage(UIImage(named: "location")?.withRenderingMode(.alwaysTemplate), for: .normal)
		currentLocationButton.imageEdgeInsets = imageInset

		addButton.setImage(UIImage(named: "add")?.withRenderingMode(.alwaysTemplate), for: .normal)
		addButton.imageEdgeInsets = imageInset

		buttonsView.isOpaque = false
		buttonsView.backgroundColor = .white
		buttonsView.alpha = 0.95
		mapView.showsCompass = false
		setCustomCompass()
	}

	private func setCustomCompass() {
		let compassButton = MKCompassButton(mapView: mapView)
		compassButton.compassVisibility = .visible
		mapView.addSubview(compassButton)
		compassButton.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			compassButton.leadingAnchor.constraint(equalTo: buttonsView.leadingAnchor),
			compassButton.topAnchor.constraint(equalTo: buttonsView.bottomAnchor, constant: 8),
			compassButton.widthAnchor.constraint(equalTo: buttonsView.widthAnchor),
			compassButton.heightAnchor.constraint(equalTo: buttonsView.heightAnchor, multiplier: 1 / 2),
			])
	}

	private func setConstraints() {
		mapView.translatesAutoresizingMaskIntoConstraints = false
		buttonsView.translatesAutoresizingMaskIntoConstraints = false
		addButton.translatesAutoresizingMaskIntoConstraints = false
		currentLocationButton.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			mapView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			mapView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			mapView.topAnchor.constraint(equalTo: self.topAnchor),
			mapView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

			buttonsView.heightAnchor.constraint(equalToConstant: 90),
			buttonsView.widthAnchor.constraint(equalToConstant: 45),
			buttonsView.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor, constant: 8),
			buttonsView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),

			addButton.leadingAnchor.constraint(equalTo: buttonsView.leadingAnchor),
			addButton.topAnchor.constraint(equalTo: buttonsView.topAnchor),
			addButton.trailingAnchor.constraint(equalTo: buttonsView.trailingAnchor),
			addButton.heightAnchor.constraint(equalTo: buttonsView.heightAnchor, multiplier: 1 / 2),

			currentLocationButton.leadingAnchor.constraint(equalTo: buttonsView.leadingAnchor),
			currentLocationButton.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor),
			currentLocationButton.trailingAnchor.constraint(equalTo: buttonsView.trailingAnchor),
			currentLocationButton.heightAnchor.constraint(equalTo: addButton.heightAnchor),
			])
	}
}
