//
//  SEmitter.h
//  ssocketoc
//
//  Created by summer on 2021/2/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^event_callback)(id data);

@interface SEmitter : NSObject {
@private NSMutableDictionary* _callbacks;
}

-on:(NSString*)event callback:(event_callback)callback;
-once:(NSString*)event callback:(event_callback)callback;
-off:(NSString*)event callback:(event_callback)callback;
-off:(NSString*)event;
-offAll;
-emit:(NSString*)event data:(id)data;

-(int)listeners:(NSString*) event;
-(int)listeners;

@end

NS_ASSUME_NONNULL_END
