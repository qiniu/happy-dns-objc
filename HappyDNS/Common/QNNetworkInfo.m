//
//  QNNetworkInfo.m
//  HappyDNS
//
//  Created by bailong on 15/6/25.
//  Copyright (c) 2015年 Qiniu Cloud Storage. All rights reserved.
//

#import "QNNetworkInfo.h"

@implementation QNNetworkInfo

- (instancetype)init:(int)connecton provider:(int)provider {
	if (self = [super init]) {
		_networkConnection = connecton;
		_provider = provider;
	}
	return self;
}

@end
