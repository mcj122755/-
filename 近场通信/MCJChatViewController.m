//
//  MCJChatViewController.m
//  近场通信
//
//  Created by MCJ on 16/7/16.
//  Copyright © 2016年 MCJ. All rights reserved.
//

#import "MCJChatViewController.h"
#import "MCJMCManager.h"

@interface MCJChatViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic)MCJMCManager *manager;
@end

@implementation MCJChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _manager = [MCJMCManager shareMCManager];
    
    // 注册一个通知 用来接收近场通信的数据
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveDataWithNotification:) name:@"MCDidReceiveDataNotification" object:nil];
}
- (IBAction)cancleButton:(id)sender {
    [_textField resignFirstResponder];
}
- (IBAction)sendButton:(id)sender {
    [self sendMyMessage];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self sendMyMessage];
    return YES;
}

#pragma mark - 发送数据
-(void)sendMyMessage{
    NSData *dataToSend = [_textField.text dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *allPeers = _manager.session.connectedPeers;
    NSError *error;
    
    [_manager.session sendData:dataToSend toPeers:allPeers withMode:MCSessionSendDataReliable error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    [_textView setText:[_textView.text stringByAppendingString:[NSString stringWithFormat:@"I wrote:\n%@\n\n", _textField.text]]];
    [_textField setText:@""];
    [_textField resignFirstResponder];
}

// 接收消息显示消息
-(void)didReceiveDataWithNotification:(NSNotification *)notification{
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    
    NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
    NSString *receivedText = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    
    [_textView performSelectorOnMainThread:@selector(setText:) withObject:[_textView.text stringByAppendingString:[NSString stringWithFormat:@"%@ wrote:\n%@\n\n", peerDisplayName, receivedText]] waitUntilDone:NO];
}
@end
