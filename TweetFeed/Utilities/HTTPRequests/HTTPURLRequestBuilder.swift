//
//  TwitterAPIRequestBuilder.swift
//  TweetFeed
//
//  Created by Abhay Curam on 4/14/18.
//  Copyright © 2018 Tweeter. All rights reserved.
//

import Foundation

public enum HTTPMethod {
    case post
    case get
    
    public func toString() -> String {
        switch self {
        case .post:
            return "POST"
        case .get:
            return "GET"
        }
    }
}

public class HTTPURLRequestBuilder {
    
    public var httpMethod: HTTPMethod
    public var urlString: String
    public var queryParams: [URLQueryItem]
    public var postBodyParams: [URLQueryItem]
    public var httpHeaders: HTTPRequestHeaders
    
    public var request: URLRequest? {
        get {
            guard let components = URLComponents(string: urlString) else { return nil }
            var urlComponents = components
            urlComponents.queryItems = queryParams
            guard let url = urlComponents.url else { return nil }
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = httpMethod.toString()
            var httpBodyComponents = URLComponents()
            httpBodyComponents.queryItems = postBodyParams
            if let percentEncodedBody = httpBodyComponents.percentEncodedQuery {
                urlRequest.httpBody = percentEncodedBody.data(using: .utf8)
            }
            httpHeaders.urlRequest = urlRequest
            for (headerKey, headerValue) in httpHeaders.headers {
                urlRequest.addValue(headerValue, forHTTPHeaderField: headerKey)
            }
            
            return urlRequest
        }
    }
    
    public init() {
        httpMethod = .get
        urlString = ""
        queryParams = [URLQueryItem]()
        postBodyParams = [URLQueryItem]()
        httpHeaders = TwitterAuthorizationHeader()
    }
}
