//
//  WZSTableViewCell.h
//  PhotoLibrary
//
//  Created by 王战胜 on 2017/2/22.
//  Copyright © 2017年 gocomtech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WZSTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *LeftImage;
@property (strong, nonatomic) IBOutlet UILabel *RightLabel;

@end
