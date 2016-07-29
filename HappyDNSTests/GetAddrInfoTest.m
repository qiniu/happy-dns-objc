//
//  GetAddrInfoTest.m
//  HappyDNS
//
//  Created by bailong on 16/7/19.
//  Copyright © 2016年 Qiniu Cloud Storage. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <netdb.h>

#import "QNDnsManager.h"
#import "QNDnspodFree.h"
#import "QNDomain.h"
#import "QNNetworkInfo.h"
#import "QNResolver.h"

#import "QNGetAddrInfo.h"
@interface GetAddrInfoTest : XCTestCase

@end

@implementation GetAddrInfoTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

static int count(struct addrinfo *ai) {
    int count = 0;
    while (ai != NULL) {
        count++;
        ai = ai->ai_next;
    }
    return count;
}

static struct addrinfo resetHints() {
    struct addrinfo hints = {0};
    hints.ai_family = PF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_flags = AI_DEFAULT;
    return hints;
}

- (void)testNotSet {
    qn_set_dns_callback(NULL);
    struct addrinfo hints = resetHints();
    struct addrinfo *ai = NULL;
    int x = qn_getaddrinfo("baidu.com", "80", &hints, &ai);
    XCTAssert(x == 0);
    XCTAssert(ai != NULL);

#if __IPHONE_OS_VERSION_MIN_REQUIRED
    struct addrinfo hints2 = resetHints();
    struct addrinfo *ai2 = NULL;
    int x2 = getaddrinfo("baidu.com", "80", &hints2, &ai2);
    NSLog(@"return qn %d, ori %d", x, x2);
    NSLog(@"count qn %d, ori %d", count(ai), count(ai2));
    XCTAssert(x2 == x);
    freeaddrinfo(ai2);
#endif
    qn_freeaddrinfo(ai);
}

static QNDnsManager *dns = nil;

- (void) template:(const char *)host {
    struct addrinfo hints = resetHints();
    struct addrinfo *ai = NULL;
    int x = qn_getaddrinfo(host, "80", &hints, &ai);
    XCTAssert(x == 0);
    XCTAssert(ai != NULL);

#if __IPHONE_OS_VERSION_MIN_REQUIRED
    struct addrinfo hints2 = resetHints();
    struct addrinfo *ai2 = NULL;
    int x2 = getaddrinfo(host, "80", &hints2, &ai2);
    XCTAssert(x2 == 0);
    XCTAssert(count(ai) <= count(ai2));
    NSLog(@"return qn %d, ori %d", x, x2);
    NSLog(@"count qn %d ori %d", count(ai), count(ai2));
    freeaddrinfo(ai2);
#endif

    qn_freeaddrinfo(ai);
}

- (void)testCustomDns {
    dns = [[QNDnsManager alloc] init:@[ [QNResolver systemResolver] ] networkInfo:nil];
    [QNDnsManager setDnsManagerForGetAddrInfo:dns];
    [self template:"baidu.com"];
    [self template:"www.qiniu.com"];
    [self template:"qq.com"];
    [self template:"taobao.com"];
}

- (void)testNoIpStatusCallback {
    qn_set_dns_callback(NULL);
    struct addrinfo hints2 = resetHints();
    struct addrinfo *ai2 = NULL;
    qn_ip_report(ai2, 3, 4);
    getaddrinfo("8.8.8.8", "80", &hints2, &ai2);
    qn_ip_report(ai2, 1, 2);
    freeaddrinfo(ai2);
}

- (void)testIpStatusCallback {
    __block NSString *ip1;
    __block int c = 0;
    __block int m = 0;
    [QNDnsManager setIpStatusCallback:^(NSString *ip, int code, int ms) {
        ip1 = ip;
        c = code;
        m = ms;
    }];
    struct addrinfo hints2 = resetHints();
    struct addrinfo *ai2 = NULL;
    getaddrinfo("8.8.8.8", "80", &hints2, &ai2);

    qn_ip_report(ai2, 1, 2);
    freeaddrinfo(ai2);
    XCTAssertEqual(c, 1);
    XCTAssertEqual(m, 2);
    XCTAssertEqualObjects(ip1, @"8.8.8.8");
}

@end
