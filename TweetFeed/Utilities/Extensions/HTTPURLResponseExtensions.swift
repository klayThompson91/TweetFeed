//
//  NSURLResponseExtensions.swift
//  TweetFeed
//
//  Created by Abhay Curam on 4/14/18.
//  Copyright © 2018 Tweeter. All rights reserved.
//

import Foundation

public extension HTTPURLResponse {
    
    public var isSuccessfulStatusCode: Bool {
        return (200...299).contains(statusCode)
    }
    
    public var isJSONMediaType: Bool {
        if let mimeType = mimeType {
            return mimeType == "application/json"
        }
        
        return false
    }
    
    public var isImageMediaType: Bool {
        if let mimeType = mimeType {
            return mimeType.hasPrefix("image")
        }
        
        return false
    }
    
}
