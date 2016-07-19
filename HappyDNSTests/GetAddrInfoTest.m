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

- (void)testNotSet {
    qn_set_dns_callback(NULL);
    struct addrinfo hints;
    struct addrinfo *ai;
    int x = qn_getaddrinfo("www.baidu.com", "http", &hints, &ai);
    XCTAssert(x == 0);
    XCTAssert(ai != NULL);
    qn_freeaddrinfo(ai);
}

static QNDnsManager *dns = nil;

static int count(struct addrinfo *ai) {
    int count = 0;
    while (ai != NULL) {
        count++;
        ai = ai->ai_next;
    }
    return count;
}

- (void) template:(const char *)host {
    struct addrinfo hints = {0};
    struct addrinfo *ai;
    int x = qn_getaddrinfo(host, "http", &hints, &ai);
    XCTAssert(x == 0);
    XCTAssert(ai != NULL);

    struct addrinfo hints2 = {0};
    struct addrinfo *ai2;
    int x2 = getaddrinfo(host, "http", &hints2, &ai2);
    XCTAssert(x2 == 0);
    XCTAssert(count(ai) <= count(ai2));
    NSLog(@"count qn %d ori %d", count(ai), count(ai2));

    qn_freeaddrinfo(ai);
    freeaddrinfo(ai2);
}

- (void)testCustomDns {
    dns = [[QNDnsManager alloc] init:@[ [QNResolver systemResolver] ] networkInfo:nil];
    [QNDnsManager setGetAddrInfoBlock:^NSArray *(NSString *host) {
        return [dns query:host];
    }];
    [self template:"baidu.com"];
    [self template:"www.qiniu.com"];
    [self template:"qq.com"];
    [self template:"taobao.com"];
}

@end
