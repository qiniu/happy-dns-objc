//
//  QNResolverDelegate.h
//  HappyDNS
//
//  Created by bailong on 15/6/23.
//  Copyright (c) 2015年 Qiniu Cloud Storage. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QNDomain;
@class QNNetworkInfo;
@protocol QNResolverDelegate <NSObject>
- (NSArray *)query:(QNDomain *)domain networkInfo:(QNNetworkInfo *)netInfo;
@end
