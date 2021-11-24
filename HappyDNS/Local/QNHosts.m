//
//  QNHosts.m
//  HappyDNS
//
//  Created by bailong on 15/6/23.
//  Copyright (c) 2015年 Qiniu Cloud Storage. All rights reserved.
//

#import "QNHosts.h"
#import "QNDomain.h"
#import "QNNetworkInfo.h"

@interface QNHostsValue : NSObject
@property (nonatomic, copy, readonly) QNRecord *record;
@property (readonly) int provider;
@end

@implementation QNHostsValue

- (instancetype)init:(QNRecord *)record provider:(int)provider {
    if (self = [super init]) {
        _record = record;
        _provider = provider;
    }
    return self;
}

@end

static NSArray<QNHostsValue *> *filter(NSArray *input, int provider) {
    NSMutableArray<QNHostsValue *> *normal = [[NSMutableArray alloc] initWithCapacity:input.count];
    NSMutableArray<QNHostsValue *> *special = [[NSMutableArray alloc] init];
    for (QNHostsValue *v in input) {
        if (v.provider == kQNISP_GENERAL) {
            [normal addObject:v];
        } else if (provider == v.provider) {
            [special addObject:v];
        }
    }
    if (special.count != 0) {
        return special;
    }
    return [normal copy];
}

@interface QNHosts ()
@property (nonatomic) NSMutableDictionary *dict;
@end

@implementation QNHosts
- (NSArray <QNRecord *> *)query:(QNDomain *)domain networkInfo:(QNNetworkInfo *)netInfo {
    NSMutableArray *x;
    @synchronized(_dict) {
        x = [_dict objectForKey:domain.domain];
    }

    if (x == nil || x.count == 0) {
        return nil;
    }
    
    @synchronized (_dict) {
        if (x.count >= 2) {
            QNHostsValue *first = [x firstObject];
            [x removeObjectAtIndex:0];
            [x addObject:first];
        }
    }

    NSArray <QNHostsValue *> *values = filter([x copy], netInfo.provider);
    return [self toRecords:values];
}

- (NSArray <QNRecord *> *)toRecords:(NSArray <QNHostsValue *> *)values {
    if (values == nil) {
        return nil;
    }

    NSMutableArray<QNRecord *> *records = [NSMutableArray array];
    for (QNHostsValue *value in values) {
        if (value.record != nil && value.record.value != nil) {
            [records addObject:value.record];
        }
    }
    return [records copy];
}


- (void)put:(NSString *)domain record:(QNRecord *)record {
    [self put:domain record:record provider:kQNISP_GENERAL];
}

- (void)put:(NSString *)domain record:(QNRecord *)record provider:(int)provider {
    QNHostsValue *v = [[QNHostsValue alloc] init:record provider:provider];
    @synchronized(_dict) {
        NSMutableArray *x = [_dict objectForKey:domain];
        if (x == nil) {
            x = [[NSMutableArray alloc] init];
        }
        [x addObject:v];
        [_dict setObject:x forKey:domain];
    }
}

- (instancetype)init {
    if (self = [super init]) {
        _dict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

@end
