//
//  Doh.h
//  Doh
//
//  Created by yangsen on 2021/7/15.
//

#import "QNResolverDelegate.h"
#import "QNDnsDefine.h"
#import "QNDnsResponse.h"

NS_ASSUME_NONNULL_BEGIN

@interface QNDoh : NSObject <QNResolverDelegate>

/// 构造函数
/// @param server doh server
/// @param timeout doh 解析 timeout，单位：秒
+ (instancetype)doh:(NSString *)server timeout:(int)timeout;

- (QNDnsResponse *)lookupHost:(NSString *)host recordType:(int)recordType error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
