//
//  UserModel.swift
//  TweetFeed
//
//  Created by Abhay Curam on 4/17/18.
//  Copyright © 2018 Tweeter. All rights reserved.
//

import Foundation

public class UserModel {
    
    public var id: String?
    public var name: String?
    public var screenName: String?
    public var twitterHandle: String?
    public var bio: String?
    public var location: String?
    public var relationship: RelationshipModel?
    public var profileImageUri: String?
    
    private let kIdKey = "id_str"
    private let kNameKey = "name"
    private let kScreenNameKey = "screen_name"
    private let kConnectionsKey = "connections"
    private let kBioKey = "description"
    private let kLocationKey = "location"
    private let kProfileImageUrl = "profile_image_url_https"
    
    public convenience init() {
        self.init([String : Any]())
    }
    
    public init(_ dictionary: [String: Any]) {
        if let id = dictionary[kIdKey] as? String {
            self.id = id
        }
        if let name = dictionary[kNameKey] as? String {
            self.name = name
        }
        if let connections = dictionary[kConnectionsKey] as? [String] {
            self.relationship = RelationshipModel(connections)
        }
        if let screenName = dictionary[kScreenNameKey] as? String {
            self.screenName = screenName
            self.twitterHandle = "@\(screenName)"
        }
        if let bioDescription = dictionary[kBioKey] as? String {
            self.bio = bioDescription
        }
        if let location = dictionary[kLocationKey] as? String {
            self.location = location
        }
        if let profileImageUrl = dictionary[kProfileImageUrl] as? String {
            self.profileImageUri = profileImageUrl
        }
    }
    
}
