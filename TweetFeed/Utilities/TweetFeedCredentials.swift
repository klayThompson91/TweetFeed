//
//  TwitterCredentials.swift
//  TweetFeed
//
//  Created by Abhay Curam on 4/14/18.
//  Copyright © 2018 Tweeter. All rights reserved.
//

import Foundation

//Encapsulates information on the currently authenticated user's credentials.
//All sensitive data is stored in the keychain and retrieved from the keychain, nothing is stored in memory.
//
//Can be viewed as a proxy to the iOS Keychain with a streamlined credentials interface.
public class TweetFeedUserCredentials {
    
    private var keychainService = KeychainService()    
    
    public static var twitterHandle = ""
    
    public var credentials: AuthenticationCredentialsModel = AuthenticationCredentialsModel() {
        didSet {
            var keychainError: NSError?
            if let accessToken = credentials.oauthToken {
                let accessTokenKeychainItem = PasswordKeychainItem(password: accessToken, identifier: OAuthConstants.tokenKey)
                if keychainService.contains(accessTokenKeychainItem) {
                    keychainService.update(accessTokenKeychainItem, error: &keychainError)
                } else {
                    keychainService.add(accessTokenKeychainItem, error: &keychainError)
                }
            }
            if let accessTokenSecret = credentials.oauthTokenSecret {
                let accessTokenSecretKeychainItem = PasswordKeychainItem(password: accessTokenSecret, identifier: OAuthConstants.tokenSecretKey)
                if keychainService.contains(accessTokenSecretKeychainItem) {
                    keychainService.update(accessTokenSecretKeychainItem, error: &keychainError)
                } else {
                    keychainService.add(accessTokenSecretKeychainItem, error: &keychainError)
                }
            }
            if let oauthVerifier = credentials.oauthVerifier {
                let oauthVerifierKeychainItem = PasswordKeychainItem(password: oauthVerifier, identifier: OAuthConstants.verifierKey)
                if keychainService.contains(oauthVerifierKeychainItem) {
                    keychainService.update(oauthVerifierKeychainItem, error: &keychainError)
                } else {
                    keychainService.add(oauthVerifierKeychainItem, error: &keychainError)
                }
            }
            if let userId = credentials.userId {
                let userIdKeychainItem = PasswordKeychainItem(password: userId, identifier: OAuthConstants.userIdKey)
                if keychainService.contains(userIdKeychainItem) {
                    keychainService.update(userIdKeychainItem, error: &keychainError)
                } else {
                    keychainService.add(userIdKeychainItem, error: &keychainError)
                }
            }
            if let userTwitterHandle = credentials.userHandle {
                TweetFeedUserCredentials.twitterHandle = userTwitterHandle
            }
        }
    }
    
    // This is very insecure and should never be done in a production application.
    // The clientSecret should be stored in authentication gateway server and passed back via HTTPS
    // and transport layer security. The application can then safely store it in the keychain.
    // More on this in the README.md
    public func clientSecret() -> String {
        return "CrM2XMzIvWeNPYq43ElSHeefmMdbFodUH0ynOeKwaEmIw8wLdy"
    }
    
    public func accessToken() -> String {
        var keychainError: NSError?
        return keychainService.getStringValue(for: PasswordKeychainItem(password: "", identifier: OAuthConstants.tokenKey), error: &keychainError)
    }
    
    public func accessTokenSecret() -> String {
        var keychainError: NSError?
        return keychainService.getStringValue(for: PasswordKeychainItem(password: "", identifier: OAuthConstants.tokenSecretKey), error: &keychainError)
    }
    
    public func oauthVerifier() -> String {
        var keychainError: NSError?
        return keychainService.getStringValue(for: PasswordKeychainItem(password: "", identifier: OAuthConstants.verifierKey), error: &keychainError)
    }
    
    public func clearAppCredentials() {
        keychainService.clearAllKeychainItems()
        credentials = AuthenticationCredentialsModel()
    }
}
