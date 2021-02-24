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

        
        SWebSocket* socket = [[SWebSocket alloc] init:@"http://10.9.16.34:8080" options:@{@"protos_request_json":json, @"protos_response_json":json}];
        
        [socket on:@"open" callback:^(id data){
            NSLog(@"SWebSocket: 连接打开[%@]", data);
        }];
        [socket on:@"close" callback:^(id data){
            NSLog(@"SWebSocket: 连接关闭[%@]", data);
        }];
        [socket on:@"error" callback:^(id data){
            NSLog(@"SWebSocket: 连接异常关闭[%@]", data);
        }];
        [socket on:@"shakehands" callback:^(id data){
            NSLog(@"SWebSocket: 握手[%@]", data);
        }];
        [socket on:@"connection" callback:^(id data){
            NSLog(@"SWebSocket: 握手完成[%@]", data);
//            [socket request:@"test" data:@{@"username":@"12312313"} callback:^(id data){
//                ResPacket* res = data;
//                NSLog(@"SWebSocket: 事件响应[%@]", [res yy_modelToJSONString]);
//            }];
            [socket request:@"test" data:@{/*@"username":@"测试", */@"amount":@12.45631, @"amount2":@456.153156}];
        }];
        [socket on:@"reconnection" callback:^(id data){
            NSLog(@"SWebSocket: 重连完成[%@]", data);
        }];
        [socket on:@"pong" callback:^(id data){
            NSLog(@"SWebSocket: 收到服务器【pong】回应[%@]", data);
        }];
        [socket on:@"ping" callback:^(id data){
            NSLog(@"SWebSocket: 向服务器发起【ping】请求[%@]", data);
        }];
        [socket on:@"reconnectioning" callback:^(id data){
            NSLog(@"SWebSocket: 正在重新连接[%@]", data);
        }];

        [socket on:@"test" callback:^(id data){
            ResPacket* res = data;
            NSLog(@"SWebSocket: 收到服务端事件回应[%@]", [res modelToJSONString]);
        }];

        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([SSOCKETOCAppDelegate class]));
    }
}
