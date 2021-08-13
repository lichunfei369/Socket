//
//  ViewController.m
//  SwiftSignalRC
//
//  Created by Apple on 2021/6/30.
//

#import "ViewController.h"
#import "SwiftSignalRC-Swift.h"
#import "SwiftSignalRC-Bridging-Header.h"
@interface ViewController (){
    SignalRSwift * socket;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //打开socket
    socket = [[SignalRSwift alloc]init];
    //设置请求头和URL
    NSString * URL =@"http://localhost/signalr";
    NSDictionary *headers = @{@"token" : @"xxxxxxx"};
    NSString *name =@"test";
    __weak __typeof(&*self)weakSelf = self;
    [socket signalROpenWithUrl:URL headers:headers hubName:name blockfunc:^(NSString * _Nonnull message) {
        [weakSelf receivePushMessage:message];
    }];
    
    //关闭
    [socket signalRClose];
    
}
- (void)receivePushMessage:(NSString *)pushMessage {
    NSLog(@"接收On方法");
    //发送方法
//    [socket sendMessageWithMessage:@"xx"];
    [socket sendMessageWithMessage:<#(NSString * _Nonnull)#> arguments:@[] resultBlock:<#^(NSDictionary<NSString *,id> * _Nonnull)resultBlock#> resultErrorBlock:<#^(NSError * _Nonnull)resultErrorBlock#>]
}

-(void)clientDidClosedWithClient:(SignalRSwift *)client error:(NSError *)error{
    
}
@end
