//
//  QNDomain.h
//  HappyDNS
//
//  Created by bailong on 15/6/23.
//  Copyright (c) 2015年 Qiniu Cloud Storage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QNDomain : NSObject
@property (nonatomic, readonly) NSString* domain;
@property (readonly) BOOL hasCname;
-(instancetype)init:(NSString*)domain;
@end
