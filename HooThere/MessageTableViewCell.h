//
//  MessageTableViewCell.h
//  KiteApp
//
//  Created by UnoiaTech on 22/12/14.
//  Copyright (c) 2014 UnoiaTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *userFrndImage;
@property (strong, nonatomic) IBOutlet UILabel *messageCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *frndName;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *messageCount;
@end
