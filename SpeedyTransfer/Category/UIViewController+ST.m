//
//  UIViewController+ST.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/17.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "UIViewController+ST.h"

@implementation UIViewController (ST)

- (STFileSelectionTabViewController *)fileSelectionTabController {
    if ([self.tabBarController isKindOfClass:[STFileSelectionTabViewController class]]) {
        return (STFileSelectionTabViewController *)self.tabBarController;
    }
    
    return nil;
}

@end
