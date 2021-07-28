//
//  QNDnspodFree.h
//  HappyDNS
//
//  Created by bailong on 15/6/23.
//  Copyright (c) 2015年 Qiniu Cloud Storage. All rights reserved.
//

#import "QNResolverDelegate.h"
#import <Foundation/Foundation.h>

@interface QNDnspodFree : NSObject <QNResolverDelegate>
- (NSArray *)query:(QNDomain *)domain networkInfo:(QNNetworkInfo *)netInfo error:(NSError *__autoreleasing *)error;

DEPRECATED_MSG_ATTRIBUTE("use initWithServer: instead, because tencent 119.29.29.29 will invalid at 2021/01/01");
- (instancetype)init;
- (instancetype)initWithServer:(NSString *)server;
- (instancetype)initWithServer:(NSString *)server
                       timeout:(NSUInteger)time;

@end
