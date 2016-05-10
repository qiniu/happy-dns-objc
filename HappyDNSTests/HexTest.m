//
//  HexTest.m
//  HappyDNS
//
//  Created by bailong on 15/8/1.
//  Copyright (c) 2015年 Qiniu Cloud Storage. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "QNHex.h"

@interface HexTest : XCTestCase

@end

@implementation HexTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testHex {
    NSString *origin = @"12345678";
    NSString *hex = [QNHex encodeHexString:origin];
    XCTAssertEqual(origin.length * 2, hex.length, @"PASS");
    NSString *n = [QNHex decodeHexToString:hex];
    XCTAssertEqualObjects(origin, n, @"PASS");
}

@end
