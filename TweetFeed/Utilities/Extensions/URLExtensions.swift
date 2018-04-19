//
//  URLExtensions.swift
//  TweetFeed
//
//  Created by Abhay Curam on 4/14/18.
//  Copyright © 2018 Tweeter. All rights reserved.
//

import Foundation

extension URL {
    func urlStringByTrimmingQuery() -> String? {
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = path
        return urlComponents.url?.absoluteString
    }
}
