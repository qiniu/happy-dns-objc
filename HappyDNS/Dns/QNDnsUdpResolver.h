//
//  QNDnsServer.h
//  Doh
//
//  Created by yangsen on 2021/7/20.
//

#import "QNDnsResolver.h"

NS_ASSUME_NONNULL_BEGIN

@interface QNDnsUdpResolver : QNDnsResolver

/// 构造函数
/// @param serverIP 指定 dns local server1. eg:8.8.8.8
/// @param timeout 超时时间
+ (instancetype)resolverWithServerIP:(NSString *)serverIP
                             timeout:(int)timeout;

/// 构造函数
/// @param serverIPs 指定多个 dns local server，同时进行 dns 解析，当第一个有效数据返回时结束，或均为解析到数据时结束. eg:@[@"8.8.8.8"]
/// @param timeout 超时时间
+ (instancetype)resolverWithServerIPs:(NSArray <NSString *> *)serverIPs
                              timeout:(int)timeout;

/// 构造函数
/// @param serverIPs 指定多个 dns local server，同时进行 dns 解析，当第一个有效数据返回时结束，或均为解析到数据时结束. eg:@[@"8.8.8.8"]
/// @param queue 多个 udp 包所在的 queue
/// @param timeout 超时时间
+ (instancetype)resolverWithServerIPs:(NSArray <NSString *> *)serverIPs
                                queue:(dispatch_queue_t _Nullable)queue
                              timeout:(int)timeout;

@end

NS_ASSUME_NONNULL_END
