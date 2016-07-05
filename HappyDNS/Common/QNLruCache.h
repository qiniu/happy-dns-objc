//
//  QNLruCache.h
//  HappyDNS
//
//  Created by bailong on 16/7/5.
//  Copyright © 2016年 Qiniu Cloud Storage. All rights reserved.
//

#import <Foundation/NSObject.h>

#import <Foundation/Foundation.h>

@interface QNLruCache : NSObject

- (nonnull instancetype)init:(NSUInteger)limit;

- (void)removeAllObjects;

- (void)removeObjectForKey:(nonnull NSString *)key;

- (nullable id)objectForKey:(nonnull NSString *)key;

- (void)setObject:(nonnull id)obj forKey:(nonnull NSString *)key;

@end
