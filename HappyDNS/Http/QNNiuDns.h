//
//  QNNiuDns.h
//  HappyDNS
//
//  Created by 何昊宇 on 2018/3/8.
//  Copyright © 2018年 Qiniu Cloud Storage. All rights reserved.
//

#import "QNResolverDelegate.h"
#import <Foundation/Foundation.h>

@interface QNNiuDns : NSObject <QNResolverDelegate>
- (NSArray *)query:(QNDomain *)domain networkInfo:(QNNetworkInfo *)netInfo error:(NSError *__autoreleasing *)error;

@property (nonatomic, strong, readonly) NSString *accountId;

@property (nonatomic, strong, readonly) NSString *encryptKey;

/**
 *    单位 s
 */
@property (nonatomic, assign, readonly) long expireTime;


@property (nonatomic, assign, readonly) BOOL isHttps;

@property (nonatomic, assign, readonly) BOOL isNeedEncrypted;

/**
 *    http DNS 加密初始化
 */
- (instancetype)initWithAccountId:(NSString *)accountId
                       encryptKey:(NSString *)encryptKey
                       expireTime:(long)expireTime
                          isHttps:(BOOL)isHttps
                  isNeedEncrypted:(BOOL)isNeedEncrypted;

@end
