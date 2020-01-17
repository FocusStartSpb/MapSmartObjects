//
//  PinListViewController.swift
//  MapSmartObjects
//
//  Created by Максим Шалашников on 17.12.2019.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import MapKit

final class PinListViewController: UIViewController
{
	private let presenter: IPinListPresenter
	private let pinListView = PinListView()
	private let searchController = UISearchController()

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
		fatalError(Constants.fatalError)
	}

	override func loadView() {
		self.view = pinListView
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		pinListView.pinTableView.dataSource = self
		pinListView.pinTableView.delegate = self
		setupSearchController()
		setupNavigationBar()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		pinListView.pinTableView.reloadData()
		checkEditMode()
	}

	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		pinListView.pinTableView.isEditing
			? pinListView.pinTableView.setEditing(false, animated: true)
			: pinListView.pinTableView.setEditing(true, animated: true)
		editButtonItem.title = pinListView.pinTableView.isEditing ? Constants.doneTitle : Constants.editTitle
	}

	private func setupSearchController() {
		let searchTextField = searchController.searchBar.searchTextField
		searchTextField.backgroundColor = Colors.complementary
		searchTextField.borderStyle = .none
		searchTextField.layer.cornerRadius = 10
		searchTextField.clipsToBounds = true
		UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])
			.defaultTextAttributes = [NSAttributedString.Key.foregroundColor: Colors.carriage]
		if let glassIconView = searchTextField.leftView as? UIImageView {
			glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
			glassIconView.tintColor = Colors.carriage
		}
		UITextField.appearance().tintColor = Colors.carriage
		searchController.searchResultsUpdater = self
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.searchBar.placeholder = Constants.searchPlaceholderName
		navigationItem.hidesSearchBarWhenScrolling = false
		navigationItem.searchController = searchController
		definesPresentationContext = true
	}

	private func setupNavigationBar() {
		title = Constants.pinsTitle
		navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
		navigationController?.navigationBar.barTintColor = Colors.mainStyle
		navigationController?.navigationBar.tintColor = Colors.complementary
		navigationItem.leftBarButtonItem = editButtonItem
	}

	private func disableEdit() {
		navigationItem.leftBarButtonItem?.title = Constants.editTitle
		navigationItem.leftBarButtonItem?.isEnabled = false
		pinListView.pinTableView.isEditing = false
		pinListView.backgroundImage.isHidden = false
		pinListView.backgroundImageLabel.isHidden = false
	}

	private func enableEdit() {
		navigationItem.leftBarButtonItem?.isEnabled = true
		pinListView.backgroundImage.isHidden = true
		pinListView.backgroundImageLabel.isHidden = true
	}
}

extension PinListViewController: UITableViewDataSource
{
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return presenter.getSmartObjectsCount(with: isFiltering)
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: PinListCell.cellID, for: indexPath) as? PinListCell
			else { return UITableViewCell() }
		let smartObject = presenter.getSmartObject(at: indexPath.row, with: isFiltering)
		cell.titleLabel.text = smartObject.name
		cell.descriptionLabel.text = smartObject.address
		return cell
	}

	func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
		return .delete
	}

	func tableView(_ tableView: UITableView,
				   commit editingStyle: UITableViewCell.EditingStyle,
				   forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			let smartObject = presenter.getSmartObject(at: indexPath.row, with: isFiltering)
			presenter.removeSmartObject(at: indexPath.row, with: isFiltering)
			CLLocationManager().stopMonitoring(for: smartObject.toCircularRegion())
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

extension PinListViewController
{
	func updateTableView() {
		pinListView.pinTableView.reloadData()
	}

	func checkEditMode() {
		pinListView.backgroundImage.image = isFiltering ? pinListView.searchImage : pinListView.emptyImage
		if isFiltering == false {
			pinListView.backgroundImageLabel.text = Constants.emptyListText
		}
		pinListView.pinTableView.visibleCells.isEmpty ? disableEdit() : enableEdit()
	}
}

extension PinListViewController: UISearchResultsUpdating
{
	func updateSearchResults(for searchController: UISearchController) {
		guard let text = searchController.searchBar.text else { return }
		backgroundImageLabel.text = Constants.nothingOnQueryText + text
		presenter.filterContentForSearchText(text)
	}
}
