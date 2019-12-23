//
//  PinListViewController.swift
//  MapSmartObjects
//
//  Created by Максим Шалашников on 17.12.2019.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import UIKit

protocol IPinListViewController
{
	func updateTableView()
}

final class PinListViewController: UIViewController
{
	private let pinTableView = UITableView()
	private let presenter: IPinListPresenter

	init(presenter: IPinListPresenter) {
		self.presenter = presenter
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.addSubview(pinTableView)
		pinTableView.dataSource = self
		pinTableView.delegate = self
		configureViews()
		setConstraints()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		presenter.setupView()
	}

	private func configureViews() {
		title = "My Pins"
		pinTableView.register(PinListCell.self, forCellReuseIdentifier: PinListCell.cellID)
		navigationItem.leftBarButtonItem = editButtonItem
		pinTableView.tableFooterView = UIView()
	}

	private func setConstraints() {
		pinTableView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			pinTableView.topAnchor.constraint(equalTo: view.topAnchor),
			pinTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			pinTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			pinTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
		])
	}

	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		pinTableView.isEditing
			? pinTableView.setEditing(false, animated: true)
			: pinTableView.setEditing(true, animated: true)
		editButtonItem.title = isEditing ? "Done" : "Edit"
	}
}

extension PinListViewController: UITableViewDataSource
{
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return  presenter.getSmartObjectsCount()
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: PinListCell.cellID, for: indexPath) as? PinListCell
			else { return UITableViewCell() }
		let smartObject = presenter.getSmartObject(at: indexPath.row)
		cell.titleLabel.text = smartObject.name
		cell.descriptionLabel.text = smartObject.address
		return cell
	}

	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}

	func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
		return .delete
	}

	func tableView(_ tableView: UITableView,
				   commit editingStyle: UITableViewCell.EditingStyle,
				   forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			presenter.removeSmartObject(at: indexPath.row)
			tableView.deleteRows(at: [indexPath], with: .automatic)
		}
	}
}

extension PinListViewController: UITableViewDelegate
{
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		presenter.showSmartObject(at: indexPath.row)
	}
}

extension PinListViewController: IPinListViewController
{
	func updateTableView() {
		pinTableView.reloadData()
	}
}
