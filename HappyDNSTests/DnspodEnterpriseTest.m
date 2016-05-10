//
//  DnspodEnterpriseTest.m
//  HappyDNS
//
//  Created by bailong on 15/8/1.
//  Copyright (c) 2015年 Qiniu Cloud Storage. All rights reserved.
//

#import "QNDnspodEnterprise.h"
#import "QNDomain.h"
#import "QNRecord.h"
#import "QNResolverDelegate.h"
#import <XCTest/XCTest.h>

@interface DnspodEnterpriseTest : XCTestCase

@end

@implementation DnspodEnterpriseTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDnspodEnterprise {
    //    id <QNResolverDelegate> resolver = [[QNDnspodEnterprise alloc] initWithId:@"007" key:@"abcdef"];
    //    NSArray *records = [resolver query:[[QNDomain alloc]init:@"baidu.com"] networkInfo:nil error:nil];
    //    XCTAssert(records != nil, @"Pass");
    //    XCTAssert(records.count > 0, @"Pass");
    //    XCTAssert(records.count >= 1, @"Pass");
    //    QNRecord *record = [records objectAtIndex:0];
    //    XCTAssert(record.ttl >= 0, @"Pass");
    //
    //    records = [resolver query:[[QNDomain alloc]init:@"www.qiniu.com"] networkInfo:nil error:nil];
    //    XCTAssert(records != nil, @"Pass");
    //    XCTAssert(records.count >= 1, @"Pass");
    //    record = [records objectAtIndex:0];
    //    XCTAssert(record.ttl >= 0, @"Pass");
}

@end
