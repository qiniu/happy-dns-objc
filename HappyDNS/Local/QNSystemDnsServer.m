//
//  QNSystemDnsServer.m
//  HappyDNS
//
//  Created by bailong on 15/6/23.
//  Copyright (c) 2015年 Qiniu Cloud Storage. All rights reserved.
//

#import "QNSystemDnsServer.h"

@implementation QNSystemDnsServer
+(NSArray*)servers{
#if __IPHONE_OS_VERSION_MIN_REQUIRED
    return nil;
#else
    NSString *fh = [NSString stringWithContentsOfFile:@"/etc/resolv.conf" encoding:NSUTF8StringEncoding error:NULL];
    if (fh == nil) {
        return nil;
    }
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSString *line in [fh componentsSeparatedByString:@"\n"]) {
        if ([line hasPrefix:@"nameserver"]) {
            NSArray* a = [line componentsSeparatedByString:@" "];
            if ([a count] !=2) {
                return nil;
            }
            [array addObject:[a objectAtIndex:1]];
        }
    }
    return array;
#endif

}
@end
