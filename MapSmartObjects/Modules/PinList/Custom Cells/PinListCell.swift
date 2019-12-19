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
	private let titleLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.boldSystemFont(ofSize: 16)
		label.textAlignment = .left
		return label
	}()
	private let descriptionLabel: UILabel = {
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
		addSubview(titleLabel)
		addSubview(descriptionLabel)
		accessoryType = .disclosureIndicator
	}

	// Name & Description labels constraints
	private func setConstraints() {
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
			titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
			titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),

			descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
			descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
			descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
			descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: readableContentGuide.bottomAnchor, constant: -8),
			])
	}
}
