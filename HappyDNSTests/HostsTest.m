//
//  HostsTest.m
//  HappyDNS
//
//  Created by bailong on 15/6/30.
//  Copyright (c) 2015年 Qiniu Cloud Storage. All rights reserved.
//

#import "QNDomain.h"
#import "QNHosts.h"
#import "QNNetworkInfo.h"
#import <XCTest/XCTest.h>

@interface HostsTest : XCTestCase

@end

@implementation HostsTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testQuery {
    QNHosts *hosts = [[QNHosts alloc] init];
    [hosts put:@"hello.qiniu.com" record:[[QNRecord alloc] init:@"1.1.1.1" ttl:120 type:kQNTypeA source:QNRecordSourceUnknown]];
    [hosts put:@"hello.qiniu.com" record:[[QNRecord alloc] init:@"2.2.2.2" ttl:120 type:kQNTypeA source:QNRecordSourceUnknown]];
    [hosts put:@"qiniu.com" record:[[QNRecord alloc] init:@"3.3.3.3" ttl:120 type:kQNTypeA source:QNRecordSourceUnknown]];
    QNNetworkInfo *info = [QNNetworkInfo normal];
    NSArray<QNRecord *> *array = [hosts query:[[QNDomain alloc] init:@"hello.qiniu.com"] networkInfo:info];
    XCTAssert(array.count == 2, @"Pass");
    XCTAssert([@"2.2.2.2" isEqual:array.firstObject.value], @"PASS");
    XCTAssert([@"1.1.1.1" isEqual:array[1].value], @"PASS");

    NSArray<QNRecord *> *array2 = [hosts query:[[QNDomain alloc] init:@"hello.qiniu.com"] networkInfo:info];
    XCTAssert(array2.count == 2, @"Pass");
    XCTAssert([@"1.1.1.1" isEqual:array2.firstObject.value], @"PASS");
    XCTAssert([@"2.2.2.2" isEqual:array2[1].value], @"PASS");
}

- (void)testCnc {
    QNHosts *hosts = [[QNHosts alloc] init];
    [hosts put:@"hello.qiniu.com" record:[[QNRecord alloc] init:@"1.1.1.1" ttl:120 type:kQNTypeA source:QNRecordSourceUnknown]];
    [hosts put:@"hello.qiniu.com" record:[[QNRecord alloc] init:@"2.2.2.2" ttl:120 type:kQNTypeA source:QNRecordSourceUnknown]];
    [hosts put:@"qiniu.com" record:[[QNRecord alloc] init:@"3.3.3.3" ttl:120 type:kQNTypeA source:QNRecordSourceUnknown]];
    [hosts put:@"qiniu.com" record:[[QNRecord alloc] init:@"4.4.4.4" ttl:120 type:kQNTypeA source:QNRecordSourceUnknown] provider:kQNISP_CNC];
    QNNetworkInfo *info = [[QNNetworkInfo alloc] init:kQNMOBILE provider:kQNISP_CNC];
    NSArray<QNRecord *> *r = [hosts query:[[QNDomain alloc] init:@"qiniu.com"] networkInfo:info];
    XCTAssertTrue(r.count == 1, @"PASS");
    XCTAssertEqualObjects(@"4.4.4.4", r.firstObject.value);
    r = [hosts query:[[QNDomain alloc] init:@"qiniu.com"] networkInfo:[QNNetworkInfo normal]];
    XCTAssertTrue(r.count == 1, @"PASS");
    XCTAssertEqualObjects(@"3.3.3.3", r.firstObject.value);
}

@end
