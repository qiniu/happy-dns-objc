//
//  QNDnsResolver.m
//  HappyDNS
//
//  Created by yangsen on 2021/7/28.
//  Copyright © 2021 Qiniu Cloud Storage. All rights reserved.
//

#import "QNRecord.h"
#import "QNDomain.h"
#import "QNDnsError.h"
#import "QNDnsResolver.h"

@interface QNDnsResolver()

@property(nonatomic, assign)int timeout;
@property(nonatomic,   copy)NSArray *servers;

@end
@implementation QNDnsResolver

+ (instancetype)resolverWithServer:(NSString *)server
                           timeout:(int)timeout {
    return [self resolverWithServers:server ? @[server] : @[] timeout:timeout];
}

+ (instancetype)resolverWithServers:(NSArray <NSString *> *)servers
                            timeout:(int)timeout {
    QNDnsResolver *resolver = [[self alloc] init];
    resolver.servers = [servers copy] ?: @[];
    resolver.timeout = timeout;
    return resolver;
}

- (NSArray *)query:(QNDomain *)domain networkInfo:(QNNetworkInfo *)netInfo error:(NSError *__autoreleasing *)error {
    NSError *err = nil;
    QNDnsResponse *response = [self lookupHost:domain.domain recordType:kQNTypeA error:&err];
    if (err != nil) {
        *error = err;
        return @[];
    }
    
    NSMutableArray *records = [NSMutableArray array];
    for (QNRecord *record in response.answerArray) {
        if (record.type == kQNTypeA || record.type == kQNTypeAAAA) {
            [records addObject:record];
        }
    }
    return [records copy];
}

- (QNDnsResponse *)lookupHost:(NSString *)host
                   recordType:(int)recordType
                        error:(NSError *__autoreleasing  _Nullable *)error {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    __block NSError *errorP = nil;
    __block QNDnsResponse *dnsResponse = nil;
    [self request:host recordType:recordType complete:^(QNDnsResponse *response, NSError *err) {
        errorP = err;
        dnsResponse = response;
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, self.timeout * NSEC_PER_SEC));
    
    if (error != NULL) {
        *error = errorP;
    }
    
    return dnsResponse;
}

- (void)request:(NSString *)host
     recordType:(int)recordType
       complete:(void(^)(QNDnsResponse *response, NSError *error))complete {
    if (complete == nil) {
        return;
    }
    
    if (self.servers == nil || self.servers.count == 0) {
        complete(nil, kQNDnsInvalidParamError(@"server can not empty"));
        return;
    }
    
    NSLock *locker = [[NSLock alloc] init];
    __block BOOL hasCallBack = false;
    __block BOOL completeCount = 0;
    for (NSString *server in self.servers) {
        [self request:server host:host recordType:recordType complete:^(QNDnsResponse *response, NSError *error) {
            BOOL shouldCallBack = false;
            
            [locker lock];
            completeCount++;
            if (completeCount == self.servers.count || (response != nil && response.rCode == 0 && !hasCallBack)) {
                shouldCallBack = true;
            }
            [locker unlock];
            
            if (shouldCallBack) {
                complete(response, error);
            }
        }];
    }
    
}

- (void)request:(NSString *)server
           host:(NSString *)host
     recordType:(int)recordType
       complete:(void(^)(QNDnsResponse *response, NSError *error))complete {}

@end
