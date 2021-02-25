# ssocketoc

[![CI Status](https://img.shields.io/travis/summer.li/ssocketoc.svg?style=flat)](https://travis-ci.org/summer.li/ssocketoc)
[![Version](https://img.shields.io/cocoapods/v/ssocketoc.svg?style=flat)](https://cocoapods.org/pods/ssocketoc)
[![License](https://img.shields.io/cocoapods/l/ssocketoc.svg?style=flat)](https://cocoapods.org/pods/ssocketoc)
[![Platform](https://img.shields.io/cocoapods/p/ssocketoc.svg?style=flat)](https://cocoapods.org/pods/ssocketoc) 

 > 仿 Koa 中间件控制的 WebSocket 服务对应的客户端程序，食用简单，上手容易, 支持 GZIP 解压缩和 ProtoBuffer 解压缩配置，觉得小弟写的还行的话，就给个[Star](https://github.com/mytwz/ssocket-oc)⭐️吧~

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

ssocketoc is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ssocketoc'
```

## Author

summer.li, asd995633088@qq.com

## License

ssocketoc is available under the MIT license. See the LICENSE file for more info.

## 使用方法
### [点击安装服务端程序](https://github.com/mytwz/ssocket)

```object-c
// ProtoBuf 解压缩配置
NSString* json = @"{\"test\":{\"required string username\":0,\"required float amount\":1,\"required double amount2\":2}}";

SWebSocket* socket = [[SWebSocket alloc] init:@"http://127.0.0.1:8080" options:@{@"protos_request_json":json, @"protos_response_json":json}];

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
    // 发送携带回调函数的请求
    [socket request:/*路由地址*/@"test" /*请求数据*/data:@{@"username":@"12312313"} callback:^(id data){
        // 收到请求回调
        ResPacket* res = data;
        NSLog(@"SWebSocket: 事件响应[%@]", [res yy_modelToJSONString]);
    }];
    // 发送没有回调函数的请求
    [socket request:@"test" data:@{@"username":@"测试", @"amount":@12.45631, @"amount2":@456.153156}];
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
// 绑定事件
[socket on:@"test" callback:^(id data){
    ResPacket* res = data;
    NSLog(@"SWebSocket: 收到服务端事件回应[%@]", [res yy_modelToJSONString]);
}];
// 打开连接
[socket connection];
// 关闭连接
[socket close];
```
