//
//  QNNetworkInfo.m
//  HappyDNS
//
//  Created by bailong on 15/6/25.
//  Copyright (c) 2015年 Qiniu Cloud Storage. All rights reserved.
//

#import "QNNetworkInfo.h"

const int kQNNO_NETWORK = -1;
const int kQNWIFI = 1;
const int kQNMOBILE = 2;

const int kQNISP_GENERAL = 0;
const int kQNISP_CTC = 1;
const int kQNISP_DIANXIN = kQNISP_CTC;
const int kQNISP_CNC = 2;
const int kQNISP_LIANTONG = kQNISP_CNC;
const int kQNISP_CMCC = 3;
const int kQNISP_YIDONG = kQNISP_CMCC;
const int kQNISP_OTHER = 999;

@implementation QNNetworkInfo

- (instancetype)init:(int)connecton provider:(int)provider {
	if (self = [super init]) {
		_networkConnection = connecton;
		_provider = provider;
	}
	return self;
}

+ (instancetype)noNet {
	return [[QNNetworkInfo alloc] init:kQNNO_NETWORK provider:kQNISP_GENERAL];
}

+ (instancetype)normal {
	return [[QNNetworkInfo alloc] init:kQNISP_GENERAL provider:kQNISP_GENERAL];
}

@end
