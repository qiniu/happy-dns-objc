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
    NSString* ip2 = [QNIP adaptiveIp:ip];
    XCTAssertNotNil(ip2, @"pass");
    if (![QNIP isV6]) {
        XCTAssertEqualObjects(ip2, ip, @"pass");
    } else {
        XCTAssertEqualObjects(ip2, @"64:ff9b::102:304", @"pass");
    }
}

- (void)testAdaptiveIP2 {
    NSString* ip = @"8.8.8.8";
    NSString* ip2 = [QNIP adaptiveIp:ip];
    NSLog(@"ip %@", ip2);
    XCTAssertNotNil(ip2, @"pass");
    if (![QNIP isV6]) {
        XCTAssertEqualObjects(ip2, ip, @"pass");
    } else {
        XCTAssertEqualObjects(ip2, @"64:ff9b::808:808", @"pass");
    }
}

- (void)testAdaptiveIP3 {
    NSString* ip = @"119.29.29.29";
    NSString* ip2 = [QNIP adaptiveIp:ip];
    NSLog(@"ip %@", ip2);
    XCTAssertNotNil(ip2, @"pass");
    if (![QNIP isV6]) {
        XCTAssertEqualObjects(ip2, ip, @"pass");
    } else {
        XCTAssertEqualObjects(ip2, @"64:ff9b::771d:1d1d", @"pass");
    }
}

- (void)testNat64 {
    NSString* ip = @"119.29.29.29";
    NSString* ip2 = [QNIP nat64:ip];
    NSLog(@"ip %@", ip2);
    XCTAssertNotNil(ip2, @"pass");

    XCTAssertEqualObjects(ip2, @"64:ff9b::771d:1d1d", @"pass");
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

- (void)testMayBeIpV4 {
    NSString* ip = @"0.0.0.0";
    XCTAssert([QNIP mayBeIpV4:ip]);

    ip = @"a.0.0.0";
    XCTAssert(![QNIP mayBeIpV4:ip]);

    ip = @"0.0.0";
    XCTAssert(![QNIP mayBeIpV4:ip]);

    ip = @"a.b.com";
    XCTAssert(![QNIP mayBeIpV4:ip]);

    ip = @"255.255.255.255";
    XCTAssert([QNIP mayBeIpV4:ip]);

    ip = @"99.99.99.99";
    XCTAssert([QNIP mayBeIpV4:ip]);
}

@end
