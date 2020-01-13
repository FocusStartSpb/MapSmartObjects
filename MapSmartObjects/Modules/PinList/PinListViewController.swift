//
//  PinListViewController.swift
//  MapSmartObjects
//
//  Created by Максим Шалашников on 17.12.2019.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import MapKit

protocol IPinListViewController
{
	func updateTableView()
}

final class PinListViewController: UIViewController
{
	private let pinTableView = UITableView()
	private let presenter: IPinListPresenter
	private let searchController = UISearchController(searchResultsController: nil)
	private let backgroundImage = UIImageView()
	private let backgroundImageLabel = UILabel()
	private let emptyImage = UIImage(named: "emptyIcon")
	private let searchImage = UIImage(named: "searchIcon")

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
		view.addSubview(backgroundImage)
		view.addSubview(backgroundImageLabel)
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
		searchController.searchBar.searchTextField.backgroundColor = Colors.complementary
		searchController.searchBar.searchTextField.borderStyle = .none
		searchController.searchBar.searchTextField.layer.cornerRadius = 10
		searchController.searchBar.searchTextField.clipsToBounds = true

		UITextField.appearance().tintColor = Colors.carriage
		searchController.searchResultsUpdater = self
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.searchBar.placeholder = "Enter pin name"
		navigationItem.hidesSearchBarWhenScrolling = false
		navigationItem.searchController = searchController
		definesPresentationContext = true
	}
	private func configureViews() {
		title = "My Pins"
		navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
		navigationController?.navigationBar.barTintColor = Colors.mainStyle
		navigationController?.navigationBar.tintColor = Colors.complementary
		backgroundImage.image = UIImage(named: "emptyIcon")
		backgroundImageLabel.numberOfLines = 0
		backgroundImageLabel.textAlignment = .center
		backgroundImageLabel.textColor = Colors.mainStyle
		pinTableView.register(PinListCell.self, forCellReuseIdentifier: PinListCell.cellID)
		navigationItem.leftBarButtonItem = editButtonItem
		pinTableView.tableFooterView = UIView()
	}

	private func setConstraints() {
		pinTableView.translatesAutoresizingMaskIntoConstraints = false
		backgroundImage.translatesAutoresizingMaskIntoConstraints = false
		backgroundImageLabel.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			pinTableView.topAnchor.constraint(equalTo: view.topAnchor),
			pinTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			pinTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			pinTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

			backgroundImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			backgroundImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			backgroundImage.widthAnchor.constraint(equalToConstant: backgroundImage.image?.size.width ?? 0),
			backgroundImage.heightAnchor.constraint(equalToConstant: backgroundImage.image?.size.height ?? 0),

			backgroundImageLabel.leadingAnchor.constraint(equalTo: backgroundImage.leadingAnchor, constant: 16),
			backgroundImageLabel.trailingAnchor.constraint(equalTo: backgroundImage.trailingAnchor, constant: -16),
			backgroundImageLabel.topAnchor.constraint(equalTo: backgroundImage.bottomAnchor),
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
		backgroundImage.isHidden = false
		backgroundImageLabel.isHidden = false
	}

	func enableEdit() {
		navigationItem.leftBarButtonItem?.isEnabled = true
		backgroundImage.isHidden = true
		backgroundImageLabel.isHidden = true
	}

	func checkEditMode() {
		backgroundImage.image = isFiltering ? searchImage : emptyImage
		if isFiltering == false {
			backgroundImageLabel.text = "The list is empty now. Add new pin on the map!"
		}
		pinTableView.visibleCells.isEmpty ? disableEdit() : enableEdit()
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
			CLLocationManager().stopMonitoring(for: smartObject.toCircularRegion())
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
		guard let text = searchController.searchBar.text else { return }
		backgroundImageLabel.text = "Nothing found on query: \(text)"
		filterContentForSearchText(text)
	}

	private func filterContentForSearchText(_ searchText: String) {
		filtredPins = presenter.getSmartObjects().filter { (smartObject: SmartObject) -> Bool in
			return smartObject.name.lowercased().contains(searchText.lowercased())
		}
		pinTableView.reloadData()
		checkEditMode()
	}
}
