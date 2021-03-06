//
//  STVideoSelectionCell.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 16/1/11.
//  Copyright © 2016年 ZZ. All rights reserved.
//

#import "STVideoSelectionCell.h"

@interface STVideoSelectionCell ()
{
	UIImageView *coverImageView;
	UILabel *titleLabel;
	UILabel *subTitleLabel;
	UIImageView *checkImageView;
}

@end

@implementation STVideoSelectionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		
		coverImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_bg"]];
		coverImageView.frame = CGRectMake(16.0f, 10.0f, 68.0f, 52.0f);
		coverImageView.layer.cornerRadius = 3.0f;
		coverImageView.layer.masksToBounds = YES;
		[self.contentView addSubview:coverImageView];
		
		titleLabel = [[UILabel alloc] init];
		titleLabel.frame = CGRectMake(coverImageView.right + 16.0f, 17.0f, 120.0f, 19.0f);
		titleLabel.textColor = RGBFromHex(0x323232);
		titleLabel.font = [UIFont systemFontOfSize:16.0f];
		[self.contentView addSubview:titleLabel];
		
		subTitleLabel = [[UILabel alloc] init];
		subTitleLabel.frame = CGRectMake(coverImageView.right + 16.0f, 42.0f, 100.0f, 17.0f);
		subTitleLabel.textColor = RGBFromHex(0x929292);
		subTitleLabel.font = [UIFont systemFontOfSize:14.0f];
		[self.contentView addSubview:subTitleLabel];
		
		checkImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check_gray"]];
		checkImageView.frame = CGRectMake(IPHONE_WIDTH - 38.0f, 25.0f, 22.0f, 22.0f);
		[self.contentView addSubview:checkImageView];
	}
	
	return self;
}

- (void)setImage:(UIImage *)image {
	coverImageView.image = image;
}

- (void)setTitle:(NSString *)title {
	_title = title;
	titleLabel.text = title;
}

- (void)setSubTitle:(NSString *)subTitle {
	_subTitle = subTitle;
	subTitleLabel.text = subTitle;
}

- (void)setChecked:(BOOL)checked {
	_checked = checked;
	if (!checked) {
		checkImageView.image = [UIImage imageNamed:@"check_gray"];
	} else {
		checkImageView.image = [UIImage imageNamed:@"check_yellow"];
	}
	
}

@end
