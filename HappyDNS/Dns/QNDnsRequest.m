//
//  DnsQuestion.m
//  Doh
//
//  Created by yangsen on 2021/7/16.
//

#import "QNRecord.h"
#import "NSData+QNRW.h"
#import "QNDnsError.h"
#import "QNDnsRequest.h"

@interface QNDnsRequest()

@property(nonatomic, assign)int messageId;
@property(nonatomic, assign)QNDnsOpCode opCode;
@property(nonatomic, assign)int rd;
@property(nonatomic, assign)int recordType;
@property(nonatomic,   copy)NSString *host;

@end
@implementation QNDnsRequest
@synthesize messageId;
@synthesize opCode;
@synthesize rd;

+ (instancetype)request:(int)messageId
             recordType:(int)recordType
                   host:(NSString *)host {
    return [self request:messageId opCode:QNDnsOpCodeQuery rd:1 recordType:recordType host:host];
}

+ (instancetype)request:(int)messageId
                 opCode:(QNDnsOpCode)opCode
                     rd:(int)rd
             recordType:(int)recordType
                   host:(NSString *)host {
    QNDnsRequest *request = [[QNDnsRequest alloc] init];
    request.messageId = messageId;
    request.opCode = opCode;
    request.rd = rd;
    request.recordType = recordType;
    request.host = host;
    return request;
}

- (NSData *)toDnsQuestionData:(NSError *__autoreleasing  _Nullable *)error {
    if (self.host == nil || self.host.length == 0) {
        [self copyError:kQNDnsInvalidParamError(@"host can not empty") toErrorPoint:error];
        return nil;
    }
    
    if (self.opCode != QNDnsOpCodeQuery &&
        self.opCode != QNDnsOpCodeIQuery &&
        self.opCode != QNDnsOpCodeStatus &&
        self.opCode != QNDnsOpCodeUpdate) {
        [self copyError:kQNDnsInvalidParamError(@"opCode is not valid") toErrorPoint:error];
        return nil;
    }
    
    if (self.rd != 0 && self.rd != 1) {
        [self copyError:kQNDnsInvalidParamError(@"rd is not valid") toErrorPoint:error];
        return nil;
    }
    
    if (self.recordType != kQNTypeA &&
        self.recordType != kQNTypeCname &&
        self.recordType != kQNTypeTXT &&
        self.recordType != kQNTypeAAAA) {
        [self copyError:kQNDnsInvalidParamError(@"recordType is not valid") toErrorPoint:error];
        return nil;
    }
    
    NSMutableData *data = [NSMutableData data];
    [data qn_appendBigEndianInt16:self.messageId]; // 16 bit id
    // |00|01|02|03|04|05|06|07|
    // |QR|  OPCODE   |AA|TC|RD|
    [data qn_appendInt8:(self.opCode<<3) + self.rd];
    // |00|01|02|03|04|05|06|07|
    // |RA|r1|r2|r3| RCODE     |
    [data qn_appendInt8:0x00];
    [data qn_appendInt8:0x00];
    [data qn_appendInt8:0x01]; // QDCOUNT (number of entries in the question section)
    [data qn_appendInt8:0x00];
    [data qn_appendInt8:0x00]; // ANCOUNT
    [data qn_appendInt8:0x00];
    [data qn_appendInt8:0x00]; // NSCOUNT
    [data qn_appendInt8:0x00];
    [data qn_appendInt8:0x00]; // ARCOUNT
    
    NSArray *hostParts = [self.host componentsSeparatedByString:@"."];
    for (NSString *part in hostParts) {
        if (part.length > 63) {
            return nil;
        }
        [data qn_appendInt8:part.length];
        [data qn_appendString:part usingEncoding:NSUTF8StringEncoding];
    }
    [data qn_appendInt8:0x00]; /* terminating zero */
    [data qn_appendInt8:0x00];
    [data qn_appendInt8:self.recordType];
    [data qn_appendInt8:0x00];
    [data qn_appendInt8:0x01]; /* IN - "the Internet" */

    return data;
}

- (void)copyError:(NSError *)error toErrorPoint:(NSError **)errorPoint {
    if (errorPoint != nil) {
        *errorPoint = error;
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"messageId:%d opcode:%ld rd:%d ra:%d type:%ld", self.messageId, (long)self.opCode, self.rd, self.ra, (long)self.recordType];
}

@end
