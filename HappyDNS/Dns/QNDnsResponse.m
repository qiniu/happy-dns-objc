//
//  DnsRecord.m
//  Doh
//
//  Created by yangsen on 2021/7/16.
//
#import "QNRecord.h"
#import "QNDnsError.h"
#import "NSData+QNRW.h"
#import "QNDnsResponse.h"


/// DNS 记录中的名字可能是引用，需要到指定的 index 读取，所以需要跳过的长度不一定是 name 的长度
@interface QNDnsRecordName : NSObject

@property(nonatomic, assign)NSInteger skipLength;
@property(nonatomic,   copy)NSString *name;

@end
@implementation QNDnsRecordName
@end


@interface QNDnsRecordResource : NSObject

@property(nonatomic,   copy)NSString *name;
@property(nonatomic, assign)int count;
@property(nonatomic, assign)int from;
@property(nonatomic, assign)int length;
@property(nonatomic, strong)NSMutableArray *records;

@end
@implementation QNDnsRecordResource
+ (instancetype)resource:(NSString *)name count:(int)count from:(int)from {
    QNDnsRecordResource *resource = [[QNDnsRecordResource alloc] init];
    resource.name = name;
    resource.count = count;
    resource.from = from;
    resource.length = 0;
    resource.records = [NSMutableArray array];
    return resource;
}
@end


@interface QNDnsResponse()

@property(nonatomic, assign)NSInteger timestamp;
@property(nonatomic, assign)QNRecordSource source;
@property(nonatomic,   copy)NSString *server;
@property(nonatomic, strong)QNDnsRequest *request;
@property(nonatomic, strong)NSData *recordData;

@property(nonatomic, assign)int messageId;
@property(nonatomic, assign)QNDnsOpCode opCode;
@property(nonatomic, assign)int aa;
@property(nonatomic, assign)int ra;
@property(nonatomic, assign)int rd;
@property(nonatomic, assign)int rCode;

@property(nonatomic,   copy)NSArray <QNRecord *> *answerArray;
@property(nonatomic,   copy)NSArray <QNRecord *> *authorityArray;
@property(nonatomic,   copy)NSArray <QNRecord *> *additionalArray;

@end
@implementation QNDnsResponse
@synthesize messageId;
@synthesize opCode;
@synthesize aa;
@synthesize ra;
@synthesize rd;
@synthesize rCode;

+ (instancetype)dnsResponse:(NSString *)server source:(QNRecordSource)source request:(QNDnsRequest *)request dnsRecordData:(NSData *)recordData error:(NSError *__autoreleasing  _Nullable *)error {
    QNDnsResponse *record = [[QNDnsResponse alloc] init];
    record.server = server;
    record.source = source;
    record.request = request;
    record.recordData = recordData;
    record.timestamp = [[NSDate date] timeIntervalSince1970];
    
    NSError *err = nil;
    [record parse:&err];
    if (error != nil) {
        *error = err;
    }
    return record;
}

- (void)parse:(NSError **)error {
    
    if (self.recordData.length < 12) {
        [self copyError:kQNDnsResponseFormatError(@"response data too small") toErrorPoint:error];
        return;
    }
    
    // Header
    [self parseHeader:error];
    if (error != nil && *error != nil) {
        return;
    }
    
    // Question
    int index = [self parseQuestion:error];
    if (error != nil && *error != nil) {
        return;
    }
    
    // Answer
    QNDnsRecordResource *answer = [QNDnsRecordResource resource:@"answer"
                                                          count:[self.recordData qn_readBigEndianInt16:6]
                                                           from:index];
    [self parseResourceRecord:answer error:error];
    if (error != nil && *error != nil) {
        return;
    }
    index += answer.length;
    self.answerArray = [answer.records copy];
    
    // Authority
    QNDnsRecordResource *authority = [QNDnsRecordResource resource:@"authority"
                                                             count:[self.recordData qn_readBigEndianInt16:8]
                                                              from:index];
    [self parseResourceRecord:authority error:error];
    if (error != nil && *error != nil) {
        return;
    }
    index += authority.length;
    self.authorityArray = [authority.records copy];
    
    // Additional
    QNDnsRecordResource *additional = [QNDnsRecordResource resource:@"additional"
                                                             count:[self.recordData qn_readBigEndianInt16:10]
                                                              from:index];
    [self parseResourceRecord:additional error:error];
    if (error != nil && *error != nil) {
        return;
    }
    self.additionalArray = [additional.records copy];
}

- (void)parseHeader:(NSError **)error {
    self.messageId = [self.recordData qn_readBigEndianInt16:0];
    // question id 不匹配
    if (self.messageId != self.request.messageId) {
        [self copyError:kQNDnsResponseFormatError(@"question id error") toErrorPoint:error];
        return;
    }
    
    // |00|01|02|03|04|05|06|07|
    // |QR|  OPCODE   |AA|TC|RD|
    int field0 = [self.recordData qn_readInt8:2];
    int qr = [self.recordData qn_readInt8:2] & 0x80;
    // 非 dns 响应数据
    if (qr == 0) {
        [self copyError:kQNDnsResponseFormatError(@"not a response data") toErrorPoint:error];
        return;
    }
    
    self.opCode = (field0 >> 3) & 0x07;
    self.aa = (field0 >> 2) & 0x01;
    self.rd = field0 & 0x01;
    
    // |00|01|02|03|04|05|06|07|
    // |RA|r1|r2|r3| RCODE     |
    int field1 = [self.recordData qn_readInt8:3];
    self.ra = (field1 >> 7) & 0x1;
    self.rCode = field1 & 0x0F;
}

- (int)parseQuestion:(NSError **)error {
    int index = 12;
    int qdCount = [self.recordData qn_readBigEndianInt16:4];
    while (qdCount) {
        QNDnsRecordName *recordName = [self getNameFrom:index];
        if (recordName == nil) {
            [self copyError:kQNDnsResponseFormatError(@"read Question error") toErrorPoint:error];
            return -1;
        }
        
        if (self.recordData.length < (index + recordName.skipLength + 4)) {
            [self copyError:kQNDnsResponseFormatError(@"read Question error: out of range") toErrorPoint:error];
            return -1;
        }
        
        index += recordName.skipLength + 4;
        qdCount --;
    }
    return index;
}

- (void)parseResourceRecord:(QNDnsRecordResource *)resource error:(NSError **)error {
    int index = resource.from;
    int count = resource.count;
    while (count) {
        QNDnsRecordName *recordName = [self getNameFrom:index];
        if (recordName == nil) {
            NSString *errorDesc = [NSString stringWithFormat:@"read %@ error", resource.name];
            [self copyError:kQNDnsResponseFormatError(errorDesc) toErrorPoint:error];
            return;
        }

        index += recordName.skipLength;
        if (self.recordData.length < (index + 2)) {
            NSString *errorDesc = [NSString stringWithFormat:@"read %@ error: out of range", resource.name];
            [self copyError:kQNDnsResponseFormatError(errorDesc) toErrorPoint:error];
            return;
        }

        int type = [self.recordData qn_readBigEndianInt16:index];
        index += 2;
        
        if (self.recordData.length < (index + 2)) {
            NSString *errorDesc = [NSString stringWithFormat:@"%@ read Answer error: out of range", resource.name];
            [self copyError:kQNDnsResponseFormatError(errorDesc) toErrorPoint:error];
            return;
        }
        
        int class = [self.recordData qn_readBigEndianInt16:index];
        index += 2;
        
        if (self.recordData.length < (index + 4)) {
            NSString *errorDesc = [NSString stringWithFormat:@"%@ read Answer error: out of range", resource.name];
            [self copyError:kQNDnsResponseFormatError(errorDesc) toErrorPoint:error];
            return;
        }
        
        int ttl = [self.recordData qn_readBigEndianInt32:index];
        index += 4;

        if (self.recordData.length < (index + 2)) {
            NSString *errorDesc = [NSString stringWithFormat:@"%@ read Answer error: out of range", resource.name];
            [self copyError:kQNDnsResponseFormatError(errorDesc) toErrorPoint:error];
            return;
        }
        
        int rdLength = [self.recordData qn_readBigEndianInt16:index];
        index += 2;
        if (self.recordData.length < (index + rdLength)) {
            NSString *errorDesc = [NSString stringWithFormat:@"%@ read Answer error: out of range", resource.name];
            [self copyError:kQNDnsResponseFormatError(errorDesc) toErrorPoint:error];
            return;
        }
        
        NSString *value = [self readData:type range:NSMakeRange(index, rdLength)];
        
        if (class == 0x01 && (type == kQNTypeCname || type == self.request.recordType)) {
            QNRecord *record = [[QNRecord alloc] init:[value copy] ttl:ttl type:type timeStamp:self.timestamp server:self.server source:self.source];
            [resource.records addObject:record];
        }
        
        index += rdLength;
        count --;
    }
    resource.length = index - resource.from;
}

- (QNDnsRecordName *)getNameFrom:(NSInteger)fromIndex {
    
    NSInteger partLength = 0;
    NSInteger index = fromIndex;
    NSMutableString *name = [NSMutableString string];
    QNDnsRecordName *recordName = [[QNDnsRecordName alloc] init];
    
    int maxLoop = 128;
    do {
        if (index >= self.recordData.length) {
            return nil;
        }
        
        partLength = [self.recordData qn_readInt8:index];
        if ((partLength & 0xc0) == 0xc0) {
            // name pointer
            if((index + 1) >= self.recordData.length) {
                return nil;
            }
            if (recordName.skipLength < 1) {
                recordName.skipLength = index + 2 - fromIndex;
            }
            index = (partLength & 0x3f) << 8 | [self.recordData qn_readInt8:index + 1];
            continue;
        } else if((partLength & 0xc0) > 0) {
            return nil;
        } else {
            index++;
        }
        
        if (partLength > 0) {
            if (name.length > 0) {
                [name appendString:@"."];
            }
            
            if (index + partLength > self.recordData.length) {
                return nil;
            }
            
            NSData *nameData = [self.recordData subdataWithRange:NSMakeRange(index, partLength)];
            [name appendString:[[NSString alloc] initWithData:nameData encoding:NSUTF8StringEncoding]];
            index += partLength;
        }
        
    } while (partLength && --maxLoop);
    
    recordName.name = name;
    if (recordName.skipLength < 1) {
        recordName.skipLength = index - fromIndex;
    }
    return recordName;
}

- (NSString *)readData:(int)recordType range:(NSRange)range {

    NSString *dataString = nil;
    NSData *dataValue = [self.recordData subdataWithRange:range];
    if (recordType == kQNTypeA) {
        if (dataValue.length == 4) {
            dataString = [NSString stringWithFormat:@"%d.%d.%d.%d", [dataValue qn_readInt8:0], [dataValue qn_readInt8:1], [dataValue qn_readInt8:2], [dataValue qn_readInt8:3]];
        }
    } else if (recordType == kQNTypeAAAA) {
        if (dataValue.length == 16) {
            NSMutableString *ipv6 = [NSMutableString string];
            for (int i=0; i<16; i+=2) {
                [ipv6 appendFormat:@"%@%02x%02x",(i?@":":@""), [dataValue qn_readInt8:i], [dataValue qn_readInt8:i+1]];
            }
            dataString = [ipv6 copy];
        }
    } else if (recordType == kQNTypeCname) {
        if (dataValue.length > 1) {
            QNDnsRecordName *name = [self getNameFrom:range.location];
            dataString = [name.name copy];
        }
    } else if (recordType == kQNTypeTXT) {
        if (dataValue.length > 1) {
            dataString = [[NSString alloc] initWithData:[dataValue subdataWithRange:NSMakeRange(1, dataValue.length - 1)] encoding:NSUTF8StringEncoding];
        }
    }
    return dataString;
}

- (void)copyError:(NSError *)error toErrorPoint:(NSError **)errorPoint {
    if (errorPoint != nil) {
        *errorPoint = error;
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"{messageId:%d, rd:%d, ra:%d, aa:%d, rCode:%d, server:%@, request:%@, answerArray:%@, authorityArray:%@, additionalArray:%@}", self.messageId, self.rd, self.ra, self.aa, self.rCode, self.server, self.request, self.answerArray, self.authorityArray, self.additionalArray];
}

@end
