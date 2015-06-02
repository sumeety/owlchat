//
//  SingleUserChatTableViewCell.m
//  Hoothere
//
//  Created by UnoiaTech on 23/04/15.
//  Copyright (c) 2015 Quovantis Technologies. All rights reserved.
//

#import "SingleUserChatTableViewCell.h"
#import "NSString+Utils.h"
@implementation SingleUserChatTableViewCell

@synthesize senderAndTimeLabel, messageContentView, labelBackgroundView;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.labelBackgroundView=[[UIView alloc]initWithFrame:CGRectZero];
        self.labelBackgroundView.layer.cornerRadius=10;
        [self.contentView addSubview:self.labelBackgroundView];

        self.senderAndTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 60, 300, 20)];
        self.senderAndTimeLabel.textAlignment = NSTextAlignmentCenter;
        self.senderAndTimeLabel.font = [UIFont systemFontOfSize:11.0];
        self.senderAndTimeLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:self.senderAndTimeLabel];
        self.messageContentView = [[UITextView alloc] init];
        self.messageContentView.backgroundColor = [UIColor clearColor];
        self.messageContentView.editable = NO;
        [self.messageContentView setFont:[UIFont systemFontOfSize:13]];
        self.messageContentView.scrollEnabled = NO;
        [self.messageContentView sizeToFit];
        [self.messageContentView setTextColor:[UIColor whiteColor]];
        self.messageContentView.textContainer.lineFragmentPadding = 0;
        self.messageContentView.textContainerInset = UIEdgeInsetsZero;
        
        [self.contentView addSubview:self.messageContentView];
    }
    
    return self;
    
}

@end
