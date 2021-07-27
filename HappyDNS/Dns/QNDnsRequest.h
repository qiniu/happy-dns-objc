//
//  DnsQuestion.h
//  Doh
//
//  Created by yangsen on 2021/7/16.
//

#import "QNDnsDefine.h"
#import "QNDnsMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface QNDnsRequest : QNDnsMessage

@property(nonatomic, assign, readonly)int recordType;
@property(nonatomic,   copy, readonly)NSString *host;

/// 构造函数
/// @param messageId 请求 id
/// @param recordType 记录类型
/// @param host 需要进行 Dns 解析的 host
+ (instancetype)request:(int)messageId
             recordType:(int)recordType
                   host:(NSString *)host;

/// 构造函数
/// @param messageId 请求 id
/// @param opCode 请求类型
/// @param rd 是否递归查询。如果该位被设置为1，则收到请求的域名服务器会递归查询域名
///           注: 该位为1，域名服务器不一定会做递归查询，这取决于域名服务器是否支持递归查询。
/// @param recordType 记录类型
/// @param host 需要进行 Dns 解析的 host
+ (instancetype)request:(int)messageId
                 opCode:(QNDnsOpCode)opCode
                     rd:(int)rd
             recordType:(int)recordType
                   host:(NSString *)host;

- (NSData *)toDnsQuestionData:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
