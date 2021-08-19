//
//  DohTest.m
//  HappyDNS
//
//  Created by yangsen on 2021/7/28.
//  Copyright © 2021 Qiniu Cloud Storage. All rights reserved.
//
#import <XCTest/XCTest.h>
#import "QNDohResolver.h"
#import "QNDomain.h"

@interface DohResolverTest : XCTestCase

@end

@implementation DohResolverTest

- (void)testSimpleDns {
    NSString *host = @"en.wikipedia.org";
    NSError *err = nil;
    
    NSArray *typeArray = @[@(kQNTypeA), @(kQNTypeAAAA)];
    for (NSNumber *type in typeArray) {
        QNDohResolver *server = [QNDohResolver resolverWithServer:@"https://dns.alidns.com/dns-query" recordType:type.intValue timeout:5];
        NSArray *records = [server query:[[QNDomain alloc] init:host] networkInfo:nil error:&err];
        NSLog(@"== records:%@", records);
        XCTAssertNil(err, "query error:%@", err);
        XCTAssertNotNil(records, "type:%@ query result nil", type);
        XCTAssertTrue(records.count > 0, "type:%@ query result empty", type);
    }
}

- (void)testMultiDnsServer {
    NSString *host = @"en.wikipedia.org";
    NSError *err = nil;
    
    NSArray *typeArray = @[@(kQNTypeA), @(kQNTypeAAAA)];
    for (NSNumber *type in typeArray) {
        // https://dns.alidns.com/dns-query
        // https://dns.google/dns-query
        QNDohResolver *server = [QNDohResolver resolverWithServers:@[@"https://dns.alidns.com/dns-query", @"https://dns.google/dns-query"] recordType:type.intValue timeout:5];
        NSArray *records = [server query:[[QNDomain alloc] init:host] networkInfo:nil error:&err];
        NSLog(@"== records:%@", records);
        XCTAssertNil(err, "query error:%@", err);
        XCTAssertNotNil(records, "type:%@ query result nil", type);
        XCTAssertTrue(records.count > 0, "type:%@ query result empty", type);
    }
}

@end
