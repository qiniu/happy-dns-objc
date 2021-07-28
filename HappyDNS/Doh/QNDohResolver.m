//
//  Doh.m
//  Doh
//
//  Created by yangsen on 2021/7/15.
//

#import "QNDohResolver.h"

@implementation QNDohResolver

- (void)request:(NSString *)server
           host:(NSString *)host
     recordType:(int)recordType
       complete:(void(^)(QNDnsResponse *response, NSError *error))complete {
    if (complete == nil) {
        return;
    }
    
    if (host == nil || host.length == 0) {
        complete(nil, kQNDnsInvalidParamError(@"host can not empty"));
        return;
    }
    
    int messageId = arc4random()%(0xFFFF);
    QNDnsRequest *dnsRequest = [QNDnsRequest request:messageId recordType:recordType host:@"upload.qiniup.com"];
    NSError *error = nil;
    NSData *requestData = [dnsRequest toDnsQuestionData:&error];
    if (error) {
        complete(nil, error);
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:server]];
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
            QNDnsResponse *dnsResponse = [QNDnsResponse dnsResponse:server source:QNRecordSourceDoh request:dnsRequest dnsRecordData:data error:nil];
            complete(dnsResponse, nil);
        } else {
            complete(nil, nil);
        }
    }];
    [task resume];
}

@end
