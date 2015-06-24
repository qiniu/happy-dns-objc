//
//  QNResolver.m
//  HappyDNS
//
//  Created by bailong on 15/6/23.
//  Copyright (c) 2015年 Qiniu Cloud Storage. All rights reserved.
//

#import "QNResolver.h"
#import "QNDomain.h"

static int udpCommunicate(char* ip, char* buffer, int len){
    return 0;
}

@interface QNResolver ()
@property (nonatomic) NSString* address;
@end

@implementation QNResolver
-(instancetype)initWithAddres:(NSString *)address{
    if (self = [super init]) {
        self.address = address;
    }
    return nil;
}

-(NSArray*)query:(QNDomain*)domain{
    int id = arc4random() & 0XFF;
    
//    byte[] query = DnsMessage.buildQuery(domain.domain, id);
//    byte[] answer = udpCommunicate(query);
//    if (answer == null) {
//        throw new DnsException(domain.domain, "cant get answer");
//    }
//    return DnsMessage.parseResponse(answer, id, domain.domain);
    return nil;
}

@end
