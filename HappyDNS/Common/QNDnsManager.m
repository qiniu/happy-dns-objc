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
#import "QNHosts.h"

@interface QNDnsManager ()

@property (nonatomic) NSCache *cache;
@property (atomic) QNNetworkInfo *curNetwork;
@property (nonatomic) NSArray *resolvers;
@property (atomic) UInt32 resolverStatus;
@property (nonatomic) QNHosts *hosts;
@end

//static inline BOOL bits_isSet(UInt32 v, int index) {
//	return (v & (1 << index)) != 0;
//}

static inline UInt32 bits_set(UInt32 v, int bitIndex) {
	return v |= (1 << bitIndex);
}

static inline UInt32 bits_leadingZeros(UInt32 x) {
	UInt32 y;
	int n = 32;
	y = x >> 16;
	if (y != 0) {
		n = n - 16; x = y;
	}
	y = x >> 8;
	if (y != 0) {
		n = n - 8; x = y;
	}
	y = x >> 4;
	if (y != 0) {
		n = n - 4; x = y;
	}
	y = x >> 2;
	if (y != 0) {
		n = n - 2; x = y;
	}
	y = x >> 1;
	if (y != 0) {
		return n - 2;
	}
	return n - x;
}

static NSArray *trimCname(NSArray *records) {
	NSMutableArray *array = [[NSMutableArray alloc] init];
	for (QNRecord *r in records) {
		if (r.type == kQNTypeA) {
			[array addObject:r];
		}
	}
	return array;
}

static NSArray *records2Ips(NSArray *records) {
	NSMutableArray *array = [[NSMutableArray alloc] init];
	for (QNRecord *r in records) {
		[array addObject:r.value];
	}
	return array;
}

@implementation QNDnsManager
- (NSArray *)query:(NSString *)domain {
	return [self queryWithDomain:[[QNDomain alloc] init:domain]];
}

- (NSArray *)queryWithDomain:(QNDomain *)domain {
	if (domain.hostsFirst) {
		NSArray *ret = [_hosts query:domain networkInfo:_curNetwork];
		if (ret != nil && ret.count != 0) {
			return ret;
		}
	}
	NSArray *result;
	@synchronized(_cache)
	{
		result = [_cache objectForKey:domain.domain];
	}

	if (result != nil && result.count > 0) {
		QNRecord *record = [result objectAtIndex:0];
		if (![record expired:[[NSDate date]timeIntervalSince1970]]) {
			return records2Ips(result);
		}
	}
	NSArray *records = nil;
	int firstOk = 32 - bits_leadingZeros(_resolverStatus);
	for (int i = 0; i < _resolvers.count; i++) {
		int pos = (firstOk + i) % _resolvers.count;
		id <QNResolverDelegate> resolver = [_resolvers objectAtIndex:pos];
		QNNetworkInfo *before = _curNetwork;
		records = [resolver query:domain networkInfo:before];
		if (records == nil || records.count == 0) {
			if (_curNetwork == before) {
				_resolverStatus = bits_set(_resolverStatus, pos);
			}
		}
		else {
			NSArray *ret = trimCname(records);
			if (_curNetwork == before) {
				@synchronized(_cache)
				{
					[_cache setObject:ret forKey:domain.domain];
				}
			}
			return records2Ips(ret);
		}
	}

	if (!domain.hostsFirst) {
		return [_hosts query:domain networkInfo:_curNetwork];
	}
	return nil;
}

- (instancetype)init:(NSArray *)resolvers networkInfo:(QNNetworkInfo *)netInfo {
	if (self = [super init]) {
		_cache = [[NSCache alloc] init];
		_cache.countLimit = 1024;
		_curNetwork = netInfo;
		_resolvers = [[NSArray alloc] initWithArray:resolvers];
		_hosts = [[QNHosts alloc] init];
	}
	return self;
}

- (void)onNetworkChange:(QNNetworkInfo *)netInfo {
	@synchronized(_cache)
	{
		[_cache removeAllObjects];
	}
	_curNetwork = netInfo;
}

- (instancetype)putHosts:(NSString *)domain ip:(NSString *)ip {
	[_hosts put:domain ip:ip];
	return self;
}

- (instancetype)putHosts:(NSString *)domain ip:(NSString *)ip provider:(int)provider {
	[_hosts put:domain ip:ip provider:provider];
	return self;
}

@end
