//
//  TweetFeedCardView.swift
//  TweetFeed
//
//  Created by Abhay Curam on 4/15/18.
//  Copyright © 2018 Tweeter. All rights reserved.
//

import Foundation
import UIKit

public class TweetFeedCardView: CardView {
    
    public let feedView = TweetFeedContainerView(frame: .zero)
    
    public var useAutoLayout: Bool = false {
        didSet {
            if useAutoLayout {
                feedView.useAutoLayout = true
                setupConstraints()
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(feedView)
        setupConstraints()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        feedView.translatesAutoresizingMaskIntoConstraints = false
        let viewConstraints = [
            feedView.topAnchor.constraint(equalTo: self.topAnchor, constant: 15),
            feedView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -15),
            feedView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 15),
            feedView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -15)
        ]
        NSLayoutConstraint.activate(viewConstraints)
    }
    
}

public class TweetFeedContainerView: UIView {
    
    public let userHandleView = TwitterUserHandleView(frame: .zero)
    public let messageView = TweetMessageView(frame: .zero)
    
    private var messageViewBottomConstraint = NSLayoutConstraint()
    
    public var useAutoLayout: Bool = false {
        didSet {
            if useAutoLayout {
                userHandleView.useAutoLayout = true
                messageView.useAutoLayout = true
                setupConstraints()
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews([userHandleView, messageView])
        //setupConstraints()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if !useAutoLayout {
            let containerRect = bounds
            let userHandleViewHeight: CGFloat = 48
            let kPadding: CGFloat = 15
            let verticalOffset = userHandleViewHeight + kPadding
            userHandleView.frame = CGRect(x: 0, y: 0, width: containerRect.size.width, height: userHandleViewHeight)
            messageView.frame = CGRect(x: 0, y: verticalOffset, width: containerRect.size.width, height: containerRect.size.height - verticalOffset)
        }
    }
    
    private func setupConstraints() {
        UIView.disableAutoresize(forViews: [userHandleView, messageView])
        let viewConstraints = [
            userHandleView.topAnchor.constraint(equalTo: self.topAnchor),
            userHandleView.leftAnchor.constraint(equalTo: self.leftAnchor),
            userHandleView.rightAnchor.constraint(equalTo: self.rightAnchor),
            messageView.topAnchor.constraint(equalTo: userHandleView.bottomAnchor, constant: 15),
            messageView.leftAnchor.constraint(equalTo: self.leftAnchor),
            messageView.rightAnchor.constraint(equalTo: self.rightAnchor),
            messageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ]
        NSLayoutConstraint.activate(viewConstraints)
    }
}
