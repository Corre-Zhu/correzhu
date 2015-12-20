//
//  STFileSelectionTabViewController.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/13.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "STFileSelectionTabViewController.h"
#import <Photos/Photos.h>
#import "STMusicInfoModel.h"
#import "STFileSelectionPopupView.h"

@interface STFileSelectionTabViewController ()
{
    UIImageView *toolView;
    UIButton *deleteButton;
    UIButton *transferButton;
    STFileSelectionPopupView *popupView;
}

@end

@implementation STFileSelectionTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"left_white"] style:UIBarButtonItemStylePlain target:self action:@selector(backBarButtonItemClick)];
    self.navigationItem.title = NSLocalizedString(@"选择文件", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    
    toolView = [[UIImageView alloc] initWithFrame:CGRectMake((IPHONE_WIDTH - 175.0f) / 2.0f, IPHONE_HEIGHT_WITHOUTTOPBAR - 92.0f, 175.0f, 40.0f)];
    toolView.image = [[UIImage imageNamed:@"xuanze_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(7.0f, 7.0f, 7.0f, 7.0f)];
    toolView.userInteractionEnabled = YES;
    [self.view addSubview:toolView];
    toolView.hidden = YES;
    
    deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteButton.frame = CGRectMake(9.0f, 2.0f, 35.0f, 35.0f);
    [deleteButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(deleteButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [toolView addSubview:deleteButton];
    
    UIImageView *lineView = [[UIImageView alloc] initWithFrame:CGRectMake(53.0f, 12.0f, 0.5f, 17.0f)];
    lineView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5f];
    [toolView addSubview:lineView];
    
    transferButton = [UIButton buttonWithType:UIButtonTypeCustom];
    transferButton.frame = CGRectMake(73.0f, 3.0f, 82.0f, 34.0f);
    [transferButton setTitle:NSLocalizedString(@"全部传输", nil) forState:UIControlStateNormal];
    [transferButton addTarget:self action:@selector(deleteButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [transferButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    transferButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [toolView addSubview:transferButton];
}

- (void)configToolView {
    NSInteger count = [self selectedFilesCount];
    if (count > 0) {
        [transferButton setTitle:[NSString stringWithFormat:@"%@ (%@)", NSLocalizedString(@"全部传输", nil), @(count)] forState:UIControlStateNormal];
        toolView.hidden = NO;
    } else {
        [transferButton setTitle:NSLocalizedString(@"全部传输", nil) forState:UIControlStateNormal];
        toolView.hidden = YES;
    }
    
    [transferButton sizeToFit];
    CGFloat width = MAX(82.0f, transferButton.width);
    toolView.width = 93.0f + width;
    toolView.left = (IPHONE_WIDTH - toolView.width) / 2.0f;
    transferButton.width = width;
}

- (void)backBarButtonItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)deleteButtonClick {
    if (!popupView) {
        popupView = [[STFileSelectionPopupView alloc] init];
    }
    popupView.dataSource = self.selectedFilesArray;
    [popupView showInView:self.navigationController.view];
}

- (void)removeAllSelectedFiles {
    _selectedFilesArray = nil;
    [self configToolView];
}

// 选中的总文件个数
- (NSInteger)selectedFilesCount {
    NSUInteger count = 0;
    for (NSArray *arr in self.selectedAssetsDic.allValues) {
        count += arr.count;
    }
    
    count += _selectedMusicsArr.count;
    
    count += _selectedVideoAssetsArr.count;
    
    count += _selectedContactsArr.count;

    return count;
}

- (NSArray *)selectedFilesArray {
    NSMutableArray *array = [NSMutableArray array];
    [array addObjectsFromArray:[self selectedAssetsArr]];
    [array addObjectsFromArray:self.selectedMusicsArr];
    [array addObjectsFromArray:self.selectedVideoAssetsArr];
    [array addObjectsFromArray:self.selectedContactsArr];
    
    return [NSArray arrayWithArray:array];
}

- (NSArray *)selectedAssetsArr {
    NSMutableArray *mutableArr = [NSMutableArray array];
    for (NSArray *arr in self.selectedAssetsDic.allValues) {
        [mutableArr addObjectsFromArray:arr];
    }
    
    return [NSArray arrayWithArray:mutableArr];
}

- (void)addAsset:(PHAsset *)asset inFetchResults:(PHFetchResult *)fetchResults {
    if (!asset || !fetchResults) {
        return;
    }
    
    if (!_selectedAssetsDic) {
        _selectedAssetsDic = [NSDictionary dictionary];
    }
    
    @autoreleasepool {
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithDictionary:_selectedAssetsDic];
        NSArray *tempArray = [tempDic objectForKey:fetchResults];
        if (tempArray) {
            if (![tempArray containsObject:asset]) {
                [tempDic setObject:[tempArray arrayByAddingObject:asset] forKey:fetchResults];
            }
        } else {
            [tempDic setObject:[NSArray arrayWithObject:asset] forKey:fetchResults];
        }
        _selectedAssetsDic = [NSDictionary dictionaryWithDictionary:tempDic];
    }
    
    [self configToolView];
}

- (void)removeAsset:(PHAsset *)asset inFetchResults:(PHFetchResult *)fetchResults {
    if (!asset || !fetchResults) {
        return;
    }
    
    if (_selectedAssetsDic) {
        @autoreleasepool {
            NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithDictionary:_selectedAssetsDic];
            NSArray *tempArray = [tempDic objectForKey:fetchResults];
            if (tempArray) {
                NSMutableArray *tempMutableArray = [NSMutableArray arrayWithArray:tempArray];
                [tempMutableArray removeObject:asset];
                [tempDic setObject:[NSArray arrayWithArray:tempMutableArray] forKey:fetchResults];
                _selectedAssetsDic = [NSDictionary dictionaryWithDictionary:tempDic];
            }
        }
    }
    
    [self configToolView];
}

- (BOOL)isSelectedWithAsset:(PHAsset *)asset inFetchResults:(PHFetchResult *)fetchResults {
    if (!asset || !fetchResults) {
        return NO;
    }
    
    NSArray *arr = [_selectedAssetsDic objectForKey:fetchResults];
    return [arr containsObject:asset];
}

- (void)addMusic:(STMusicInfoModel *)music {
    if (!music) {
        return;
    }
    
    @autoreleasepool {
        if (!_selectedMusicsArr) {
            _selectedMusicsArr = [NSArray arrayWithObject:music];
        } else {
            if (![_selectedMusicsArr containsObject:music]) {
                _selectedMusicsArr = [_selectedMusicsArr arrayByAddingObject:music];
            }
        }
    }
    
    [self configToolView];
}

- (void)addMusics:(NSArray *)musics {
    if (!musics) {
        return;
    }
    
    @autoreleasepool {
        if (!_selectedMusicsArr) {
            _selectedMusicsArr = [NSArray arrayWithArray:musics];
        } else {
            _selectedMusicsArr = [_selectedMusicsArr arrayByAddingObjectsFromArray:musics];
        }
    }
    
    [self configToolView];
}

- (void)removeMusic:(STMusicInfoModel *)music {
    if (!music) {
        return;
    }
    
    @autoreleasepool {
        if ([_selectedMusicsArr containsObject:music]) {
            NSMutableArray *tempArr = [NSMutableArray arrayWithArray:_selectedMusicsArr];
            [tempArr removeObject:music];
            _selectedMusicsArr = [NSArray arrayWithArray:tempArr];
        }
    }
    
    [self configToolView];
}

- (void)removeMusics:(NSArray *)musics {
    if (!musics) {
        return;
    }
    
    @autoreleasepool {
        NSMutableArray *tempArr = [NSMutableArray arrayWithArray:_selectedMusicsArr];
        [tempArr removeObjectsInArray:musics];
        _selectedMusicsArr = [NSArray arrayWithArray:tempArr];
    }
    
    [self configToolView];
}

- (BOOL)isSelectedWithMusic:(STMusicInfoModel *)music {
    return [_selectedMusicsArr containsObject:music];
}

- (BOOL)isSelectedWithMusics:(NSArray *)musics {
    for (STMusicInfoModel *model in musics) {
        if (![_selectedMusicsArr containsObject:model]) {
            return NO;
        }
    }
    
    return YES;
}

- (void)addVideoAsset:(PHAsset *)asset {
    if (!asset) {
        return;
    }
    
    @autoreleasepool {
        if (!_selectedVideoAssetsArr) {
            _selectedVideoAssetsArr = [NSArray arrayWithObject:asset];
        } else {
            NSMutableArray *tempArr = [NSMutableArray arrayWithArray:_selectedVideoAssetsArr];
            if (![tempArr containsObject:asset]) {
                [tempArr addObject:asset];
                _selectedVideoAssetsArr = [NSArray arrayWithArray:tempArr];
            }
        }
       
    }
    
    [self configToolView];
}

- (void)removeVideoAsset:(PHAsset *)asset {
    if (!asset) {
        return;
    }
    
    @autoreleasepool {
        if (_selectedVideoAssetsArr) {
            NSMutableArray *tempArr = [NSMutableArray arrayWithArray:_selectedVideoAssetsArr];
            if ([tempArr containsObject:asset]) {
                [tempArr removeObject:asset];
                _selectedVideoAssetsArr = [NSArray arrayWithArray:tempArr];
            }
        }
        
    }
    
    [self configToolView];
}

- (BOOL)isSelectedWithVideoAsset:(PHAsset *)asset {
    return [_selectedVideoAssetsArr containsObject:asset];
}

- (void)addContact:(STContactModel *)contact {
    if (!contact) {
        return;
    }
    
    @autoreleasepool {
        if (!_selectedContactsArr) {
            _selectedContactsArr = [NSArray arrayWithObject:contact];
        } else {
            if (![_selectedContactsArr containsObject:contact]) {
                _selectedContactsArr = [_selectedContactsArr arrayByAddingObject:contact];
            }
        }
    }
    
    [self configToolView];
}

- (void)addContacts:(NSArray *)contacts {
    if (!contacts) {
        return;
    }
    
    @autoreleasepool {
        if (!_selectedContactsArr) {
            _selectedContactsArr = [NSArray arrayWithArray:contacts];
        } else {
            _selectedContactsArr = [_selectedContactsArr arrayByAddingObjectsFromArray:contacts];
        }
    }
    
    [self configToolView];
}

- (void)removeContact:(STContactModel *)contact {
    if (!contact) {
        return;
    }
    
    @autoreleasepool {
        if ([_selectedContactsArr containsObject:contact]) {
            NSMutableArray *tempArr = [NSMutableArray arrayWithArray:_selectedContactsArr];
            [tempArr removeObject:contact];
            _selectedContactsArr = [NSArray arrayWithArray:tempArr];
        }
    }
    
    [self configToolView];
}

- (void)removeContacts:(NSArray *)contacts {
    if (!contacts) {
        return;
    }
    
    @autoreleasepool {
        NSMutableArray *tempArr = [NSMutableArray arrayWithArray:_selectedContactsArr];
        [tempArr removeObjectsInArray:contacts];
        _selectedContactsArr = [NSArray arrayWithArray:tempArr];
    }
    
    [self configToolView];
}

- (BOOL)isSelectedWithContact:(STContactModel *)contact {
    return [_selectedContactsArr containsObject:contact];
}

- (BOOL)isSelectedWithContacts:(NSArray *)contacts {
    for (STContactModel *model in contacts) {
        if (![_selectedContactsArr containsObject:model]) {
            return NO;
        }
    }
    
    return YES;
}

@end
