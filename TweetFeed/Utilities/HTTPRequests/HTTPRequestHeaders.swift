//
//  HTTPHeaderBuilder.swift
//  TweetFeed
//
//  Created by Abhay Curam on 4/14/18.
//  Copyright © 2018 Tweeter. All rights reserved.
//

import Foundation

public protocol HTTPRequestHeaders {
    var headers: [String : String] { get }
    var urlRequest: URLRequest? { get set }
}

public class TwitterAuthorizationHeader: HTTPRequestHeaders {
    
    public var headers: [String : String] {
        get {
            var httpHeaders = [String : String]()
            guard let urlRequest = urlRequest else { return httpHeaders }
            var authorizationHeaderValueString = kAuthorizationHeaderPrefix
            for (oauthParamKey, oauthParamValue) in oauthParameters(urlRequest) {
                var keyValueString = oauthParamKey.rfc3986PercentEncoding() ?? ""
                keyValueString += kEqualChar
                keyValueString += ""
                keyValueString += oauthParamValue.rfc3986PercentEncoding() ?? ""
                keyValueString += ""
                keyValueString += kCommaSpaceStr
                authorizationHeaderValueString += keyValueString
            }
            
            httpHeaders[kAuthorizationHeaderFieldKey] = String(authorizationHeaderValueString.dropLast(2))
            return httpHeaders
        }
    }
    
    public var urlRequest: URLRequest?
    public var additionalAuthParams = [String : String]()
    
    private let kApiKey = "52xFb1NIyVcjwO2q28rvwjTPV"
    private let kAuthorizationHeaderFieldKey = "Authorization"
    private let kAuthorizationHeaderPrefix = "OAuth "
    private let kEqualChar = "="
    private let kCommaSpaceStr = ", "
    
    public func oauthParameters(_ urlRequest: URLRequest) -> [String : String] {
        let credentials = TweetFeedUserCredentials()
        var oauthParamDictionary = [String : String]()
        oauthParamDictionary[OAuthConstants.consumerKey] = kApiKey
        oauthParamDictionary[OAuthConstants.signatureMethodKey] = OAuthConstants.signatureMethod
        oauthParamDictionary[OAuthConstants.versionKey] = OAuthConstants.version
        if credentials.accessToken() != "" {
            oauthParamDictionary[OAuthConstants.tokenKey] = credentials.accessToken()
        }
        oauthParamDictionary[OAuthConstants.nonceKey] = String.randomAlphaNumericString(20)
        oauthParamDictionary[OAuthConstants.timeStampKey] = String(Int(Date().timeIntervalSince1970))
        for (additionalParamKey, additionalParamValue) in additionalAuthParams {
            oauthParamDictionary[additionalParamKey] = additionalParamValue
        }
        oauthParamDictionary[OAuthConstants.signatureKey] = SignatureDigestBuilder.signatureDigest(for: urlRequest, oauthParams: oauthParamDictionary)
        return oauthParamDictionary
    }
}
