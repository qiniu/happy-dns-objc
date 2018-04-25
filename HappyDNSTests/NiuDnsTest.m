//
//  NiuDnsTest.m
//  HappyDNS
//
//  Created by 何昊宇 on 2018/3/8.
//  Copyright © 2018年 Qiniu Cloud Storage. All rights reserved.
//

#import "QNDomain.h"
#import "QNNiuDns.h"
#import "QNRecord.h"
#import "QNResolverDelegate.h"
#import <XCTest/XCTest.h>

@interface NiuDnsTest : XCTestCase

@end

@implementation NiuDnsTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testHttpDNS {
    id<QNResolverDelegate> resolver = [[QNNiuDns alloc] initWithAccountId:@"8470251734" encryptKey:@"73047d275cce9496555b08f86c7286d8" expireTime:(long)[[NSDate date] timeIntervalSince1970] + 3600 isHttps:YES isNeedEncrypted:YES];
    NSArray *records = [resolver query:[[QNDomain alloc] init:@"www.baidu.com"] networkInfo:nil error:nil];
    XCTAssert(records != nil, @"Pass");
    XCTAssert(records.count > 0, @"Pass");
    XCTAssert(records.count >= 1, @"Pass");
    QNRecord *record = [records objectAtIndex:0];
    XCTAssert(record.ttl >= 0, @"Pass");

    records = [resolver query:[[QNDomain alloc] init:@"www.qiniu.com"] networkInfo:nil error:nil];
    XCTAssert(records != nil, @"Pass");
    XCTAssert(records.count >= 1, @"Pass");
    record = [records objectAtIndex:0];
    XCTAssert(record.ttl >= 0, @"Pass");
}

- (void)testHttpsDNS {
    id<QNResolverDelegate> resolver = [[QNNiuDns alloc] initWithAccountId:@"8470251734" encryptKey:@"73047d275cce9496555b08f86c7286d8" expireTime:(long)[[NSDate date] timeIntervalSince1970] + 3600 isHttps:NO isNeedEncrypted:NO];
    NSArray *records = [resolver query:[[QNDomain alloc] init:@"www.baidu.com"] networkInfo:nil error:nil];
    XCTAssert(records != nil, @"Pass");
    XCTAssert(records.count > 0, @"Pass");
    XCTAssert(records.count >= 1, @"Pass");
    QNRecord *record = [records objectAtIndex:0];
    XCTAssert(record.ttl >= 0, @"Pass");

    records = [resolver query:[[QNDomain alloc] init:@"www.qiniu.com"] networkInfo:nil error:nil];
    XCTAssert(records != nil, @"Pass");
    XCTAssert(records.count >= 1, @"Pass");
    record = [records objectAtIndex:0];
    XCTAssert(record.ttl >= 0, @"Pass");
}

@end
