//
//  AuthenticationCredentialsModel.swift
//  TweetFeed
//
//  Created by Abhay Curam on 4/14/18.
//  Copyright © 2018 Tweeter. All rights reserved.
//

import Foundation

//AuthenticationCredentialsModel encapsulates all of the current user's twitter
//account credentials information that are gathered from the initial authentication flow.
//
//Never store these credentials yourself, when you get a CredentialsModel simply set it on
//the TweetFeedUserCredentials object. TweetFeedUserCredentials will hold on to the credentials
//by setting them in the iOS Keychain. Subsequent credentials queries should be routed to
//TweetFeedUserCredentials after setting the credentials on it.
public class AuthenticationCredentialsModel {
    
    public private(set) var oauthToken: String? = nil
    public private(set) var oauthTokenSecret: String? = nil
    public private(set) var oauthVerifier: String? = nil
    public private(set) var redirectUriConfirmed: Bool = false
    public private(set) var userId: String? = nil
    public private(set) var userHandle: String? = nil
    
    private let kAmpersandChar = "&"
    private let kTrueValue = "true"
    private let kEqualChar = "="
    
    public convenience init(_ string: String) {
        self.init()
        let authParams = string.components(separatedBy: kAmpersandChar)
        for oauthParam in authParams {
            let oauthPair = oauthParam.components(separatedBy: kEqualChar)
            if let oauthKey = oauthPair.first {
                switch oauthKey {
                case OAuthConstants.tokenKey:
                    oauthToken = oauthPair.last
                case OAuthConstants.verifierKey:
                    oauthVerifier = oauthPair.last
                case OAuthConstants.tokenSecretKey:
                    oauthTokenSecret = oauthPair.last
                case OAuthConstants.callbackConfirmedKey:
                    redirectUriConfirmed = (oauthPair.last == kTrueValue)
                case OAuthConstants.userIdKey:
                    userId = oauthPair.last
                case OAuthConstants.userHandleKey:
                    userHandle = "@\(oauthPair.last ?? "")"
                default:
                    continue
                }
            }
        }
    }
    
}
