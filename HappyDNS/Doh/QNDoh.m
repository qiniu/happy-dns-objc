//
//  Doh.m
//  Doh
//
//  Created by yangsen on 2021/7/15.
//

#import "QNDoh.h"
#import "QNDomain.h"
#import "QNDnsError.h"
#import "QNDnsResponse.h"

@interface QNDoh()

@property(nonatomic, assign)int timeout;
@property(nonatomic,   copy)NSString *server;

@end
@implementation QNDoh

+ (instancetype)doh:(NSString *)server timeout:(int)timeout {
    QNDoh *doh = [[QNDoh alloc] init];
    doh.server = server;
    doh.timeout = timeout;
    return doh;
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
    
    if (host == nil || host.length == 0) {
        complete(nil, kQNDnsInvalidParamError(@"host can not empty"));
        return;
    }
    
    int messageId = arc4random()%1000000;
    QNDnsRequest *dnsRequest = [QNDnsRequest request:messageId recordType:recordType host:@"upload.qiniup.com"];
    NSError *error = nil;
    NSData *requestData = [dnsRequest toDnsQuestionData:&error];
    if (error) {
        complete(nil, error);
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.server]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = requestData;
    request.timeoutInterval = self.timeout;
    [request addValue:@"application/dns-message" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/dns-message" forHTTPHeaderField:@"Accept"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            complete(nil, error);
        } else if (data) {
            QNDnsResponse *dnsResponse = [QNDnsResponse dnsResponse:self.server request:dnsRequest dnsRecordData:data error:nil];
            complete(dnsResponse, nil);
        } else {
            complete(nil, nil);
        }
    }];
    [task resume];
}
@end
