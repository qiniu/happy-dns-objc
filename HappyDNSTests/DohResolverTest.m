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
    NSString *host = @"qiniu.com";
    // https://dns.alidns.com/dns-query
    // https://dns.google/dns-query
    QNDohResolver *server = [QNDohResolver resolverWithServer:@"https://dns.alidns.com/dns-query" timeout:5];
    NSError *err = nil;
    
    NSArray *typeArray = @[@(kQNTypeA), @(kQNTypeCname), @(kQNTypeAAAA), @(kQNTypeTXT)];
    for (NSNumber *type in typeArray) {
        QNDnsResponse *response = [server lookupHost:host recordType:type.intValue error:&err];
        NSLog(@"response:%@", response);
        
        XCTAssertNil(err, "error:%@", err);
        XCTAssertTrue(response.rCode == 0, "type:%@ response:%@", type, response);
    }
    
    NSArray *ipv4List = [server query:[[QNDomain alloc] init:host] networkInfo:nil error:&err];
    NSLog(@"host:%@ ips:%@", host, ipv4List);
    XCTAssertNil(err, "ipv4 query error:%@", err);
    XCTAssertNotNil(ipv4List, "ipv4 query result nil");
    XCTAssertTrue(ipv4List.count > 0, "ipv4 query result empty");
}

- (void)testMutiDnsServer {
    NSString *host = @"qiniu.com";
    
    // https://dns.alidns.com/dns-query
    // https://dns.google/dns-query
    QNDohResolver *server = [QNDohResolver resolverWithServers:@[@"https://dns.alidns.com/dns-query", @"https://dns.google/dns-query"] timeout:5];
    NSError *err = nil;
    
    NSArray *typeArray = @[@(kQNTypeA), @(kQNTypeCname), @(kQNTypeAAAA), @(kQNTypeTXT)];
    for (NSNumber *type in typeArray) {
        QNDnsResponse *response = [server lookupHost:host recordType:type.intValue error:&err];
        NSLog(@"response:%@", response);
        
        XCTAssertNil(err, "error:%@", err);
        XCTAssertTrue(response.rCode == 0, "type:%@ response:%@", type, response);
    }
    
    NSArray *ipv4List = [server query:[[QNDomain alloc] init:host] networkInfo:nil error:&err];
    XCTAssertNil(err, "ipv4 query error:%@", err);
    XCTAssertNotNil(ipv4List, "ipv4 query result nil");
    XCTAssertTrue(ipv4List.count > 0, "ipv4 query result empty");
}

@end
