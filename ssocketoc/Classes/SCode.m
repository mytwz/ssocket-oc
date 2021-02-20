//
//  SCode.m
//  ssocketoc
//
//  Created by summer on 2021/2/20.
//

#import "SCode.h"

@implementation ShakehandsPackage
- init:(NSString*) ID ack:(int)ack {
    [self setID:ID];
    [self setAck:ack];
    return self;
}
@end
@implementation HeartbeatPackage
- init:(long) time {
    [self setTime:time];
    return self;
}
@end
@implementation DataPackage
-init:(NSString*) path request_id:(int)request_id status:(int)status msg:(NSString*)msg data:(id)data {
    [self setPath:path];
    [self setRequest_id:request_id];
    [self setStatus:status];
    [self setMsg:msg];
    [self setData:data];
    return self;
}
@end

@implementation ResPacket
-(id)init:(int)type data:(id)data{
    self = [super init];
    [self setType:type];
    [self setData:data];
    return self;
}
@end

@implementation SCode

-(void) parseRequestJson:(NSString*) jsonString{
    if(nil == requestProtoBuf) requestProtoBuf = [SProtoBuf new];
    [requestProtoBuf parse:jsonString];
}
-(void) parseResponseJson:(NSString*) jsonString{
    if(nil == responseProtoBuf) responseProtoBuf = [SProtoBuf new];
    [responseProtoBuf parse:jsonString];
}

/**
 * 握手消息
 * - +------+----------------------------------+------+
 * - | head | This data exists when type == 0  | body |
 * - +------+------------+---------------------+------+
 * - | type | id length  | id                  | ack  |
 * - +------+------------+---------------------+------+
 * - | 1B   | 4B         | --                  | 1B   |
 * - +------+------------+---------------------+------+
 */
-(NSMutableData*) encodeShakehandsPackage:(NSString*) ID ack:(int)ack{
    @autoreleasepool {
        NSMutableData* buffer = [NSMutableData new];
        [SByteUtils writeUint8:buffer value: shakehands];
        NSMutableData* id_data = [[NSMutableData alloc] initWithData: [ID dataUsingEncoding:NSUTF8StringEncoding]];
        [SByteUtils writeUint32:buffer value:[id_data length]];
        [SByteUtils writeBytes:buffer value:id_data length:[id_data length]];
        [SByteUtils writeUint8:buffer value:ack];
        return buffer;
    }
}
/**
 * 心跳消息
 * - +------+----------------------------------+------+
 * - | head | This data exists when type == 1  | body |
 * - +------+----------------------------------+------+
 * - | type | body length                      | time |
 * - +------+----------------------------------+------+
 * - | 1B   | 0B                               | 8B   |
 * - +------+----------------------------------+------+
 */
-(NSMutableData*) encodeHeartbeatPackage{
    @autoreleasepool {
        NSMutableData* buffer = [NSMutableData new];
        [SByteUtils writeUint8:buffer value: heartbeat];
        [SByteUtils writeUint64:buffer value:[[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000];
        return buffer;
    }
}

/**
 * 数据消息
 * - +------+---------------------------------------------------+------+
 * - | head | This data exists when type == 2                   | body |
 * - +------+------------+---------------+--------+-------------+------+
 * - | type | request_id | path length   | path   | body length | body |
 * - +------+------------+---------------+--------+-------------+------+
 * - | 1B   | 4B         | 4B            | 4B     | 4B          | --   |
 * - +------+------------+---------------+--------+-------------+------+
 */
-(NSMutableData*) encodeDataPackage:(NSString*) path data:(id)body request_id:(int)request_id{
    @autoreleasepool {
        NSMutableData* buffer = [NSMutableData new];
        [SByteUtils writeUint8:buffer value: data];
        [SByteUtils writeUint32:buffer value:request_id];
        NSMutableData* path_data = [[NSMutableData alloc] initWithData: [path dataUsingEncoding:NSUTF8StringEncoding]];
        [SByteUtils writeUint32:buffer value:[path_data length]];
        [SByteUtils writeBytes:buffer value:path_data length:[path_data length]];
        NSMutableData* body_buf = [requestProtoBuf encode:path data:body];
        if([body_buf length] > 128){
            body_buf = [SByteUtils gzip:body_buf];
        }
        [SByteUtils writeUint32:buffer value:[body_buf length]];
        [SByteUtils writeBytes:buffer value:body_buf length:[body_buf length]];
        
        return buffer;
    }
}

/*
 *
 * - +------+----------------------------------+------+
 * - | head | This data exists when type == 0  | body |
 * - +------+------------+---------------------+------+
 * - | type | id length  | id                  | ack  |
 * - +------+------------+---------------------+------+
 * - | 1B   | 4B         | --                  | 1B   |
 * - +------+------------+---------------------+------+
 * - +------+----------------------------------+------+
 * - | head | This data exists when type == 1  | body |
 * - +------+----------------------------------+------+
 * - | type | body length                      | time |
 * - +------+----------------------------------+------+
 * - | 1B   | 0B                               | 8B   |
 * - +------+----------------------------------+------+
 * - +------+-------------------------------------------------------------------------------+------+
 * - | head | This data exists when type == 2                                               | body |
 * - +------+------------+---------------+--------+--------+------------+-----+-------------+------+
 * - | type | request_id | path length   | path   | status | msg length | msg | body length | body |
 * - +------+------------+---------------+--------+--------+------------+-----+-------------+------+
 * - | 1B   | 4B         | 4B            | --     | 4B     | 4B         | --  | 4B          | --   |
 * - +------+------------+---------------+--------+--------+------------+-----+-------------+------+
 * -
 */
-(ResPacket*)decode:(NSMutableData*) buffer{
    @autoreleasepool {
        int offset = 0;
        int type = [SByteUtils readUint8:buffer offset:offset]; offset += 1;
        if(shakehands == type){
            int length = [SByteUtils readUint32:buffer offset:offset]; offset += 4;
            NSString* ID = [SByteUtils readString:buffer offset:offset length:length]; offset += length;
            int ack = [SByteUtils readUint8:buffer offset:offset];
            return [[ResPacket alloc] init:type data:[[ShakehandsPackage alloc] init:ID ack:ack]];
        }
        else if(heartbeat == type){
            long time = (long)[SByteUtils readUint64:buffer offset:offset];
            return [[ResPacket alloc] init:type data:[[HeartbeatPackage alloc] init:time]];
        }
        else if(data == type){
            int  request_id = [SByteUtils readUint32:buffer offset:offset]; offset += 4;
            int path_length = [SByteUtils readUint32:buffer offset:offset]; offset += 4;
            NSString* path = [SByteUtils readString:buffer offset:offset length:path_length]; offset += path_length;
            int status = [SByteUtils readUint32:buffer offset:offset]; offset += 4;
            int msg_length = [SByteUtils readUint32:buffer offset:offset]; offset += 4;
            NSString* msg = [SByteUtils readString:buffer offset:offset length:msg_length]; offset += msg_length;
            int body_length = [SByteUtils readUint32:buffer offset:offset]; offset += 4;
            NSMutableDictionary* body = [responseProtoBuf decode:path buffer:[SByteUtils gunzip:[SByteUtils slice:buffer offset:offset length:body_length]]];
            
            return [[ResPacket alloc] init:type data:[[DataPackage alloc] init:path request_id:request_id status:status msg:msg data:body]];
        }
    }
    return nil;
}
@end
