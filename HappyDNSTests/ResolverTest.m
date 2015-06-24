//
//  ResolverTest.m
//  HappyDNS
//
//  Created by bailong on 15/6/24.
//  Copyright (c) 2015年 Qiniu Cloud Storage. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "QNResolverDelegate.h"
#import "QNResolver.h"
#import "QNDomain.h"

@interface ResolverTest : XCTestCase

@end

@implementation ResolverTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testTemplate:(NSString*)server{
    id<QNResolverDelegate> resolver = [[QNResolver alloc] initWithAddres:server];
    NSArray * records = [resolver query:[[QNDomain alloc]init:@"baidu.com"]];
    XCTAssert(records != nil, @"Pass");
    XCTAssert(records.count > 0, @"Pass");
    
    records = [resolver query:[[QNDomain alloc]init:@"www.qiniu.com"]];
    XCTAssert(records != nil, @"Pass");
    XCTAssert(records.count >= 3 , @"Pass");
}

- (void)testLocal {
    [self testTemplate:nil];
}

//    http://www.alidns.com/
- (void)testAli {
    [self testTemplate:@"223.5.5.5"];
}

//    https://www.114dns.com/
- (void)test114 {
    [self testTemplate:@"114.114.115.115"];
}

//    http://dudns.baidu.com/
- (void)testDu {
    [self testTemplate:@"180.76.76.76"];
}

//    http://www.sdns.cn/
- (void)testCnnic {
    [self testTemplate:@"1.2.4.8"];
}

- (void)testGoogle {
    [self testTemplate:@"8.8.4.4"];
}

//    http://www.dnspai.com/
- (void)testPai {
    [self testTemplate:@"101.226.4.6"];
}

@end
