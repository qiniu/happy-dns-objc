//
//  NSMutableData+QNWriter.m
//  Doh
//
//  Created by yangsen on 2021/7/16.
//
#import "NSData+QNRW.h"

@implementation NSData (QNReader)

//MARK: 读数据
- (uint8_t)qn_readInt8:(NSInteger)from {
    uint8_t value = 0;
    [[self subdataWithRange:NSMakeRange(from, sizeof(value))] getBytes:&value length:sizeof(value)];
    return value;
}

#define READ_METHOD(endian, size)                                                                           \
- (uint ## size ## _t)qn_read ## endian ## EndianInt ## size:(NSInteger)from {                              \
    uint ## size ## _t value = 0;                                                                           \
    [[self subdataWithRange:NSMakeRange(from, sizeof(value))] getBytes:&value length:sizeof(value)];        \
    value = CFSwapInt ## size ## HostTo ## endian(value);                                                   \
    return value;                                                                                           \
}

READ_METHOD(Little, 16)
READ_METHOD(Little, 32)
READ_METHOD(Little, 64)
READ_METHOD(Big, 16)
READ_METHOD(Big, 32)
READ_METHOD(Big, 64)

#undef READ_METHOD

- (int8_t)qn_readSInt8:(NSInteger)from {
    int8_t value = 0;
    [[self subdataWithRange:NSMakeRange(from, 8)] getBytes:&value length:sizeof(value)];
    return value;
}

#define READ_METHOD(endian, size)                                                                           \
- (int ## size ## _t)qn_read ## endian ## EndianSInt ## size:(NSInteger)from {                              \
    int ## size ## _t value = 0;                                                                            \
    [[self subdataWithRange:NSMakeRange(from, sizeof(value))] getBytes:&value length:sizeof(value)];        \
    value = CFSwapInt ## size ## HostTo ## endian(value);                                                   \
    return value;                                                                                           \
}

READ_METHOD(Little, 16)
READ_METHOD(Little, 32)
READ_METHOD(Little, 64)
READ_METHOD(Big, 16)
READ_METHOD(Big, 32)
READ_METHOD(Big, 64)

#undef READ_METHOD


- (float)qn_readFloat:(NSInteger)from {
    float value = 0;
    [[self subdataWithRange:NSMakeRange(from, sizeof(value))] getBytes:&value length:sizeof(value)];
    return value;
}

- (double)qn_readDouble:(NSInteger)from {
    double value = 0;
    [[self subdataWithRange:NSMakeRange(from, sizeof(value))] getBytes:&value length:sizeof(value)];
    return value;
}

- (float)qn_readSwappedFloat:(NSInteger)from {
    CFSwappedFloat32 value;
    [[self subdataWithRange:NSMakeRange(from, sizeof(value))] getBytes:&value length:sizeof(value)];
    return CFConvertFloatSwappedToHost(value);
}

- (double)qn_readSwappedDouble:(NSInteger)from {
    CFSwappedFloat64 value;
    [[self subdataWithRange:NSMakeRange(from, sizeof(value))] getBytes:&value length:sizeof(value)];
    return CFConvertDoubleSwappedToHost(value);
}

- (NSString *)qn_readString:(NSRange)range usingEncoding:(NSStringEncoding)encoding {
    NSData *value = [self subdataWithRange:range];
    return [[NSString alloc] initWithData:value encoding:encoding];
}

@end

@implementation NSMutableData (QNWriter)

- (void)qn_appendInt8:(uint8_t)value {
    [self appendBytes:&value length:sizeof(value)];
}

#define APPEND_METHOD(endian, size)                                          \
- (void)qn_append ## endian ## EndianInt ## size:(uint ## size ## _t)value { \
    value = CFSwapInt ## size ## HostTo ## endian(value);                    \
    [self appendBytes:&value length:sizeof(value)];                          \
}

APPEND_METHOD(Little, 16)
APPEND_METHOD(Little, 32)
APPEND_METHOD(Little, 64)
APPEND_METHOD(Big, 16)
APPEND_METHOD(Big, 32)
APPEND_METHOD(Big, 64)

#undef APPEND_METHOD

- (void)qn_appendSInt8:(int8_t)value {
    [self qn_appendInt8:*(int8_t *)&value];
}

#define APPEND_METHOD(endian, size)                                                \
- (void)qn_append ## endian ## EndianSInt ## size:(int ## size ## _t)value {       \
    [self qn_append ## endian ## EndianInt ## size:*(uint ## size ## _t *)&value]; \
}

APPEND_METHOD(Little, 16)
APPEND_METHOD(Little, 32)
APPEND_METHOD(Little, 64)
APPEND_METHOD(Big, 16)
APPEND_METHOD(Big, 32)
APPEND_METHOD(Big, 64)

#undef APPEND_METHOD

- (void)qn_appendFloat:(float)value {
    [self appendBytes:&value length:sizeof(value)];
}

- (void)qn_appendDouble:(double)value {
    [self appendBytes:&value length:sizeof(value)];
}

- (void)qn_appendSwappedFloat:(float)value {
    CFSwappedFloat32 v = CFConvertFloatHostToSwapped(value);
    [self appendBytes:&v length:sizeof(value)];
}

- (void)qn_appendSwappedDouble:(double)value {
    CFSwappedFloat64 v = CFConvertDoubleHostToSwapped(value);
    [self appendBytes:&v length:sizeof(value)];
}

- (void)qn_appendString:(NSString *)value usingEncoding:(NSStringEncoding)encoding {
    [self appendData:[value dataUsingEncoding:encoding]];
}

@end
