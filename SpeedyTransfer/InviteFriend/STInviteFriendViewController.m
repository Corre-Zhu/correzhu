//
//  STInviteFriendViewController.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 16/1/3.
//  Copyright © 2016年 ZZ. All rights reserved.
//

#import "STInviteFriendViewController.h"

@interface STInviteFriendViewController ()
{
    UILabel *label;
    UISwitch *switchCon;
    UIImageView *imageView;
}

@end

@implementation STInviteFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"邀请好友安装", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"left_white"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemClick)];
    
    CGFloat width = 249.0f;
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(IPHONE_WIDTH / 2.0f, 22.0f, 1.0f, (IPHONE_HEIGHT_WITHOUTTOPBAR - width - 60.0f) / 2.0f)];
    line1.backgroundColor = RGBFromHex(0xc8c7cc);
    [self.view addSubview:line1];
    
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake((IPHONE_WIDTH - 183.0f) / 2.0f, line1.bottom + 41.0f, 183.0f, 183.0f)];
    view2.backgroundColor = [UIColor whiteColor];
    view2.layer.borderColor = RGBFromHex(0x646464).CGColor;
    view2.layer.borderWidth = 1.0f;
    view2.layer.cornerRadius = 10.0f;
    view2.transform = CGAffineTransformMakeRotation(M_PI_4);
    [self.view addSubview:view2];
    
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(IPHONE_WIDTH / 2.0f, view2.bottom + 8.0f, 1.0f, (IPHONE_HEIGHT_WITHOUTTOPBAR - width - 60.0f) / 2.0f)];
    line2.backgroundColor = RGBFromHex(0xc8c7cc);
    [self.view addSubview:line2];
    
    UIView *line3 = [[UIView alloc] initWithFrame:CGRectMake(0.0f, view2.centerY, (IPHONE_WIDTH - width - 16.0f) / 2.0f, 1.0f)];
    line3.backgroundColor = RGBFromHex(0xc8c7cc);
    [self.view addSubview:line3];

    UIView *line4 = [[UIView alloc] initWithFrame:CGRectMake(IPHONE_WIDTH - line3.width, view2.centerY, line3.width, 1.0f)];
    line4.backgroundColor = RGBFromHex(0xc8c7cc);
    [self.view addSubview:line4];

    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, view2.top - 14.0f, IPHONE_WIDTH / 2.0f, 18.0f)];
    label1.text = NSLocalizedString(@"邮件", nil);
    label1.textColor = RGBFromHex(0x323232);
    label1.font = [UIFont systemFontOfSize:14.0f];
    label1.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label1];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button1 setImage:[UIImage imageNamed:@"mail"] forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(emailButtonClick) forControlEvents:UIControlEventTouchUpInside];
    button1.frame = CGRectMake((IPHONE_WIDTH / 2.0f - 72.0f) / 2.0f, label1.top - 81.0f, 72.0f, 72.0f);
    [self.view addSubview:button1];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(IPHONE_WIDTH / 2.0f, view2.top - 14.0f, IPHONE_WIDTH / 2.0f, 18.0f)];
    label2.text = NSLocalizedString(@"微博", nil);
    label2.textColor = RGBFromHex(0x323232);
    label2.font = [UIFont systemFontOfSize:14.0f];
    label2.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label2];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button2 setImage:[UIImage imageNamed:@"weibo"] forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(weiboButtonClick) forControlEvents:UIControlEventTouchUpInside];
    button2.frame = CGRectMake(IPHONE_WIDTH / 2.0f + (IPHONE_WIDTH / 2.0f - 72.0f) / 2.0f, label1.top - 81.0f, 72.0f, 72.0f);
    [self.view addSubview:button2];
    
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button3 setImage:[UIImage imageNamed:@"weixin"] forState:UIControlStateNormal];
    [button3 addTarget:self action:@selector(weixinButtonClick) forControlEvents:UIControlEventTouchUpInside];
    button3.frame = CGRectMake((IPHONE_WIDTH / 2.0f - 72.0f) / 2.0f, view2.bottom, 72.0f, 72.0f);
    [self.view addSubview:button3];
    
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, button3.bottom + 9.0f, IPHONE_WIDTH / 2.0f, 18.0f)];
    label3.text = NSLocalizedString(@"微信", nil);
    label3.textColor = RGBFromHex(0x323232);
    label3.font = [UIFont systemFontOfSize:14.0f];
    label3.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label3];
    
    UIButton *button4 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button4 setImage:[UIImage imageNamed:@"qq"] forState:UIControlStateNormal];
    [button4 addTarget:self action:@selector(qqButtonClick) forControlEvents:UIControlEventTouchUpInside];
    button4.frame = CGRectMake(IPHONE_WIDTH / 2.0f + (IPHONE_WIDTH / 2.0f - 72.0f) / 2.0f, view2.bottom, 72.0f, 72.0f);
    [self.view addSubview:button4];
    
    UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(IPHONE_WIDTH / 2.0f, button4.bottom + 9.0f, IPHONE_WIDTH / 2.0f, 18.0f)];
    label4.text = NSLocalizedString(@"腾讯QQ", nil);
    label4.textColor = RGBFromHex(0x323232);
    label4.font = [UIFont systemFontOfSize:14.0f];
    label4.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label4];

    
    
}

- (void)leftBarButtonItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)emailButtonClick {
    
}

- (void)weiboButtonClick {
    
}

- (void)weixinButtonClick {
    
}

- (void)qqButtonClick {
    
}

@end