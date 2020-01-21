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
	let pinCounterView: InfoBadge = {
		let info = InfoBadge()
		let imageView = info.imageView
		imageView.image = UIImage(named: Constants.imageViewPin)
		imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
		imageView.tintColor = Colors.complementary
		info.title.textColor = Colors.complementary
		info.backgroundColor = Colors.mainStyle
		info.layer.shadowColor = Colors.shadows.cgColor
		info.layer.shadowOpacity = 0.2
		info.layer.shadowOffset = .zero
		info.layer.shadowRadius = 5
		return info
	}()
	let loadHUD = LoadHUD(text: Constants.loadingTitle)
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
		fatalError(Constants.fatalError)
	}

	private func addSubviews() {
		self.addSubview(mapView)
		self.addSubview(buttonsView)
		self.addSubview(pinCounterView)
		self.addSubview(loadHUD)
		buttonsView.addSubview(addButton)
		buttonsView.addSubview(currentLocationButton)
	}

	override func layoutSubviews() {
		buttonsView.layer.cornerRadius = buttonsView.frame.size.height / 10
	}

	private func configureViews() {
		currentLocationButton.setImage(UIImage(named: Constants.locationImageName)?
			.withRenderingMode(.alwaysTemplate), for: .normal)
		currentLocationButton.imageEdgeInsets = imageInset
		currentLocationButton.tintColor = Colors.mainStyle

		addButton.setImage(UIImage(named: Constants.addButtonImagename)?.withRenderingMode(.alwaysTemplate), for: .normal)
		addButton.tintColor = Colors.mainStyle
		addButton.imageEdgeInsets = imageInset
		buttonsView.isOpaque = false
		buttonsView.backgroundColor = Colors.complementary
		buttonsView.alpha = 0.95
		dropShadow(from: buttonsView)
		mapView.showsCompass = false
	}

	private func dropShadow(from view: UIView) {
		view.layer.shadowColor = Colors.shadows.cgColor
		view.layer.shadowOpacity = 0.2
		view.layer.shadowOffset = .zero
		view.layer.shadowRadius = 5
	}

	private func setConstraints() {
		mapView.translatesAutoresizingMaskIntoConstraints = false
		buttonsView.translatesAutoresizingMaskIntoConstraints = false
		addButton.translatesAutoresizingMaskIntoConstraints = false
		currentLocationButton.translatesAutoresizingMaskIntoConstraints = false
		pinCounterView.translatesAutoresizingMaskIntoConstraints = false
		loadHUD.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			mapView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			mapView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			mapView.topAnchor.constraint(equalTo: self.topAnchor),
			mapView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

			loadHUD.centerYAnchor.constraint(equalTo: self.centerYAnchor),
			loadHUD.centerXAnchor.constraint(equalTo: self.centerXAnchor),
			loadHUD.heightAnchor.constraint(equalToConstant: 50),

			buttonsView.heightAnchor.constraint(equalToConstant: 90),
			buttonsView.widthAnchor.constraint(equalToConstant: 45),
			buttonsView.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor, constant: -8),
			buttonsView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),

			pinCounterView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
			pinCounterView.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor, constant: 8),
			pinCounterView.heightAnchor.constraint(equalToConstant: 38),

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
