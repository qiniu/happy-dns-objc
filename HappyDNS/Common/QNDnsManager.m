//
//  QNDnsManager.m
//  HappyDNS
//
//  Created by bailong on 15/6/23.
//  Copyright (c) 2015年 Qiniu Cloud Storage. All rights reserved.
//

#import "QNDnsManager.h"
#import "QNDomain.h"
#import "QNHosts.h"
#import "QNIP.h"
#import "QNLruCache.h"
#import "QNNetworkInfo.h"
#import "QNRecord.h"
#import "QNResolverDelegate.h"

#include "QNGetAddrInfo.h"

@interface QNDnsManager ()

@property (nonatomic, strong) QNLruCache *cache;
@property (atomic) QNNetworkInfo *curNetwork;
@property (nonatomic) NSArray *resolvers;
@property (atomic) UInt32 resolverStatus;
@property (nonatomic, strong) QNHosts *hosts;
@property (nonatomic, strong) id<QNRecordSorter> sorter;
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
        n = n - 16;
        x = y;
    }
    y = x >> 8;
    if (y != 0) {
        n = n - 8;
        x = y;
    }
    y = x >> 4;
    if (y != 0) {
        n = n - 4;
        x = y;
    }
    y = x >> 2;
    if (y != 0) {
        n = n - 2;
        x = y;
    }
    y = x >> 1;
    if (y != 0) {
        return n - 2;
    }
    return n - x;
}

static NSMutableArray *trimCname(NSArray *records) {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (QNRecord *r in records) {
        if (r.type == kQNTypeA || r.type == kQNTypeAAAA) {
            [array addObject:r];
        }
    }
    return array;
}

static NSArray<NSString *> *records2Ips(NSArray<QNRecord *> *records) {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (QNRecord *r in records) {
        if (r.value && r.value.length > 0) {
            [array addObject:r.value];
        }
    }
    return [array copy];
}

static NSArray<QNRecord *> * filterInvalidRecords(NSArray *records) {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    long long timestamp = [[NSDate date] timeIntervalSince1970];
    for (QNRecord *r in records) {
        if (r.value && r.value.length > 0 && ![r expired:timestamp]) {
            [array addObject:r];
        }
    }
    return [array copy];
}

@interface DummySorter : NSObject <QNRecordSorter>

@end

@implementation DummySorter

//sorted already
- (NSArray *)sort:(NSArray *)ips {
    return ips;
}

@end

@implementation QNDnsManager

- (NSArray <QNRecord *> *)queryRecords:(NSString *)domain {
    return [self queryRecordsWithDomain:[[QNDomain alloc] init:domain]];
}

- (NSArray <QNRecord *> *)queryRecordsWithDomain:(QNDomain *)domain{
    if (domain == nil) {
        return nil;
    }
    if ([QNIP mayBeIpV4:domain.domain]) {
        QNRecord *record = [[QNRecord alloc] init:domain.domain ttl:kQNRecordForeverTTL type:kQNTypeA source:QNRecordSourceUnknown];
        return [NSArray arrayWithObject:record];
    }
    NSArray<QNRecord *> *records = [self queryInternalWithDomain:domain];
    return [_sorter sort:records];
}

- (NSArray <QNRecord *> *)queryInternalWithDomain:(QNDomain *)domain {
    if (domain.hostsFirst) {
        NSArray <QNRecord *> *result = [_hosts query:domain networkInfo:_curNetwork];
        result = filterInvalidRecords(result);
        if (result.count > 0) {
            return [result copy];
        }
    }
    
    if ([_curNetwork isEqualToInfo:[QNNetworkInfo normal]] && [QNNetworkInfo isNetworkChanged]) {
        @synchronized(_cache) {
            [_cache removeAllObjects];
        }
        _resolverStatus = 0;
    } else {
        @synchronized(_cache) {
            NSArray *result = [_cache objectForKey:domain.domain];
            result = filterInvalidRecords(result);
            if (result.count > 0) {
                return [result copy];
            }
        }
    }

    NSArray *records = nil;
    NSError *error = nil;
    int firstOk = 32 - bits_leadingZeros(_resolverStatus);
    for (int i = 0; i < _resolvers.count; i++) {
        int pos = (firstOk + i) % _resolvers.count;
        id<QNResolverDelegate> resolver = [_resolvers objectAtIndex:pos];
        QNNetworkInfo *previousNetwork = _curNetwork;
        NSString *previousIp = [QNNetworkInfo getIp];
        records = [resolver query:domain networkInfo:previousNetwork error:&error];
        if (error != nil) {
            NSError *tmp = error;
            error = nil;
            if (tmp.code == kQNDomainNotOwnCode) {
                continue;
            }
            
            if (self.queryErrorHandler) {
                self.queryErrorHandler(error, domain.domain);
            }
        }

        if (records == nil || records.count == 0) {
            if (_curNetwork == previousNetwork && [previousIp isEqualToString:[QNNetworkInfo getIp]]) {
                _resolverStatus = bits_set(_resolverStatus, pos);
            }
        } else {
            NSMutableArray *result = trimCname(records);
            if (_curNetwork == previousNetwork && [previousIp isEqualToString:[QNNetworkInfo getIp]]) {
                @synchronized(_cache) {
                    [_cache setObject:[result copy] forKey:domain.domain];
                }
            }
            return [result copy];
        }
    }

    if (!domain.hostsFirst) {
        return [_hosts query:domain networkInfo:_curNetwork];
    }
    
    return nil;
}

- (instancetype)init:(NSArray *)resolvers networkInfo:(QNNetworkInfo *)netInfo {
    return [self init:resolvers networkInfo:netInfo sorter:nil];
}

- (instancetype)init:(NSArray *)resolvers networkInfo:(QNNetworkInfo *)netInfo sorter:(id<QNRecordSorter>)sorter {
    if (self = [super init]) {
        _cache = [[QNLruCache alloc] init:1024];
        _curNetwork = netInfo;
        _resolvers = [[NSArray alloc] initWithArray:resolvers];
        _hosts = [[QNHosts alloc] init];
        if (sorter == nil) {
            _sorter = [[DummySorter alloc] init];
        } else {
            _sorter = sorter;
        }
    }
    return self;
}

- (void)onNetworkChange:(QNNetworkInfo *)netInfo {
    @synchronized(_cache) {
        [_cache removeAllObjects];
    }
    _curNetwork = netInfo;
}

- (instancetype)putHosts:(NSString *)domain ipv4:(NSString *)ipv4 {
    return [self putHosts:domain ip:ipv4 type:kQNTypeA provider:kQNISP_GENERAL];
}

- (instancetype)putHosts:(NSString *)domain ip:(NSString *)ip type:(int)type provider:(int)provider {
    return [self putHosts:domain record:[[QNRecord alloc] init:ip ttl:kQNRecordForeverTTL type:type source:QNRecordSourceCustom] provider:provider];
}

- (instancetype)putHosts:(NSString *)domain record:(QNRecord *)record provider:(int)provider {
    QNRecord *recordNew = [[QNRecord alloc] init:record.value ttl:record.ttl type:record.type timeStamp:record.timeStamp server:record.server source:QNRecordSourceCustom];
    [_hosts put:domain record:recordNew provider:provider];
    return self;
}

- (NSURL *)queryAndReplaceWithIP:(NSURL *)url {
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:YES];
    if (!urlComponents) {
        return nil;
    }

    NSString *host = urlComponents.host;
    NSArray<QNRecord *> *records = [self queryRecords:host];

    NSURL *URL = nil;
    if (records && records.firstObject) {
        urlComponents.host = [QNIP ipHost:records.firstObject.value];
    }

    URL = urlComponents.URL;
    return URL;
}

static QNGetAddrInfoCallback getAddrInfoCallback = nil;
static qn_ips_ret *dns_callback_internal(const char *host) {
    if (getAddrInfoCallback == nil) {
        return NULL;
    }
    NSString *s = [[NSString alloc] initWithUTF8String:host];
    if (s == nil) {
        return NULL;
    }
    NSArray *ips = getAddrInfoCallback(s);
    if (ips == nil) {
        return NULL;
    }
    qn_ips_ret *ret = calloc(sizeof(char *), ips.count + 1);
    for (int i = 0; i < ips.count; i++) {
        NSString *ip = ips[i];
        char *ip2 = strdup([ip cStringUsingEncoding:NSUTF8StringEncoding]);
        ret->ips[i] = ip2;
    }
    return ret;
}
static qn_ips_ret *dns_callback(const char *host) {
    qn_ips_ret *ret = dns_callback_internal(host);
    if (ret == NULL) {
        //only for compatible
        qn_ips_ret *ret = calloc(sizeof(char *), 2);
        ret->ips[0] = strdup(host);
    }
    return ret;
}

static QNIpStatusCallback ipStatusCallback = nil;
static void ip_status_callback(const char *ip, int code, int time_ms) {
    if (ipStatusCallback == nil) {
        return;
    }
    NSString *s = [[NSString alloc] initWithUTF8String:ip];
    if (s == nil) {
        return;
    }
    ipStatusCallback(s, code, time_ms);
}

+ (void)setGetAddrInfoBlock:(QNGetAddrInfoCallback)block {
    if ([QNIP isIpV6FullySupported] || ![QNIP isV6]) {
        getAddrInfoCallback = block;
        qn_set_dns_callback(dns_callback);
    }
}

+ (void)setDnsManagerForGetAddrInfo:(QNDnsManager *)dns {
    [QNDnsManager setGetAddrInfoBlock:^NSArray<NSString *> *(NSString *host) {
        NSArray *records = [dns queryRecords:host];
        return records2Ips(records);
    }];
}

+ (void)setIpStatusCallback:(QNIpStatusCallback)block {
    ipStatusCallback = block;
    qn_set_ip_report_callback(ip_status_callback);
}

+ (BOOL)needHttpDns {
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    NSString *tzName = [timeZone name];
    return [tzName isEqual:@"Asia/Shanghai"] || [tzName isEqual:@"Asia/Chongqing"] || [tzName isEqual:@"Asia/Harbin"] || [tzName isEqual:@"Asia/Urumqi"];
}
@end
