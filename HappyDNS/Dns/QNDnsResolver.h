//
//  QNDnsResolver.h
//  HappyDNS
//
//  Created by yangsen on 2021/7/28.
//  Copyright © 2021 Qiniu Cloud Storage. All rights reserved.
//

#import "QNDnsDefine.h"
#import "QNDnsResponse.h"
#import "QNResolverDelegate.h"

NS_ASSUME_NONNULL_BEGIN

// 抽象对象，不能直接使用，使用其子类
@interface QNDnsResolver : NSObject <QNResolverDelegate>

@property(nonatomic, assign, readonly)int timeout;
@property(nonatomic,   copy, readonly)NSArray *servers;

/// 构造函数
/// @param server 指定 dns server
///                 1. UdpResolver时 server 为 ip。 eg:8.8.8.8
///                 2. Doh 时 server 为 url。 eg:https://dns.google/dns-query
/// @param timeout 超时时间
+ (instancetype)resolverWithServer:(NSString *)server
                           timeout:(int)timeout;

/// 构造函数
/// @param serverIPs 指定多个 dns server，同时进行 dns 解析，当第一个有效数据返回时结束，或均为解析到数据时结束
///                 1. UdpResolver时 server 为 ip。 eg:8.8.8.8
///                 2. Doh 时 server 为 url。 eg:https://dns.google/dns-query
/// @param timeout 超时时间
+ (instancetype)resolverWithServers:(NSArray <NSString *> *)servers
                            timeout:(int)timeout;

- (QNDnsResponse *)lookupHost:(NSString *)host recordType:(int)recordType error:(NSError **)error;

// 抽象方法，子类实现
- (void)request:(NSString *)server
           host:(NSString *)host
     recordType:(int)recordType
       complete:(void(^)(QNDnsResponse *response, NSError *error))complete;

@end

NS_ASSUME_NONNULL_END
