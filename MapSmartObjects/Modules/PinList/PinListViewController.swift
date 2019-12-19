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
}

final class PinListViewController: UIViewController
{
	private let pinTableView = UITableView()
	private var pins = [AnyObject]()
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
		view.backgroundColor = .white
		pinTableView.dataSource = self
		setConstraints()
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
}

extension PinListViewController: UITableViewDataSource
{
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return pins.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: PinListCell.cellID) as? PinListCell
		else { return UITableViewCell() }
		//реализация ячейки
		return cell
	}
}

extension PinListViewController: IPinListViewController
{
}
