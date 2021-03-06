//
//  STPictureCollectionReusableView.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/19.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHFetchResult;
@class STFileSelectionTabViewController;
@class STPictureCollectionHeaderInfo;

@interface STPictureCollectionReusableView : UICollectionReusableView

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, weak) STFileSelectionTabViewController *tabViewController;
@property (nonatomic, strong) STPictureCollectionHeaderInfo *model;
@property (nonatomic, strong) UIButton *expandButton;

- (void)reloadData;

@end
