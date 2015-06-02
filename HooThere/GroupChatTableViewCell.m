//
//  GroupChatTableViewCell.m
//  Hoothere
//
//  Created by UnoiaTech on 03/04/15.
//  Copyright (c) 2015 Quovantis Technologies. All rights reserved.
//

#import "GroupChatTableViewCell.h"

@implementation GroupChatTableViewCell
@synthesize messageContentView;

/*
- (void)awakeFromNib {
    // Initialization code
}
*/

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.labelBackgroundView=[[UIView alloc]initWithFrame:CGRectZero];
        self.labelBackgroundView.layer.cornerRadius=10;
        [self.contentView addSubview:self.labelBackgroundView];
        
        self.messageContentView = [[UITextView alloc] init];
        self.messageContentView.backgroundColor = [UIColor clearColor];
        self.messageContentView.editable = NO;
        [self.messageContentView setFont:[UIFont systemFontOfSize:14]];
        [self.messageContentView setTextColor:[UIColor whiteColor]];
        self.messageContentView.scrollEnabled = NO;
        [self.messageContentView sizeToFit];
        self.messageContentView.textContainer.lineFragmentPadding = 0;
        self.messageContentView.textContainerInset = UIEdgeInsetsZero;
        [self.contentView addSubview:self.messageContentView];
        
        self.senderAndTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 60, 300, 20)];
        self.senderAndTimeLabel.textAlignment = NSTextAlignmentCenter;
        self.senderAndTimeLabel.font = [UIFont systemFontOfSize:11.0];
        self.senderAndTimeLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:self.senderAndTimeLabel];
    }
    
    return self;
    
}


- (void)prepareForReuse
{
    [super prepareForReuse];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
