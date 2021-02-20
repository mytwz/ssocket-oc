//
//  SProtoBuf.h
//  ssocketoc
//
//  Created by summer on 2021/2/20.
//

#import <Foundation/Foundation.h>
#import "SByteUtils.h"
#import "SJSONObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface SProtoBuf : NSObject

{
@private NSMutableDictionary* protosConfig;
}

- parse:(NSString* )protos_config;
-(NSMutableData*)encode:(NSString*) proto_name data:(NSDictionary*)data;
-(NSMutableDictionary*)decode:(NSString*) proto_name buffer:(NSMutableData*)buffer ;

@end

NS_ASSUME_NONNULL_END
