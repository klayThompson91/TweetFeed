//
//  TweetMessageView.swift
//  TweetFeed
//
//  Created by Abhay Curam on 4/15/18.
//  Copyright © 2018 Tweeter. All rights reserved.
//

import Foundation
import UIKit

public class TweetMessageView: UIView {
    
    public let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    public let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1.0)
        return label
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews([messageLabel, subtitleLabel])
        setupConstraints()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        UIView.disableAutoresize(forViews: [messageLabel, subtitleLabel])
        let viewConstraints = [
            messageLabel.topAnchor.constraint(equalTo: self.topAnchor),
            messageLabel.leftAnchor.constraint(equalTo: self.leftAnchor),
            messageLabel.rightAnchor.constraint(equalTo: self.rightAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 5),
            subtitleLabel.leftAnchor.constraint(equalTo: self.leftAnchor),
            subtitleLabel.rightAnchor.constraint(equalTo: self.rightAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(viewConstraints)
    }
}
