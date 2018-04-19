//
//  TweetFeedTableViewController.swift
//  TweetFeed
//
//  Created by Abhay Curam on 4/15/18.
//  Copyright © 2018 Tweeter. All rights reserved.
//

import Foundation
import UIKit

public class TweetFeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let kPageTitle = "Feed"
    private let kChunkSize = 25
    private let tweetTimelineService = TweetTimelineService()
    private let relationshipService = RelationshipService()
    private var mainLoadingView = UIActivityIndicatorView()
    private var initialContentOffset: CGFloat?
    
    private var fetchingRecentTweets: Bool = false
    private var fetchingOldTweets: Bool = false
    private var reloadFeed: Bool = false
    
    private var tweetFeed = BoundedDequeueArray<TweetModel>(count: 200)
    private var recentTweetsDebouncerThrottle = Debouncer(delay: 0.25)
    private var pastTweetsDebouncerThrottle = Debouncer(delay: 0.10)
    
    private let tableView: UITableView = {
        var tweetFeedTableView = UITableView(frame: .zero, style: .grouped)
        tweetFeedTableView.separatorStyle = .none
        tweetFeedTableView.backgroundColor = TweetFeedStyle.tableViewBackgroundColor
        tweetFeedTableView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: CGFloat.leastNormalMagnitude))
        tweetFeedTableView.sectionFooterHeight = 5.0
        tweetFeedTableView.sectionHeaderHeight = 5.0
        tweetFeedTableView.estimatedRowHeight = 200
        tweetFeedTableView.rowHeight = UITableViewAutomaticDimension
        tweetFeedTableView.register(TweetFeedCardTableViewCell.self, forCellReuseIdentifier: CellReuseIdentifiers.tweetFeedCardCell)
        tweetFeedTableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: CellReuseIdentifiers.blankHeaderFooterCell)
        return tweetFeedTableView
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        view.backgroundColor = TweetFeedStyle.tableViewBackgroundColor
        view.addSubview(tableView)
        view.addSubview(mainLoadingView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        TweetFeedStyle.styleNavigationBar(navigationController?.navigationBar)
        navigationItem.title = kPageTitle
        setupConstraints()
        
        tableView.isHidden = true
        configureLoadingView(&mainLoadingView)
        mainLoadingView.startAnimating()
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserSignOut(_:)), name: NotificationConstants.userSignedOut, object: nil)
        loadInitialTweets()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        //If someone logs out and logs in to a different account which is sort of edge case
        //we are still holding on to the old feed in memory. In this case we need to wipe the
        //feed from memory and repopulate. This isn't very expensive since our feed is bounded
        //at a max of 200 elements at any given time.
        if reloadFeed {
            tweetFeed.removeAll()
            tableView.reloadData()
            loadInitialTweets()
            reloadFeed = false
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
    
    // MARK: UITableViewDataSource + UITableViewDelegate
    public func numberOfSections(in tableView: UITableView) -> Int {
        return tweetFeed.items.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = TweetFeedCardTableViewCell(style: .default, reuseIdentifier: CellReuseIdentifiers.tweetFeedCardCell)
        if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: CellReuseIdentifiers.tweetFeedCardCell) as? TweetFeedCardTableViewCell {
            cell = dequeuedCell
        }
        
        let currentTweet = tweetFeed.items[indexPath.section]
        cell.feedView.userHandleView.userHandleLabel.text = currentTweet.user?.twitterHandle ?? ""
        cell.feedView.userHandleView.userNameLabel.text = currentTweet.user?.name ?? ""
        cell.feedView.userHandleView.profileImageUri = currentTweet.user?.profileImageUri
        cell.feedView.messageView.messageLabel.text = currentTweet.text ?? ""
        cell.feedView.messageView.subtitleLabel.text = currentTweet.date ?? ""
        cell.selectionStyle = .none
        return cell
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var footer = UITableViewHeaderFooterView(reuseIdentifier: CellReuseIdentifiers.blankHeaderFooterCell)
        if let dequeuedFooter = tableView.dequeueReusableHeaderFooterView(withIdentifier: CellReuseIdentifiers.blankHeaderFooterCell) {
            footer = dequeuedFooter
        }
        return footer
    }
    
    // MARK: ScrollViewDelegate
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentYoffset = scrollView.contentOffset.y
        if let initialContentOffset = initialContentOffset {
            if contentYoffset < initialContentOffset {
                if !fetchingRecentTweets {
                    loadMostRecentTweets()
                }
            }
            let distanceFromBottom = scrollView.contentSize.height - contentYoffset
            let height = scrollView.frame.size.height
            if distanceFromBottom < height {
                if !fetchingOldTweets {
                    loadPastTweets()
                }
            }
        } else {
            initialContentOffset = contentYoffset
        }
    }
    
    // MARK: Private Helpers
    private func loadInitialTweets() {
        self.tweetTimelineService.fetchTweets(count: kChunkSize * 2) { (tweets, error) in
            self.mainLoadingView.stopAnimating()
            self.tweetFeed.insertFront(tweets)
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
    
    private func loadMostRecentTweets() {
        if let sinceId = tweetFeed.items.first?.id {
            fetchingRecentTweets = true
            recentTweetsDebouncerThrottle.perform {
                self.tweetTimelineService.fetchTweetsSince(id: sinceId, count: self.kChunkSize, completionHandler: { (tweets, error) in
                    if error == nil && tweets.count > 0 {
                        self.tweetFeed.insertFront(tweets)
                        self.tableView.reloadData()
                    }
                    self.fetchingRecentTweets = false
                })
            }
        }
    }
    
    private func loadPastTweets() {
        if let maxId = tweetFeed.items.last?.id {
            fetchingOldTweets = true
            pastTweetsDebouncerThrottle.perform {
                self.tweetTimelineService.fetchTweetsBefore(id: maxId, count: self.kChunkSize, completionHandler: { (tweets, error) in
                    if error == nil && tweets.count > 0 {
                        self.tweetFeed.insertBack(tweets)
                        self.tableView.reloadData()
                    }
                    self.fetchingOldTweets = false
                })
            }
        }
    }
    
    private func configureLoadingView(_ view: inout UIActivityIndicatorView) {
        view = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        view.hidesWhenStopped = true
        view.center = self.view.center
    }
    
    @objc private func handleUserSignOut(_ notification: Notification) {
        reloadFeed = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
