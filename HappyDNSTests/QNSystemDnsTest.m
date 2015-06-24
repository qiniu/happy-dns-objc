//
//  QNSystemDnsTest.m
//  HappyDNS
//
//  Created by bailong on 15/6/24.
//  Copyright (c) 2015年 Qiniu Cloud Storage. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "QNSystemDnsServer.h"

@interface QNSystemDnsTest : XCTestCase

@end

@implementation QNSystemDnsTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSystem {
    NSArray * servers = [QNSystemDnsServer servers];
    XCTAssertTrue([servers count] > 0);
}

@end
