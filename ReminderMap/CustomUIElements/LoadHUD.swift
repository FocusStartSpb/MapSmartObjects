//
//  HUD.swift
//  ReminderMap
//
//  Created by Максим Шалашников on 21.01.2020.
//  Copyright © 2020 Максим Шалашников. All rights reserved.
//
import UIKit

final class LoadHUD: UIVisualEffectView
{
	var text: String? {
		didSet {
			label.text = text
		}
	}

	let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
	let label = UILabel()
	let blurEffect = UIBlurEffect(style: .light)
	let vibrancyView: UIVisualEffectView
	let activityIndicatorSize: CGFloat = 40

	init(text: String) {
		self.text = text
		vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
		super.init(effect: blurEffect)
		addSubviews()
		setConstraints()
		configureView()
	}
	@available(*, unavailable)
	required init?(coder aDecoder: NSCoder) {
		vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
		super.init(coder: aDecoder)
	}

	private func addSubviews() {
		contentView.addSubview(vibrancyView)
		contentView.addSubview(activityIndicator)
		contentView.addSubview(label)
	}

	private func configureView() {
		activityIndicator.startAnimating()
		label.text = text
		label.textAlignment = .center
		label.textColor = Colors.carriage
		label.font = UIFont.boldSystemFont(ofSize: 16)
		hide()
	}
	override func layoutSubviews() {
		vibrancyView.frame = self.bounds
		layer.cornerRadius = 8.0
		layer.masksToBounds = true
	}

	private func setConstraints() {
		activityIndicator.translatesAutoresizingMaskIntoConstraints = false
		label.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			activityIndicator.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
			activityIndicator.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
			activityIndicator.widthAnchor.constraint(equalToConstant: activityIndicatorSize),
			activityIndicator.heightAnchor.constraint(equalToConstant: activityIndicatorSize),

			label.leadingAnchor.constraint(equalTo: activityIndicator.trailingAnchor, constant: 5),
			label.topAnchor.constraint(equalTo: self.topAnchor),
			label.heightAnchor.constraint(equalToConstant: 50),
			label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),

			self.widthAnchor.constraint(greaterThanOrEqualTo: label.widthAnchor),
		])
	}

	func show() {
		self.isHidden = false
	}

	func hide() {
		self.isHidden = true
	}
}
