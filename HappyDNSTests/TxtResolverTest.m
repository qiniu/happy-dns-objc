//
//  TxtResolverTest.m
//  HappyDNS
//
//  Created by bailong on 16/1/5.
//  Copyright © 2016年 Qiniu Cloud Storage. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "QNDomain.h"
#import "QNRecord.h"
#import "QNResolverDelegate.h"
#import "QNTxtResolver.h"

@interface TxtResolverTest : XCTestCase

@end

@implementation TxtResolverTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void) template:(NSString *)server {
    id<QNResolverDelegate> resolver = [[QNTxtResolver alloc] initWithAddress:server];
    // txttest.qiniu.com.   600 IN  TXT "183.136.139.10,183.136.139.16,115.231.182.136"
    NSArray *records = [resolver query:[[QNDomain alloc] init:@"txttest.qiniu.com"] networkInfo:nil error:nil];
    XCTAssert(records != nil, @"Pass");
    XCTAssert(records.count >= 2, @"Pass");
    QNRecord *record = [records objectAtIndex:0];
    XCTAssert(record.ttl >= 0, @"Pass");
}

- (void)testLocal {
    [self template:nil];
}

- (void)testDnspod {
    [self template:@"119.29.29.29"];
}

@end
