//
//  QNDnsServer.h
//  Doh
//
//  Created by yangsen on 2021/7/20.
//

#import "QNResolverDelegate.h"
#import "QNDnsDefine.h"
#import "QNDnsResponse.h"

NS_ASSUME_NONNULL_BEGIN

@interface QNDnsServer : NSObject <QNResolverDelegate>

+ (instancetype)dnsServer:(NSString *)server
                  timeout:(int)timeout;

+ (instancetype)dnsServer:(NSArray <NSString *> *)servers
                    queue:(dispatch_queue_t _Nullable)queue
                  timeout:(int)timeout;

- (QNDnsResponse *)lookupHost:(NSString *)host recordType:(int)recordType error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
