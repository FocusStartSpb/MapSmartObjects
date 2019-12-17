//
//  PinInfoCell.swift
//  MapSmartObjects
//
//  Created by Igor Shelginskiy on 12/17/19.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import Foundation
import UIKit

final class PinInfoCell: UITableViewCell
{
	// MARK: Private properties
	private let titleLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.boldSystemFont(ofSize: 16)
		label.textAlignment = .left
		label.numberOfLines = 0
		return label
	}()
	private let descriptionLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 14)
		label.textAlignment = .left
		label.numberOfLines = 0
		return label
	}()

	// MARK: Initialization
	override init(style: CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setup()
		setConstraints()
	}

	@available(*, unavailable)
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: Private methods
	private func setup() {
		addSubview(titleLabel)
		addSubview(descriptionLabel)
		accessoryType = .disclosureIndicator
	}

	private func setConstraints() {
		// Name label constraints
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.leadingAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
		titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
		titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30).isActive = true
		titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
		// Description label constraints
		descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
		descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2).isActive = true
		descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
		descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor,
												   constant: -30).isActive = true
		descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: readableContentGuide.bottomAnchor,
												 constant: -8).isActive = true
		let descriptionLabelBottomAnchor = NSLayoutConstraint(
			item: descriptionLabel,
			attribute: .bottom,
			relatedBy: .equal,
			toItem: self,
			attribute: .bottom,
			multiplier: 1,
			constant: -8)
		descriptionLabelBottomAnchor.priority = .defaultLow
		descriptionLabelBottomAnchor.isActive = true
	}
}
