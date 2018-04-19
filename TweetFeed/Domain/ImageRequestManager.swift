//
//  ImageRequestManager.swift
//  TweetFeed
//
//  Created by Abhay Curam on 4/17/18.
//  Copyright © 2018 Tweeter. All rights reserved.
//

import Foundation
import UIKit

public class ImageRequest {
    public var imageUri: String
    public var requestHandler: ((UIImage?) -> Void)
    
    public init(_ imageUri: String, _ handler: @escaping ((UIImage?) -> Void)) {
        self.imageUri = imageUri
        self.requestHandler = handler
    }
}

public class ImageRequestManager {
    
    public static let shared = ImageRequestManager()
    
    private typealias ImageRequestMap = [ObjectIdentifier : ImageRequest]
    private var currentRequests = [String : (currentTask: URLSessionDataTask, observers: ImageRequestMap)]()
    public var imageCache = NSCache<NSString, UIImage>()
    
    public init() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleMemoryPressure(_:)), name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: nil)
    }
    
    public func addRequest(_ imageRequest: ImageRequest) {
        if let cachedImage = imageCache.object(forKey: imageRequest.imageUri as NSString) {
            imageRequest.requestHandler(cachedImage)
        } else {
            //first check if we currently are serving this request
            if currentRequests[imageRequest.imageUri] != nil {
                currentRequests[imageRequest.imageUri]?.observers[ObjectIdentifier(imageRequest)] = imageRequest
            } else {
                //create the request, record it, then execute it
                if let url = URL(string: imageRequest.imageUri) {
                    let task = URLSession.shared.dataTask(with: url, completionHandler: { [weak self] (data: Data?, response: URLResponse?, error: Error?) in
                        if let strongSelf = self {
                            if error != nil {
                                strongSelf.publishResponse(nil, imageRequest.imageUri)
                            }
                            guard let response = response as? HTTPURLResponse else {
                                strongSelf.publishResponse(nil, imageRequest.imageUri)
                                return
                            }
                            if response.isSuccessfulStatusCode, let data = data {
                                strongSelf.publishResponse(UIImage(data: data), imageRequest.imageUri)
                            } else {
                                strongSelf.publishResponse(nil, imageRequest.imageUri)
                            }
                        }
                    })
                    currentRequests[imageRequest.imageUri] = (task, [ObjectIdentifier(imageRequest) : imageRequest])
                    task.resume()
                }
            }
        }
    }
    
    public func cancelRequest(_ imageRequest: ImageRequest) {
        // you clear the passed in imageRequest call back first.
        // If you have cleared them all then suspend the download task since its not needed.
        let key = ObjectIdentifier(imageRequest)
        if currentRequests[imageRequest.imageUri] != nil {
            currentRequests[imageRequest.imageUri]?.observers.removeValue(forKey: key)
            if currentRequests[imageRequest.imageUri]?.observers.count == 0 {
                currentRequests[imageRequest.imageUri]?.currentTask.cancel()
                currentRequests.removeValue(forKey: imageRequest.imageUri)
            }
        }
    }
    
    private func publishResponse(_ image: UIImage?, _ uri: String) {
        DispatchQueue.main.async { [weak self] in
            if let strongSelf = self, let storedRequest = strongSelf.currentRequests[uri] {
                if let image = image {
                    strongSelf.imageCache.setObject(image, forKey: uri as NSString)
                }
                let observers = storedRequest.observers
                for (_, observer) in observers {
                    observer.requestHandler(image)
                }
                strongSelf.currentRequests.removeValue(forKey: uri)
            }
        }
    }
    
    @objc private func handleMemoryPressure(_ notification: Notification) {
        imageCache.removeAllObjects()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
