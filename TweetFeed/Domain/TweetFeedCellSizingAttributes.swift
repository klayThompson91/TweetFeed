//
//  TweetFeedCellSizingAttributes.swift
//  TweetFeed
//
//  Created by Abhay Curam on 4/28/18.
//  Copyright © 2018 Tweeter. All rights reserved.
//

import Foundation
import UIKit

public struct TweetFeedCellSizingAttributes {
    
    var cellHeight: CGFloat = 0
    var userNameLabelHeight: CGFloat = 0
    var userHandleLabelHeight: CGFloat = 0
    var tweetLabelHeight: CGFloat = 0
    var tweetSubtitleLabelHeight: CGFloat = 0
    
    private let kUserHandleImageDiameter = 48
    
    public init(sizingCell: TweetFeedCardTableViewCell, width: CGFloat) {
        let boundingRect = CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude)
        sizingCell.feedView.messageView.messageLabel.frame = boundingRect
        sizingCell.feedView.messageView.messageLabel.sizeToFit()
        tweetLabelHeight = sizingCell.feedView.messageView.messageLabel.bounds.size.height
        
        sizingCell.feedView.messageView.subtitleLabel.frame = boundingRect
        sizingCell.feedView.messageView.subtitleLabel.sizeToFit()
        tweetSubtitleLabelHeight = sizingCell.feedView.messageView.subtitleLabel.bounds.size.height
        
        sizingCell.feedView.userHandleView.userNameLabel.frame = boundingRect
        sizingCell.feedView.userHandleView.userNameLabel.sizeToFit()
        userNameLabelHeight = sizingCell.feedView.userHandleView.userNameLabel.frame.size.height
        
        sizingCell.feedView.userHandleView.userHandleLabel.frame = boundingRect
        sizingCell.feedView.userHandleView.userHandleLabel.sizeToFit()
        userHandleLabelHeight = sizingCell.feedView.userHandleView.userHandleLabel.frame.size.height

        cellHeight = 48 + tweetLabelHeight + tweetSubtitleLabelHeight + 45
    }
    
}
