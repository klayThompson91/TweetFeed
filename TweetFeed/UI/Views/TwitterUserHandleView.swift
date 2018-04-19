//
//  TwitterUserHandleView.swift
//  TweetFeed
//
//  Created by Abhay Curam on 4/15/18.
//  Copyright © 2018 Tweeter. All rights reserved.
//

import Foundation
import UIKit

public class TwitterUserHandleView: UIView {
    
    public var profileImageUri: String? = nil {
        didSet {
            if let currentRequest = currentImageRequest {
                ImageRequestManager.shared.cancelRequest(currentRequest)
                currentImageRequest = nil
            }
            if let imageUri = profileImageUri {
                let newImageRequest = ImageRequest(imageUri, { [weak self] (image) in
                    if let strongSelf = self {
                        if let image = image {
                            strongSelf.profileImageView.image = image
                        }
                        strongSelf.currentImageRequest = nil
                    }
                })
                ImageRequestManager.shared.addRequest(newImageRequest)
                currentImageRequest = newImageRequest
            }
        }
    }
    
    public let profileImageView: CircularImageView = {
        let imageView = CircularImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = TweetFeedImages.twitterLogoIcon
        return imageView
    }()
    
    //name
    public let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor.black
        return label
    }()
    
    //screen_name
    public let userHandleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1.0)
        return label
    }()
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: kImageDiameter)
    }
    
    private var currentImageRequest: ImageRequest? = nil
    
    private let kImageDiameter: CGFloat = 48
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews([profileImageView, userNameLabel, userHandleLabel])
        setupConstraints()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        UIView.disableAutoresize(forViews: [profileImageView, userNameLabel, userHandleLabel])
        let viewConstraints = [
            profileImageView.topAnchor.constraint(equalTo: self.topAnchor),
            profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor),
            profileImageView.heightAnchor.constraint(equalToConstant: kImageDiameter),
            profileImageView.widthAnchor.constraint(equalToConstant: kImageDiameter),
            userNameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 10),
            userNameLabel.topAnchor.constraint(equalTo: self.topAnchor),
            userNameLabel.rightAnchor.constraint(equalTo: self.rightAnchor),
            userHandleLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 10),
            userHandleLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor),
            userHandleLabel.rightAnchor.constraint(equalTo: self.rightAnchor)
        ]
        
        NSLayoutConstraint.activate(viewConstraints)
    }
}
