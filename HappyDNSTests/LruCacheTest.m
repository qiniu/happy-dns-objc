//
//  LruCacheTest.m
//  HappyDNS
//
//  Created by bailong on 16/7/5.
//  Copyright © 2016年 Qiniu Cloud Storage. All rights reserved.
//

#import "QNLruCache.h"
#import <XCTest/XCTest.h>

@interface LruCacheTest : XCTestCase

@end

@implementation LruCacheTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPut {
    QNLruCache *x = [[QNLruCache alloc] init:2];
    [x setObject:@"1" forKey:@"1"];
    [x setObject:@"2" forKey:@"2"];
    [x setObject:@"3" forKey:@"3"];
    XCTAssertNil([x objectForKey:@"1"]);
    XCTAssertEqualObjects(@"2", [x objectForKey:@"2"]);
    XCTAssertEqualObjects(@"3", [x objectForKey:@"3"]);
    [x removeObjectForKey:@"2"];
    [x setObject:@"1" forKey:@"1"];
    XCTAssertEqualObjects(@"1", [x objectForKey:@"1"]);
    XCTAssertNil([x objectForKey:@"2"]);
}

- (void)testOut {
    QNLruCache *x = [[QNLruCache alloc] init:2];
    [x setObject:@"1" forKey:@"1"];
    [x setObject:@"2" forKey:@"2"];
    [x objectForKey:@"1"];
    [x setObject:@"3" forKey:@"3"];
    XCTAssertNil([x objectForKey:@"2"]);
    XCTAssertEqualObjects(@"1", [x objectForKey:@"1"]);
    XCTAssertEqualObjects(@"3", [x objectForKey:@"3"]);
    [x removeObjectForKey:@"2"];
    [x setObject:@"1" forKey:@"1"];
    XCTAssertEqualObjects(@"1", [x objectForKey:@"1"]);
    XCTAssertNil([x objectForKey:@"2"]);
}

- (void)testClear {
    QNLruCache *x = [[QNLruCache alloc] init:2];
    [x setObject:@"1" forKey:@"1"];
    [x setObject:@"2" forKey:@"2"];
    [x setObject:@"3" forKey:@"3"];
    [x removeAllObjects];
    XCTAssertNil([x objectForKey:@"3"]);
    [x setObject:@"1" forKey:@"1"];
    [x setObject:@"2" forKey:@"2"];
    [x setObject:@"3" forKey:@"3"];
    XCTAssertNil([x objectForKey:@"1"]);
    XCTAssertEqualObjects(@"2", [x objectForKey:@"2"]);
    XCTAssertEqualObjects(@"3", [x objectForKey:@"3"]);
}

@end
