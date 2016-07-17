//
//  MCJMCManager.h
//  近场通信
//
//  Created by MCJ on 16/7/16.
//  Copyright © 2016年 MCJ. All rights reserved.
//

#import <Foundation/Foundation.h>
// 添加近场通信框架
@import MultipeerConnectivity;


@interface MCJMCManager : NSObject
/**
 *  表示设备
 */
@property (nonatomic, strong) MCPeerID *peerID;
/**
 *  近场通信的组织者
 */
@property (nonatomic, strong) MCSession *session;
/**
 *  系统提供的显示附近设备的UI
 */
@property (nonatomic, strong) MCBrowserViewController *browserViewController;
/**
 *  广告对象，让别的设备易于发现自己
 */
@property (nonatomic, strong) MCAdvertiserAssistant *advertiserAssistant;

/**
 *  获取一个近场通信单利
 *
 *  @return 一个近场通信单利
 */
+(MCJMCManager *)shareMCManager;

/**
 *  获取通信的组织者
 *
 *  @param displayName 当前设备的名字
 */
-(void)setupPeerAndSessionWithDisplayName:(NSString *)displayName;
/**
 *  设置显示附近设备的UI
 */
-(void)setupMCBrowser;

/**
 *  设置是否可以被发现
 *
 *  @param shouldAdvertise 是否被发现的bool
 */
-(void)advertiseSelf:(BOOL)shouldAdvertise;
@end
