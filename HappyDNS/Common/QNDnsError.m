//
//  QNDnsError.m
//  Doh
//
//  Created by yangsen on 2021/7/20.
//

#import "QNDnsError.h"

const int kQNDomainHijackingCode = -7001;
const int kQNDomainNotOwnCode = -7002;
const int kQNDomainSeverError = -7003;

const int kQNDnsMethodErrorCode = -7010;

const int kQNDnsInvalidParamCode = -7021;
const int kQNDnsResponseBadTypeCode = -7022;
const int kQNDnsResponseBadClassCode = -7023;
const int kQNDnsResponseFormatCode = -7024;

@implementation QNDnsError

+ (NSError *)error:(int)code desc:(NSString *)desc {
    return [NSError errorWithDomain:kQNDnsErrorDomain code:code userInfo:@{@"user_info" : desc ?: @"nil"}];
}

@end
