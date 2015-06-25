//
//  DnspodFreeTest.m
//  HappyDNS
//
//  Created by bailong on 15/6/25.
//  Copyright (c) 2015年 Qiniu Cloud Storage. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "QNDnspodFree.h"
#import "QNResolverDelegate.h"
#import "QNDomain.h"
#import "QNRecord.h"

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
	id <QNResolverDelegate> resolver = [[QNDnspodFree alloc] init];
	NSArray *records = [resolver query:[[QNDomain alloc]init:@"baidu.com"] networkInfo:nil];
	XCTAssert(records != nil, @"Pass");
	XCTAssert(records.count > 0, @"Pass");
	XCTAssert(records.count >= 1, @"Pass");
	QNRecord *record = [records objectAtIndex:0];
	XCTAssert(record.ttl >= 0, @"Pass");

	records = [resolver query:[[QNDomain alloc]init:@"www.qiniu.com"] networkInfo:nil];
	XCTAssert(records != nil, @"Pass");
	XCTAssert(records.count >= 1, @"Pass");
	record = [records objectAtIndex:0];
	XCTAssert(record.ttl >= 0, @"Pass");
}

@end
