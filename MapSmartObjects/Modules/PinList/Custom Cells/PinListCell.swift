//
//  PinListCell.swift
//  MapSmartObjects
//
//  Created by Igor Shelginskiy on 12/18/19.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//
import Foundation
import UIKit

final class PinListCell: UITableViewCell
{
	// MARK: Private properties
	var titleLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.boldSystemFont(ofSize: 16)
		label.textAlignment = .left
		return label
	}()
	var descriptionLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 14)
		label.textAlignment = .left
		return label
	}()
	static let cellID = "pin"

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
		contentView.addSubview(titleLabel)
		contentView.addSubview(descriptionLabel)
		accessoryType = .disclosureIndicator
	}

	// Name & Description labels constraints
	private func setConstraints() {
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
			titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
			titleLabel.trailingAnchor.constraint(equalToSystemSpacingAfter: contentView.trailingAnchor, multiplier: -10),

			descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
			descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
			descriptionLabel.trailingAnchor.constraint(equalToSystemSpacingAfter: contentView.trailingAnchor, multiplier: -10),
			descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16),
			])
	}
}
