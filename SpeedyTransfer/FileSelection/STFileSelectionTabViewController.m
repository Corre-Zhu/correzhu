//
//  STFileSelectionTabViewController.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/13.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "STFileSelectionTabViewController.h"
#import <Photos/Photos.h>
#import "STMusicInfo.h"
#import "STFileSelectionPopupView.h"
#import "STWifiNotConnectedPopupView.h"
#import "STTransferInstructionViewController.h"
#import "STFileTransferModel.h"
#import "STContactInfo.h"

@interface STFileSelectionTabViewController ()
{
    UIImageView *toolView;
    UIButton *deleteButton;
    UIButton *transferButton;
    STFileSelectionPopupView *popupView;
    STWifiNotConnectedPopupView *wifiNotConnectedPopupView;
    
    NSTimeInterval lastTimeInterval;
}

@end

@implementation STFileSelectionTabViewController

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"left_white"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemClick)];
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
    [transferButton addTarget:self action:@selector(transferButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [transferButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    transferButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [toolView addSubview:transferButton];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityStatusChange:) name:kHTReachabilityChangedNotification object:nil];
}

- (void)deleteButtonClick {
    popupView = [[STFileSelectionPopupView alloc] init];
    popupView.tabViewController = self;
    popupView.dataSource = [NSMutableArray arrayWithArray:self.selectedFilesArray];
    [popupView showInView:self.navigationController.view];
}

- (void)reachabilityStatusChange:(NSNotification *)notification {
	NetworkStatus status = [ZZReachability shareInstance].currentReachabilityStatus;
	switch (status) {
		case NotReachable:
			break;
		case ReachableViaWiFi: {
			if ([wifiNotConnectedPopupView isShow]) {
				[wifiNotConnectedPopupView removeFromSuperview];
				
				STTransferInstructionViewController *transferIns = [[STTransferInstructionViewController alloc] init];
				[self.navigationController pushViewController:transferIns animated:YES];
			}
		}
			break;
		
		default:
			return;
	}
}

- (void)transferButtonClick {
	if ([ZZReachability shareInstance].currentReachabilityStatus != ReachableViaWiFi) {
        if (!wifiNotConnectedPopupView) {
            wifiNotConnectedPopupView = [[STWifiNotConnectedPopupView alloc] init];
        }
        [wifiNotConnectedPopupView showInView:self.navigationController.view];
        
    } else {
        STTransferInstructionViewController *transferIns = [[STTransferInstructionViewController alloc] init];
        [self.navigationController pushViewController:transferIns animated:YES];
    }
}

#pragma mark - Send file

- (void)startSendFile {
    self.sendingFile = YES;
    
    // 发送图片
    if (self.selectedAssetsArr.count > 0) {
        PHAsset *sendAsset = self.fileSelectionTabController.selectedAssetsArr.firstObject;
        [self.fileSelectionTabController removeAsset:sendAsset];
        [self.fileSelectionTabController reloadAssetsTableView];
        [[PHImageManager defaultManager] requestImageDataForAsset:sendAsset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            NSURL *url = [info objectForKey:@"PHImageFileURLKey"];
            NSString *path = [[ZZPath picturePath] stringByAppendingPathComponent:[url.absoluteString lastPathComponent]];
            [imageData writeToFile:path atomically:YES];
            self.currentTransferInfo = [[STFileTransferModel shareInstant] saveAssetWithIdentifier:sendAsset.localIdentifier fileName:[url.absoluteString lastPathComponent] length:imageData.length forKey:nil];
            
            __weak STFileTransferInfo *weakInfo = _currentTransferInfo;
            
            lastTimeInterval = [[NSDate date] timeIntervalSince1970];
            NSProgress *progress = [[STFileTransferModel shareInstant].transceiver sendResourceAtURL:[NSURL fileURLWithPath:path] withName:[url.absoluteString lastPathComponent] toPeer:[STFileTransferModel shareInstant].transceiver.connectedPeers.firstObject withCompletionHandler:^(NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [progress removeObserver:self forKeyPath:@"fractionCompleted" context:NULL];
                    if (!error) {
                        weakInfo.status = STFileTransferStatusSucceed;
                        [[STFileTransferModel shareInstant] updateStatus:STFileTransferStatusSucceed rate:weakInfo.sizePerSecond withIdentifier:weakInfo.identifier];
                    } else {
                        weakInfo.status = STFileTransferStatusFailed;
                        [[STFileTransferModel shareInstant] updateStatus:STFileTransferStatusFailed rate:weakInfo.sizePerSecond withIdentifier:weakInfo.identifier];
                    }
                    
                    [self startSendFile];
                });
            }];
            
            [progress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:NULL];
        }];
        return;
    }
    
    // 发送音乐
    if (self.fileSelectionTabController.selectedMusicsArr.count > 0) {
        STMusicInfo *musicInfo = self.fileSelectionTabController.selectedMusicsArr.firstObject;
        [self.fileSelectionTabController removeMusic:musicInfo];
        [self.fileSelectionTabController reloadMusicsTableView];
        
        NSURL *url = musicInfo.url;
        AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:url options:nil];
        
        AVAssetExportSession *exporter = [[AVAssetExportSession alloc]
                                          initWithAsset: songAsset
                                          presetName: AVAssetExportPresetAppleM4A];
        
        exporter.outputFileType = @"com.apple.m4a-audio";
        
        NSString *exportFile = [[ZZPath documentPath] stringByAppendingPathComponent:@"31412313.m4a"];
        
        NSError *error1;
        
        if([[NSFileManager defaultManager] fileExistsAtPath:exportFile])
        {
            [[NSFileManager defaultManager] removeItemAtPath:exportFile error:&error1];
        }
        
        NSURL* exportURL = [NSURL fileURLWithPath:exportFile];
        
        exporter.outputURL = exportURL;
        
        // do the export
        [exporter exportAsynchronouslyWithCompletionHandler:^
         {
             NSData *data1 = [NSData dataWithContentsOfFile:exportFile];
             int exportStatus = exporter.status;
             
             switch (exportStatus) {
                     
                 case AVAssetExportSessionStatusFailed: {
                     // log error to text view
                     NSError *exportError = exporter.error;
                     
                     NSLog (@"AVAssetExportSessionStatusFailed: %@", exportError);
                     break;
                 }
                     
                 case AVAssetExportSessionStatusCompleted: {
                     
                     NSLog (@"AVAssetExportSessionStatusCompleted");
                     
                     [[STFileTransferModel shareInstant].transceiver sendResourceAtURL:exportURL withName:@"sdfsdfsdf.sdf" toPeer:[STFileTransferModel shareInstant].transceiver.connectedPeers.firstObject withCompletionHandler:^(NSError * _Nullable error) {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [self startSendFile];
                         });
                     }];
                     break;
                 }
                 default:
                 { NSLog (@"didn't get export status");
                     break;
                 }
             }
             
         }];
        
        return;
    }
    
    // 发送联系人
    if (self.fileSelectionTabController.selectedContactsArr.count > 0) {
        STContactInfo *contact = self.fileSelectionTabController.selectedContactsArr.firstObject;
        NSData *data = [contact.vcardString dataUsingEncoding:NSUTF8StringEncoding];
        if (data.length > 0) {
            STFileTransferInfo *info = [[STFileTransferModel shareInstant] setContactInfo:contact forKey:nil];
            NSTimeInterval start = [[NSDate date] timeIntervalSince1970];
            [[STFileTransferModel shareInstant].transceiver sendUnreliableData:data toPeers:[STFileTransferModel shareInstant].transceiver.connectedPeers completion:^(NSError *error) {
                if (error) {
                    NSLog(@"%@", error);
                    info.status = STFileTransferStatusFailed;
                    [[STFileTransferModel shareInstant] updateStatus:info.status rate:0 withIdentifier:info.identifier];
                } else {
                    NSTimeInterval end = [[NSDate date] timeIntervalSince1970];
                    info.sizePerSecond = 1 / (end - start) * data.length;
                    info.status = STFileTransferStatusSucceed;
                    info.progress = 1.0f;
                    [[STFileTransferModel shareInstant] updateStatus:info.status rate:info.sizePerSecond withIdentifier:info.identifier];
                }
                [self.fileSelectionTabController removeContact:contact];
                [self.fileSelectionTabController reloadContactsTableView];
                [self startSendFile];
            }];
        } else {
            [self.fileSelectionTabController removeContact:contact];
            [self.fileSelectionTabController reloadContactsTableView];
            [self startSendFile];
        }
        
        return;
    }
    
    self.sendingFile = NO;
}

- (void)reloadAssetsTableView {
    UICollectionViewController *viewC = self.viewControllers.firstObject;
    [viewC.collectionView reloadData];
}

- (void)reloadMusicsTableView {
    UITableViewController *viewC = self.viewControllers[1];
    [viewC.tableView reloadData];
}

- (void)reloadVideosTableView {
    UITableViewController *viewC = self.viewControllers[2];
    [viewC.tableView reloadData];
}

- (void)reloadContactsTableView {
    UITableViewController *viewC = self.viewControllers.lastObject;
    [viewC.tableView reloadData];
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

- (void)leftBarButtonItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)removeAllSelectedFiles {
    _selectedFilesArray = nil;
    _selectedAssetsArr = nil;
    _selectedMusicsArr = nil;
    _selectedVideoAssetsArr = nil;
    _selectedContactsArr = nil;
    [self configToolView];
}

// 选中的总文件个数
- (NSInteger)selectedFilesCount {
    NSUInteger count = 0;
    count += _selectedAssetsArr.count;
    
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

- (void)addAsset:(PHAsset *)asset {
    if (!asset) {
        return;
    }
    
    @autoreleasepool {
        if (!_selectedAssetsArr) {
            _selectedAssetsArr = [NSArray arrayWithObject:asset];
        } else {
            if (![_selectedAssetsArr containsObject:asset]) {
                _selectedAssetsArr = [_selectedAssetsArr arrayByAddingObject:asset];
            }
        }
    }
    
    [self configToolView];
}

- (void)addAssets:(NSArray *)assetss {
    if (!assetss) {
        return;
    }
    
    @autoreleasepool {
        if (!_selectedAssetsArr) {
            _selectedAssetsArr = [NSArray arrayWithArray:assetss];
        } else {
            _selectedAssetsArr = [_selectedAssetsArr arrayByAddingObjectsFromArray:assetss];
        }
    }
    
    [self configToolView];
}

- (void)removeAsset:(PHAsset *)asset {
    if (!asset) {
        return;
    }
    
    @autoreleasepool {
        if ([_selectedAssetsArr containsObject:asset]) {
            NSMutableArray *tempArr = [NSMutableArray arrayWithArray:_selectedAssetsArr];
            [tempArr removeObject:asset];
            _selectedAssetsArr = [NSArray arrayWithArray:tempArr];
        }
    }
    
    [self configToolView];
}

- (void)removeAssets:(NSArray *)assets {
    if (!assets) {
        return;
    }
    
    @autoreleasepool {
        NSMutableArray *tempArr = [NSMutableArray arrayWithArray:_selectedAssetsArr];
        [tempArr removeObjectsInArray:assets];
        _selectedAssetsArr = [NSArray arrayWithArray:tempArr];
    }
    
    [self configToolView];
}

- (BOOL)isSelectedWithAsset:(PHAsset *)asset {
    return [_selectedAssetsArr containsObject:asset];
}

- (void)addMusic:(STMusicInfo *)music {
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

- (void)removeMusic:(STMusicInfo *)music {
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

- (BOOL)isSelectedWithMusic:(STMusicInfo *)music {
    return [_selectedMusicsArr containsObject:music];
}

- (BOOL)isSelectedWithMusics:(NSArray *)musics {
    for (STMusicInfo *model in musics) {
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

- (void)addContact:(STContactInfo *)contact {
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

- (void)removeContact:(STContactInfo *)contact {
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

- (BOOL)isSelectedWithContact:(STContactInfo *)contact {
    return [_selectedContactsArr containsObject:contact];
}

- (BOOL)isSelectedWithContacts:(NSArray *)contacts {
    for (STContactInfo *model in contacts) {
        if (![_selectedContactsArr containsObject:model]) {
            return NO;
        }
    }
    
    return YES;
}

@end
