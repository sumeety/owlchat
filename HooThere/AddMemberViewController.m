//
//  AddMemberViewController.m
//  Hoothere
//
//  Created by UnoiaTech on 05/05/15.
//  Copyright (c) 2015 Quovantis Technologies. All rights reserved.
//

#import "AddMemberViewController.h"
#import "UtilitiesHelper.h"
#import "CoreDataInterface.h"
#import "GroupMemberTableViewCell.h"
#import "AppDelegate.h"
@interface AddMemberViewController ()

@end

@implementation AddMemberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _listOfFriends =[[NSMutableArray alloc]init];
    _listOfSelectedFriends=[[NSMutableArray alloc]init];
    self.title=self.roomName;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        _activityIndicator = [UtilitiesHelper loadCustomActivityIndicatorWithYorigin:self.view.center.y -80 Xorigin:self.view.center.x-50];
    }
    else {
        _activityIndicator = [UtilitiesHelper loadCustomActivityIndicatorWithYorigin:self.view.center.x-80 Xorigin:self.view.center.y -50];
    }
    
    [self.view addSubview:_activityIndicator];
    [self.view bringSubviewToFront:_activityIndicator];
    [self getListofFriends];
     [AppDel joinMultiUserChatRoom:self.roomName];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getListofFriends {
   
    [_activityIndicator startAnimating];
   
    NSMutableArray *friends =  [CoreDataInterface searchObjectsInContext:@"Friends" andPredicate:nil andSortkey:@"firstName" isSortAscending:YES];
            for (int i = 0; i < friends.count; i++) {
                Friends *contactInfo = [friends objectAtIndex:i];
                if ([[contactInfo status] isEqualToString:@"F"])  {
                    if ([_alreadyMembersList containsObject:[contactInfo fullName]]) {
                        
                    }
                    else {
                    [_listOfFriends addObject:contactInfo];
                    }
                    
                }
            }
    [_activityIndicator stopAnimating];
            [_tableView reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _listOfFriends.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"GroupMemberTableViewCell";
    NSMutableDictionary *friendsDict=[_listOfFriends objectAtIndex:indexPath.row];

    GroupMemberTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"GroupMemberTableViewCell" bundle:nil]forCellReuseIdentifier:@"GroupMemberTableViewCell"];
        cell=[tableView dequeueReusableCellWithIdentifier:@"GroupMemberTableViewCell"];

    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.userNameLabel.text=[friendsDict valueForKey:@"fullName"];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id contactInfo;
    GroupMemberTableViewCell *cell= (GroupMemberTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    contactInfo = [_listOfFriends objectAtIndex:indexPath.row];
    NSLog(@"contact info is %@",contactInfo);
    if ([_listOfSelectedFriends containsObject:contactInfo]) {
        
        [_listOfSelectedFriends removeObject:contactInfo];
        cell.inviteImageView.image = [UIImage imageNamed:@"invite-border"];
     //   NSLog(@"list of selected friends in if statement %@",_listOfSelectedFriends);
    }
    else if (![_listOfSelectedFriends containsObject:contactInfo]) {
        [_listOfSelectedFriends addObject:contactInfo];
       cell.inviteImageView.image = [UIImage imageNamed:@"select_blue"];
       // NSLog(@"list of selected friends in ELSE statement %@",_listOfSelectedFriends);
    }
}

- (IBAction)addToGroup:(id)sender {
    NSLog(@"list of frineds selected is %@",_listOfSelectedFriends);
    if (_listOfSelectedFriends.count<1) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"No user selected to add" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
          [AppDel leaveGroup];
    }
    else {
    for (int i = 0; i < _listOfSelectedFriends.count; i++) {
        id objectInfo = [_listOfSelectedFriends objectAtIndex:i];
        NSRange range=[[objectInfo email]  rangeOfString:@"@"];
        NSString *userName=[[objectInfo email]  substringToIndex:range.location];
        
     //   [[AppDel xmppRoom] inviteUser:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@%@",userName,kDomainName]] withMessage:@"Join group chat"];
        
     //   [[AppDel xmppRoom] editRoomPrivileges:@[[XMPPRoom itemWithAffiliation:@"member" jid:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@%@",userName,kDomainName]]]]];
        [[AppDel xmppRoom] editRoomPrivileges:@[[XMPPRoom itemWithAffiliation:@"member" jid:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@%@",userName,kDomainName]]]]];
        NSLog(@"room name is %@ %@ %@",_room.roomJID,userName,kDomainName);
    }
  //  [AppDel leaveGroup];
   // [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (IBAction)cancelAddingMembers:(id)sender {
    [AppDel leaveGroup];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
