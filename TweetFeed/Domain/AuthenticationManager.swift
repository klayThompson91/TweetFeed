//
//  AuthenticationManager.swift
//  TweetFeed
//
//  Created by Abhay Curam on 4/14/18.
//  Copyright © 2018 Tweeter. All rights reserved.
//

import Foundation

public enum AuthenticationState {
    case notAuthenticating
    case retrieveRequestToken
    case authenticateWithTwitter
    case retrieveAccessToken
    case authenticationSucceeded
    case authenticationFailed
}

public protocol AuthenticationManagerDelegate: class {
    func launchBrowser(authenticationUrl: URL)
    func dismissBrowser()
    func authenticationDidSucceed()
    func authenticationFailed()
}

// AuthenticationManager manages the authentication flow with Twitter's OAuth API's.
// To drive an authentication session simply instantiate the manager, implement the necessary
// delegate methods and invoke authenticate()
public class AuthenticationManager {
    
    public weak var delegate: AuthenticationManagerDelegate?
    
    private let authenticationService: AuthenticationService
    private let appCredentials: TweetFeedUserCredentials
    private var authenticationState: AuthenticationState
    private let kTwitterAuthEndpoint = "https://api.twitter.com/oauth/authenticate"
    
    public init() {
        self.authenticationState = .notAuthenticating
        self.authenticationService = AuthenticationService()
        self.appCredentials = TweetFeedUserCredentials()
        NotificationCenter.default.addObserver(self, selector: #selector(handleTwitterAuthRedirect(_:)), name: NotificationConstants.twitterAuthRedirect, object: nil)
    }
    
    public func authenticate() {
        transitionToState(.retrieveRequestToken)
    }
    
    public func cancel() {
        appCredentials.clearAppCredentials()
        transitionToState(.notAuthenticating)
    }
    
    private func transitionToState(_ state: AuthenticationState) {
        authenticationState = state
        handleState(newState: authenticationState)
    }
    
    private func handleState(newState: AuthenticationState) {
        switch newState {
        case .retrieveRequestToken:
            authenticationService.fetchRequestToken(completionHandler: { [unowned self] (authenticationModel, error) in
                if error == nil, let authenticationModel = authenticationModel, authenticationModel.redirectUriConfirmed {
                    self.appCredentials.credentials = authenticationModel
                    self.transitionToState(.authenticateWithTwitter)
                } else {
                    self.transitionToState(.authenticationFailed)
                }
            })
        case .authenticateWithTwitter:
            if let twitterAuthRequest = self.authenticationService.twitterAuthenticationRequest(), let authUrl = twitterAuthRequest.url {
                self.delegate?.launchBrowser(authenticationUrl: authUrl)
            } else {
                self.delegate?.authenticationFailed()
            }
        case .retrieveAccessToken:
            self.delegate?.dismissBrowser()
            authenticationService.fetchAccessToken(verifier: appCredentials.oauthVerifier(), completionHandler: { (authModel, error) in
                if error == nil, let authenticationModel = authModel {
                    self.appCredentials.credentials = authenticationModel
                    self.transitionToState(.authenticationSucceeded)
                } else {
                    self.transitionToState(.authenticationFailed)
                }
            })
        case .authenticationSucceeded:
            self.delegate?.authenticationDidSucceed()
        case .authenticationFailed:
            self.delegate?.dismissBrowser()
            self.delegate?.authenticationFailed()
        case .notAuthenticating:
            return
        }
    }
    
    @objc private func handleTwitterAuthRedirect(_ notification: Notification)
    {
        if let userInfo = notification.userInfo, let authModel = userInfo[OAuthConstants.tokenKey] as? AuthenticationCredentialsModel {
            if let oauthToken = authModel.oauthToken, let _ = authModel.oauthVerifier, appCredentials.accessToken() == oauthToken, authenticationState == .authenticateWithTwitter {
                appCredentials.credentials = authModel
                transitionToState(.retrieveAccessToken)
            } else {
                transitionToState(.authenticationFailed)
            }
        } else {
            transitionToState(.authenticationFailed)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
