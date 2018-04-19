//
//  OAuthSignature.h
//  TweetFeed
//
//  Created by Abhay Curam on 4/13/18.
//  Copyright © 2018 Tweeter. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HmacSHA1Signer : NSObject

+(NSString *)sign:(NSString *)baseText forKey:(NSString *)signatureKey;

@end

NS_ASSUME_NONNULL_END
