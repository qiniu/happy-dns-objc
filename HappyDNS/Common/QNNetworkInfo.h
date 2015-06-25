//
//  QNNetworkInfo.h
//  HappyDNS
//
//  Created by bailong on 15/6/25.
//  Copyright (c) 2015年 Qiniu Cloud Storage. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const int kQN;

@interface QNNetworkInfo : NSObject

@property (readonly) int networkConnection;
@property (readonly) int provider;

- (instancetype)init:(int)connecton provider:(int)provider;
@end
