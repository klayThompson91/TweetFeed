//
//  TweetTimelineService.swift
//  TweetFeed
//
//  Created by Abhay Curam on 4/16/18.
//  Copyright © 2018 Tweeter. All rights reserved.
//

import Foundation

public class TweetTimelineService {
    
    public typealias TweetTimelineCompletionHandler = (([TweetModel], Error?) -> Void)
    
    private let kUserTimelineEndpoint = "https://api.twitter.com/1.1/statuses/home_timeline.json"
    private let kCountKey = "count"
    private let kSinceIdKey = "since_id"
    private let kMaxIdKey = "max_id"
    
    public func fetchTweets(count: Int, completionHandler: @escaping TweetTimelineCompletionHandler) {
        fetchTweets(idPair: nil, count: count, completionHandler: completionHandler)
    }
    
    public func fetchTweetsSince(id: String, count: Int, completionHandler: @escaping TweetTimelineCompletionHandler) {
        fetchTweets(idPair: (kSinceIdKey, id), count: count, completionHandler: completionHandler)
    }
    
    public func fetchTweetsBefore(id: String, count: Int, completionHandler: @escaping TweetTimelineCompletionHandler) {
        fetchTweets(idPair: (kMaxIdKey, id), count: count, completionHandler: completionHandler)
    }
    
    private func fetchTweets(idPair: (String, String)?, count: Int, completionHandler: @escaping TweetTimelineCompletionHandler) {
        if let fetchTweetsRequest = buildTimelineRequest(idPair: idPair, count: count).request {
            let task = URLSession.shared.dataTask(with: fetchTweetsRequest, completionHandler: { [weak self] (data: Data?, response: URLResponse?, error: Error?) in
                if let strongSelf = self {
                    DispatchQueue.main.async {
                        strongSelf.handleTimelineResponse(data: data, response: response, error: error, completionHandler: completionHandler)
                    }
                }
            })
            task.resume()
        }
    }
    
    private func buildTimelineRequest(idPair: (String, String)?, count: Int) -> HTTPURLRequestBuilder {
        let requestBuilder = HTTPURLRequestBuilder()
        requestBuilder.urlString = kUserTimelineEndpoint
        requestBuilder.httpHeaders = TwitterAuthorizationHeader()
        requestBuilder.httpMethod = .get
        var queryParams = [URLQueryItem(name: kCountKey, value: String(count))]
        if let idPair = idPair {
            queryParams.append(URLQueryItem(name: idPair.0, value: idPair.1))
        }
        requestBuilder.queryParams = queryParams
        return requestBuilder
    }
    
    private func handleTimelineResponse(data: Data?, response: URLResponse?, error: Error?, completionHandler: TweetTimelineCompletionHandler) {
        guard error == nil else {
            completionHandler([TweetModel](), error)
            return
        }
        guard let response = response as? HTTPURLResponse, response.isSuccessfulStatusCode else {
            completionHandler([TweetModel](), HTTPServiceErrors.unsuccessfulHTTPStatusCode)
            return
        }
        guard response.isJSONMediaType else {
            completionHandler([TweetModel](), HTTPServiceErrors.responseContainedIncorrectMediaType)
            return
        }
        
        if let data = data {
            do {
                if let tweetCollection = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                    completionHandler(tweetCollection.map { TweetModel($0) }, nil)
                }
            } catch {
                completionHandler([TweetModel](), HTTPServiceErrors.responseDeserializationFailed)
            }
        } else {
            completionHandler([TweetModel](), HTTPServiceErrors.emptyResponseData)
        }
    }
}
