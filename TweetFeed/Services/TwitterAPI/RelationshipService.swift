//
//  RelationshipService.swift
//  TweetFeed
//
//  Created by Abhay Curam on 4/16/18.
//  Copyright © 2018 Tweeter. All rights reserved.
//

import Foundation

public enum RelationshipUpdateIntent {
    case follow
    case unfollow
}

public class RelationshipService {
    
    public typealias RelationshipLookupCompletionHandler = (([UserModel], Error?) -> Void)
    public typealias RelationshipUpdateCompletionHandler = ((Bool, Error?) -> Void)
    
    private let kRelationshipCreateEndpoint = "https://api.twitter.com/1.1/friendships/create.json"
    private let kRelationshipDestroyEndpoint = "https://api.twitter.com/1.1/friendships/destroy.json"
    private let kRelationshipLookupEndpoint = "https://api.twitter.com/1.1/friendships/lookup.json"
    private let kUserIdKey = "user_id"
    private let kFollowKey = "follow"
    private let kTrueStr = "true"
    
    public func relationshipWithUsers(_ userIds: [String], completionHandler: @escaping RelationshipLookupCompletionHandler) {
        let requestBuilder = HTTPURLRequestBuilder()
        requestBuilder.urlString = kRelationshipLookupEndpoint
        requestBuilder.httpMethod = .get
        requestBuilder.httpHeaders = TwitterAuthorizationHeader()
        requestBuilder.queryParams = userIds.map { URLQueryItem(name: kUserIdKey, value: $0) }
        if let relationshipRequest = requestBuilder.request {
            let task = URLSession.shared.dataTask(with: relationshipRequest, completionHandler: { [weak self] (data: Data?, response: URLResponse?, error: Error?) in
                DispatchQueue.main.async {
                    if let strongSelf = self {
                        strongSelf.handleRelationshipLookupResponse(data: data, response: response, error: error, completionHandler: completionHandler)
                    }
                }
            })
            task.resume()
        }
    }
    
    public func updateRelationship(with userId: String, intent: RelationshipUpdateIntent, completionHandler: @escaping RelationshipUpdateCompletionHandler) {
        let requestBuilder = HTTPURLRequestBuilder()
        requestBuilder.urlString = (intent == .follow) ? kRelationshipCreateEndpoint : kRelationshipDestroyEndpoint
        requestBuilder.httpMethod = .post
        requestBuilder.httpHeaders = TwitterAuthorizationHeader()
        requestBuilder.postBodyParams = (intent == .follow) ? [URLQueryItem(name: kUserIdKey, value: userId), URLQueryItem(name: kFollowKey, value: kTrueStr)] : [URLQueryItem(name: kUserIdKey, value: userId)]
        
        if let updateRelationshipRequest = requestBuilder.request {
            let task = URLSession.shared.dataTask(with: updateRelationshipRequest, completionHandler: { [weak self] (data: Data?, response: URLResponse?, error: Error?) in
                DispatchQueue.main.async {
                    if let strongSelf = self {
                        strongSelf.handleUpdateRelationshipResponse(data: data, response: response, error: error, completionHandler: completionHandler)
                    }
                }
            })
            task.resume()
        }
    }
    
    private func handleUpdateRelationshipResponse(data: Data?, response: URLResponse?, error: Error?, completionHandler: RelationshipUpdateCompletionHandler) {
        guard error == nil else {
            completionHandler(false, error)
            return
        }
        guard let response = response as? HTTPURLResponse, response.isSuccessfulStatusCode else {
            completionHandler(false, HTTPServiceErrors.unsuccessfulHTTPStatusCode)
            return
        }
        guard let data = data else {
            completionHandler(false, HTTPServiceErrors.emptyResponseData)
            return
        }
        do {
            if let _ = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                completionHandler(true, nil)
            } else {
                completionHandler(false, HTTPServiceErrors.emptyResponseData)
            }
        } catch {
            completionHandler(false, HTTPServiceErrors.responseDeserializationFailed)
        }
    }
    
    private func handleRelationshipLookupResponse(data: Data?, response: URLResponse?, error: Error?, completionHandler: RelationshipLookupCompletionHandler) {
        guard error == nil else {
            completionHandler([UserModel](), error)
            return
        }
        guard let response = response as? HTTPURLResponse, response.isSuccessfulStatusCode else {
            completionHandler([UserModel](), HTTPServiceErrors.unsuccessfulHTTPStatusCode)
            return
        }
        guard let data = data else {
            completionHandler([UserModel](), HTTPServiceErrors.emptyResponseData)
            return
        }
        do {
            if let data = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                completionHandler(data.map { UserModel($0) }, nil)
            } else {
                completionHandler([UserModel](), HTTPServiceErrors.emptyResponseData)
            }
        } catch {
            completionHandler([UserModel](), HTTPServiceErrors.responseDeserializationFailed)
        }
    }
    
}
