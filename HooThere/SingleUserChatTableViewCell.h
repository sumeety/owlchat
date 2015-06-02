//
//  SingleUserChatTableViewCell.h
//  Hoothere
//
//  Created by UnoiaTech on 23/04/15.
//  Copyright (c) 2015 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SingleUserChatTableViewCell : UITableViewCell

@property (nonatomic,strong) UILabel *senderAndTimeLabel;
@property (nonatomic,strong) UITextView *messageContentView;
@property (nonatomic,strong) UIView *labelBackgroundView;

@end
