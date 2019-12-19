//
//  MapViewController.swift
//  MapSmartObjects
//
//  Created by Максим Шалашников on 17.12.2019.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import UIKit
import MapKit

final class MapViewController: UIViewController
{
	private let presenter: IMapPresenter
	private let mapView = MKMapView()
	private let buttonsView = UIView()
	private let blurEffectView = UIVisualEffectView(effect:
		UIBlurEffect(style: UIBlurEffect.Style.regular))
	private let addButton = UIButton(type: .contactAdd)
	private let currentLocationButton = UIButton()

	init(presenter: IMapPresenter) {
		self.presenter = presenter
		super.init(nibName: nil, bundle: nil)
	}

	@available (*, unavailable)
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		addSubviews()
		configureViews()
		setConstraints()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		buttonsView.layer.cornerRadius = buttonsView.frame.size.height / 10
	}

	private func addSubviews() {
		view.addSubview(mapView)
		view.addSubview(blurEffectView)
		mapView.addSubview(buttonsView)
		buttonsView.addSubview(addButton)
		buttonsView.addSubview(currentLocationButton)
	}
	private func configureViews() {
		currentLocationButton.setImage(UIImage(named: "location"), for: .normal)
		buttonsView.isOpaque = false
		buttonsView.backgroundColor = .white
		buttonsView.alpha = 0.95
	}
	private func setConstraints() {
		mapView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			mapView.topAnchor.constraint(equalTo: view.topAnchor),
			mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
		])
		buttonsView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			buttonsView.heightAnchor.constraint(equalTo: view.heightAnchor,
												multiplier: 1 / 9),
			buttonsView.widthAnchor.constraint(equalTo: view.widthAnchor,
											   multiplier: 1 / 8),
			buttonsView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 8),
			buttonsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
		])

		blurEffectView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			blurEffectView.widthAnchor.constraint(equalTo: view.widthAnchor),
			blurEffectView.topAnchor.constraint(equalTo: view.topAnchor),
			blurEffectView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
		])
		mapView.layoutSubviews()

		addButton.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			addButton.leadingAnchor.constraint(equalTo: buttonsView.leadingAnchor),
			addButton.topAnchor.constraint(equalTo: buttonsView.topAnchor),
			addButton.trailingAnchor.constraint(equalTo: buttonsView.trailingAnchor),
			addButton.heightAnchor.constraint(equalToConstant: buttonsView.frame.height / 2),
		])

		currentLocationButton.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			currentLocationButton.leadingAnchor.constraint(equalTo: buttonsView.leadingAnchor),
			currentLocationButton.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor),
			currentLocationButton.trailingAnchor.constraint(equalTo: buttonsView.trailingAnchor),
			currentLocationButton.heightAnchor.constraint(equalTo: addButton.heightAnchor),
		])

		buttonsView.layoutSubviews()
	}
}
