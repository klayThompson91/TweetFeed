//
//  TweetFeedCardCollectionViewCell.swift
//  TweetFeed
//
//  Created by Abhay Curam on 4/15/18.
//  Copyright © 2018 Tweeter. All rights reserved.
//

import Foundation
import UIKit

public class TweetFeedCardTableViewCell: CardTableViewCell {
    
    public let feedView = TweetFeedContainerView(frame: .zero)
    private let kInsetPadding: CGFloat = 15
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(feedView)
        //setupConstraints()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let contentRect = contentView.bounds
        let width = contentRect.width - (kInsetPadding * 2)
        let height = contentRect.height - (kInsetPadding * 2)
        feedView.frame = CGRect(x: kInsetPadding, y: kInsetPadding, width: width, height: height)
    }
    
    private func setupConstraints() {
        UIView.disableAutoresize(forViews: [feedView])
        let viewConstraints = [
            feedView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: kInsetPadding),
            feedView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: kInsetPadding),
            feedView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -kInsetPadding),
            feedView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -kInsetPadding),
        ]
        NSLayoutConstraint.activate(viewConstraints)
    }
}
