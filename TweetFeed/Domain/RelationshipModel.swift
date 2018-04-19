//
//  RelationshipModel.swift
//  TweetFeed
//
//  Created by Abhay Curam on 4/17/18.
//  Copyright © 2018 Tweeter. All rights reserved.
//

import Foundation

public class RelationshipModel {
    
    public var isFollowing: Bool = false
    public var followRequestSent: Bool = false
    public var followedBy: Bool = false
    public var blocked: Bool = false
    
    private let kFollowingKey = "following"
    private let kFollowRequestSentKey = "following_requested"
    private let kFollowedByKey = "followed_by"
    private let kBlockedKey = "blocking"
    
    public convenience init() {
        self.init([String]())
    }
    
    public init(_ relationships: [String]) {
        for relation in relationships {
            switch relation {
            case kFollowingKey:
                isFollowing = true
            case kFollowRequestSentKey:
                followRequestSent = true
            case kFollowedByKey:
                followedBy = true
            case kBlockedKey:
                blocked = true
            default:
                continue
            }
        }
    }
    
}
