//
//  UserSearchViewController.swift
//  TweetFeed
//
//  Created by Abhay Curam on 4/17/18.
//  Copyright © 2018 Tweeter. All rights reserved.
//

import Foundation
import UIKit

public class UserSearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {
    
    private let tableView: UITableView = {
        var tableView = UITableView(frame: .zero, style: .grouped)
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 40
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundColor = TweetFeedStyle.tableViewBackgroundColor
        tableView.register(TwitterUserHandleTableViewCell.self, forCellReuseIdentifier: CellReuseIdentifiers.userHandleTableViewCell)
        return tableView
    }()
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var resultsFeed = [UserModel]()
    private let searchService = UserSearchService()
    private let relationshipService = RelationshipService()
    private let debouncerThrottle = Debouncer(delay: 0.25)
    private var dismissKeyboardTapGestureRecognizer = UITapGestureRecognizer()
    private let kSearchBarText = "Search Twitter"
    private let kPageTitle = "Search"
    
    // MARK: - View Controller Layout and Constraint Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        configureSearchController()
        configureSearchBar()
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        TweetFeedStyle.styleNavigationBar(navigationController?.navigationBar)
        navigationItem.title = kPageTitle
        dismissKeyboardTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
        dismissKeyboardTapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissKeyboardTapGestureRecognizer)
        setupConstraints()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = false
        }
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = true
        }
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
        return resultsFeed.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = TwitterUserHandleTableViewCell(style: .default, reuseIdentifier: CellReuseIdentifiers.userHandleTableViewCell)
        if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: CellReuseIdentifiers.userHandleTableViewCell) as? TwitterUserHandleTableViewCell {
            cell = dequeuedCell
        }
        
        let currentResult = resultsFeed[indexPath.row]
        cell.userHandleView.userNameLabel.text = currentResult.name
        cell.userHandleView.userHandleLabel.text = currentResult.twitterHandle
        cell.userHandleView.profileImageUri = currentResult.profileImageUri
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let userId = resultsFeed[indexPath.row].id {
            let selectedUser = resultsFeed[indexPath.row]
            relationshipService.relationshipWithUsers([userId]) { (relations, error) in
                if let user = relations.first, error == nil {
                    user.bio = selectedUser.bio
                    user.location = selectedUser.location
                    user.profileImageUri = selectedUser.profileImageUri
                    self.navigationController?.pushViewController(UserProfileViewController(user), animated: true)
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - UISearchControllerDelegate
    public func updateSearchResults(for searchController: UISearchController) {
        if let searchString = searchController.searchBar.text, !searchString.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty {
            debouncerThrottle.perform {
                self.searchService.usersForQuery(searchString, numPages: 1, completionHandler: { (searchResults, error) in
                    if error == nil {
                        self.resultsFeed = searchResults
                        self.tableView.reloadData()
                    }
                })
            }
        } else {
            resultsFeed.removeAll()
            tableView.reloadData()
        }
    }
    
    // MARK: - Private Helpers
    @objc private func dismissKeyboard(_ tapGestureRecognizer: UITapGestureRecognizer) {
        searchController.searchBar.resignFirstResponder()
    }
    
    private func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = kSearchBarText
        searchController.searchBar.barStyle = .black
        navigationItem.searchController = searchController
        searchController.searchBar.tintColor = UIColor.black
        definesPresentationContext = true
    }
    
    private func configureSearchBar() {
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: UIColor.black]
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).attributedPlaceholder = NSAttributedString(string: kSearchBarText, attributes: [NSAttributedStringKey.foregroundColor: UIColor.black])
        if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            textfield.textColor = UIColor.blue
            if let backgroundview = textfield.subviews.first {
                backgroundview.backgroundColor = UIColor.white
                backgroundview.layer.cornerRadius = 10;
                backgroundview.clipsToBounds = true;
            }
        }
    }
}
