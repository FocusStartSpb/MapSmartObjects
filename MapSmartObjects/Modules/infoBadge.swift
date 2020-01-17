//
//  infoBadge.swift
//  MapSmartObjects
//
//  Created by Максим Шалашников on 12.01.2020.
//  Copyright © 2020 Максим Шалашников. All rights reserved.
//

import UIKit

final class InfoBadge: UIView
{
	let imageView = UIImageView()
	let title = UILabel()

	init() {
		super.init(frame: .zero)
		addSubviews()
		setConstraints()
		configureView()
	}

	@available(*, unavailable)
	required init?(coder aDecoder: NSCoder) {
		fatalError(Constants.fatalError)
	}

	override func layoutSubviews() {
		layer.cornerRadius = frame.size.height / 2
	}

	private func configureView() {
		backgroundColor = Colors.complementary
		imageView.image = UIImage(named: Constants.timerImageName)
		imageView.contentMode = .scaleAspectFit
		title.font = UIFont(name: Constants.helveticaFont, size: 21.0)
		title.text = Constants.defaultvalue
	}
	private func addSubviews() {
		addSubview(imageView)
		addSubview(title)
	}

	func setConstraints() {
		imageView.translatesAutoresizingMaskIntoConstraints = false
		title.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			title.centerYAnchor.constraint(equalTo: self.centerYAnchor),
			title.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
			title.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
			title.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
			title.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),

			imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
			imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
			imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
			imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),

			self.widthAnchor.constraint(greaterThanOrEqualTo: title.widthAnchor),
			])
	}
}
