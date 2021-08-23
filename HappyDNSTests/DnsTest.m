//
//  DnsTest.m
//  HappyDNS
//
//  Created by bailong on 15/6/30.
//  Copyright (c) 2015年 Qiniu Cloud Storage. All rights reserved.
//

#import "QNDnsManager.h"
#import "QNDomain.h"
#import "QNHijackingDetectWrapper.h"
#import "QNNetworkInfo.h"
#import "QNResolver.h"
#import <XCTest/XCTest.h>

@interface DnsTest : XCTestCase

@end

@interface NotRunResolver : NSObject <QNResolverDelegate>
- (NSArray *)query:(QNDomain *)domain networkInfo:(QNNetworkInfo *)netInfo error:(NSError *__autoreleasing *)error;

@end

@implementation NotRunResolver

- (NSArray *)query:(QNDomain *)domain networkInfo:(QNNetworkInfo *)netInfo error:(NSError *__autoreleasing *)error {
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:@"does not run here"
                                 userInfo:nil];
    return nil;
}

@end

@implementation DnsTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDns {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:[QNResolver systemResolver]];
    [array addObject:[[QNResolver alloc] initWithAddress:@"119.29.29.29"]];
    QNDnsManager *dns = [[QNDnsManager alloc] init:array networkInfo:[QNNetworkInfo normal]];
    NSArray *records = [dns queryRecords:@"www.baidu.com"];
    XCTAssertNotNil(records, @"PASS");
    XCTAssertTrue(records.count > 0, @"PASS");
}

- (void)testCnc {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:[QNResolver systemResolver]];
    [array addObject:[[QNResolver alloc] initWithAddress:@"119.29.29.29"]];
    QNNetworkInfo *info = [[QNNetworkInfo alloc] init:kQNMOBILE provider:kQNISP_CNC];
    QNDnsManager *dns = [[QNDnsManager alloc] init:array networkInfo:info];
    [dns putHosts:@"hello.qiniu.com" ipv4:@"1.1.1.1"];
    [dns putHosts:@"hello.qiniu.com" ipv4:@"2.2.2.2"];
    [dns putHosts:@"qiniu.com" ipv4:@"3.3.3.3"];
    [dns putHosts:@"qiniu.com" ip:@"4.4.4.4" type:kQNTypeA provider:kQNISP_CNC];
    QNDomain *domain = [[QNDomain alloc] init:@"qiniu.com" hostsFirst:YES hasCname:NO maxTtl:0];
    NSArray<QNRecord *> *r = [dns queryRecordsWithDomain:domain];
    XCTAssertEqual(r.count, 1, @"PASS");
    XCTAssertEqualObjects(@"4.4.4.4", [r.firstObject value], @"PASS");
}

- (void)testTtl {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:[[QNHijackingDetectWrapper alloc] initWithResolver:[QNResolver systemResolver]]];
    [array addObject:[[QNHijackingDetectWrapper alloc] initWithResolver:[[QNResolver alloc] initWithAddress:@"114.114.115.115"]]];
    QNNetworkInfo *info = [[QNNetworkInfo alloc] init:kQNMOBILE provider:kQNISP_CNC];
    QNDnsManager *dns = [[QNDnsManager alloc] init:array networkInfo:info];
    [dns putHosts:@"hello.qiniu.com" ipv4:@"1.1.1.1"];
    [dns putHosts:@"hello.qiniu.com" ipv4:@"2.2.2.2"];
    [dns putHosts:@"qiniu.com" ipv4:@"3.3.3.3"];
    [dns putHosts:@"qiniu.com" ip:@"4.4.4.4" type:kQNTypeA provider:kQNISP_CNC];

    QNDomain *domain = [[QNDomain alloc] init:@"qiniu.com" hostsFirst:NO hasCname:NO maxTtl:10];
    NSArray<QNRecord *> *r = [dns queryRecordsWithDomain:domain];
    XCTAssertEqual(r.count, 1, @"PASS");
    XCTAssertEqualObjects(@"4.4.4.4", [r.firstObject value], @"PASS");

    domain = [[QNDomain alloc] init:@"qiniu.com" hostsFirst:NO hasCname:NO maxTtl:1000];
    r = [dns queryRecordsWithDomain:domain];
    XCTAssertEqual(r.count, 1, @"PASS");
    XCTAssertFalse([@"4.4.4.4" isEqualToString:[r.firstObject value]], @"PASS");
}

- (void)testCname {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:[[QNHijackingDetectWrapper alloc] initWithResolver:[QNResolver systemResolver]]];
    [array addObject:[[QNHijackingDetectWrapper alloc] initWithResolver:[[QNResolver alloc] initWithAddress:@"114.114.115.115"]]];
    QNNetworkInfo *info = [QNNetworkInfo normal];
    QNDnsManager *dns = [[QNDnsManager alloc] init:array networkInfo:info];
    [dns putHosts:@"hello.qiniu.com" ipv4:@"1.1.1.1"];
    [dns putHosts:@"hello.qiniu.com" ipv4:@"2.2.2.2"];
    [dns putHosts:@"qiniu.com" ipv4:@"3.3.3.3"];
    [dns putHosts:@"qiniu.com" ip:@"4.4.4.4" type:kQNTypeA provider:kQNISP_CNC];

    QNDomain *domain = [[QNDomain alloc] init:@"qiniu.com" hostsFirst:NO hasCname:YES maxTtl:0];
    NSArray<QNRecord *> *r = [dns queryRecordsWithDomain:domain];
    XCTAssertEqual(r.count, 1, @"PASS");
    XCTAssertEqualObjects(@"3.3.3.3", [r.firstObject value], @"PASS");

    domain = [[QNDomain alloc] init:@"qiniu.com" hostsFirst:NO hasCname:NO maxTtl:0];
    r = [dns queryRecordsWithDomain:domain];
    XCTAssertEqual(r.count, 1, @"PASS");
    XCTAssertFalse([@"3.3.3.3" isEqualToString:r[0]], @"PASS");
}

- (void)testUrlQuery {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:[QNResolver systemResolver]];
    [array addObject:[[QNResolver alloc] initWithAddress:@"119.29.29.29"]];
    QNDnsManager *dns = [[QNDnsManager alloc] init:array networkInfo:[QNNetworkInfo normal]];
    NSURL *u = [[NSURL alloc] initWithString:@"rtmp://www.qiniu.com/abc?q=1"];
    NSURL *u2 = [dns queryAndReplaceWithIP:u];

    XCTAssertNotNil(u2, @"PASS");
    NSLog(@"%@ %@", u.path, u2.path);
    XCTAssertEqualObjects(u.path, u2.path, @"PASS");
    XCTAssertEqualObjects(u.scheme, u2.scheme, @"PASS");
    XCTAssertNotEqualObjects(u.host, u2.host, @"PASS");
}

- (void)testUrlQueryV6 {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:[QNResolver systemResolver]];
    [array addObject:[[QNResolver alloc] initWithAddress:@"119.29.29.29"]];
    QNDnsManager *dns = [[QNDnsManager alloc] init:array networkInfo:[QNNetworkInfo normal]];
    NSURL *u = [[NSURL alloc] initWithString:@"rtmp://ipv6test.qiniu.com/abc?q=1"];
    NSURL *u2 = [dns queryAndReplaceWithIP:u];

    XCTAssertNotNil(u2, @"PASS");
    NSLog(@"path %@ %@", u.path, u2.path);
    XCTAssertEqualObjects(u.path, u2.path, @"PASS");
    XCTAssertEqualObjects(u.scheme, u2.scheme, @"PASS");
    NSLog(@"host %@ %@", u.host, u2.host);
    XCTAssertNotEqualObjects(u.host, u2.host, @"PASS");
}

- (void)testIpQuery {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:[NotRunResolver new]];
    [array addObject:[[QNResolver alloc] initWithAddress:@"119.29.29.29"]];
    QNDnsManager *dns = [[QNDnsManager alloc] init:array networkInfo:[QNNetworkInfo normal]];
    NSURL *u = [[NSURL alloc] initWithString:@"rtmp://119.29.29.29/abc?q=1"];
    NSURL *u2 = [dns queryAndReplaceWithIP:u];

    XCTAssertNotNil(u2, @"PASS");
    NSLog(@"%@ %@", u.path, u2.path);
    XCTAssertEqualObjects(u.path, u2.path, @"PASS");
    XCTAssertEqualObjects(u.scheme, u2.scheme, @"PASS");
    XCTAssertEqualObjects(u.host, u2.host, @"PASS");
}

- (void)testNeedHttpDns {
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    NSString *tzName = [timeZone name];
    if ([tzName isEqual:@"Asia/Shanghai"]) {
        XCTAssertTrue([QNDnsManager needHttpDns]);
    } else {
        XCTAssertFalse([QNDnsManager needHttpDns]);
    }
}

@end
