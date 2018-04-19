//
//  OAuthConstants.swift
//  TweetFeed
//
//  Created by Abhay Curam on 4/14/18.
//  Copyright © 2018 Tweeter. All rights reserved.
//

import Foundation
import UIKit

public enum HTTPServiceErrors: Error {
    case unsuccessfulHTTPStatusCode
    case emptyResponseData
    case requestCreationFailed
    case responseContainedIncorrectMediaType
    case responseDeserializationFailed
}

public struct OAuthConstants {
    static let tokenKey = "oauth_token"
    static let tokenSecretKey = "oauth_token_secret"
    static let verifierKey = "oauth_verifier"
    static let callbackConfirmedKey = "oauth_callback_confirmed"
    static let consumerKey = "oauth_consumer_key"
    static let nonceKey = "oauth_nonce"
    static let signatureKey = "oauth_signature"
    static let signatureMethodKey = "oauth_signature_method"
    static let timeStampKey = "oauth_timestamp"
    static let versionKey = "oauth_version"
    static let signatureMethod = "HMAC-SHA1"
    static let version = "1.0"
    static let userHandleKey = "screen_name"
    static let userIdKey = "user_id"
}

public struct NotificationConstants {
    static let twitterAuthRedirect = NSNotification.Name(rawValue: "twitter_auth_redirect")
    static let userSignedOut = NSNotification.Name(rawValue: "user_signed_out")
}

public struct TweetFeedImages {
    static let twitterLogo = UIImage(named: "TwitterLogo")
    static let twitterLogoIcon = UIImage(named: "TwitterLogoIcon")
    static let userProfilePlaceholder = UIImage(named: "EmptyUserProfile")
    static let feedTabBarSelectedImage = UIImage(named: "FeedTabBarSelected")?.withRenderingMode(.alwaysOriginal)
    static let feedTabBarUnselectedImage = UIImage(named: "FeedTabBarUnselected")?.withRenderingMode(.alwaysOriginal)
    static let settingsTabBarSelectedImage = UIImage(named: "SettingsTabBarSelected")?.withRenderingMode(.alwaysOriginal)
    static let settingsTabBarUnselectedImage = UIImage(named: "SettingsTabBarUnselected")?.withRenderingMode(.alwaysOriginal)
    static let peopleSearchTabBarSelectedImage = UIImage(named: "PeopleSearchTabBarSelected")?.withRenderingMode(.alwaysOriginal)
    static let peopleSearchTabBarUnselectedImage = UIImage(named: "PeopleSearchTabBarUnselected")?.withRenderingMode(.alwaysOriginal)
}

public struct TweetFeedStyle {
    static let themeColor = UIColor(red: 3/255, green: 169/255, blue: 244/255, alpha: 1.0)
    static let tableViewBackgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1.0)
    
    static func styleNavigationBar(_ navigationBar: UINavigationBar?) {
        navigationBar?.isTranslucent = false
        navigationBar?.barTintColor = TweetFeedStyle.themeColor //#03a9f4
        navigationBar?.tintColor = UIColor.white
        navigationBar?.titleTextAttributes = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 18, weight: .semibold), NSAttributedStringKey.foregroundColor : UIColor.white]
    }
    
    static func styleTabBar(_ tabBar: UITabBar) {
        tabBar.isTranslucent = false
        tabBar.barTintColor = UIColor.white
    }
}

public struct CellReuseIdentifiers {
    static let tweetFeedCardCell = "TweetFeedCardTableViewCellIdentifier"
    static let standardTableViewCell = "TableViewCellIdentifier"
    static let blankHeaderFooterCell = "BlankHeaderFooterViewIdentifier"
    static let userHandleTableViewCell = "TwitterUserHandleTableViewCellIdentifier"
}
