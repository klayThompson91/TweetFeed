//
//  TabBarItemFactory.swift
//  TweetFeed
//
//  Created by Abhay Curam on 4/16/18.
//  Copyright © 2018 Tweeter. All rights reserved.
//

import Foundation
import UIKit

public class TabBarItemFactory {
    
    public class func makeTabBarItem(title: String, selectedImage: UIImage?, unselectedImage: UIImage?) -> UITabBarItem
    {
        let tabBarItem = UITabBarItem()
        tabBarItem.title = title
        tabBarItem.image = unselectedImage
        tabBarItem.selectedImage = selectedImage
        return tabBarItem
    }
    
}
