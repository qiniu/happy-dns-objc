//
//  DnsServerTest.m
//  HappyDNS
//
//  Created by yangsen on 2021/7/28.
//  Copyright © 2021 Qiniu Cloud Storage. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "QNDomain.h"
#import "QNDnsUdpResolver.h"

@interface DnsServerResolverTest : XCTestCase

@end

@implementation DnsServerResolverTest

- (void)testSimpleDns {
    NSString *host = @"qiniu.com";
    NSError *err = nil;
    
    NSArray *typeArray = @[@(kQNTypeA), @(kQNTypeCname), @(kQNTypeAAAA), @(kQNTypeTXT)];
    for (NSNumber *type in typeArray) {
        QNDnsUdpResolver *server = [QNDnsUdpResolver resolverWithServerIP:@"8.8.8.8" recordType:type.intValue timeout:5];
        QNDnsResponse *response = [server lookupHost:host error:&err];
        NSLog(@"response:%@", response);
        
        XCTAssertNil(err, "error:%@", err);
        XCTAssertTrue(response.rCode == 0, "type:%@ response:%@", type, response);
    }
    
    QNDnsUdpResolver *server = [QNDnsUdpResolver resolverWithServerIP:@"8.8.8.8"];
    NSArray *ipv4List = [server query:[[QNDomain alloc] init:host] networkInfo:nil error:&err];
    XCTAssertNil(err, "ipv4 query error:%@", err);
    XCTAssertNotNil(ipv4List, "ipv4 query result nil");
    XCTAssertTrue(ipv4List.count > 0, "ipv4 query result empty");
}

- (void)testMutiDnsServer {
    NSString *host = @"qiniu.com";
    NSError *err = nil;
    
    NSArray *typeArray = @[@(kQNTypeA), @(kQNTypeCname), @(kQNTypeAAAA), @(kQNTypeTXT)];
    for (NSNumber *type in typeArray) {
        QNDnsUdpResolver *server = [QNDnsUdpResolver resolverWithServerIPs:@[@"8.8.8.8", @"114.114.114.114"] recordType:type.intValue queue:nil timeout:5];
        QNDnsResponse *response = [server lookupHost:host error:&err];
        NSLog(@"response:%@", response);
        
        XCTAssertNil(err, "error:%@", err);
        XCTAssertTrue(response.rCode == 0, "type:%@ response:%@", type, response);
    }
    
    QNDnsUdpResolver *server = [QNDnsUdpResolver resolverWithServerIPs:@[@"8.8.8.8", @"114.114.114.114"] recordType:kQNTypeA queue:nil timeout:5];
    NSArray *ipv4List = [server query:[[QNDomain alloc] init:host] networkInfo:nil error:&err];
    XCTAssertNil(err, "ipv4 query error:%@", err);
    XCTAssertNotNil(ipv4List, "ipv4 query result nil");
    XCTAssertTrue(ipv4List.count > 0, "ipv4 query result empty");
}

@end
