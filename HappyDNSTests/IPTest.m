//
//  IPTest.m
//  HappyDNS
//
//  Created by bailong on 16/5/26.
//  Copyright © 2016年 Qiniu Cloud Storage. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "QNIP.h"

@interface IPTest : XCTestCase

@end

@implementation IPTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAdaptiveIP {
    NSString* ip = @"1.2.3.4";
    XCTAssertEqualObjects(ip, [QNIP adaptiveIp:ip], @"pass");
}

- (void)testLocalIP {
    NSString* ip = [QNIP local];
    NSLog(@"ip %@", ip);
    XCTAssertNotNil(ip, @"pass");
}

- (void)testHost {
    NSString* ipv4 = @"1.2.3.4";
    XCTAssertEqualObjects(ipv4, [QNIP ipHost:ipv4], @"pass");

    NSString* domain = @"a.b.c";
    XCTAssertEqualObjects(domain, [QNIP ipHost:domain], @"pass");

    NSString* ipv6 = @"::AB:CD";
    NSString* a = [NSString stringWithFormat:@"[%@]", ipv6];
    XCTAssertEqualObjects(a, [QNIP ipHost:ipv6], @"pass");
}

@end
