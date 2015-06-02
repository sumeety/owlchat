//
//  GroupChatInfoViewController.m
//  Hoothere
//
//  Created by UnoiaTech on 02/04/15.
//  Copyright (c) 2015 Quovantis Technologies. All rights reserved.
//

#import "GroupChatInfoViewController.h"
#import "MentionTagTableViewCell.h"
#import "ProfileImageTableViewCell.h"
#import "AddMemberViewController.h"
#import "AppDelegate.h"
@interface GroupChatInfoViewController ()
{
    NSMutableArray *membersArray;
}
@end

@implementation GroupChatInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    membersArray =[[NSMutableArray alloc]init];
    
    UIBarButtonItem *leftBarButton=[[UIBarButtonItem alloc]initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonTapped)];
    self.navigationItem.leftBarButtonItem=leftBarButton;
  
      self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"Add members" style:UIBarButtonItemStylePlain target:self action:@selector(addMembers:)];
    
    self.title=[NSString stringWithFormat:@"%@",_eventName];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    if (membersArray.count<1) {
        [self getGroupsMembers];
        [_tableView reloadData];
    }
    else {
        [_tableView reloadData];
    }
}
-(void)closeButtonTapped {
    [AppDel leaveGroup];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)editButtonTapped {
    
}

#pragma Mark UITableViewDelegate/UItableViewDataSource Methods 

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return 1;
    }
    else if (section==1) {
        return 1;
    }
 
    
    return YES;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section==0) {
        ProfileImageTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"ProfileImageTableViewCell"];
        if (cell==nil)
        {
            [tableView registerNib:[UINib nibWithNibName:@"ProfileImageTableViewCell" bundle:nil]forCellReuseIdentifier:@"ProfileImageTableViewCell"];
            cell=[tableView dequeueReusableCellWithIdentifier:@"ProfileImageTableViewCell"];
        }
        
        if (membersArray.count<1) {
            [_tableView reloadData];
       }
        else {
        NSLog(@"nslog member list %lu   %@",(unsigned long)[AppDel memberList].count,[AppDel memberList]);
        cell.membersCount.text=[NSString stringWithFormat:@"%d members  ",membersArray.count];
}
        cell.groupName.text=_eventName;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (indexPath.section==1) {
        MentionTagTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"MentionTagTableViewCell"];
        if (cell==nil)
        {
            [tableView registerNib:[UINib nibWithNibName:@"MentionTagTableViewCell" bundle:nil]forCellReuseIdentifier:@"MentionTagTableViewCell"];
            cell=[tableView dequeueReusableCellWithIdentifier:@"MentionTagTableViewCell"];
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return nil;
    }
    if (section==1) {
        
        UIView *sectionView=[[UIView alloc]init];
        sectionView.backgroundColor=[UIColor colorWithRed:230.0/255 green:230.0/255 blue:238.0/255 alpha:1];
        UILabel *titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(15,0, 200, 30)];
        titleLabel.text=@"NOTIFICATIONS";
        titleLabel.textColor=[UIColor colorWithRed:101.0/255 green:111.0/255 blue:124.0/255 alpha:1];
        [titleLabel setFont:[UIFont systemFontOfSize:13]];
        titleLabel.backgroundColor=[UIColor clearColor];
        [sectionView addSubview:titleLabel];
        return sectionView;
    }
    return nil;
}
-(CGFloat)tableViefdw:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section==0) {
        return 0;
    }
    else{
        return 60;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        return 90;
    }
    else if (indexPath.section==1) {
        return 70;
    }
   
    return YES;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}

-(void)addMembers:(id)sender {
    AddMemberViewController *addMember=[[AddMemberViewController alloc]initWithNibName:@"AddMemberViewController" bundle:nil];
    addMember.room=_room;
    addMember.roomName=self.title;
    addMember.alreadyMembersList=membersArray;
    [self.navigationController pushViewController:addMember animated:YES];
}

-(void)getGroupsMembers{
    NSString *urlString=[NSString stringWithFormat:@"%@/getGroupMembers",BaseURL];
    NSLog(@"url string %@",urlString);
    NSURL *url=[NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    NSString *postData=[NSString stringWithFormat:@"group_name=%@",_eventName];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"posted data is %@",postData);
    [request setValue:@"binary"
   forHTTPHeaderField:@"Content-Transfer-Encoding"];
    [request setValue:@"application/x-www-form-urlencoded; charset=UTF-8"
   forHTTPHeaderField:@"Content-Type"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (data) {
            NSError *error = [[NSError alloc] init];
            NSDictionary* responseDict = [NSJSONSerialization
                                          JSONObjectWithData:data
                                          options:kNilOptions
                                          error:&error];
            
            NSString *responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"data got in responseStr is %@",responseStr);
            if ([[responseDict valueForKey:@"message"] isEqualToString:@"Request successful"])
            {
                NSLog(@"response dictionary %@",responseDict);
                NSArray *memberArray=[responseDict objectForKey:@"members_list"];
                
                for (int i=0; i<memberArray.count; i++) {
                    NSMutableDictionary *data=[[[memberArray valueForKey:@"member"] objectAtIndex:i] mutableCopy];
                    [membersArray addObject:data];
                    NSLog(@"members array cont %@",membersArray);
                }
                //  [self stopProgress];
            }
            else
            {
                // [self.delegate stopAddingFriendProgress:[responseDict valueForKey:@"message"]];
                //  [self stopProgress];
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"ERROR" message:@"Something went wrong" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                // [alertView show];
                NSLog(@"Error %@",responseDict);
            }
        }
        else
        {
            // [self stopProgress];
            //  [self.delegate stopAddingFriendProgress:@"Somthing went wrong"];
        }
        
    }];
    
}
@end
