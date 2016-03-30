//
//  STWebServerModel.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 16/1/17.
//  Copyright © 2016年 ZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTSingleton.h"

@interface STWebServerModel : NSObject

HT_AS_SINGLETON(STWebServerModel, shareInstant);

- (void)startWebServer;
- (void)stopWebServer;

// 无界传输
@property (nonatomic, strong) NSDictionary *variables;
- (void)startWebServer2;
- (void)stopWebServer2;

@end
