//
//  QNDomain.m
//  HappyDNS
//
//  Created by bailong on 15/6/23.
//  Copyright (c) 2015年 Qiniu Cloud Storage. All rights reserved.
//

#import "QNDomain.h"

@implementation QNDomain
- (instancetype)init:(NSString *)domain {
	if (self = [super init]) {
		_domain = domain;
		_hasCname = NO;
		_maxTtl = 0;
	}
	return self;
}

@end
