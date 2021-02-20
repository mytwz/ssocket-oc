//
//  SByteUtils.m
//  ssocketoc
//
//  Created by summer on 2021/2/20.
//

#import "SByteUtils.h"

@implementation SByteUtils

+(int)changInt32:(int)value{
    
    return (value & 0x000000FF) << 24 |
    (value & 0x0000FF00) << 8 |
    (value & 0x00FF0000) >> 8 |
    (value & 0xFF000000) >> 24;
}

+(long)changeInt64:(long)value{
    
    @autoreleasepool {
        NSData* tmp = [[NSData alloc] initWithBytes:(Byte[]){
            (value & 0x00000000000000FF) >> 0,
            (value & 0x000000000000FF00) >> 8,
            (value & 0x0000000000FF0000) >> 16,
            (value & 0x00000000FF000000) >> 24,
            (value & 0x000000FF00000000) >> 32,
            (value & 0x0000FF0000000000) >> 40,
            (value & 0x00FF000000000000) >> 48,
            (value & 0xFF00000000000000) >> 56
        } length:8];
        
        NSMutableData* data = [NSMutableData new];
        for(long i = tmp.length; i > 0; i--){
            [data appendData:[tmp subdataWithRange:NSMakeRange(i - 1, 1)]];
        }
        
        return *(uint64_t*)[data bytes];
    }
}

/*
 * 写入1个字节的无符号 int 值
 * @param NSMutableData 二进制缓冲区
 * @param value 写入的值
 * @returns void
 */
+(void) writeUint8:(NSMutableData*) buffer value:(int)value {
    @autoreleasepool {
        Byte byte = (value & 0x000000FF) >> 0;
        [buffer appendBytes:(Byte[]){ byte } length:1];
    }
}
/*
 * 写入2个字节的无符号 int 值
 * @param NSMutableData 二进制缓冲区
 * @param value 写入的值
 * @returns void
 */
+(void) writeUint16:(NSMutableData*) buffer value:(int)value {
    @autoreleasepool {
        value = [self changInt32:value] >> 16;
        
        Byte byte1 = (value & 0x000000FF) >> 0;
        Byte byte2 = (value & 0x0000FF00) >> 8;
        [buffer appendBytes:(Byte[]){ byte1, byte2 } length:2];
    }
}
/*
 * 写入4个字节的无符号 int 值
 * @param NSMutableData 二进制缓冲区
 * @param value 写入的值
 * @returns void
 */
+(void) writeUint32:(NSMutableData*) buffer value:(int)value {
    @autoreleasepool {
        value = [self changInt32:value];
        
        Byte byte1 = (value & 0x000000FF) >> 0;
        Byte byte2 = (value & 0x0000FF00) >> 8;
        Byte byte3 = (value & 0x00FF0000) >> 16;
        Byte byte4 = (value & 0xFF000000) >> 24;
        [buffer appendBytes:(Byte[]){ byte1, byte2, byte3, byte4 } length:4];
    }
}
/*
 * 写入8个字节的无符号 int 值
 * @param NSMutableData 二进制缓冲区
 * @param value 写入的值
 * @returns void
 */
+(void) writeUint64:(NSMutableData*) buffer value:(long)value {
    @autoreleasepool {
        
        Byte byte1 = (value & 0x00000000000000FF) >> 0;
        Byte byte2 = (value & 0x000000000000FF00) >> 8;
        Byte byte3 = (value & 0x0000000000FF0000) >> 16;
        Byte byte4 = (value & 0x00000000FF000000) >> 24;
        Byte byte5 = (value & 0x000000FF00000000) >> 32;
        Byte byte6 = (value & 0x0000FF0000000000) >> 40;
        Byte byte7 = (value & 0x00FF000000000000) >> 48;
        Byte byte8 = (value & 0xFF00000000000000) >> 56;
        [buffer appendBytes:(Byte[]){
            byte8, byte7, byte6, byte5,
            byte4, byte3, byte2, byte1
        } length:8];
        
    }
}
/*
 * 写入4个字节的无符号 浮点数 值
 * @param NSMutableData 二进制缓冲区
 * @param value 写入的值
 * @returns void
 */
+(void) writeUFloat:(NSMutableData*) buffer value:(float)value {
    @autoreleasepool {
        union __attribute__((objc_boxable)) UFloat {
            unsigned int data;
            float value;
        } proxy ;
        
        proxy.value = value;
        
        Byte byte1 = (proxy.data & 0x000000FF) >> 0;
        Byte byte2 = (proxy.data & 0x0000FF00) >> 8;
        Byte byte3 = (proxy.data & 0x00FF0000) >> 16;
        Byte byte4 = (proxy.data & 0xFF000000) >> 24;
        [buffer appendBytes:(Byte[]){ byte4, byte3, byte2, byte1 } length:4];
    }
}
/*
 * 写入8个字节的无符号 浮点数 值
 * @param NSMutableData 二进制缓冲区
 * @param value 写入的值
 * @returns void
 */
+(void) writeUDouble:(NSMutableData*) buffer value:(double)value {
    @autoreleasepool {
        union __attribute__((objc_boxable)) UDouble {
            unsigned long long data;
            double value;
        } proxy ;
        
        proxy.value = value;
        
        Byte byte1 = (proxy.data & 0x00000000000000FF) >> 0;
        Byte byte2 = (proxy.data & 0x000000000000FF00) >> 8;
        Byte byte3 = (proxy.data & 0x0000000000FF0000) >> 16;
        Byte byte4 = (proxy.data & 0x00000000FF000000) >> 24;
        Byte byte5 = (proxy.data & 0x000000FF00000000) >> 32;
        Byte byte6 = (proxy.data & 0x0000FF0000000000) >> 40;
        Byte byte7 = (proxy.data & 0x00FF000000000000) >> 48;
        Byte byte8 = (proxy.data & 0xFF00000000000000) >> 56;
        [buffer appendBytes:(Byte[]){
            byte8, byte7, byte6, byte5,
            byte4, byte3, byte2, byte1
        } length:8];
    }
}
/*
 * 写入字符串
 * @param NSMutableData 二进制缓冲区
 * @param NSMutableData 写入的值
 * @param int 写入长度
 * @returns void
 */
+(void) writeBytes:(NSMutableData*) buffer value:(NSMutableData*)value length:(long)length{
    @autoreleasepool {
        [buffer appendData:[value subdataWithRange:NSMakeRange(0, length)]];
    }
}

/*
 * 读取1个字节的无符号 int 值
 * @param NSMutableData 二进制缓冲区
 * @param int 读取位置
 * @returns int
 */
+(int) readUint8:(NSMutableData*) buffer offset:(int)offset{
    @autoreleasepool {
        NSData* data = [buffer subdataWithRange:NSMakeRange(offset, 1)];
        int value = *(uint8_t *)([data bytes]);
        return value ;
    }
}
/*
 * 读取2个字节的无符号 int 值
 * @param NSMutableData 二进制缓冲区
 * @param int 读取位置
 * @returns int
 */
+(int) readUint16:(NSMutableData*) buffer offset:(int)offset{
    @autoreleasepool {
        NSData* data = [buffer subdataWithRange:NSMakeRange(offset, 2)];
        int value = *(uint16_t *)([data bytes]);
        return ((value & 0x000000FF) << 8) | ((value & 0x0000FF00) >> 8);
    }
}
/*
 * 读取4个字节的无符号 int 值
 * @param NSMutableData 二进制缓冲区
 * @param int 读取位置
 * @returns int
 */
+(int) readUint32:(NSMutableData*) buffer offset:(int)offset{
    @autoreleasepool {
        NSData* data = [buffer subdataWithRange:NSMakeRange(offset, 4)];
        int value = *(uint32_t *)([data bytes]);
        return [self changInt32:value] ;
    }
}
/*
 * 读取64个字节的无符号 int 值
 * @param NSMutableData 二进制缓冲区
 * @param int 读取位置
 * @returns long
 */
+(long) readUint64:(NSMutableData*) buffer offset:(int)offset{
    @autoreleasepool {
        NSData* big = [buffer subdataWithRange:NSMakeRange(offset, 4)];
        NSData* low = [buffer subdataWithRange:NSMakeRange(offset + 4, 4)];
        
        NSMutableData* big2 = [NSMutableData new];
        for(long i = big.length; i > 0; i--){
            [big2 appendData:[big subdataWithRange:NSMakeRange(i - 1, 1)]];
        }
        NSMutableData* low2 = [NSMutableData new];
        for(long i = low.length; i > 0; i--){
            [low2 appendData:[low subdataWithRange:NSMakeRange(i - 1, 1)]];
        }
        
        NSMutableData* data = [NSMutableData new];
        [data appendData:low2];
        [data appendData:big2];
        long value = *(uint64_t *)([data bytes]);
        return value;
    }
}
/*
 * 读取4个字节的无符号 浮点数 值
 * @param NSMutableData 二进制缓冲区
 * @param int 读取位置
 * @returns float
 */
+(float) readUFloat:(NSMutableData*) buffer offset:(int)offset{
    @autoreleasepool {
        NSData* data = [buffer subdataWithRange:NSMakeRange(offset, 4)];
        
        union __attribute__((objc_boxable)) UFloat {
            unsigned int data;
            float value;
        } proxy ;
        
        proxy.value = *(float_t *)([data bytes]);
        proxy.data = [self changInt32:proxy.data] ;
        
        return proxy.value;
    }
}
/*
 * 读取8个字节的无符号 浮点数 值
 * @param NSMutableData 二进制缓冲区
 * @param int 读取位置
 * @returns double
 */
+(double) readUDouble:(NSMutableData*) buffer offset:(int)offset{
    @autoreleasepool {
        NSData* data = [buffer subdataWithRange:NSMakeRange(offset, 8)];
        union __attribute__((objc_boxable)) UDouble {
            unsigned long long data;
            double value;
        } proxy ;
        proxy.value = *(double_t *)([data bytes]);
        proxy.data = [self changeInt64:proxy.data];
        return proxy.value;
    }
}
/*
 * 截取指定区域的二进制数据
 * @param NSMutableData 二进制缓冲区
 * @param int 截取位置
 * @returns int 截取长度
 */
+(NSMutableData*) slice:(NSMutableData*) buffer offset:(int)offset length:(long)length{
    if([buffer length] <= length) length = [buffer length] - offset;
    return [NSMutableData dataWithData:[buffer subdataWithRange:NSMakeRange(offset, length)]] ;
}

/*
 * 读取一个字符串
 * @param NSMutableData 二进制缓冲区
 * @param int 读取的位置
 * @param long 读取长度
 * @returns NSString
 */
+(NSString*) readString:(NSMutableData*) buffer offset:(int)offset length:(long)length {
    @autoreleasepool {
        return [[NSString alloc] initWithData:[self slice:buffer offset:offset length:length] encoding:NSUTF8StringEncoding];
    }
}

/*
 * 写入一个字符串
 * @param NSMutableData 二进制缓冲区
 * @param NSString 写入的值
 * @param int 写入位置
 * @returns int 写入长度
 */
+(long) writeString:(NSMutableData*) buffer value:(NSString*)value offset:(int)offset {
    @autoreleasepool {
        NSMutableData* str = [[NSMutableData alloc] initWithData:[value dataUsingEncoding:NSUTF8StringEncoding]];
        [self writeBytes:buffer value:str length:[str length]];
        return [str length];
    }
}

/*
 * GZIP 压缩
 * @param NSMutableData 二进制缓冲区
 * @returns NSMutableData 压缩后的数据
 */
+(NSMutableData*) gzip:(NSMutableData*) buffer {
    @autoreleasepool {
        return [[NSMutableData alloc] initWithData:[[[NSMutableData alloc] initWithData:buffer] gzippedData] ];
    }
}
/*
 * GZIP 解压缩
 * @param NSMutableData 二进制缓冲区
 * @returns NSMutableData 解压缩后的数据
 */
+(NSMutableData*) gunzip:(NSMutableData*) buffer {
    @autoreleasepool {
        return [[NSMutableData alloc] initWithData:[[[NSMutableData alloc] initWithData:buffer] gunzippedData] ];
    }
}

@end
