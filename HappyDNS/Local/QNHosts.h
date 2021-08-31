//
//  QNHosts.h
//  HappyDNS
//
//  Created by bailong on 15/6/23.
//  Copyright (c) 2015年 Qiniu Cloud Storage. All rights reserved.
//

#import "QNRecord.h"
#import "QNResolverDelegate.h"
#import <Foundation/Foundation.h>

@interface QNHosts : NSObject

- (NSArray <QNRecord *> *)query:(QNDomain *)domain networkInfo:(QNNetworkInfo *)netInfo;

- (void)put:(NSString *)domain record:(QNRecord *)record;
- (void)put:(NSString *)domain record:(QNRecord *)record provider:(int)provider;

@end
