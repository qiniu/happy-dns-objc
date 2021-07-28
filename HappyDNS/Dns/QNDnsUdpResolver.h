//
//  QNDnsServer.h
//  Doh
//
//  Created by yangsen on 2021/7/20.
//

#import "QNDnsResolver.h"

NS_ASSUME_NONNULL_BEGIN

@interface QNDnsUdpResolver : QNDnsResolver

+ (instancetype)resolverWithServerIP:(NSString *)serverIP
                             timeout:(int)timeout;

+ (instancetype)resolverWithServerIPs:(NSArray <NSString *> *)serverIPs
                              timeout:(int)timeout;

+ (instancetype)resolverWithServerIPs:(NSArray <NSString *> *)serverIPs
                                queue:(dispatch_queue_t _Nullable)queue
                              timeout:(int)timeout;

@end

NS_ASSUME_NONNULL_END
