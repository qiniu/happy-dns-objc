//
//  QNIPV6.m
//  HappyDNS
//
//  Created by bailong on 16/5/25.
//  Copyright © 2016年 Qiniu Cloud Storage. All rights reserved.
//

#import <arpa/inet.h>
#import <netdb.h>
#import <netinet/in.h>
#import <unistd.h>

#include <netinet/in.h>
#include <netinet/tcp.h>

#import "QNIP.h"

static NSString *lock = @"";
int qn_localIp(char *buf, int buf_size) {
    struct addrinfo hints = {0}, *ai;
    int err = 0;
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_DGRAM;
    int ret = getaddrinfo("8.8.8.8", "53", &hints, &ai);
    if (ret != 0) {
        err = errno;
        return err;
    }

    int family = ai->ai_family;
    int sock = socket(family, ai->ai_socktype, 0);
    if (sock < 0) {
        err = errno;
        freeaddrinfo(ai);
        return err;
    }

    //fix getaddrinfo bug in ipv4 to ipv6
    if (ai->ai_family == AF_INET6) {
        ((struct sockaddr_in6 *)ai->ai_addr)->sin6_port = htons(53);
    }

    err = connect(sock, ai->ai_addr, ai->ai_addrlen);
    if (err < 0) {
        err = errno;
    }
    freeaddrinfo(ai);
    uint32_t localAddress[16] = {0};

    socklen_t addressLength = sizeof(localAddress);
    err = getsockname(sock, (struct sockaddr *)&localAddress, &addressLength);
    close(sock);
    if (err != 0) {
        return err;
    }
    void *addr;
    if (family == AF_INET6) {
        addr = &((struct sockaddr_in6 *)&localAddress)->sin6_addr;
    } else {
        addr = &((struct sockaddr_in *)&localAddress)->sin_addr;
    }
    const char *ip = inet_ntop(family, addr, buf, buf_size);
    if (ip == nil) {
        return -1;
    }
    return 0;
}

@implementation QNIP

+ (BOOL)isV6 {
    struct addrinfo hints = {0}, *ai;
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    int ret = getaddrinfo("8.8.8.8", "http", &hints, &ai);
    if (ret != 0) {
        return NO;
    }
    int family = ai->ai_family;
    freeaddrinfo(ai);
    return family == AF_INET6;
}

+ (NSString *)adaptiveIp:(NSString *)ipv4 {
    struct addrinfo hints = {0}, *ai;
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    int ret = getaddrinfo(ipv4.UTF8String, "http", &hints, &ai);
    if (ret != 0) {
        return NO;
    }
    int family = ai->ai_family;

    void *addr;
    if (family == AF_INET6) {
        addr = &((struct sockaddr_in6 *)ai->ai_addr)->sin6_addr;
    } else {
        addr = &((struct sockaddr_in *)ai->ai_addr)->sin_addr;
    }
    char buf[32] = {0};
    const char *ip = inet_ntop(family, addr, buf, sizeof(buf));

    freeaddrinfo(ai);
    return [NSString stringWithUTF8String:ip];
}

+ (NSString *)local {
    char buf[32] = {0};
    int err = qn_localIp(buf, 32);
    if (err != 0) {
        return nil;
    }
    return [NSString stringWithUTF8String:buf];
}

+ (NSString *)ipHost:(NSString *)ip {
    NSRange range = [ip rangeOfString:@":"];
    if (range.location != NSNotFound) {
        return [NSString stringWithFormat:@"[%@]", ip];
    }
    return ip;
}

@end
