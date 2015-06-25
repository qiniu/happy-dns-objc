//
//  QNDnsManager.m
//  HappyDNS
//
//  Created by bailong on 15/6/23.
//  Copyright (c) 2015年 Qiniu Cloud Storage. All rights reserved.
//

#import "QNDnsManager.h"
#import "QNRecord.h"
#import "QNResolverDelegate.h"
#import "QNDomain.h"

@interface QNDnsManager ()

@property (nonatomic) NSCache *cache;
@property (nonatomic) QNNetworkInfo *curNetwork;
@property (nonatomic) NSMutableOrderedSet *resolvers;
@end

static NSArray *trimCname(NSArray *records) {
	NSMutableArray *array = [[NSMutableArray alloc] init];
	for (QNRecord *r in records) {
		if (r.type == kQNTypeA) {
			[array addObject:r];
		}
	}
	return array;
}

@implementation QNDnsManager
- (NSArray *)query:(NSString *)domain {
	return [self queryWithDomain:[[QNDomain alloc] init:domain]];
}

- (NSArray *)queryWithDomain:(QNDomain *)domain {
	unsigned long count = [_resolvers count];
	for (int i = 0; i < count; i++) {
		id <QNResolverDelegate> resolver = [_resolvers firstObject];
		NSArray *raw = [resolver query:domain networkInfo:_curNetwork];
		NSArray *array = trimCname(raw);
		if (array == nil || array.count == 0 || (domain.hasCname && raw.count == array.count)) {
			[_resolvers removeObjectAtIndex:0];
			[_resolvers addObject:resolver];
			continue;
		}
		return array;
	}
	return nil;
}

- (instancetype)init:(NSArray *)resolvers networkInfo:(QNNetworkInfo *)netInfo {
	if (self = [super init]) {
		_cache = [[NSCache alloc] init];
		_cache.countLimit = 256;
		_curNetwork = netInfo;
		_resolvers = [[NSMutableOrderedSet alloc] initWithArray:resolvers];
	}
	return self;
}

- (void)onNetworkChange:(QNNetworkInfo *)netInfo {
	[_cache removeAllObjects];
	_curNetwork = netInfo;
}

@end
