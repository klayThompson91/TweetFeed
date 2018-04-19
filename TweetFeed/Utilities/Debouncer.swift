//
//  Debouncer.swift
//  TweetFeed
//
//  Created by Abhay Curam on 4/17/18.
//  Copyright © 2018 Tweeter. All rights reserved.
//

import Foundation

public class Debouncer {
    
    public var callback: (() -> Void)?
    public var delay: Double
    weak var timer: Timer?
    
    public required init(delay: Double, callback: (() -> Void)? = nil) {
        self.delay = delay
        self.callback = callback
    }
    
    public func cancel() {
        timer?.invalidate()
    }
    
    public func perform(callback: (() -> Void)? = nil) {
        cancel()
        
        if let callback = callback {
            self.callback = callback
        }
        
        if #available(iOS 10.0, *) {
            timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false, block: { [weak self] _ in
                self?.fireNow()
            })
        } else {
            timer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(fireNow), userInfo: nil, repeats: false)
        }
    }
    
    @objc private func fireNow() {
        callback?()
        callback = nil
        timer = nil
    }
}
