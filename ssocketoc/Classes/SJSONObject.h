//
//  SJSONObject.h
//  ssocketoc
//
//  Created by summer on 2021/2/20.
//

#import <Foundation/Foundation.h>
#import <YYModel/YYModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface SJSONObject : NSObject

+(NSMutableDictionary*) parseDictionary:(NSString*) json;
+(NSString*) toJSONString:(NSMutableDictionary*) dict;
+(instancetype) parseObject:(NSString*) json;

-(NSString*) toJSONString;
-(NSMutableDictionary*) toJSONDict;
-(NSMutableData*) toJSONData;

@end

NS_ASSUME_NONNULL_END
