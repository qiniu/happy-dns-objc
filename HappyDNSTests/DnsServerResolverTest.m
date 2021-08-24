//
//  DnsServerTest.m
//  HappyDNS
//
//  Created by yangsen on 2021/7/28.
//  Copyright © 2021 Qiniu Cloud Storage. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "QNDnsManager.h"
#import "QNDomain.h"
#import "QNDnsUdpResolver.h"

@interface DnsServerResolverTest : XCTestCase

@end

@implementation DnsServerResolverTest

- (void)testSimpleDns {
    NSString *host = @"en.wikipedia.org";
    NSError *err = nil;
    
    NSArray *typeArray = @[@(kQNTypeA), @(kQNTypeAAAA)];
    for (NSNumber *type in typeArray) {
        QNDnsUdpResolver *server = [QNDnsUdpResolver resolverWithServerIP:@"8.8.8.8" recordType:type.intValue timeout:5];
        NSArray *records = [server query:[[QNDomain alloc] init:host] networkInfo:nil error:&err];
        NSLog(@"== records:%@", records);
        XCTAssertNil(err, "query error:%@", err);
        XCTAssertNotNil(records, "type:%@ query result nil", type);
        XCTAssertTrue(records.count > 0, "type:%@ query result empty", type);
    }
    
    for (NSNumber *type in typeArray) {
        QNDnsUdpResolver *server = [QNDnsUdpResolver resolverWithServerIP:@"8.8.8.8" recordType:type.intValue timeout:5];
        QNDnsManager *manager = [[QNDnsManager alloc] init:@[server] networkInfo:nil];
        NSArray *records = [manager queryRecords:host];
        NSLog(@"== records:%@", records);
        XCTAssertNotNil(records, "type:%@ query result nil", type);
        XCTAssertTrue(records.count > 0, "type:%@ query result empty", type);
    }
}

- (void)testMultiDnsServer {
    NSString *host = @"en.wikipedia.org";
    NSError *err = nil;
    
    NSArray *typeArray = @[@(kQNTypeA), @(kQNTypeAAAA)];
    for (NSNumber *type in typeArray) {
        QNDnsUdpResolver *server = [QNDnsUdpResolver resolverWithServerIPs:@[@"8.8.8.8", @"114.114.114.114"] recordType:type.intValue queue:nil timeout:5];
        NSArray *records = [server query:[[QNDomain alloc] init:host] networkInfo:nil error:&err];
        NSLog(@"== records:%@", records);
        XCTAssertNil(err, "query error:%@", err);
        XCTAssertNotNil(records, "type:%@ query result nil", type);
        XCTAssertTrue(records.count > 0, "type:%@ query result empty", type);
    }
}

@end
