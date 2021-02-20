#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "SByteUtils.h"
#import "SCode.h"
#import "SEmitter.h"
#import "SJSONObject.h"
#import "SProtoBuf.h"
#import "SWebSocket.h"

FOUNDATION_EXPORT double ssocketocVersionNumber;
FOUNDATION_EXPORT const unsigned char ssocketocVersionString[];

