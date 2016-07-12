//
//  DnspodFreeTest.m
//  HappyDNS
//
//  Created by bailong on 15/6/25.
//  Copyright (c) 2015年 Qiniu Cloud Storage. All rights reserved.
//

#import "QNDnspodFree.h"
#import "QNDomain.h"
#import "QNRecord.h"
#import "QNResolverDelegate.h"
#import <XCTest/XCTest.h>

@interface DnspodFreeTest : XCTestCase

@end

@implementation DnspodFreeTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDnspodFree {
    id<QNResolverDelegate> resolver = [[QNDnspodFree alloc] init];
    NSArray *records = [resolver query:[[QNDomain alloc] init:@"qq.com"] networkInfo:nil error:nil];
    XCTAssert(records != nil, @"Pass");
    XCTAssert(records.count > 0, @"Pass");
    XCTAssert(records.count >= 1, @"Pass");
    QNRecord *record = [records objectAtIndex:0];
    XCTAssert(record.ttl >= 0, @"Pass");

    records = [resolver query:[[QNDomain alloc] init:@"www.qiniu.com"] networkInfo:nil error:nil];
    XCTAssert(records != nil, @"Pass");
    XCTAssert(records.count >= 1, @"Pass");
    record = [records objectAtIndex:0];
    XCTAssert(record.ttl >= 0, @"Pass");
}

- (void)testTimeout {
    id<QNResolverDelegate> resolver = [[QNDnspodFree alloc] initWithServer:@"8.1.1.1" timeout:5];
    NSDate *t1 = [NSDate date];
    NSError *err;
    NSArray *records = [resolver query:[[QNDomain alloc] init:@"qq.com"] networkInfo:nil error:&err];
    NSTimeInterval duration = -[t1 timeIntervalSinceNow];
    XCTAssert(records == nil, @"Pass");
    XCTAssert(err != nil, @"Pass");
    XCTAssert(err.code == NSURLErrorTimedOut, @"Pass");
    XCTAssert(duration > 4 && duration < 6, @"Pass");
}

@end
