//
//  DoubleEndedArrayQueue.swift
//  TweetFeed
//
//  Created by Abhay Curam on 4/16/18.
//  Copyright © 2018 Tweeter. All rights reserved.
//

import Foundation

public class BoundedDequeueArray<T: Any> {
    
    public private(set) var items = [T]()
    public private(set) var maxElements = 0
    
    public required init(count: Int) {
        maxElements = count
    }
    
    public func insertFront(_ newItems: [T]) {
        guard newItems.count <= maxElements else { return }
        if items.count + newItems.count > maxElements {
            let numItemsToRemove = (items.count + newItems.count) - maxElements
            items.removeLast(numItemsToRemove)
            items.insert(contentsOf: newItems, at: 0)
        } else {
            items.insert(contentsOf: newItems, at: 0)
        }
    }
    
    public func insertBack(_ newItems: [T]) {
        guard newItems.count <= maxElements else { return }
        if items.count + newItems.count > maxElements {
            let numItemsToRemove = (items.count + newItems.count) - maxElements
            items.removeFirst(numItemsToRemove)
            items.append(contentsOf: newItems)
        } else {
            items.append(contentsOf: newItems)
        }
    }
    
    public func removeAll() {
        items.removeAll()
    }
}

