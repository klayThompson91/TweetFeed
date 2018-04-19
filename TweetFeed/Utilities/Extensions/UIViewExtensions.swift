//
//  UIViewExtensions.swift
//  TweetFeed
//
//  Created by Abhay Curam on 4/15/18.
//  Copyright © 2018 Tweeter. All rights reserved.
//

import Foundation
import UIKit

public extension UIView {
    
    public func addSubviews(_ subviews: [UIView]) {
        for subview in subviews {
            self.addSubview(subview)
        }
    }
    
    public class func disableAutoresize(forViews: [UIView])
    {
        for view in forViews {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
    }
}
