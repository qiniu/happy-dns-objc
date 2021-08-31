//
//  NSMutableData+QNWriter.h
//  Doh
//
//  Created by yangsen on 2021/7/16.
//
#import <Foundation/Foundation.h>

@interface NSData (QNReader)

//MARK: 读数据
- (uint8_t)qn_readInt8:(NSInteger)from;

- (uint16_t)qn_readLittleEndianInt16:(NSInteger)from;
- (uint32_t)qn_readLittleEndianInt32:(NSInteger)from;
- (uint64_t)qn_readLittleEndianInt64:(NSInteger)from;

- (uint16_t)qn_readBigEndianInt16:(NSInteger)from;
- (uint32_t)qn_readBigEndianInt32:(NSInteger)from;
- (uint64_t)qn_readBigEndianInt64:(NSInteger)from;

- (int8_t)qn_readSInt8:(NSInteger)from;
- (int16_t)qn_readLittleEndianSInt16:(NSInteger)from;
- (int32_t)qn_readLittleEndianSInt32:(NSInteger)from;
- (int64_t)qn_readLittleEndianSInt64:(NSInteger)from;

- (int16_t)qn_readBigEndianSInt16:(NSInteger)from;
- (int32_t)qn_readBigEndianSInt32:(NSInteger)from;
- (int64_t)qn_readBigEndianSInt64:(NSInteger)from;

- (float)qn_readFloat:(NSInteger)from;
- (double)qn_readDouble:(NSInteger)from;

- (float)qn_readSwappedFloat:(NSInteger)from;
- (double)qn_readSwappedDouble:(NSInteger)from;

- (NSString *)qn_readString:(NSRange)range usingEncoding:(NSStringEncoding)encoding;

@end


@interface NSMutableData (QNWriter)

//MARK: 写数据
- (void)qn_appendInt8:(uint8_t)value;

- (void)qn_appendLittleEndianInt16:(uint16_t)value;
- (void)qn_appendLittleEndianInt32:(uint32_t)value;
- (void)qn_appendLittleEndianInt64:(uint64_t)value;

- (void)qn_appendBigEndianInt16:(uint16_t)value;
- (void)qn_appendBigEndianInt32:(uint32_t)value;
- (void)qn_appendBigEndianInt64:(uint64_t)value;

- (void)qn_appendSInt8:(int8_t)value;

- (void)qn_appendLittleEndianSInt16:(int16_t)value;
- (void)qn_appendLittleEndianSInt32:(int32_t)value;
- (void)qn_appendLittleEndianSInt64:(int64_t)value;

- (void)qn_appendBigEndianSInt16:(int16_t)value;
- (void)qn_appendBigEndianSInt32:(int32_t)value;
- (void)qn_appendBigEndianSInt64:(int64_t)value;

// These methods append floating point values depending on the architecture of your processor
// they're usually not appropriate for network transmission
- (void)qn_appendFloat:(float)value;
- (void)qn_appendDouble:(double)value;

- (void)qn_appendSwappedFloat:(float)value;
- (void)qn_appendSwappedDouble:(double)value;

- (void)qn_appendString:(NSString *)value usingEncoding:(NSStringEncoding)encoding;

@end
