//
//  TweetModel.swift
//  TweetFeed
//
//  Created by Abhay Curam on 4/16/18.
//  Copyright © 2018 Tweeter. All rights reserved.
//

import Foundation

public class TweetModel {
    
    public var id: String?
    public var date: String?
    public var user: UserModel?
    public var text: String?
    
    private let kDateKey = "created_at"
    private let kIdKey = "id_str"
    private let kUserKey = "user"
    private let kTextKey = "text"
    
    private let kLocaleString = "en_US_POSIX"
    private let kPosixDateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
    private let kHumanReadableDateFormat = "MMM d yyyy, h:mm a"
    
    public convenience init() {
        self.init([String : Any]())
    }
    
    public init(_ dictionary: [String: Any]) {
        if let id = dictionary[kIdKey] as? String {
            self.id = id
        }
        if let dateStr = dictionary[kDateKey] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: kLocaleString)
            dateFormatter.dateFormat = kPosixDateFormat
            if let serverDate = dateFormatter.date(from: dateStr) {
                let newDateFormatter = DateFormatter()
                newDateFormatter.dateFormat = kHumanReadableDateFormat
                date = newDateFormatter.string(from: serverDate)
            }
        }
        if let text = dictionary[kTextKey] as? String {
            self.text = text
        }
        if let userDictionary = dictionary[kUserKey] as? [String: Any] {
            self.user = UserModel(userDictionary)
        }
    }
}
