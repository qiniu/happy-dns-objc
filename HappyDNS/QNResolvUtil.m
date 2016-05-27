//
//  QNResolvUtil.m
//  HappyDNS
//
//  Created by bailong on 16/5/28.
//  Copyright © 2016年 Qiniu Cloud Storage. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <arpa/inet.h>
#include <resolv.h>
#include <string.h>

#include <netdb.h>
#include <netinet/in.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <unistd.h>

#import "QNIP.h"

#if __IPHONE_OS_VERSION_MIN_REQUIRED
#import <MobileCoreServices/MobileCoreServices.h>
#import <UIKit/UIKit.h>
#endif

BOOL isV6(NSString *address) {
    return strchr(address.UTF8String, ':') != NULL;
}

int setup_dns_server(void *_res_state, NSString *dns_server) {
    res_state res = (res_state)_res_state;
    int r = res_ninit(res);
    if (r != 0) {
        return r;
    }
    if (dns_server == NULL) {
        return 0;
    }

    union res_sockaddr_union server = {0};

    struct addrinfo hints = {0}, *ai = NULL;
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

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
    float sysVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (sysVersion < 9.0 && sysVersion >= 8.0 && family == AF_INET) {
        if ([QNIP isV6]) {
            freeaddrinfo(ai);
            ai = NULL;
            bzero(&hints, 0);
            hints.ai_family = AF_UNSPEC;
            hints.ai_socktype = SOCK_STREAM;
            char buf[64] = {0};
            qn_nat64(buf, sizeof(buf), dns_server.UTF8String);
            int ret = getaddrinfo(buf, "53", &hints, &ai);
            if (ret != 0) {
                return -1;
            }
            ((struct sockaddr_in6 *)ai->ai_addr)->sin6_port = htons(53);
            server.sin6 = *((struct sockaddr_in6 *)ai->ai_addr);
        }
    }
#endif

    freeaddrinfo(ai);
    res_setservers(res, &server, 1);
    return 0;
}