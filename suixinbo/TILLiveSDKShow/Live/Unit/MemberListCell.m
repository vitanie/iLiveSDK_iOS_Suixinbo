//
//  MemberListCell.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/11/9.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "MemberListCell.h"

@implementation MemberListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self addSubViews];
        [self layout];
    }
    return self;
}

- (void)addSubViews
{
    _identifier = [[UILabel alloc] init];
    _identifier.textAlignment = NSTextAlignmentLeft;
    _identifier.layer.cornerRadius = 5.0;
    _identifier.layer.borderColor = kColorPurple.CGColor;
    _identifier.layer.borderWidth = 0.5;
    _identifier.textColor = kColorWhite;
    _identifier.textAlignment = NSTextAlignmentCenter;
    _identifier.backgroundColor = kColorBlue;
    [self.contentView addSubview:_identifier];
    
    _connectBtn = [[UIButton alloc] init];
    _connectBtn.layer.cornerRadius = 5.0;
    _connectBtn.layer.borderColor = kColorPurple.CGColor;
    _connectBtn.layer.borderWidth = 0.5;
    [_connectBtn setTitle:@"连麦" forState:UIControlStateNormal];
    [_connectBtn setTitleColor:kColorBlack forState:UIControlStateNormal];
    [_connectBtn addTarget:self action:@selector(onConnect:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_connectBtn];
}

- (void)layout
{
    CGRect selfRect = self.bounds;
    CGFloat selfW = selfRect.size.width;
    
    [_identifier sizeWith:CGSizeMake(selfW * 2/5, 30)];
    [_identifier alignParentTopWithMargin:kDefaultMargin];
    [_identifier alignParentLeftWithMargin:kDefaultMargin];
    
    [_connectBtn sizeWith:CGSizeMake(selfW / 5, 30)];
    [_connectBtn alignParentTopWithMargin:kDefaultMargin];
    [_connectBtn alignParentRight];
}

- (void)configId:(MemberListItem *)item
{
    _item = item;
    _identifier.text = item.identifier;
    if (item.isUpVideo)
    {
        [_connectBtn setTitle:@"下麦" forState:UIControlStateNormal];
        [_connectBtn setTitleColor:kColorWhite forState:UIControlStateNormal];
        [_connectBtn setBackgroundColor:kColorRed];
        _connectBtn.layer.borderColor = kColorGray.CGColor;
    }
    else
    {
        [_connectBtn setTitle:@"连麦" forState:UIControlStateNormal];
        [_connectBtn setTitleColor:kColorWhite forState:UIControlStateNormal];
        [_connectBtn setBackgroundColor:kColorGreen];
    }
}

- (void)onConnect:(UIButton *)button
{
    if (_item.isUpVideo)
    {
        [self downVideo];
        return;
    }
    if ([UserViewManager shareInstance].total >= kMaxUserViewCount)
    {
        NSString *message = [NSString stringWithFormat:@"连麦画面不能超过%d路,可以先取消一路连麦",kMaxUserViewCount+1];
        [AlertHelp alertWith:@"提示" message:message cancelBtn:@"好吧" alertStyle:UIAlertControllerStyleAlert cancelAction:nil];
        return;
    }
    ILVLiveCustomMessage *video = [[ILVLiveCustomMessage alloc] init];
    video.recvId = _identifier.text;
    video.data = [_identifier.text dataUsingEncoding:NSUTF8StringEncoding];
    video.type = ILVLIVE_IMTYPE_C2C;
    video.cmd = (ILVLiveIMCmd)AVIMCMD_Multi_Host_Invite;
    [[TILLiveManager getInstance] sendCustomMessage:video succ:^{
        NSLog(@"send succ");
    } failed:^(NSString *module, int errId, NSString *errMsg) {
        NSLog(@"login fail. module=%@,errid=%d,errmsg=%@",module,errId,errMsg);
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:kClickConnect_Notification object:_identifier.text];
}

- (void)downVideo
{
    ILVLiveCustomMessage *video = [[ILVLiveCustomMessage alloc] init];
    video.recvId = _identifier.text;
    video.data = [_identifier.text dataUsingEncoding:NSUTF8StringEncoding];
    video.type = ILVLIVE_IMTYPE_GROUP;
    video.cmd = (ILVLiveIMCmd)AVIMCMD_Multi_CancelInteract;
    [[TILLiveManager getInstance] sendCustomMessage:video succ:^{
        NSLog(@"send succ");
    } failed:^(NSString *module, int errId, NSString *errMsg) {
        NSLog(@"login fail. module=%@,errid=%d,errmsg=%@",module,errId,errMsg);
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:kClickDownVideo_Notification object:_identifier.text];
}

@end
