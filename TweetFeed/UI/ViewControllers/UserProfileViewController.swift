//
//  RelationshipViewController.swift
//  TweetFeed
//
//  Created by Abhay Curam on 4/17/18.
//  Copyright © 2018 Tweeter. All rights reserved.
//

import Foundation
import UIKit

public class UserProfileViewController: UIViewController {
    
    private var user: UserModel
    private var relation: RelationshipModel
    private var relationshipActionButton = UIButton()
    private var blockStatusLabel = UILabel()
    
    private var profileView = TweetFeedCardView()
    
    private var relationshipIntent: RelationshipUpdateIntent = .follow
    private let relationshipService = RelationshipService()
    
    private let kBlockingUserText = "You are currently blocking this user"
    private let kFollowText = "Follow"
    private let kUnfollowText = "Unfollow"
    
    public init(_ user: UserModel) {
        self.user = user
        self.relation = user.relationship ?? RelationshipModel()
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Not Implemented")
    }
    
    // MARK: - ViewController layout + constraint cycle
    public override func viewDidLoad() {
        configureRelationshipActionButton()
        configureBlockedStatusLabel()
        configureProfileView()
        TweetFeedStyle.styleNavigationBar(navigationController?.navigationBar)
        navigationItem.title = user.twitterHandle
        view.backgroundColor = TweetFeedStyle.tableViewBackgroundColor
        view.addSubview(blockStatusLabel)
        view.addSubview(relationshipActionButton)
        view.addSubview(profileView)
        setupConstraints()
    }
    
    // MARK: - Private Helpers
    private func configureRelationshipActionButton() {
        relationshipActionButton.layer.cornerRadius = 20
        relationshipActionButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        relationshipActionButton.titleLabel?.textColor = UIColor.white
        if relation.isFollowing || relation.followRequestSent {
            relationshipActionButton.setTitle(kUnfollowText, for: .normal)
            relationshipActionButton.backgroundColor = UIColor.red
            relationshipIntent = .unfollow
        } else if !relation.isFollowing && !relation.followRequestSent && !relation.blocked {
            relationshipActionButton.setTitle(kFollowText, for: .normal)
            relationshipActionButton.backgroundColor = TweetFeedStyle.themeColor
            relationshipIntent = .follow
        }
        
        relationshipActionButton.adjustsImageWhenDisabled = true
        relationshipActionButton.isHidden = relation.blocked
        relationshipActionButton.addTarget(self, action: #selector(relationshipActionButtonTapped(_:)), for: .touchUpInside)
    }
    
    private func configureBlockedStatusLabel() {
        blockStatusLabel.numberOfLines = 0
        blockStatusLabel.lineBreakMode = .byWordWrapping
        blockStatusLabel.text = kBlockingUserText
        blockStatusLabel.isHidden = !relation.blocked
        blockStatusLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        blockStatusLabel.textColor = .red
    }
    
    private func configureProfileView() {
        profileView.feedView.userHandleView.userNameLabel.text = user.name
        profileView.feedView.userHandleView.userHandleLabel.text = user.twitterHandle
        profileView.feedView.messageView.messageLabel.text = user.bio
        profileView.feedView.messageView.subtitleLabel.text = user.location
        profileView.feedView.userHandleView.profileImageUri = user.profileImageUri
    }
    
    private func setupConstraints() {
        UIView.disableAutoresize(forViews: [blockStatusLabel, relationshipActionButton, profileView])
        var viewConstraints = [
            profileView.topAnchor.constraint(equalTo: view.topAnchor, constant: 15),
            profileView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15),
            profileView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15)
        ]
        if !relationshipActionButton.isHidden {
            let buttonConstraints = [
                relationshipActionButton.topAnchor.constraint(equalTo: profileView.bottomAnchor, constant: 20),
                relationshipActionButton.heightAnchor.constraint(equalToConstant: 40),
                relationshipActionButton.widthAnchor.constraint(equalToConstant: 120),
                relationshipActionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ]
            viewConstraints += buttonConstraints
        } else {
            let labelConstraints = [
                blockStatusLabel.topAnchor.constraint(equalTo: profileView.bottomAnchor, constant: 20),
                blockStatusLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
                blockStatusLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 20)
            ]
            viewConstraints += labelConstraints
        }
        
        NSLayoutConstraint.activate(viewConstraints)
    }
    
    @objc private func relationshipActionButtonTapped(_ sender: UIButton) {
        sender.backgroundColor = sender.backgroundColor?.withAlphaComponent(0.5)
        if let userId = user.id {
            relationshipService.updateRelationship(with: userId, intent: relationshipIntent) { (success, error) in
                if success && error == nil {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}
