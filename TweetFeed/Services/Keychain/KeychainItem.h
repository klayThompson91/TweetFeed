//
//  KeychainItem.h
//  TweetFeed
//
//  Created by Abhay Curam on 4/13/18.
//  Copyright © 2018 Tweeter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

/**
 A KeychainItem access level, these directly correspond to kSecAccessibleAttr:
 https://developer.apple.com/reference/security/keychain_services/item_class_value_constants
 */
typedef NS_ENUM(NSUInteger, KeychainAccessLevel)
{
    KeychainAccessLevelAccessibleAfterFirstUnlock,
    KeychainAccessLevelAccessibleAfterFirstUnlockThisDeviceOnly,
    KeychainAccessLevelAccessibleAlways,
    KeychainAccessLevelAccessibleWhenPasscodeSetThisDeviceOnly,
    KeychainAccessLevelAccessibleAlwaysThisDeviceOnly,
    KeychainAccessLevelAccessibleWhenUnlocked,
    KeychainAccessLevelAccessibleWhenUnlockedThisDeviceOnly
};

NS_ASSUME_NONNULL_BEGIN

/**
 A KeychainItem to use with iOS Keychain. KeychainItems contain keys and values
 to be stored in iOS keychain. Please do not store a KeychainItem directly in iOS
 keychain, use one of KeychainItem's subclass PasswordKeychainItem.
 */
@interface KeychainItem : NSObject

@property (nonatomic, assign) KeychainAccessLevel accessLevel;
@property (nonatomic, copy) NSString *itemDescription;
@property (nonatomic, copy) NSString *itemValue;

@property (nonatomic, readonly) NSMutableDictionary *key;
@property (nonatomic, readonly) NSMutableDictionary *value;

- (instancetype)initWithDescription:(NSString *)itemDescription value:(NSString *)itemValue;
- (instancetype)initWithDescription:(NSString *)itemDescription value:(NSString *)itemValue accessLevel:(KeychainAccessLevel)accessLevel;
- (instancetype)init NS_UNAVAILABLE;

- (BOOL)isEqualToKeychainItem:(KeychainItem *)keychainItem;

@end

NS_ASSUME_NONNULL_END

