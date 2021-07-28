//
//  DnsRecord.h
//  Doh
//
//  Created by yangsen on 2021/7/16.
//

#import "QNRecord.h"
#import "QNDnsRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface QNDnsResponse : QNDnsMessage

@property(nonatomic, assign, readonly)NSInteger timestamp;
@property(nonatomic, assign, readonly)QNRecordSource source;
@property(nonatomic,   copy, readonly)NSString *server;
@property(nonatomic, strong, readonly)QNDnsRequest *request;
@property(nonatomic, strong, readonly)NSData *recordData;


/**
 * 响应该消息的域名服务器是该域中的权威域名服务器。因为Answer Section中可能会有很多域名
 */
@property(nonatomic, assign, readonly)int aa;

/**
 * 响应消息的类型：
 * 0  成功的响应
 * 1  格式错误--域名服务器无法解析请求，因为请求消息格式错误
 * 2  服务器错误--域名服务器因为内部错误无法解析该请求
 * 3  名字错误-- 只在权威域名服务器的响应消息中有效，标示请求中请求的域不存在
 * 4  Not Implemented--域名服务器不支持请求的类型
 * 5  Refused -- 域名服务器因为策略的原因拒绝执行请求的操作。例如域名服务器不会为特定的请求者返回查询结果，或者域名服务器不会为特定的请求返回特定的数据
 */
@property(nonatomic, assign, readonly)int rCode;

@property(nonatomic,   copy, readonly)NSArray <QNRecord *> *answerArray;
@property(nonatomic,   copy, readonly)NSArray <QNRecord *> *authorityArray;
@property(nonatomic,   copy, readonly)NSArray <QNRecord *> *additionalArray;

+ (instancetype)dnsResponse:(NSString *)server source:(QNRecordSource)source request:(QNDnsRequest *)request dnsRecordData:(NSData *)recordData error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
