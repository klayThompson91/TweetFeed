//
//  UserSearchService.swift
//  TweetFeed
//
//  Created by Abhay Curam on 4/17/18.
//  Copyright © 2018 Tweeter. All rights reserved.
//

import Foundation

public class UserSearchService {
    
    public typealias UserSearchResultsCompletionHandler = (([UserModel], Error?) -> Void)
    private let kUserSearchEndpoint = "https://api.twitter.com/1.1/users/search.json"
    
    private let kIncludeEntitiesKey = "include_entities"
    private let kIncludeEntitiesValue = "false"
    private let kPageKey = "page"
    private let kSearchQueryKey = "q"
    
    public func usersForQuery(_ searchQuery: String, numPages: Int, completionHandler: @escaping UserSearchResultsCompletionHandler) {
        let requestBuilder = HTTPURLRequestBuilder()
        requestBuilder.urlString = kUserSearchEndpoint
        requestBuilder.httpHeaders = TwitterAuthorizationHeader()
        requestBuilder.httpMethod = .get
        var queryParams = [URLQueryItem(name: kSearchQueryKey, value: searchQuery), URLQueryItem(name: kIncludeEntitiesKey, value: kIncludeEntitiesValue)]
        if numPages > 0 {
            queryParams.append(URLQueryItem(name: kPageKey, value: String(numPages)))
        }
        requestBuilder.queryParams = queryParams
        if let userSearchRequest = requestBuilder.request {
            let task = URLSession.shared.dataTask(with: userSearchRequest, completionHandler: { [weak self] (data: Data?, response: URLResponse?, error: Error?) in
                if let strongSelf = self {
                    DispatchQueue.main.async {
                        strongSelf.handleResponse(data: data, response: response, error: error, completionHandler: completionHandler)
                    }
                }
            })
            task.resume()
        }
    }
    
    private func handleResponse(data: Data?, response: URLResponse?, error: Error?, completionHandler: UserSearchResultsCompletionHandler) {
        guard error == nil else {
            completionHandler([UserModel](), error)
            return
        }
        guard let response = response as? HTTPURLResponse, response.isSuccessfulStatusCode else {
            completionHandler([UserModel](), HTTPServiceErrors.unsuccessfulHTTPStatusCode)
            return
        }
        guard response.isJSONMediaType else {
            completionHandler([UserModel](), HTTPServiceErrors.responseContainedIncorrectMediaType)
            return
        }
        
        if let data = data {
            do {
                if let userResultsDict = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                    completionHandler(userResultsDict.map { UserModel($0) }, nil)
                }
            } catch {
                completionHandler([UserModel](), HTTPServiceErrors.responseDeserializationFailed)
            }
        } else {
            completionHandler([UserModel](), HTTPServiceErrors.emptyResponseData)
        }
    }
}
