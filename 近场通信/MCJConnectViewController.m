//
//  MCJConnectViewController.m
//  近场通信
//
//  Created by MCJ on 16/7/16.
//  Copyright © 2016年 MCJ. All rights reserved.
//

#import "MCJConnectViewController.h"
#import "MCJMCManager.h"
@import MultipeerConnectivity;

@interface MCJConnectViewController ()<MCBrowserViewControllerDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>
// 设置设备名称
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UISwitch *switchUI;

// 显示设备
@property (weak, nonatomic) IBOutlet UITableView *showTableView;
// 数据源
@property (nonatomic, strong) NSMutableArray *arrConnectedDevices;

// 近场通信的session
@property (strong, nonatomic)MCJMCManager *mcManager;


@end

@implementation MCJConnectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 实例换数据源
    _arrConnectedDevices = [NSMutableArray array];
    
    // 近场通信设置
    _mcManager = [MCJMCManager shareMCManager];
    [_mcManager setupPeerAndSessionWithDisplayName:[UIDevice currentDevice].name];
    [_mcManager advertiseSelf:_switchUI.on];
    
    // 设置名称
    _name.delegate = self;
    
    
    // 添加通知中心，监听近场通信的状态的改变
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(peerDidChangeStateWithNotification:) name:@"MCDidChangeStateNotification" object:nil];
}


#pragma mark - 界面按钮点击事件
// 是否显示
- (IBAction)switchUI:(id)sender {
     [_mcManager advertiseSelf:_switchUI.isOn];
}

// 刷新设备显示
- (IBAction)browDevices:(id)sender {
    [_mcManager setupMCBrowser];
    [_mcManager.browserViewController setDelegate:self];
    // 推出设备显示界面
    [self presentViewController:_mcManager.browserViewController animated:YES completion:nil];
}

// 断开连接
- (IBAction)offConnect:(id)sender {
    [_mcManager.session disconnect];
    _name.enabled = YES;
    [_arrConnectedDevices removeAllObjects];
    [_showTableView reloadData];
}


#pragma mark - MCBrowserViewControllerDelegate代理方法
-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController{
    [_mcManager.browserViewController dismissViewControllerAnimated:YES completion:nil];
}
-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController{
    [_mcManager.browserViewController dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark -UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [_name resignFirstResponder];
    
    _mcManager.peerID = nil;
    _mcManager.session = nil;
    _mcManager.browserViewController = nil;
    
    if (_switchUI.isOn) {
        // 停止可见
        [_mcManager.advertiserAssistant stop];
    }
    _mcManager.advertiserAssistant = nil;
    
    [_mcManager setupPeerAndSessionWithDisplayName:_name.text];
    [_mcManager setupMCBrowser];
    [_mcManager advertiseSelf:_switchUI.isOn];
    
    return YES;
}


#pragma mark 获取通知中心的事件
-(void)peerDidChangeStateWithNotification:(NSNotification *)notification{
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    MCSessionState state = [[[notification userInfo] objectForKey:@"state"] intValue];
    
    if (state != MCSessionStateConnecting) {
        if (state == MCSessionStateConnected) { // 已经连接
            [_arrConnectedDevices addObject:peerDisplayName];
        }
        else if (state == MCSessionStateNotConnected){ // 没有连接 ， 查找是否存在，如果存在移除
            if ([_arrConnectedDevices count] > 0) {
                NSInteger indexOfPeer = [_arrConnectedDevices indexOfObject:peerDisplayName];
                [_arrConnectedDevices removeObjectAtIndex:indexOfPeer];
            }
        }
        
        
        // 刷新数据
        [_showTableView reloadData];
    }
}

#pragma mark - tableView代理方法
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_arrConnectedDevices count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
    }
    
    cell.textLabel.text = [_arrConnectedDevices objectAtIndex:indexPath.row];
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}
@end
