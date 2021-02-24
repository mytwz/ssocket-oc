//
//  SCode.h
//  ssocketoc
//
//  Created by summer on 2021/2/20.
//

#import <Foundation/Foundation.h>
#import "SProtoBuf.h"
#import "SJSONObject.h"

NS_ASSUME_NONNULL_BEGIN


extern enum PackageType {
    /**握手 */
    shakehands = 0,
    /**心跳 */
    heartbeat = 1,
    /**消息 */
    data = 2
};

/**Socket 状态 */
extern enum SocketStatus {
    /**打开 */
    OPEN = 0,
    /**正在握手 */
    SHAKING_HANDS,
    /**握手完毕 */
    HANDSHAKE,
    /**连接 */
    CONNECTION,
    /**关闭 */
    CLOSE,
    /**重连 */
    RECONNECTION,
    /*手动关闭*/
    SHUTDOWN,
    /*正在连接*/
    OPENING,
    /**初始化*/
    INIT,
};

// 握手包
@interface ShakehandsPackage : SJSONObject
@property(nonatomic, copy) NSString* ID;
@property(nonatomic, assign) int ack;
- init:(NSString*) ID ack:(int)ack;
@end
// 心跳包
@interface HeartbeatPackage : SJSONObject
@property(nonatomic, assign) long time;
- init:(long) time;
@end
// 数据包
@interface DataPackage : SJSONObject
@property(nonatomic, copy) NSString* path;
@property(nonatomic, assign) int request_id;
@property(nonatomic, assign) int status;
@property(nonatomic, copy) NSString* msg;
@property(nonatomic, strong) id data;

-init:(NSString*) path request_id:(int)request_id status:(int)status msg:(NSString*)msg data:(id)data;
@end

@interface ResPacket : NSObject
@property(nonatomic, assign) int type;
@property(nonatomic, strong) id data;
-init:(int)type data:(id)data;
@end

@interface SCode : SJSONObject {
@private SProtoBuf* requestProtoBuf;
@private SProtoBuf* responseProtoBuf;
}
-init;
-(void) parseRequestJson:(NSString*) jsonString;
-(void) parseResponseJson:(NSString*) jsonString;

-(ResPacket*)decode:(NSMutableData*) buffer;
-(NSMutableData*) encodeShakehandsPackage:(NSString*) ID ack:(int)ack;
-(NSMutableData*) encodeHeartbeatPackage;
-(NSMutableData*) encodeDataPackage:(NSString*) path data:(id)data request_id:(int)request_id;


@end

NS_ASSUME_NONNULL_END
