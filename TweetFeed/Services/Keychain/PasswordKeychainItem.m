//
//  PasswordKeychainItem.m
//  TweetFeed
//
//  Created by Abhay Curam on 4/13/18.
//  Copyright © 2018 Tweeter. All rights reserved.
//

#import "PasswordKeychainItem.h"

@implementation PasswordKeychainItem

@synthesize key = _key, password = _password;

- (instancetype)initWithPassword:(NSString *)password
                      identifier:(NSString *)keychainIdentifier
{
    return [self initWithPassword:password identifier:keychainIdentifier description:@"password" accessLevel:KeychainAccessLevelAccessibleWhenUnlocked];
}

- (instancetype)initWithPassword:(NSString *)password
                      identifier:(NSString *)keychainIdentifier
                     description:(NSString *)itemDescription
{
    return [self initWithPassword:password identifier:keychainIdentifier description:itemDescription accessLevel:KeychainAccessLevelAccessibleWhenUnlocked];
}

- (instancetype)initWithPassword:(NSString *)password
                      identifier:(NSString *)keychainIdentifier
                     description:(NSString *)itemDescription
                     accessLevel:(KeychainAccessLevel)accessLevel
{
    if (self = [super initWithDescription:itemDescription value:password accessLevel:accessLevel]) {
        self.password = password;
        self.identifier = keychainIdentifier;
    }
    
    return self;
}

-(NSMutableDictionary *)key
{
    NSMutableDictionary *key = super.key;
    key[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    NSString *itemId = (self.identifier) ? self.identifier : self.itemDescription;
    NSString *service = self.itemDescription;
    if (itemId) {
        key[(__bridge id)kSecAttrAccount] = [itemId dataUsingEncoding:NSUTF8StringEncoding];
    }
    if (service) {
        key[(__bridge id)kSecAttrService] = [service dataUsingEncoding:NSUTF8StringEncoding];
    }
    _key = key;
    return _key;
}

-(void)setPassword:(NSString *)password
{
    if (password) {
        _password = password.copy;
        super.itemValue = password;
    }
}

- (NSString *)password
{
    return _password.copy;
}

- (BOOL)isEqualToPasswordKeychainItem:(PasswordKeychainItem *)passwordKeychainItem {
    return ([(KeychainItem *)self isEqualToKeychainItem:(KeychainItem *)passwordKeychainItem] && [self.identifier isEqualToString:passwordKeychainItem.identifier]);
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[PasswordKeychainItem class]]) {
        if (self == object) {
            return YES;
        } else {
            return [self isEqualToPasswordKeychainItem:(PasswordKeychainItem *)object];
        }
    }
    
    return NO;
}

- (NSUInteger)hash {
    return (super.hash ^ self.identifier.hash);
}

@end

