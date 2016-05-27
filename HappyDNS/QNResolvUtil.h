//
//  QNResolv.h
//  HappyDNS
//
//  Created by bailong on 16/5/28.
//  Copyright © 2016年 Qiniu Cloud Storage. All rights reserved.
//

#ifndef QNResolv_h
#define QNResolv_h

BOOL isV6(NSString *address);

int setup_dns_server(res_state res, NSString *dns_server);

#endif /* QNResolv_h */
