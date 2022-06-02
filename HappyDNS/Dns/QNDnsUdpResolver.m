//
//  QNDnsServer.m
//  Doh
//
//  Created by yangsen on 2021/7/20.
//

#import "QNRecord.h"
#import "QNDomain.h"
#import "QNDnsError.h"
#import "QNDnsResponse.h"
#import "QNDnsUdpResolver.h"
#import "QNAsyncUdpSocket.h"

@interface QNDnsFlow : NSObject

@property(nonatomic, assign)long flowId;
@property(nonatomic,   copy)NSString *server;
@property(nonatomic, strong)QNDnsRequest *dnsRequest;
@property(nonatomic, strong)QNAsyncUdpSocket *socket;
@property(nonatomic,   copy)void(^complete)(QNDnsResponse *response, NSError *error);

@end
@implementation QNDnsFlow
@end

#define kDnsPort 53
@interface QNDnsUdpResolver()<QNAsyncUdpSocketDelegate>

@property(nonatomic, assign)int recordType;
@property(nonatomic, assign)int timeout;
@property(nonatomic,   copy)NSArray *servers;
@property(nonatomic, strong)dispatch_queue_t queue;
@property(nonatomic, strong)NSMutableDictionary *flows;

@end

@implementation QNDnsUdpResolver
@synthesize recordType;
@synthesize timeout;
@synthesize servers;

+ (instancetype)resolverWithServerIP:(NSString *)serverIP {
    return [self resolverWithServerIP:serverIP recordType:kQNTypeA timeout:QN_DNS_DEFAULT_TIMEOUT];
}

+ (instancetype)resolverWithServerIP:(NSString *)serverIP
                          recordType:(int)recordType
                             timeout:(int)timeout {
    return [self resolverWithServerIPs:serverIP ? @[serverIP] : @[] recordType:recordType timeout:timeout];
}

+ (instancetype)resolverWithServerIPs:(NSArray <NSString *> *)serverIPs
                           recordType:(int)recordType
                              timeout:(int)timeout {
    return [self resolverWithServerIPs:serverIPs recordType:recordType queue:nil timeout:timeout];
}

+ (instancetype)resolverWithServerIPs:(NSArray <NSString *> *)servers
                           recordType:(int)recordType
                                queue:(dispatch_queue_t _Nullable)queue
                              timeout:(int)timeout {
    
    QNDnsUdpResolver *resolver = [[self alloc] init];
    resolver.recordType = recordType;
    resolver.servers = [servers copy] ?: @[];
    resolver.timeout = timeout;
    resolver.queue = queue;
    return resolver;
}

+ (dispatch_queue_t)defaultQueue {
    static dispatch_once_t onceToken;
    static dispatch_queue_t timerQueue;
    dispatch_once(&onceToken, ^{
        timerQueue = dispatch_queue_create("com.qiniu.dns.udp.queue", DISPATCH_QUEUE_CONCURRENT);
    });
    return timerQueue;
}

- (dispatch_queue_t)queue {
    if (_queue == nil) {
        _queue = [QNDnsUdpResolver defaultQueue];
    }
    return _queue;
}

- (NSMutableDictionary *)flows {
    if (_flows == nil) {
        _flows = [NSMutableDictionary dictionary];
    }
    return _flows;
}

- (void)request:(NSString *)server
           host:(NSString *)host
     recordType:(int)recordType
       complete:(void(^)(QNDnsResponse *response, NSError *error))complete {
    if (complete == nil) {
        return;
    }
    
    int messageId = arc4random()%(0xFFFF);
    QNDnsRequest *dnsRequest = [QNDnsRequest request:messageId recordType:recordType host:host];
    
    NSError *error = nil;
    NSData *requestData = [dnsRequest toDnsQuestionData:&error];
    if (error) {
        complete(nil, error);
        return;
    }
    
    QNAsyncUdpSocket *socket = [[QNAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:self.queue];
    // 由系统决定端口号
    [socket bindToPort:0 error: &error];
    if (error) {
        complete(nil, error);
        return;
    }
    
    [socket beginReceiving:&error];
    if (error) {
        complete(nil, error);
        return;
    }
    
    QNDnsFlow *flow = [[QNDnsFlow alloc] init];
    flow.flowId = [socket hash];
    flow.server = server;
    flow.dnsRequest = dnsRequest;
    flow.socket = socket;
    flow.complete = complete;
    [self setFlow:flow withId:flow.flowId];
    
    [socket sendData:requestData toHost:server port:kDnsPort withTimeout:self.timeout tag:flow.flowId];
}

- (void)udpSocketComplete:(QNAsyncUdpSocket *)sock data:(NSData *)data error:(NSError * _Nullable)error {
    [sock close];
    
    QNDnsFlow *flow = [self getFlowWithId:[sock hash]];
    if (!flow) {
        return;
    }
    [self removeFlowWithId:flow.flowId];
    
    if (error != nil) {
        flow.complete(nil, error);
    } else if (data != nil) {
        NSError *err = nil;
        QNDnsResponse *response = [QNDnsResponse dnsResponse:flow.server source:QNRecordSourceUdp request:flow.dnsRequest dnsRecordData:data error:&err];
        flow.complete(response, err);
    } else {
        flow.complete(nil, nil);
    }
}

//MARK: -- QNAsyncUdpSocketDelegate
- (void)udpSocket:(QNAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address {
}

- (void)udpSocket:(QNAsyncUdpSocket *)sock didNotConnect:(NSError * _Nullable)error {
    [self udpSocketComplete:sock data:nil error:error];
}

- (void)udpSocket:(QNAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
}

- (void)udpSocket:(QNAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError * _Nullable)error {
    [self udpSocketComplete:sock data:nil error:error];
}

- (void)udpSocket:(QNAsyncUdpSocket *)sock
   didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(nullable id)filterContext {
    [self udpSocketComplete:sock data:data error:nil];
}

- (void)udpSocketDidClose:(QNAsyncUdpSocket *)sock withError:(NSError  * _Nullable)error {
    [self udpSocketComplete:sock data:nil error:error];
}


//MARK: flows
- (QNDnsFlow *)getFlowWithId:(long)flowId {
    NSString *key = [NSString stringWithFormat:@"%ld", flowId];
    QNDnsFlow *flow = nil;
    @synchronized (self) {
        flow = self.flows[key];
    }
    return flow;
}

- (BOOL)setFlow:(QNDnsFlow *)flow withId:(long)flowId {
    if (flow == nil) {
        return false;
    }
    
    NSString *key = [NSString stringWithFormat:@"%ld", flowId];
    @synchronized (self) {
        self.flows[key] = flow;
    }
    return true;
}

- (void)removeFlowWithId:(long)flowId {
    NSString *key = [NSString stringWithFormat:@"%ld", flowId];
    @synchronized (self) {
        [self.flows removeObjectForKey:key];
    }
}

@end
