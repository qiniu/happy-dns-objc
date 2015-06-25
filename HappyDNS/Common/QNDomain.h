//
//  QNDomain.h
//  HappyDNS
//
//  Created by bailong on 15/6/23.
//  Copyright (c) 2015年 Qiniu Cloud Storage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QNDomain : NSObject
@property (nonatomic, readonly) NSString *domain;

// 用来判断劫持
@property (readonly) BOOL hasCname;
// 用来判断劫持
@property (readonly) int maxTtl;
- (instancetype)init:(NSString *)domain;

@property int customTag;
@end
