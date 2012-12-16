//
//  VARRankingCell.h
//  MobileClassFinalProject
//
//  Created by Vincent on 12/12/3.
//  Copyright (c) 2012年 VAR. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VARRankingCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *EnglishName;
@property (strong, nonatomic) IBOutlet UILabel *ChineseName;
@property (strong, nonatomic) IBOutlet UIImageView *crownImage;
@property (strong, nonatomic) IBOutlet UILabel *rankingNumber;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end
