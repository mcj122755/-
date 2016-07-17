//
//  MCJMCManager.m
//  近场通信
//
//  Created by MCJ on 16/7/16.
//  Copyright © 2016年 MCJ. All rights reserved.
//

#import "MCJMCManager.h"

// 遵守近场通信协议
@interface MCJMCManager ()<MCSessionDelegate>

@end

@implementation MCJMCManager

#pragma mark - 实现我们自定义的方法
- (void)setupPeerAndSessionWithDisplayName:(NSString *)displayName
{
    _peerID = [[MCPeerID alloc] initWithDisplayName:displayName];
    _session = [[MCSession alloc] initWithPeer:_peerID];
    _session.delegate = self;
}

-(void)setupMCBrowser{
    // ServiceType定义浏览器应该寻找的类型的服务, 也就是设备之间定义的类型，可以搜到相同类型的设置，随便设置
    _browserViewController = [[MCBrowserViewController alloc] initWithServiceType:@"chat-files"session:_session];
}

-(void)advertiseSelf:(BOOL)shouldAdvertise{
    if (shouldAdvertise) {
        //ServiceType 要和MCBrowserViewController的ServiceType一致
        _advertiserAssistant = [[MCAdvertiserAssistant alloc] initWithServiceType:@"chat-files" discoveryInfo:nil session:_session];
        //
        [_advertiserAssistant start];
    }
    else{
        [_advertiserAssistant stop];
        _advertiserAssistant = nil;
    }
}

#pragma mark - 近场通信代理方法
#pragma mark 状态改变的时候会调用（连接或断开）MCSessionStateConnected , MCSessionStateConnecting  and  MCSessionStateNotConnected。
-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{
    
    // 把数据通过通知中心传出去
    NSDictionary *dict = @{@"peerID": peerID,
                           @"state" : [NSNumber numberWithInt:state]
                           };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidChangeStateNotification" object:nil userInfo:dict];
}

/**
 *  接受的数据是消息的时候
 */
-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
    NSDictionary *dict = @{@"data": data,
                           @"peerID": peerID
                           };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidReceiveDataNotification" object:nil userInfo:dict];
}


/**
 *  接受的数据是资源的时候
 */
-(void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress{
    
}


-(void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error{
    
}

/**
 *  接受的数据是流的时候
 */
-(void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID{
    
}


#pragma mark - 获取单利
static MCJMCManager *_manager;
+ (MCJMCManager *)shareMCManager
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _manager = [[super allocWithZone:NULL] init] ;
    }) ;
    
    return _manager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [MCJMCManager shareMCManager];
}
@end
