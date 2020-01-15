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
	func checkEditMode()
}

final class PinListViewController: UIViewController
{
	private let pinTableView = UITableView()
	private let presenter: IPinListPresenter
	private let searchController = UISearchController(searchResultsController: nil)
	private let backgroundImage = UIImageView()
	private let backgroundImageLabel = UILabel()
	private let emptyImage = UIImage(named: Constants.emptyImageName)
	private let searchImage = UIImage(named: Constants.searchImageName)

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
		if let searchTextField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
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
		}
		UITextField.appearance().tintColor = Colors.carriage
		searchController.searchResultsUpdater = self
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.searchBar.placeholder = "Enter pin name"
		navigationItem.hidesSearchBarWhenScrolling = false
		navigationItem.searchController = searchController
		definesPresentationContext = true
	}
	private func configureViews() {
		title = Constants.pinsTitle
		navigationController?.navigationBar.barStyle = .black
		navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
		navigationController?.navigationBar.barTintColor = Colors.mainStyle
		navigationController?.navigationBar.tintColor = Colors.complementary
		backgroundImage.image = UIImage(named: Constants.emptyImageName)
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
		editButtonItem.title = pinTableView.isEditing ? Constants.doneTitle : Constants.editTitle
	}

	func disableEdit() {
		navigationItem.leftBarButtonItem?.title = Constants.editTitle
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
			backgroundImageLabel.text = Constants.emptyListText
		}
		pinTableView.visibleCells.isEmpty ? disableEdit() : enableEdit()
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
		backgroundImageLabel.text = "\(Constants.nothingOnQueryText) \(text)"
		presenter.filterContentForSearchText(text)
	}
}
