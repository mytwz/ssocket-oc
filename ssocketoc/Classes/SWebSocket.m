//
//  SWebSocket.m
//  ssocketoc
//
//  Created by summer on 2021/2/20.
//

#import "SWebSocket.h"

@implementation SSOptions
-init:(NSDictionary*) dict {
    
    long ping_timeout = [[NSString stringWithFormat:@"%@", dict[@"ping_timeout"]] longLongValue];
    long ping_time = [[NSString stringWithFormat:@"%@", dict[@"ping_time"]] longLongValue];
    int reconnection_count = [[NSString stringWithFormat:@"%@", dict[@"reconnection_count"]] intValue];
    long reconnection_time = [[NSString stringWithFormat:@"%@", dict[@"reconnection_time"]] longLongValue];
    NSString* protos_request_json = dict[@"protos_request_json"];
    NSString* protos_response_json = dict[@"protos_response_json"];
    
    
    [self setPing_time:ping_time > 0 ? ping_time : 10];
    [self setPing_timeout:ping_timeout > 0 ? ping_timeout : 60];
    [self setReconnection_time:reconnection_time > 0 ? reconnection_time : 2];
    [self setReconnection_count:reconnection_count > 0 ? reconnection_count : INT_MAX];
    [self setProtos_request_json:nil == protos_request_json ? @"" : protos_request_json];
    [self setProtos_response_json:nil == protos_response_json ? @"" : protos_response_json];
    return self;
}
@end

@interface SWebSocket()<SRWebSocketDelegate>
@property(nonatomic, assign) BOOL isPong;
@property(nonatomic, strong) Reachability* hostReachability;
@property(nonatomic, strong) Reachability* routeReachability;
@property(nonatomic, strong) NSMutableDictionary* requestIdDic;
@end    
@implementation SWebSocket
-init:(NSString*)url {
    return [self init:url options:[NSDictionary new]];
}
-init:(NSString*)url options:(NSDictionary*)optdict{
    self = [super init];
    
    code = [[SCode alloc] init];
    __index__ = 0;
    options = [[SSOptions alloc] init:optdict];
    reconnection_count = [options reconnection_count];
    self.status = INIT;
    self.ID = @"";
    self.url = url;
    self.requestIdDic = [NSMutableDictionary new];
    if(![@"" isEqualToString:[options protos_request_json]]){
        [code parseRequestJson:[options protos_request_json]];
    }
    if(![@"" isEqualToString:[options protos_response_json]]){
        [code parseResponseJson:[options protos_response_json]];
    }
    
    // 监听网络状态
    // Reachability 网络状态通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appReachaabilityChanegd:) name:kReachabilityChangedNotification object:nil];
    // 检测指定服务器是否可达
    self.hostReachability = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    // 检测默认路由是否可达
    self.routeReachability = [Reachability reachabilityForInternetConnection];
    
    [self.hostReachability startNotifier];
    [self.routeReachability startNotifier];
    
    return self;
}

-(void) appReachaabilityChanegd:(NSNotification*) not {
    Reachability* reach = [not object];
    if([reach isKindOfClass:[Reachability class]]){
        if(self.hostReachability == reach || self.routeReachability == reach) {
            NetworkStatus status = [reach currentReachabilityStatus];
            if(status == NotReachable){
                // 没有网络
                NSLog(@"没网络");
                if(self.status == CONNECTION){
                    self.status = SHUTDOWN;
                    [self close];
                }
            }
            else if(status == ReachableViaWiFi || status == ReachableViaWWAN){
                //  手机流量或者Wifi
                NSLog(@"有网络");
                if(self.status == CLOSE){
                    [self connection];
                }
            }
        }
    }
}

-connection {
    @autoreleasepool {
        if(self.status == OPENING) return self;
        if ([self status] == CLOSE || [self status] == SHUTDOWN || self.status == INIT) {
            socket = [[SRWebSocket alloc] initWithURLRequest: [NSURLRequest requestWithURL:[NSURL URLWithString:[self url]]]];
            socket.delegate = self;
            self.isPong = true;
            self.status = OPENING;
            [socket open];
            NSLog(@"发起 WebSocket 连接请求，地址是：%@",socket.url.absoluteString);
        }
        return self;
    }
}

-(void)close {
    if (nil != socket && self.status == CONNECTION) {
        @autoreleasepool {
            [self setStatus:SHUTDOWN];
            [self onClose:4020 reason:@"client close"];
            [socket closeWithCode:4020 reason:@"client close!"];
        }
    }
}

- (void)webSocketDidOpen:(SRWebSocket*)webSocket{
    @autoreleasepool {
        reconnection_count = options.reconnection_count;
        [self setStatus:OPEN];
        [self emit:@"open" data:@""];
        [self sendShakehands:SHAKING_HANDS];
        [self setStatus:SHAKING_HANDS];
        [self emit:@"shakehands" data:[NSNumber numberWithInt:SHAKING_HANDS]];
    }
}

- (void)webSocket:(SRWebSocket*)webSocket didFailWithError:(NSError*)error{
    @autoreleasepool {
        @try {
            [self emit:@"error" data:error];
            [self onClose:4104 reason:@"client error"];
        } @catch (NSException *exception) {
            NSLog(@"SWebSocket 收到前端报错回调函数： %@", exception);
        } @finally {
            
        }
    }
}
- (void)webSocket:(SRWebSocket*)webSocket didCloseWithCode:(NSInteger)code reason:(nullable NSString*)reason wasClean:(BOOL)wasClean{
    [self onClose:code reason:reason];
}


-(void)onClose:(int) code reason:(NSString*)reason {
    @autoreleasepool {
        if(self.status == CLOSE) return;
        for(NSString* event in [self.requestIdDic allKeys]){
            [self emit:event data:@{@"status":[NSNumber numberWithInteger:code], @"msg":@"socket colse!"}];
        }
        self.requestIdDic = [NSMutableDictionary new];
        socket.delegate = nil;
        socket = nil;
        [self emit:@"close" data:@{@"code": [NSNumber numberWithInteger:code], @"reason":reason, @"status": [NSNumber numberWithInteger:self.status]}];
        if(self.status != SHUTDOWN){
            [self setStatus:CLOSE];
            if(reconnection_count-- > 0){
                [self performSelector:@selector(startReconnectioning) withObject:nil afterDelay:options.reconnection_time];
            }
        }
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    @try {
        if([message isKindOfClass:NSData.class]){
            @autoreleasepool {
                ResPacket* packet = [code decode:[[NSMutableData alloc] initWithData:message]];
                if(nil != packet){
                    if(shakehands == [packet type]){
                        ShakehandsPackage* pack = [packet data];
                        if(HANDSHAKE == [pack ack]){
                            if([@"" isEqualToString:[self ID]]){ [self setID:[pack ID]]; }
                            [self sendShakehands:CONNECTION];
                            [self setStatus:HANDSHAKE];
                            [self emit:@"shakehands" data:[NSNumber numberWithInt:HANDSHAKE]];
                        }
                        else if(CONNECTION == [pack ack]){
                            [self setStatus:CONNECTION];
                            [self emit:@"shakehands" data:[NSNumber numberWithInt:CONNECTION]];
                            [self emit:[[self ID] isEqualToString:pack.ID] ? @"connection" : @"reconnection" data:[NSNumber numberWithInt:CONNECTION]];
                            [self sendHeartbeat];
                        }
                    }
                    else if(heartbeat == [packet type]){
                        self.isPong = true;
                        HeartbeatPackage* pack = [packet data];
                        [self emit:@"pong" data:[NSNumber numberWithLong:pack.time]];
                        [self performSelector:@selector(sendHeartbeat) withObject:nil afterDelay:options.ping_time];
                    }
                    else if(data == [packet type]){
                        DataPackage* pack = [packet data];
                        if(0 != pack.request_id){ [self emit:[NSString stringWithFormat:@"%d", pack.request_id] data:pack]; }
                        else { [self emit:pack.path data:pack]; }
                    }
                }
            }
        }
    } @catch (NSException *exception) {
        [self emit:@"error" data:exception];
        NSLog(@"SWebSocket 处理异常： %@", exception);
    } @finally {
        
    }
    
}

-(void) startReconnectioning{
    if(self.status == CLOSE){
        [self emit:@"reconnectioning" data:[NSNumber numberWithInt:options.reconnection_count - reconnection_count]];
        [self connection];
    }
}

-(void) startPongtimeout{
    if(!self.isPong){
        if (nil != socket && socket.readyState == SR_OPEN) {
            [socket closeWithCode:4102 reason:@"server pong timeout"];
        }
        [self emit:@"pong_timeout" data:nil];
    }
}

-(void)sendHeartbeat {
    if (nil != socket && socket.readyState == SR_OPEN) {
        NSMutableData* buffer = [code encodeHeartbeatPackage];
        [socket send:buffer];
        self.isPong = false;
        [self emit:@"ping" data:[NSNumber numberWithLong:[[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000]];
        [self performSelector:@selector(startPongtimeout) withObject:nil afterDelay:options.ping_timeout];
    }
}

-(void)sendShakehands:(int)ack {
    if (nil != socket && socket.readyState == SR_OPEN) {
        NSMutableData* buffer = [code encodeShakehandsPackage:[self ID] ack:ack];
        [socket send:buffer];
    }
}

-request:(NSString*) path data:(NSDictionary*)data{
    @autoreleasepool {
        if (nil != socket && socket.readyState == SR_OPEN && self.status == CONNECTION) {
            int request_id = __index__++ > 999999 ? (__index__ = 1) : __index__;
            NSMutableData* buffer = [code encodeDataPackage:path data:data request_id:request_id];
            [socket send:buffer];
        }
        return self;
    }
}

-request:(NSString*) path data:(NSDictionary*)data callback:(event_callback)callback{
    @autoreleasepool {
        if (nil != socket && socket.readyState == SR_OPEN && self.status == CONNECTION) {
            int request_id = __index__++ > 999999 ? (__index__ = 1) : __index__;
            NSString* ID = [NSString stringWithFormat:@"%d", request_id];
            [self.requestIdDic setValue:ID forKey:ID];
            [self once:ID callback:^(id data) {
                callback(data);
                [self.requestIdDic removeObjectForKey:ID];
            }];
            NSMutableData* buffer = [code encodeDataPackage:path data:data request_id:request_id];
            [socket send:buffer];
        }
        return self;
    }
}

@end
