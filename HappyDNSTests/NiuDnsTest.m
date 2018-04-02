//
//  NiuDnsTest.m
//  HappyDNS
//
//  Created by 何昊宇 on 2018/3/8.
//  Copyright © 2018年 Qiniu Cloud Storage. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "QNDomain.h"
#import "QNRecord.h"
#import "QNResolverDelegate.h"
#import "QNNiuDns.h"

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

- (void)testHttpDNSWithEncryptKey {
    id<QNResolverDelegate> resolver = [[QNNiuDns alloc] initWithAccountId:@"123456" encryptKey:@"a0dfe6fe42c4d948bb52d022b1a4a4d8" expireTime:3600];
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

- (void)testHttpDNS {
    id<QNResolverDelegate> resolver = [[QNNiuDns alloc] initWithAccountId:@"123456"];
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
