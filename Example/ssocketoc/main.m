//
//  main.m
//  ssocketoc
//
//  Created by summer.li on 02/20/2021.
//  Copyright (c) 2021 summer.li. All rights reserved.
//

@import UIKit;
#import "SSOCKETOCAppDelegate.h"
#import "ssocketoc/SWebSocket.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
        
        NSString* json = @"{\"test\":{\"required string username\":0,\"required float amount\":1,\"required double amount2\":2}}";

        
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([SSOCKETOCAppDelegate class]));
    }
}
