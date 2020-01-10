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
	private let searchController = UISearchController(searchResultsController: nil)
	private var filtredPins = [SmartObject]()
	private var searchBarIsEmpty: Bool {
		guard let text = searchController.searchBar.text else { return false }
		return text.isEmpty
	}
	private var isFiltering: Bool {
		return searchController.isActive && searchBarIsEmpty == false
	}

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
		setupSearchController()
		configureViews()
		setConstraints()
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		pinTableView.reloadData()
		checkEditMode()
	}

	private func setupSearchController() {
		searchController.searchResultsUpdater = self
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.searchBar.placeholder = "Enter pin name"
		navigationItem.hidesSearchBarWhenScrolling = false
		navigationItem.searchController = self.searchController
		definesPresentationContext = true
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
		editButtonItem.title = pinTableView.isEditing ? "Done" : "Edit"
	}

	func disableEdit() {
		navigationItem.leftBarButtonItem?.title = "Edit"
		navigationItem.leftBarButtonItem?.isEnabled = false
		pinTableView.isEditing = false
	}

	func enableEdit() {
		navigationItem.leftBarButtonItem?.isEnabled = true
	}

	func checkEditMode() {
		if pinTableView.visibleCells.count == 0 {
			disableEdit()
		}
		else {
			enableEdit()
		}
	}
}

extension PinListViewController: UITableViewDataSource
{
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return isFiltering ? filtredPins.count : presenter.getSmartObjectsCount()
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: PinListCell.cellID, for: indexPath) as? PinListCell
			else { return UITableViewCell() }
		let smartObject = isFiltering ? filtredPins[indexPath.row] : presenter.getSmartObject(at: indexPath.row)
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
			let smartObject = isFiltering ? filtredPins[indexPath.row] : presenter.getSmartObject(at: indexPath.row)
			presenter.removeSmartObject(at: presenter.getSmartObjects().firstIndex(of: smartObject) ?? 0)
			if isFiltering {
				filtredPins.remove(at: indexPath.row)
			}
			tableView.deleteRows(at: [indexPath], with: .automatic)
			checkEditMode()
		}
	}
}

extension PinListViewController: UITableViewDelegate
{
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		presenter.showDetails(at: indexPath.row)
	}
}

extension PinListViewController: IPinListViewController
{
	func updateTableView() {
		pinTableView.reloadData()
	}
}

extension PinListViewController: UISearchResultsUpdating
{
	func updateSearchResults(for searchController: UISearchController) {
		filterContentForSearchText(searchController.searchBar.text ?? "")
	}

	private func filterContentForSearchText(_ searchText: String) {
		filtredPins = presenter.getSmartObjects().filter { (smartObject: SmartObject) -> Bool in
			return smartObject.name.lowercased().contains(searchText.lowercased())
		}
		pinTableView.reloadData()
	}
}
