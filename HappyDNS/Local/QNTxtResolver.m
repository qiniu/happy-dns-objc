//
//  QNTxtResolver.m
//  HappyDNS
//
//  Created by bailong on 16/1/5.
//  Copyright © 2016年 Qiniu Cloud Storage. All rights reserved.
//

#import "QNTxtResolver.h"

#include <arpa/inet.h>
#include <resolv.h>
#include <string.h>

#include <netdb.h>
#include <netinet/in.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <unistd.h>

#import "QNDomain.h"
#import "QNRecord.h"
#import "QNResolver.h"

@interface QNTxtResolver ()
@property (nonatomic) NSString *address;
@end

static BOOL isV6(NSString *address) {
    return strchr(address.UTF8String, ':') != NULL;
}

static NSArray *query_ip(res_state res, const char *host) {
    u_char answer[1500];
    int len = res_nquery(res, host, ns_c_in, ns_t_txt, answer, sizeof(answer));

    ns_msg handle;
    ns_initparse(answer, len, &handle);

    int count = ns_msg_count(handle, ns_s_an);
    if (count != 1) {
        res_ndestroy(res);
        return nil;
    }

    char txtbuf[256];
    memset(txtbuf, 0, sizeof(txtbuf));

    ns_rr rr;
    if (ns_parserr(&handle, ns_s_an, 0, &rr) != 0) {
        res_ndestroy(res);
        return nil;
    }
    int t = ns_rr_type(rr);
    int ttl = ns_rr_ttl(rr);
    int rdlen = ns_rr_rdlen(rr);
    if (rdlen <= 1 + 7) {
        res_ndestroy(res);
        return nil;
    }
    NSString *val;
    if (t == ns_t_txt) {
        memcpy(txtbuf, ns_rr_rdata(rr) + 1, rdlen - 1);
        val = [NSString stringWithUTF8String:txtbuf];
    } else {
        res_ndestroy(res);
        return nil;
    }
    NSArray *ipArray = [val componentsSeparatedByString:@","];
    NSMutableArray *ret = [[NSMutableArray alloc] initWithCapacity:ipArray.count];
    for (int i = 0; i < ipArray.count; i++) {
        QNRecord *record = [[QNRecord alloc] init:[ipArray objectAtIndex:i] ttl:ttl type:kQNTypeA];
        [ret addObject:record];
    }

    res_ndestroy(res);
    return ret;
}

static int setup_dns_server(res_state res, NSString *dns_server) {
    int r = res_ninit(res);
    if (r != 0) {
        return r;
    }
    if (dns_server == NULL) {
        return 0;
    }

    union res_sockaddr_union server = {0};

    struct addrinfo hints = {0}, *ai;
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    int ret = getaddrinfo(dns_server.UTF8String, "53", &hints, &ai);
    if (ret != 0) {
        return -1;
    }
    int family = ai->ai_family;

    if (family == AF_INET6) {
        ((struct sockaddr_in6 *)ai->ai_addr)->sin6_port = htons(53);
        server.sin6 = *((struct sockaddr_in6 *)ai->ai_addr);
    } else {
        server.sin = *((struct sockaddr_in *)ai->ai_addr);
    }

    freeaddrinfo(ai);
    res_setservers(res, &server, 1);
    return 0;
}

@implementation QNTxtResolver
- (instancetype)initWithAddres:(NSString *)address {
    if (self = [super init]) {
        _address = address;
    }
    return self;
}

- (NSArray *)query:(QNDomain *)domain networkInfo:(QNNetworkInfo *)netInfo error:(NSError *__autoreleasing *)error {
    struct __res_state res;

    int r = setup_dns_server(&res, _address);
    if (r != 0) {
        return nil;
    }

    return query_ip(&res, [domain.domain cStringUsingEncoding:NSUTF8StringEncoding]);
}

@end
