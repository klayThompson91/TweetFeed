//
//  TwitterUserHandleTableViewCell.swift
//  TweetFeed
//
//  Created by Abhay Curam on 4/17/18.
//  Copyright © 2018 Tweeter. All rights reserved.
//

import Foundation
import UIKit

public class TwitterUserHandleTableViewCell: UITableViewCell {
    
    public let userHandleView = TwitterUserHandleView(frame: .zero)
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userHandleView)
        setupConstraints()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        UIView.disableAutoresize(forViews: [userHandleView])
        let viewConstraints = [
            userHandleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            userHandleView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 15),
            userHandleView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -15),
            userHandleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
        ]
        NSLayoutConstraint.activate(viewConstraints)
    }

}
