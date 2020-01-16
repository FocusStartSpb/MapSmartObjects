//
//  PinListView.swift
//  MapSmartObjects
//
//  Created by Kirill Fedorov on 16.01.2020.
//  Copyright © 2020 Максим Шалашников. All rights reserved.
//

import UIKit

final class PinListView: UIView
{
	let pinTableView = UITableView()
	let backgroundImage = UIImageView()
	let backgroundImageLabel = UILabel()
	let emptyImage = UIImage(named: Constants.emptyImageName)
	let searchImage = UIImage(named: Constants.searchImageName)

	init() {
		super.init(frame: .zero)
		addSubviews()
		setupViews()
		setConstraints()
	}

	@available(*, unavailable)
	required init?(coder aDecoder: NSCoder) {
		fatalError(Constants.fatalError)
	}

	private func addSubviews() {
		self.addSubview(pinTableView)
		self.addSubview(backgroundImage)
		self.addSubview(backgroundImageLabel)
	}

	private func setupViews() {
		backgroundImage.image = UIImage(named: Constants.emptyImageName)
		backgroundImageLabel.numberOfLines = 0
		backgroundImageLabel.textAlignment = .center
		backgroundImageLabel.textColor = Colors.mainStyle
		pinTableView.register(PinListCell.self, forCellReuseIdentifier: PinListCell.cellID)
		pinTableView.tableFooterView = UIView()
	}

	private func setConstraints() {
		pinTableView.translatesAutoresizingMaskIntoConstraints = false
		backgroundImage.translatesAutoresizingMaskIntoConstraints = false
		backgroundImageLabel.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			pinTableView.topAnchor.constraint(equalTo: self.topAnchor),
			pinTableView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			pinTableView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			pinTableView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

			backgroundImage.centerYAnchor.constraint(equalTo: self.centerYAnchor),
			backgroundImage.centerXAnchor.constraint(equalTo: self.centerXAnchor),
			backgroundImage.widthAnchor.constraint(equalToConstant: backgroundImage.image?.size.width ?? 0),
			backgroundImage.heightAnchor.constraint(equalToConstant: backgroundImage.image?.size.height ?? 0),

			backgroundImageLabel.leadingAnchor.constraint(equalTo: backgroundImage.leadingAnchor, constant: 16),
			backgroundImageLabel.trailingAnchor.constraint(equalTo: backgroundImage.trailingAnchor, constant: -16),
			backgroundImageLabel.topAnchor.constraint(equalTo: backgroundImage.bottomAnchor),
			])
	}
}
