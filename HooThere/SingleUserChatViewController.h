//
//  SingleUserChatViewController.h
//  Hoothere
//
//  Created by UnoiaTech on 23/04/15.
//  Copyright (c) 2015 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMMessageDelegate.h"
@interface SingleUserChatViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,SMMessageDelegate>

@property (strong,nonatomic) NSString *frndName;
@property (strong,nonatomic) NSString *titleText;
@property (strong, nonatomic) IBOutlet UIToolbar *toolBar;
@property (strong, nonatomic) IBOutlet UITableView *chatTableView;
- (void)loadChatHistoryWithUserName:(NSString *)userName;
- (void)newMessageReceived:(NSMutableDictionary *)messageContent;
- (id) initWithUser:(NSString *) userName;
@end
