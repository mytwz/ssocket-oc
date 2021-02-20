//
//  SWebSocket.h
//  ssocketoc
//
//  Created by summer on 2021/2/20.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import <SocketRocket/SocketRocket.h>
#import "SEmitter.h"
#import "SCode.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSOptions : NSObject
@property(nonatomic, assign) long ping_timeout;
@property(nonatomic, assign) long ping_time;
@property(nonatomic, assign) int reconnection_count;
@property(nonatomic, assign) long reconnection_time;
@property(nonatomic, copy) NSString* protos_request_json;
@property(nonatomic, copy) NSString* protos_response_json;

-init:(NSDictionary*) dict;
@end

@interface SWebSocket: SEmitter {
@private SCode* code;
@private int __index__;
@private SSOptions* options;
@private SRWebSocket *socket;
@private int reconnection_count;
}
@property(nonatomic, copy) NSString* ID;
@property(nonatomic, assign) int status;
@property(nonatomic, strong) NSString* url;

-init:(NSString*)url;
-init:(NSString*)url options:(NSDictionary*)options;
-request:(NSString*) path data:(NSDictionary*)data;
-request:(NSString*) path data:(NSDictionary*)data callback:(event_callback)callback;
-connection;
-(void)close;
@end

NS_ASSUME_NONNULL_END
