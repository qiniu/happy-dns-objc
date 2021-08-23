//
//  QNRecord.m
//  HappyDNS
//
//  Created by bailong on 15/6/23.
//  Copyright (c) 2015年 Qiniu Cloud Storage. All rights reserved.
//

#import "QNRecord.h"

const int kQNTypeA = 1;
const int kQNTypeAAAA = 28;
const int kQNTypeCname = 5;
const int kQNTypeTXT = 16;
const int kQNRecordForeverTTL = -1;

@implementation QNRecord
- (instancetype)init:(NSString *)value
                 ttl:(int)ttl
                type:(int)type
              source:(QNRecordSource)source {
    if (self = [super init]) {
        _value = value;
        _type = type;
        _ttl = ttl;
        _source = source;
        _timeStamp = [[NSDate date] timeIntervalSince1970];
    }
    return self;
}

- (instancetype)init:(NSString *)value
                 ttl:(int)ttl
                type:(int)type
           timeStamp:(long long)timeStamp
              server:(NSString *)server
              source:(QNRecordSource)source {
    if (self = [super init]) {
        _value = value;
        _type = type;
        _ttl = ttl;
        _server = server;
        _source = source;
        _timeStamp = timeStamp;
    }
    return self;
}

- (BOOL)expired:(long long)time {
    if (_ttl == kQNRecordForeverTTL) {
        return false;
    }
    return time > _timeStamp + _ttl;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"value:%@, ttl:%d, timestamp:%lld, type:%d server:%@ source:%lu", _value,  _ttl, _timeStamp, _type, _server, (unsigned long)_source];
}

@end
