//
//  QNDnsMessage.h
//  Doh
//
//  Created by yangsen on 2021/7/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNDnsMessage : NSObject

/**
 * 16位的消息ID标示一次正常的交互，该ID由消息请求者设置，消息响应者回复请求时带上该ID。最大：0xFFFF，即：65536
 */
@property(nonatomic, assign, readonly)int messageId;

/**
 * 请求类型，目前有三类值：
 * 0 QUERY, 标准查询
 * 1 IQUERY, 反向查询
 * 2 STATUS, DNS状态请求
 * 5 UPDATE, DNS域更新请求
 */
@property(nonatomic, assign, readonly)int opCode;

/**
 * 是否递归查询。如果该位被设置为1，则收到请求的域名服务器会递归查询域名，
 * 注: 该位为1，域名服务器不一定会做递归查询，这取决于域名服务器是否支持递归查询。
 */
@property(nonatomic, assign, readonly)int rd;

/**
 * 在响应消息中清除并设置。表示该DNS域名服务器是否支持递归查询。
 */
@property(nonatomic, assign, readonly)int ra;

@end

NS_ASSUME_NONNULL_END
