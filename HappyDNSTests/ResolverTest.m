//
//  ResolverTest.m
//  HappyDNS
//
//  Created by bailong on 15/6/24.
//  Copyright (c) 2015年 Qiniu Cloud Storage. All rights reserved.
//

#import "QNDomain.h"
#import "QNRecord.h"
#import "QNResolver.h"
#import "QNResolverDelegate.h"
#import <XCTest/XCTest.h>

@interface ResolverTest : XCTestCase

@end

@implementation ResolverTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void) template:(NSString *)server {
    id<QNResolverDelegate> resolver = [[QNResolver alloc] initWithAddres:server];
    NSArray *records = [resolver query:[[QNDomain alloc] init:@"baidu.com"] networkInfo:nil error:nil];
    XCTAssert(records != nil, @"Pass");
    XCTAssert(records.count >= 1, @"Pass");
    QNRecord *record = [records objectAtIndex:0];
    XCTAssert(record.ttl >= 0, @"Pass");

    records = [resolver query:[[QNDomain alloc] init:@"www.qiniu.com"] networkInfo:nil error:nil];
    XCTAssert(records != nil, @"Pass");
    XCTAssert(records.count >= 3, @"Pass");
    record = [records objectAtIndex:0];
    XCTAssert(record.ttl >= 0, @"Pass");

    records = [resolver query:[[QNDomain alloc] init:@"fasdfasfasf.qiniu.com"] networkInfo:nil error:nil];
    XCTAssert(records == nil, @"Pass");
}

- (void)templateV6:(NSString *)server {
    id<QNResolverDelegate> resolver = [[QNResolver alloc] initWithAddres:server];
    NSArray *records = [resolver query:[[QNDomain alloc] init:@"ipv6test.qiniu.com"] networkInfo:nil error:nil];
    XCTAssert(records != nil, @"Pass");
    XCTAssert(records.count >= 1, @"Pass");
    QNRecord *record = [records objectAtIndex:0];
    XCTAssert(record.ttl >= 0, @"Pass");
    XCTAssert(record.type == kQNTypeAAAA, @"Pass");
    XCTAssert([record.value isEqual:@"2404:6800:4005:802::2004"], @"Pass");
}

- (void)testLocal {
    [self template:nil];
}

- (void)testLocalV6 {
    [self templateV6:nil];
}

//    http://www.alidns.com/
//- (void)testAli {
//	[self template:@"223.5.5.5"];
//}

//    https://www.114dns.com/
- (void)test114 {
    [self template:@"114.114.115.115"];
}

- (void)test114V6 {
    [self templateV6:@"114.114.115.115"];
}

//    http://dudns.baidu.com/
//- (void)testDu {
//	[self template:@"180.76.76.76"];
//}

//    http://www.sdns.cn/
//- (void)testCnnic {
//	[self template:@"1.2.4.8"];
//}

- (void)testGoogle {
    [self template:@"8.8.4.4"];
}

- (void)testGoogleV6 {
    [self templateV6:@"8.8.4.4"];
}

//    http://www.dnspai.com/
//- (void)testPai {
//	[self template:@"101.226.4.6"];
//}

@end
