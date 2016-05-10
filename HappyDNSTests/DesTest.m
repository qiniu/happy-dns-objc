//
//  DesTest.m
//  HappyDNS
//
//  Created by bailong on 15/8/1.
//  Copyright (c) 2015年 Qiniu Cloud Storage. All rights reserved.
//

#import "QNDes.h"
#import <XCTest/XCTest.h>

@interface DesTest : XCTestCase

@end

@implementation DesTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testEncrypt {
    NSData *key = [@"12345678" dataUsingEncoding:NSUTF8StringEncoding];
    NSString *origin = @"abcdef";
    QNDes *des = [[QNDes alloc] init:key];
    NSData *enc = [des encrypt:[origin dataUsingEncoding:NSUTF8StringEncoding]];
    NSData *dec = [des decrpyt:enc];
    NSString *n = [[NSString alloc] initWithData:dec encoding:NSUTF8StringEncoding];
    // This is an example of a functional test case.
    XCTAssertEqualObjects(origin, n, @"PASS");
}

@end
