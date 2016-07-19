//
//  QNGetAddrInfo.h
//  HappyDNS
//
//  Created by bailong on 16/7/19.
//  Copyright © 2016年 Qiniu Cloud Storage. All rights reserved.
//

#ifndef QNGetAddrInfo_h
#define QNGetAddrInfo_h

typedef struct qn_ips_ret {
    char *ips[1];
} qn_ips_ret;

typedef qn_ips_ret *(*qn_dns_callback)(const char *host);

void qn_free_ips_ret(qn_ips_ret *ip_list);

int qn_getaddrinfo(const char *hostname, const char *servname, const struct addrinfo *hints, struct addrinfo **res);

void qn_freeaddrinfo(struct addrinfo *ai);

void qn_set_dns_callback(qn_dns_callback cb);

#endif /* QNGetAddrInfo_h */
