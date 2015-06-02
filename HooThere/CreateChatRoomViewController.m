//
//  CreateChatRoomViewController.m
//  Hoothere
//
//  Created by UnoiaTech on 04/05/15.
//  Copyright (c) 2015 Quovantis Technologies. All rights reserved.
//

#import "CreateChatRoomViewController.h"
#import "GroupChatViewController.h"
#import "AppDelegate.h"
@implementation CreateChatRoomViewController

-(void)viewDidLoad {
        [AppDel connect];
    self.groupNameTextField.delegate=self;
    self.title=@"Create Group";
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];
}
- (IBAction)doneTapped:(id)sender {
    if (self.groupNameTextField.text.length<1) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Please enter a valid group name" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }
    else {
    [AppDel createChatRoom:self.groupNameTextField.text];
    GroupChatViewController *groupChatVC=[[GroupChatViewController alloc]initWithNibName:@"GroupChatViewController" bundle:nil];
    groupChatVC.hidesBottomBarWhenPushed=YES;
    groupChatVC.groupName=self.groupNameTextField.text;
    groupChatVC.fromView=@"chatViewController";
    [AppDel discoverRoom];
    [self.navigationController pushViewController:groupChatVC animated:YES];
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    return [self.groupNameTextField resignFirstResponder];
}
@end
