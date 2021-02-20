//
//  SProtoBuf.m
//  ssocketoc
//
//  Created by summer on 2021/2/20.
//

#import "SProtoBuf.h"

static const NSString* FIELD_TYPE_MESSAGE = @"message";
static const NSString* FIELD_TYPE_REQUIRED = @"required";
static const NSString* FIELD_TYPE_OPTIONAL = @"optional";
static const NSString* FIELD_TYPE_REPEATED = @"repeated";

static const NSString* DATA_TYPE_UINT8 = @"uint8";
static const NSString* DATA_TYPE_UINT16 = @"uint16";
static const NSString* DATA_TYPE_UINT32 = @"uint32";
static const NSString* DATA_TYPE_UINT64 = @"uint64";
static const NSString* DATA_TYPE_FLOAT = @"float";
static const NSString* DATA_TYPE_DOUBLE = @"double";
static const NSString* DATA_TYPE_STRING = @"string";
static const NSString* DATA_TYPE_MESSAGE = @"message";

@interface NSString (SProtoBuf)
+(int) parseIntValue:(id)value;
+(float) parseFloatValue:(id)value;
+(double) parseDoubleValue:(id)value;
+(long) parseLongValue:(id)value;
+(NSString*) toString:(id) value;
+(NSMutableData*) toUTF8MutableData:(id) value;
-(NSMutableData*) toUTF8MutableData;
@end

@implementation NSString (SProtoBuf)

+(int) parseIntValue:(id)value {
    return [[self toString:value] intValue];
}
+(float) parseFloatValue:(id)value {
    return [[self toString:value] floatValue];
}
+(double) parseDoubleValue:(id)value {
    return [[self toString:value] doubleValue];
}
+(long) parseLongValue:(id)value {
    return [[self toString:value] longLongValue];
}
+(NSString*) toString:(id) value {
    return [NSString stringWithFormat:@"%@",value];
}

+(NSMutableData*) toUTF8MutableData:(id) value{
    return [[self toString:value] toUTF8MutableData];
}
-(NSMutableData*) toUTF8MutableData{
    return [[NSMutableData alloc] initWithData:[self dataUsingEncoding:NSUTF8StringEncoding]];
}
@end

@interface ReadBody : SJSONObject
@property int offset;
@property id value;
@end
@implementation ReadBody
@end

@implementation SProtoBuf

- parse:(NSString* )protos_config {
    @autoreleasepool {
        if(!protosConfig) protosConfig = [NSMutableDictionary new];
        NSMutableDictionary* protos = [SJSONObject parseDictionary: protos_config];
        if(protos){
            NSEnumerator * enumeratorKey = [protos keyEnumerator];
            for (NSString *key in enumeratorKey) {
                [protosConfig setObject:[self parseObject: [protos objectForKey:key]] forKey:key];
            }
        }
        
        return self;
    }
}

-(NSMutableDictionary*) parseObject:(NSMutableDictionary* )protos_config {
    @autoreleasepool {
        NSMutableDictionary* proto = [NSMutableDictionary new];
        NSMutableDictionary* nestProtos = [NSMutableDictionary new];
        NSMutableDictionary* tags = [NSMutableDictionary new];
        NSEnumerator * enumeratorKey = [protos_config keyEnumerator];
        for (NSString *key in enumeratorKey) {
            @autoreleasepool {
                id tag = [protos_config objectForKey:key];
                NSArray* params = [key componentsSeparatedByString:@" "];
                NSString* fieldType = params[0];
                if([FIELD_TYPE_MESSAGE isEqualToString:fieldType]){
                    if([params count] != 2){ continue; }
                    [nestProtos setObject:[self parseObject: tag] forKey:params[1]];
                    continue;
                }
                else if(
                        [FIELD_TYPE_REPEATED isEqualToString:fieldType] ||
                        [FIELD_TYPE_OPTIONAL isEqualToString:fieldType] ||
                        [FIELD_TYPE_REQUIRED isEqualToString:fieldType]
                        ){
                    if([params count] != 3 || [tags objectForKey:tag]){ continue; }
                    [proto setObject:@{ @"option": params[0], @"type": params[1], @"tag": [NSString toString:tag] } forKey:params[2]];
                    [tags setObject:params[2] forKey:[NSString toString:tag]];
                }
            }
        }
        [proto setObject:nestProtos forKey:@"__messages"];
        [proto setObject:tags forKey:@"__tags"];
        return proto;
    }
}

-(void) writeTag:(NSMutableData*)buffer tag:(int)tag {
    [SByteUtils writeUint8:buffer value:tag];
}

-(int) readTag:(NSMutableData*)buffer offset:(int)offset {
    return [SByteUtils readUint8:buffer offset:offset];
}

-(NSMutableData*)encode:(NSString*) proto_name data:(NSDictionary*)data {
    @autoreleasepool {
        NSMutableDictionary* data2 = [[NSMutableDictionary alloc] initWithDictionary:data];
        if([protosConfig objectForKey:proto_name]){
            NSMutableData* buffer = [NSMutableData new];
            int length = [self write:[protosConfig objectForKey:proto_name] data:data2 buffer:buffer];
            return [SByteUtils slice:buffer offset:0 length:length];
        }
        return [[NSMutableData alloc] initWithData:[[data2 yy_modelToJSONString] dataUsingEncoding:NSUTF8StringEncoding] ];
    }
}

-(int) write:(NSMutableDictionary*) protos data:(NSMutableDictionary*)data buffer:(NSMutableData*)buffer{
    @autoreleasepool {
        int offset = 0;
        NSEnumerator * enumeratorKey = [data keyEnumerator];
        for (NSString *key in enumeratorKey) {
            @autoreleasepool {
                if([protos objectForKey:key]){
                    NSMutableDictionary* proto = [protos objectForKey:key];
                    NSString* option = [proto objectForKey:@"option"];
                    NSString* type = [proto objectForKey:@"type"];
                    int tag = [NSString parseIntValue:[proto objectForKey:@"tag"]];
                    if([FIELD_TYPE_OPTIONAL isEqualToString:option] ||
                       [FIELD_TYPE_REQUIRED isEqualToString:option]){
                        [self writeTag:buffer tag:tag]; offset += 1;
                        offset = [self writeBody:[data objectForKey:key] buffer:buffer type:type offset:offset protos:protos];
                    }
                    else if([FIELD_TYPE_REPEATED isEqualToString:option]){
                        [self writeTag:buffer tag:tag]; offset += 1;
                        NSMutableArray* list = [data objectForKey:key];
                        [SByteUtils writeUint32:buffer value:(int)[list count]]; offset += 4;
                        for (id obj in list){
                            offset = [self writeBody:obj buffer:buffer type:type offset:offset protos:protos];
                        };
                    }
                }
            }
        }
        return offset;
    }
}

-(int) writeBody:(id)value buffer:(NSMutableData*)buffer type:(NSString*)type offset:(int)offset protos:(NSMutableDictionary*)protos {
    @autoreleasepool {
        if([DATA_TYPE_UINT8 isEqualToString: type]){
            [SByteUtils writeUint8:buffer value:[NSString parseIntValue:value]]; offset += 1;
        }
        else if([DATA_TYPE_UINT16 isEqualToString: type]){
            [SByteUtils writeUint16:buffer value:[NSString parseIntValue:value]]; offset += 2;
        }
        else if([DATA_TYPE_UINT32 isEqualToString: type]){
            [SByteUtils writeUint32:buffer value:[NSString parseIntValue:value]]; offset += 4;
        }
        else if([DATA_TYPE_UINT64 isEqualToString: type]){
            [SByteUtils writeUint64:buffer value:[NSString parseLongValue:value]]; offset += 8;
        }
        else if([DATA_TYPE_FLOAT isEqualToString: type]){
            [SByteUtils writeUFloat:buffer value: [NSString parseFloatValue:value]]; offset += 4;
        }
        else if([DATA_TYPE_DOUBLE isEqualToString: type]){
            [SByteUtils writeUDouble:buffer value: [NSString parseDoubleValue:value]]; offset += 8;
        }
        else if([DATA_TYPE_STRING isEqualToString: type]){
            NSMutableData* bytes = [NSString toUTF8MutableData:value];
            int length = (int)[bytes length];
            [SByteUtils writeUint32:buffer value:length]; offset += 4;
            [SByteUtils writeBytes:buffer value:bytes length:length]; offset += length;
        }
        else {
            NSMutableDictionary* message = [[protos objectForKey:@"__messages"] objectForKey:type];
            if(message){
                NSMutableData* tmpbuf = [NSMutableData new];
                int length = [self write:message data:value buffer:tmpbuf];
                [SByteUtils writeUint32:buffer value:length]; offset += 4;
                [SByteUtils writeBytes:buffer value:tmpbuf length:length]; offset += length;
            }
        }
        
        return offset;
    }
}

-(NSMutableDictionary*)decode:(NSString*) proto_name buffer:(NSMutableData*)buffer {
    @autoreleasepool {
        NSMutableDictionary* protos = [protosConfig objectForKey:proto_name];
        if(protos){
            NSMutableDictionary* data = [NSMutableDictionary new];
            [self read:protos data:data buffer:buffer offset:0];
            return data;
        }
        return [buffer length] > 0 ? [SJSONObject parseDictionary:[[NSString alloc] initWithData:buffer encoding:NSUTF8StringEncoding]] : [NSMutableDictionary new];
    }
}

-(void) read:(NSMutableDictionary*) protos data:(NSMutableDictionary*)data buffer:(NSMutableData*)buffer offset:(int)offset {
    @autoreleasepool {
        while (offset < [buffer length]) {
            @autoreleasepool {
                NSString* tag = [NSString stringWithFormat:@"%d", [self readTag:buffer offset:offset]]; offset += 1;
                NSString* name = [[protos objectForKey:@"__tags"] objectForKey:tag];
                if(name){
                    NSMutableDictionary* proto = [protos  objectForKey:name];
                    NSString* option = [proto objectForKey:@"option"];
                    NSString* type = [proto objectForKey:@"type"];
                    if([FIELD_TYPE_OPTIONAL isEqualToString:option] ||
                       [FIELD_TYPE_REQUIRED isEqualToString:option]){
                        ReadBody* body = [self readBody:buffer type:type offset:offset protos:protos];
                        offset = [body offset];
                        [data setObject:[body value] forKey:name];
                    }
                    else if([FIELD_TYPE_REPEATED isEqualToString:option]){
                        if(![data objectForKey: name]){ [data setObject:[NSMutableArray new] forKey:name]; }
                        NSMutableArray* list = [data objectForKey: name];
                        int length = [SByteUtils readUint32:buffer offset:offset]; offset += 4;
                        for(int i = 0; i < length; i++){
                            ReadBody* body = [self readBody:buffer type:type offset:offset protos:protos];
                            offset = [body offset];
                            [list addObject: body.value];
                        }
                    }
                }
            }
        }
    }
}

-(ReadBody*) readBody:(NSMutableData*) buffer type:(NSString*)type offset:(int)offset protos:(NSMutableDictionary*)protos{
    @autoreleasepool {
        ReadBody* body = [ReadBody new];
        if([DATA_TYPE_UINT8 isEqualToString: type]){
            int value = [SByteUtils readUint8:buffer offset:offset]; offset += 1;
            [body setValue:@(value)];
        }
        else if([DATA_TYPE_UINT16 isEqualToString: type]){
            int value = [SByteUtils readUint16:buffer offset:offset]; offset += 2;
            [body setValue:@(value)];
        }
        else if([DATA_TYPE_UINT32 isEqualToString: type]){
            int value = [SByteUtils readUint32:buffer offset:offset]; offset += 4;
            [body setValue:@(value)];
        }
        else if([DATA_TYPE_UINT64 isEqualToString: type]){
            long value = [SByteUtils readUint64:buffer offset:offset]; offset += 8;
            [body setValue:@(value)];
        }
        else if([DATA_TYPE_FLOAT isEqualToString: type]){
            float value = [SByteUtils readUFloat:buffer offset:offset]; offset += 4;
            [body setValue:@(value)];
        }
        else if([DATA_TYPE_DOUBLE isEqualToString: type]){
            float value = [SByteUtils readUDouble:buffer offset:offset]; offset += 8;
            [body setValue:@(value)];
        }
        else if([DATA_TYPE_STRING isEqualToString: type]){
            int length = [SByteUtils readUint32:buffer offset:offset]; offset += 4;
            [body setValue:[SByteUtils readString:buffer offset:offset length:length]]; offset += length;
        }
        else {
            NSMutableDictionary* message = [[protos objectForKey:@"__messages"] objectForKey:type];
            if(message){
                NSMutableDictionary* data = [NSMutableDictionary new];
                int length = [SByteUtils readUint32:buffer offset:offset]; offset += 4;
                [self read:message data:data buffer:[SByteUtils slice:buffer offset:offset length:length] offset:0]; offset += length;
                [body setValue: data];
            }
        }
        
        [body setOffset:offset];
        return body;
    }
}

@end
