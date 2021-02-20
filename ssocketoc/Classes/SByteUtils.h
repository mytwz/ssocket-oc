//
//  SByteUtils.h
//  ssocketoc
//
//  Created by summer on 2021/2/20.
//

#import <Foundation/Foundation.h>
#import "GZIP/GZIP.h"

NS_ASSUME_NONNULL_BEGIN

@interface SByteUtils : NSObject

/*
 * 写入1个字节的无符号 int 值
 * @param NSMutableData 二进制缓冲区
 * @param value 写入的值
 * @returns void
 */
+(void) writeUint8:(NSMutableData*) buffer value:(int)value ;
/*
 * 写入2个字节的无符号 int 值
 * @param NSMutableData 二进制缓冲区
 * @param value 写入的值
 * @returns void
 */
+(void) writeUint16:(NSMutableData*) buffer value:(int)value ;
/*
 * 写入4个字节的无符号 int 值
 * @param NSMutableData 二进制缓冲区
 * @param value 写入的值
 * @returns void
 */
+(void) writeUint32:(NSMutableData*) buffer value:(int)value ;
/*
 * 写入8个字节的无符号 int 值
 * @param NSMutableData 二进制缓冲区
 * @param value 写入的值
 * @returns void
 */
+(void) writeUint64:(NSMutableData*) buffer value:(long)value ;
/*
 * 写入4个字节的无符号 浮点数 值
 * @param NSMutableData 二进制缓冲区
 * @param value 写入的值
 * @returns void
 */
+(void) writeUFloat:(NSMutableData*) buffer value:(float)value ;
/*
 * 写入8个字节的无符号 浮点数 值
 * @param NSMutableData 二进制缓冲区
 * @param value 写入的值
 * @returns void
 */
+(void) writeUDouble:(NSMutableData*) buffer value:(double)value ;
/*
 * 写入字符串
 * @param NSMutableData 二进制缓冲区
 * @param NSMutableData 写入的值
 * @param int 写入位置
 * @param int 写入长度
 * @returns void
 */
+(void) writeBytes:(NSMutableData*) buffer value:(NSMutableData*)value  length:(long)length;

/*
 * 读取1个字节的无符号 int 值
 * @param NSMutableData 二进制缓冲区
 * @param int 读取位置
 * @returns int
 */
+(int) readUint8:(NSMutableData*) buffer offset:(int)offset;
/*
 * 读取2个字节的无符号 int 值
 * @param NSMutableData 二进制缓冲区
 * @param int 读取位置
 * @returns int
 */
+(int) readUint16:(NSMutableData*) buffer offset:(int)offset;
/*
 * 读取4个字节的无符号 int 值
 * @param NSMutableData 二进制缓冲区
 * @param int 读取位置
 * @returns int
 */
+(int) readUint32:(NSMutableData*) buffer offset:(int)offset;
/*
 * 读取64个字节的无符号 int 值
 * @param NSMutableData 二进制缓冲区
 * @param int 读取位置
 * @returns long
 */
+(long) readUint64:(NSMutableData*) buffer offset:(int)offset;
/*
 * 读取4个字节的无符号 浮点数 值
 * @param NSMutableData 二进制缓冲区
 * @param int 读取位置
 * @returns float
 */
+(float) readUFloat:(NSMutableData*) buffer offset:(int)offset;
/*
 * 读取8个字节的无符号 浮点数 值
 * @param NSMutableData 二进制缓冲区
 * @param int 读取位置
 * @returns double
 */
+(double) readUDouble:(NSMutableData*) buffer offset:(int)offset;
/*
 * 截取指定区域的二进制数据
 * @param NSMutableData 二进制缓冲区
 * @param int 截取位置
 * @param int 截取长度
 * @returns NSMutableData
 */
+(NSMutableData*) slice:(NSMutableData*) buffer offset:(int)offset length:(long)length;

/*
 * 读取一个字符串
 * @param NSMutableData 二进制缓冲区
 * @param int 读取的位置
 * @param long 读取长度
 * @returns NSString
 */
+(NSString*) readString:(NSMutableData*) buffer offset:(int)offset length:(long)length;

/*
 * 写入一个字符串
 * @param NSMutableData 二进制缓冲区
 * @param NSString 写入的值
 * @param int 写入位置
 * @returns int 写入长度
 */
+(long) writeString:(NSMutableData*) buffer value:(NSString*)value offset:(int)offset;

/*
 * GZIP 压缩
 * @param NSMutableData 二进制缓冲区
 * @returns NSMutableData 压缩后的数据
 */
+(NSMutableData*) gzip:(NSMutableData*) buffer;
/*
 * GZIP 解压缩
 * @param NSMutableData 二进制缓冲区
 * @returns NSMutableData 解压缩后的数据
 */
+(NSMutableData*) gunzip:(NSMutableData*) buffer;

@end

NS_ASSUME_NONNULL_END
