//
//  OAuthSignature.m
//  TweetFeed
//
//  Created by Abhay Curam on 4/13/18.
//  Copyright © 2018 Tweeter. All rights reserved.
//

#import "HmacSHA1Signer.h"
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>

@implementation HmacSHA1Signer

+(NSString *)sign:(NSString *)baseText forKey:(NSString *)signatureKey {
    const char *cKey  = [signatureKey cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [baseText cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    NSString *hash = [HMAC base64EncodedStringWithOptions:0];
    return hash;
}

@end
