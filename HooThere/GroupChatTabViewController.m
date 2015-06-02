//
//  GroupChatTabViewController.m
//  Hoothere
//
//  Created by UnoiaTech on 04/05/15.
//  Copyright (c) 2015 Quovantis Technologies. All rights reserved.
//

#import "GroupChatTabViewController.h"
#import "MessageTableViewCell.h"
#import "GroupChatViewController.h"
#import "AppDelegate.h"
#import "CreateChatRoomViewController.h"
#import "UserListViewController.h"
@implementation GroupChatTabViewController
{
    NSMutableArray *roomList;
    NSMutableArray *chatList;
    UIView *footerView;
}

-(void)viewDidLoad {
    [super viewDidLoad];
  //  [self getRoomsList];
    chatList=[[NSMutableArray alloc]init];
    roomList=[[NSMutableArray alloc]init];
//    [AppDel discoverRoom];
  //  roomList=[AppDel roomList];
    [_chatRoomListTableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self loadPeerToPeerChatUser];
    [AppDel discoverRoom];
    self.title=@"Messages";
    
 //   roomList=[AppDel roomList];
    
    // AdMob Integration
    
    // For Production Mode   self.adMobBannerView.adUnitID =@"ca-app-pub-4886788404179515/1267784183";
    
    // For Development Mode
    self.adMobBannerView.adUnitID = @"ca-app-pub-3940256099942544/2934735716";
    self.adMobBannerView.rootViewController = self;
    [self.adMobBannerView loadRequest:[GADRequest request]];
    GADRequest *request = [GADRequest request];
    // Requests test ads on devices you specify. Your test device ID is printed to the console when
    // an ad request is made. GADBannerView automatically returns test ads when running on a
    // simulator.
    request.testDevices =@[[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"device_id"]]]; // Device ID
  
    [self.adMobBannerView loadRequest:request];
    NSLog(@"device id %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"device_id"]);
    if (roomList.count<1) {
       [self getRoomsList];
   [_chatRoomListTableView reloadData];
    }
    else{
       [_chatRoomListTableView reloadData];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
  //  [AppDel discoverRoom];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section==1)
    {
     NSLog(@"number of chats in list %d",roomList.count);
        return roomList.count;
    }
    else if (section==0)
    {
        return chatList.count;
    }
    return roomList.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"MessageTableViewCell";
   
    MessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"MessageTableViewCell" owner:nil options:nil];
        cell = (MessageTableViewCell*)[topLevelObjects objectAtIndex:0];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
     if (indexPath.section==1) {
    if (roomList.count<1) {
        [tableView reloadData];
    }
    else {
        NSDictionary *roomData=[roomList objectAtIndex:indexPath.row];
        
   

    [cell.textLabel setHidden:YES];
    [cell.userFrndImage setImage:[UIImage imageNamed:@"group.png"]];
    cell.frndName.text=[roomData valueForKey:@"room_name"];
    }
//    NSString *nameWithJid=[NSString stringWithFormat:@"%@",[cellData valueForKey:@"bareJidStr"]];
  //  NSRange range=[nameWithJid rangeOfString:@"@"];
 //   NSString *newName=[nameWithJid substringToIndex:range.location];
 //   cell.textLabel.text=newName;
    
    //  id contactInformation;
    //  NSLog(@"status F friends are %@",_statusFFriends);
    //contactInformation = [_statusFFriends objectAtIndex:indexPath.row];
    
    //   NSString *nameFromEmail=[contactInformation email];
    //  NSRange nameRange=[nameFromEmail rangeOfString:@"@"];
    //  NSString *extractedName=[nameWithJid substringToIndex:nameRange.location];
  //  cell.frndName.text=newName;
    
/*    cell.messageLabel.text=[cellData valueForKey:@"mostRecentMessageBody"];
    
    NSString *time=[cellData valueForKey:@"mostRecentMessageTimestamp"];
    NSString *timeNew=[NSString stringWithFormat:@"%@",time];
    NSRange timeRange=[timeNew rangeOfString:@"+"];
    NSString *newTime=[timeNew substringToIndex:timeRange.location];
    
    NSString *dateStr =[ NSString stringWithFormat:@"%@",newTime];
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    [dateFormatter1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter1 dateFromString:dateStr];
    
    NSTimeZone *currentTimeZone = [NSTimeZone localTimeZone];
    NSTimeZone *utcTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    
    NSInteger currentGMTOffset = [currentTimeZone secondsFromGMTForDate:date];
    NSInteger gmtOffset = [utcTimeZone secondsFromGMTForDate:date];
    NSTimeInterval gmtInterval = currentGMTOffset - gmtOffset;
    
    NSDate *destinationDate =[[NSDate alloc] initWithTimeInterval:gmtInterval sinceDate:date] ;
    
    NSDateFormatter *dateFormatters = [[NSDateFormatter alloc] init];
    [dateFormatters setDateFormat:@"dd-MMM-yyyy hh:mm"];
    [dateFormatters setDateStyle:NSDateFormatterShortStyle];
    [dateFormatters setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatters setDoesRelativeDateFormatting:YES];
    [dateFormatters setTimeZone:[NSTimeZone systemTimeZone]];
    dateStr = [dateFormatters stringFromDate: destinationDate];
    cell.timeLabel.text =[NSString stringWithFormat:@"%@",dateStr];
    */
        
    }
    else if (indexPath.section==0) {
        
        static NSString *CellIdentifier = @"MessageTableViewCell";
        
        NSDictionary *cellData=[chatList objectAtIndex:indexPath.row];
        
        MessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if(cell == nil)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"MessageTableViewCell" owner:nil options:nil];
            cell = (MessageTableViewCell*)[topLevelObjects objectAtIndex:0];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        [cell.textLabel setHidden:YES];
        
        [cell.userFrndImage setImage:[UIImage imageNamed:@"user.png"]];
        NSString *nameWithJid=[NSString stringWithFormat:@"%@",[cellData valueForKey:@"bareJidStr"]];
        NSRange range=[nameWithJid rangeOfString:@"@"];
        NSString *newName=[nameWithJid substringToIndex:range.location];
        cell.textLabel.text=newName;
        
        //  id contactInformation;
        //  NSLog(@"status F friends are %@",_statusFFriends);
        //contactInformation = [_statusFFriends objectAtIndex:indexPath.row];
        
        //   NSString *nameFromEmail=[contactInformation email];
        //  NSRange nameRange=[nameFromEmail rangeOfString:@"@"];
        //  NSString *extractedName=[nameWithJid substringToIndex:nameRange.location];
        cell.frndName.text=newName;
        
        cell.messageLabel.text=[cellData valueForKey:@"mostRecentMessageBody"];
        
        NSString *time=[cellData valueForKey:@"mostRecentMessageTimestamp"];
        NSString *timeNew=[NSString stringWithFormat:@"%@",time];
        NSRange timeRange=[timeNew rangeOfString:@"+"];
        NSString *newTime=[timeNew substringToIndex:timeRange.location];
        
        NSString *dateStr =[ NSString stringWithFormat:@"%@",newTime];
        NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
        [dateFormatter1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *date = [dateFormatter1 dateFromString:dateStr];
        
        NSTimeZone *currentTimeZone = [NSTimeZone localTimeZone];
        NSTimeZone *utcTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
        
        NSInteger currentGMTOffset = [currentTimeZone secondsFromGMTForDate:date];
        NSInteger gmtOffset = [utcTimeZone secondsFromGMTForDate:date];
        NSTimeInterval gmtInterval = currentGMTOffset - gmtOffset;
        
        NSDate *destinationDate =[[NSDate alloc] initWithTimeInterval:gmtInterval sinceDate:date] ;
        
        NSDateFormatter *dateFormatters = [[NSDateFormatter alloc] init];
        [dateFormatters setDateFormat:@"dd-MMM-yyyy hh:mm"];
        [dateFormatters setDateStyle:NSDateFormatterShortStyle];
        [dateFormatters setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatters setDoesRelativeDateFormatting:YES];
        [dateFormatters setTimeZone:[NSTimeZone systemTimeZone]];
        dateStr = [dateFormatters stringFromDate: destinationDate];
        cell.timeLabel.text =[NSString stringWithFormat:@"%@",dateStr];
        
        return cell;
    }

    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 58;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==1) {
        
    MessageTableViewCell *cell=(MessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    GroupChatViewController *groupChatVC=[[GroupChatViewController alloc]initWithNibName:@"GroupChatViewController" bundle:nil];
    groupChatVC.hidesBottomBarWhenPushed=YES;
    groupChatVC.groupName=cell.frndName.text;
    [self.navigationController pushViewController:groupChatVC animated:YES];
    }
    else if (indexPath.section==0) {
        MessageTableViewCell *cell = (MessageTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        //  NSRange emailRange =[cell.rejectFriendRequestButton.titleLabel.text rangeOfString:@"@"];
        //   NSString *userNameXMPP=[cell.rejectFriendRequestButton.titleLabel.text substringToIndex:emailRange.location];
        SingleUserChatViewController *singleUserChatVC=[[SingleUserChatViewController alloc]initWithUser:cell.frndName.text];
        singleUserChatVC.titleText=cell.frndName.text;
        singleUserChatVC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:singleUserChatVC animated:YES];
    }
}
/*
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return 0;
    }
    if (section==1) {
        
        UIView *sectionView=[[UIView alloc]init];
        sectionView.backgroundColor=[UIColor colorWithRed:230.0/255 green:230.0/255 blue:238.0/255 alpha:1];
        UILabel *titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(15, 3, 200, 20)];
        titleLabel.text=@"GROUPS";
        titleLabel.textColor=[UIColor colorWithRed:101.0/255 green:111.0/255 blue:124.0/255 alpha:1];
        [titleLabel setFont:[UIFont systemFontOfSize:13]];
        titleLabel.backgroundColor=[UIColor clearColor];
        [sectionView addSubview:titleLabel];
        return sectionView;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return 0;
    }
    else
    return 20;
}
*/
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    footerView=[[UIView alloc] initWithFrame:CGRectMake(0,0,320,1)];
    footerView.backgroundColor=[UIColor clearColor];
    return footerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section==0) {
        return 0;
    }
    else if (section==1){
        return 5.0f;
    }
    return 0;
}

- (void)loadPeerToPeerChatUser;
{
    //NSLog(@"filtered image contains data %@",friendList);
    NSString *userJid= [NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults]valueForKey:@"user_name"],kDomainName];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    NSManagedObjectContext *context=[[AppDel xmppMessageArchivingCoreDataStorage ] mainThreadManagedObjectContext];
    NSEntityDescription *messageEntity = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Contact_CoreDataObject" inManagedObjectContext:context];
    
    [request setEntity:messageEntity];
    [request setReturnsObjectsAsFaults:NO];
    NSString *predicateFrmt = @"streamBareJidStr == %@";
    NSPredicate *predicateName = [NSPredicate predicateWithFormat:predicateFrmt,userJid];
    request.predicate = predicateName;
    
    // NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"mostRecentMessageTimestamp" ascending:NO];
    // request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSError *error = nil;
    NSArray *chatUsers=[[NSArray alloc]init];
    chatUsers = [context executeFetchRequest:request error:&error];
    NSString *string=@"@conference.127.0.0.1";
    NSPredicate *sPredicate = [NSPredicate predicateWithFormat:@"NOT (bareJidStr CONTAINS[cd] %@)", string];
    NSArray *searchedArray = [chatUsers filteredArrayUsingPredicate:sPredicate];
    chatList=[NSMutableArray arrayWithArray:searchedArray];
}

-(IBAction)createNewChat:(id)sender{
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alert.view setTintColor:[UIColor colorWithRed:142.0f/255 green:58.0f/255 blue:173.0f/255 alpha:1]];
    UIAlertAction *createGroup=[UIAlertAction actionWithTitle:@"Create Group" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        CreateChatRoomViewController *createGroup=[self.storyboard instantiateViewControllerWithIdentifier:@"createChatRoom"];
        [self.navigationController pushViewController:createGroup animated:YES];
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIAlertAction *createSingleChat=[UIAlertAction actionWithTitle:@"New Chat" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UserListViewController *addMemberVC=[[UserListViewController alloc]initWithNibName:@"UserListViewController" bundle:nil];
        [self.navigationController pushViewController:addMemberVC animated:YES];
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIAlertAction *cancelActionSheet=[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:createGroup];
    [alert addAction:createSingleChat];
    [alert addAction:cancelActionSheet];
    [self presentViewController:alert animated:YES completion:nil];
}
-(void)getRoomsList
{
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/getMemberRooms",BaseURL]]];
    [request setHTTPMethod:@"POST"];
    NSString *postData=[NSString stringWithFormat:@"user_name=%@@127.0.0.1",[AppDel xmppStream].myJID.user];
    NSLog(@"posted data %@",postData);
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
                NSArray *roomsArray=[responseDict objectForKey:@"rooms_joined"];
                for (int i=0; i<roomsArray.count; i++) {
                    NSLog(@"roomsArray content %@",[roomsArray objectAtIndex:i]);
                    NSMutableDictionary *data=[[roomsArray objectAtIndex:i] mutableCopy];
                    [roomList addObject:data];
                    [_chatRoomListTableView reloadData];
                    }
                [_chatRoomListTableView reloadData];
                    //  [self stopProgress];
            }
            else
            {
                NSLog(@"Error %@",responseDict);
            }
        }
        else
        {
        }
        
    }];
}
@end
