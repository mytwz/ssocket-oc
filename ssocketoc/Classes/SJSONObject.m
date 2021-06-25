//
//  SJSONObject.m
//  ssocketoc
//
//  Created by summer on 2021/2/20.
//

#import "SJSONObject.h"

@implementation SJSONObject

+(NSMutableDictionary*) parseDictionary:(NSString*) json {
    NSError *err;
    return [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
}

+(NSString*) toJSONString:(NSMutableDictionary*) dict {
    return [dict modelToJSONString];
}

+(instancetype) parseObject:(NSString*) json {
    return [self modelWithJSON:json];
}

-(NSString*) toJSONString {
    return [self modelToJSONString];
}

-(NSMutableDictionary*) toJSONDict {
    return [SJSONObject parseDictionary:[ self toJSONString ]];
}

-(NSMutableData*) toJSONData {
    return [[NSMutableData alloc] initWithData:[[self toJSONString] dataUsingEncoding:NSUTF8StringEncoding] ];
}

@end
