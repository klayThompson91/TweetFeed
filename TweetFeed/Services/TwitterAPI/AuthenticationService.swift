//
//  AuthenticationService.swift
//  TweetFeed
//
//  Created by Abhay Curam on 4/14/18.
//  Copyright © 2018 Tweeter. All rights reserved.
//

import Foundation

public class AuthenticationService {
    
    private let kRequestTokenEndpoint = "https://api.twitter.com/oauth/request_token"
    private let kAccessTokenEndpoint = "https://api.twitter.com/oauth/access_token"
    private let kTwitterAuthEndpoint = "https://api.twitter.com/oauth/authenticate"
    private let kOauthCallbackParamKey = "oauth_callback"
    private let kRedirectUri = "https://tweeter-feed.herokuapp.com/"
    private let kOauthVerifierKey = "oauth_verifier"
    
    public typealias AuthCompletionHandler = ((AuthenticationCredentialsModel?, Error?) -> Void)
    
    public func fetchRequestToken(completionHandler: @escaping AuthCompletionHandler) {
        let requestBuilder = HTTPURLRequestBuilder()
        requestBuilder.urlString = kRequestTokenEndpoint
        requestBuilder.httpMethod = .post
        let httpHeader = TwitterAuthorizationHeader()
        httpHeader.additionalAuthParams = [kOauthCallbackParamKey : kRedirectUri]
        requestBuilder.httpHeaders = httpHeader
        if let fetchTokenRequest = requestBuilder.request {
            let task = URLSession.shared.dataTask(with: fetchTokenRequest, completionHandler: { [unowned self] (data: Data?, response: URLResponse?, error: Error?) in
                DispatchQueue.main.async {
                    self.handleAuthResponse(data: data, response: response, error: error, completionHandler: completionHandler)
                }
            })
            task.resume()
        } else {
            DispatchQueue.main.async {
                completionHandler(nil, HTTPServiceErrors.requestCreationFailed)
            }
        }
    }
    
    public func fetchAccessToken(verifier: String, completionHandler: @escaping AuthCompletionHandler) {
        let requestBuilder = HTTPURLRequestBuilder()
        requestBuilder.httpMethod = .post
        requestBuilder.urlString = kAccessTokenEndpoint
        requestBuilder.postBodyParams = [URLQueryItem(name: kOauthVerifierKey, value: verifier)]
        if let accessTokenRequest = requestBuilder.request {
            let task = URLSession.shared.dataTask(with: accessTokenRequest, completionHandler: { [unowned self] (data: Data?, response: URLResponse?, error: Error?) in
                DispatchQueue.main.async {
                    self.handleAuthResponse(data: data, response: response, error: error, completionHandler: completionHandler)
                }
            })
            task.resume()
        } else {
            DispatchQueue.main.async {
                completionHandler(nil, HTTPServiceErrors.requestCreationFailed)
            }
        }
    }
    
    public func twitterAuthenticationRequest() -> URLRequest? {
        let requestBuilder = HTTPURLRequestBuilder()
        requestBuilder.httpMethod = .get
        requestBuilder.urlString = kTwitterAuthEndpoint
        requestBuilder.queryParams = [URLQueryItem(name: OAuthConstants.tokenKey, value: TweetFeedUserCredentials().accessToken())]
        return requestBuilder.request
    }
    
    private func handleAuthResponse(data: Data?, response: URLResponse?, error: Error?, completionHandler: AuthCompletionHandler) {
        guard error == nil else {
            completionHandler(nil, error)
            return
        }
        guard let response = response as? HTTPURLResponse, response.isSuccessfulStatusCode else {
            completionHandler(nil, HTTPServiceErrors.unsuccessfulHTTPStatusCode)
            return
        }
        guard let data = data, let responseDataStr = String(data: data, encoding: .utf8) else {
            completionHandler(nil, HTTPServiceErrors.emptyResponseData)
            return
        }
        completionHandler(AuthenticationCredentialsModel(responseDataStr), nil)
    }
}
