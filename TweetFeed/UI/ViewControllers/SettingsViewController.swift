//
//  SettingsViewController.swift
//  TweetFeed
//
//  Created by Abhay Curam on 4/16/18.
//  Copyright © 2018 Tweeter. All rights reserved.
//

import Foundation
import UIKit

public class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let kPageTitle = "Settings"
    private let kUserSignOutText = "Sign Out"
    private let kAttentionTitle = "Attention"
    private let kMessageTitle = "Clear Safari website data in \"Settings\", \"Safari\", \"Clear History and Website Data\" to successfully sign in as another user."
    private let kOkText = "OK"
    
    private let tableView: UITableView = {
        var tableView = UITableView(frame: .zero, style: .grouped)
        tableView.separatorStyle = .none
        tableView.backgroundColor = TweetFeedStyle.tableViewBackgroundColor
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellReuseIdentifiers.standardTableViewCell)
        return tableView
    }()

    // MARK: - View Controller Layout and Constraint Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        TweetFeedStyle.styleNavigationBar(navigationController?.navigationBar)
        navigationItem.title = kPageTitle
        setupConstraints()
    }
    
    private func setupConstraints() {
        let viewConstraints = [
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ]
        NSLayoutConstraint.activate(viewConstraints)
    }
    
    // MARK: - UITableViewDelegate + DataSource
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: CellReuseIdentifiers.standardTableViewCell)
        cell.textLabel?.text = kUserSignOutText
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alertController = UIAlertController(title: kAttentionTitle, message:
            kMessageTitle, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: kOkText, style: .default, handler: { (action) in
            NotificationCenter.default.post(name: NotificationConstants.userSignedOut, object: nil)
        }))
        self.present(alertController, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
