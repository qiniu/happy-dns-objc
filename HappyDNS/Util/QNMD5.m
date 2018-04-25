//
//  QNMD5.m
//  HappyDNS_Mac
//
//  Created by 何昊宇 on 2018/4/25.
//  Copyright © 2018年 Qiniu Cloud Storage. All rights reserved.
//

#import "QNMD5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation QNMD5

+ (NSString *)MD5:(NSString *)string{
    
    const char* input = [string UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02x", result[i]];
    }
    
    return digest;
}

@end
