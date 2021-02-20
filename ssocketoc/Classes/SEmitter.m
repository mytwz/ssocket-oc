//
//  SEmitter.m
//  ssocketoc
//
//  Created by summer on 2021/2/20.
//

#import "SEmitter.h"

@implementation SEmitter

-init{
    self = [super init];
    _callbacks = [NSMutableDictionary new];
    return self;
}
-on:(NSString*)event callback:(event_callback)callback{
    if(![_callbacks objectForKey:event]) [_callbacks setObject:[NSMutableArray new] forKey:event];
    NSMutableArray* list = [_callbacks objectForKey:event];
    [list addObject:callback];
    return self;
}
-once:(NSString*)event callback:(event_callback)callback{
    __block event_callback call_tmp = ^(id data){
        @autoreleasepool {
            [self off:event callback:call_tmp];
            callback(data);
            call_tmp = nil;
        }
    };
    [self on:event callback:call_tmp];
    return self;
}
-off:(NSString*)event callback:(event_callback)callback{
    if([_callbacks objectForKey:event]){
        NSMutableArray* list = [_callbacks objectForKey:event];
        if([list containsObject:callback]){
            [list removeObject:callback];
        }
    }
    return self;
}
-off:(NSString*)event{
    if([_callbacks objectForKey:event]){
        [_callbacks removeObjectForKey:event];
    }
    return self;
}
-offAll{
    _callbacks = [NSMutableDictionary new];
    return self;
}
-emit:(NSString*)event data:(id)data{
    @autoreleasepool {
        if([_callbacks objectForKey:event]){
            NSMutableArray*  list = [[_callbacks objectForKey:event] mutableCopy];
            for(event_callback call_tmp in list){
                call_tmp(data);
            }
        }
        return self;
    }
}

-(int)listeners:(NSString*) event{
    @autoreleasepool {
        if([_callbacks objectForKey:event]){
            NSMutableArray*  list = [[_callbacks objectForKey:event] mutableCopy];
            return (int)[list count];
        }
        return 0;
    }
}
@end
