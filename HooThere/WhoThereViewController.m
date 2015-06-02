//
//  WhoThereViewController.m
//  HooThere
//
//  Created by Abhishek Tyagi on 23/09/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import "WhoThereViewController.h"
#import "CustomTableViewCell.h"
#import "CoreDataInterface.h"
#import "UtilitiesHelper.h"
#import "EventDetailsViewController.h"
#import "EventHelper.h"
#import "GeofenceMonitor.h"
#import <MapKit/MapKit.h>
#import "SeeAllViewController.h"
#import "AppDelegate.h"
#import "CreateEventViewController.h"
#import "AddressBook.h"
#import "OverViewViewController.h"
#import "NotificationHelper.h"
#import "UIImageView+WebCache.h"

@interface WhoThereViewController ()

@end

@implementation WhoThereViewController

@synthesize refreshControl;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [AddressBook getContactsFromAddressBook];
    });
    
    if([_fromWhereCalled isEqualToString:@"HT"]){
        self.navigationItem.hidesBackButton = NO;
    }
    else {
        self.navigationItem.hidesBackButton = YES;
        NSMutableArray *navigationArray = [self.navigationController.viewControllers mutableCopy];
        [navigationArray removeObjectAtIndex:0];
        [self.navigationController setViewControllers:navigationArray];
        UIBarButtonItem *createEventButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"create-event.png"] style:UIBarButtonItemStylePlain target:self action:@selector(createEventButtonClicked)];
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:createEventButton, nil];
        
    }
    
    [self.tabBarController.tabBar setTintColor:[UIColor purpleColor]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshEventlist) name:@"kUpdateHooThereEvents" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getUpcomingEvents) name:@"kPushUpdateEventList" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutButtonClicked) name:@"kLogoutButtonClicked" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadInvitedDetailsView:) name:@"kloadEventDetailsAfterSingleInvitation" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshEventlist) name:@"kAutoCheckInCheckOutHappened" object:nil];



    _activityIndicator = [UtilitiesHelper loadCustomActivityIndicatorWithYorigin:self.view.center.y -80 Xorigin:self.view.center.x-50];
    [self.tableView addSubview:_activityIndicator];
    [self.tableView bringSubviewToFront:_activityIndicator];
    [_activityIndicator startAnimating];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor whiteColor];
    self.refreshControl.tintColor = [UIColor darkGrayColor];
    [self.refreshControl addTarget:self
                            action:@selector(getUpcomingEvents)
                  forControlEvents:UIControlEventValueChanged];
    [eventTableView addSubview:self.refreshControl];
    [self.refreshControl endRefreshing];
    
//    eventTableView.hidden = YES;
    
    
    self.tabBarController.tabBar.hidden = NO;
    
    [self getUpcomingEvents];

    _noEvents = TRUE;
    _noRequest = TRUE;
    
    [[[[[self tabBarController] tabBar] items] objectAtIndex:2] setBadgeValue:nil];
    [self fetchListOfHootThereFriends];
}

- (void)fetchListOfHootThereFriends {
    [self.view endEditing:YES];
    NSString *userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/friends/%@/getAll?page=0",kwebUrl,userId];
    [UtilitiesHelper fetchListOfHootThereFriends:[NSURL URLWithString:urlString] requestType:@"GET" complettionBlock:^(BOOL success,NSDictionary *jsonDict){
        [_activityIndicator stopAnimating];
        if (success) {
            //_listOfFriends = [jsonDict objectForKey:@"Friends"];
            [CoreDataInterface saveFriendList:[jsonDict objectForKey:@"Friends"]];
        }
    }];
}

- (void)fetchNumberOfNotifcations {
    [NotificationHelper getCountOfNotificationsWithComplettionBlock:^(BOOL success, NSString *notificationCount){
        if (success) {
            if (notificationCount.integerValue > 0) {
                [[[[[self tabBarController] tabBar] items] objectAtIndex:2] setBadgeValue:notificationCount];
            }
            else {
                [[[[[self tabBarController] tabBar] items] objectAtIndex:2] setBadgeValue:nil];
            }
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:notificationCount.integerValue];
        }
    }];
}
/*
- (void)logoutButtonClicked {
    self.tabBarController.selectedIndex = 0;
    self.tabBarController.tabBar.hidden = YES;
    
    OverViewViewController *overViewView = [self.storyboard instantiateViewControllerWithIdentifier:@"overViewView"];
    [self.navigationController setViewControllers:[NSArray arrayWithObjects:overViewView, nil] animated:NO];
}
*/
- (void)createEventButtonClicked {
    CreateEventViewController *createEvent = [self .storyboard instantiateViewControllerWithIdentifier:@"createEventView"];
    createEvent.title = @"What's Happening?";
    [self.navigationController pushViewController:createEvent animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL loggedIn = [defaults boolForKey:@"isloggedin"];
    if (loggedIn) {
        [self fetchNumberOfNotifcations];
        [self refreshEventlist];
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }
}

- (void)getUpcomingEvents{
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];

    [CoreDataInterface deleteAllObject:@"Events" andManagedOBC:appDelegate.managedObjectContext];

    
    if (self.refreshControl) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *title = [NSString stringWithFormat:@"Last updated: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor darkGrayColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;
    }
    
    NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    NSString *urlString = [NSString stringWithFormat:@"%@/user/%@/upcomingEvents",kwebUrl,uid];
    [UtilitiesHelper getResponseFor:nil url:[NSURL URLWithString:urlString] requestType:@"GET" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {
         [self.activityIndicator stopAnimating];
         [self.refreshControl endRefreshing];
         [[NSNotificationCenter defaultCenter] postNotificationName:@"kStopActivityIndicator" object:nil];
         if (success) {
                         //TODO : add key according to response
             [_activityIndicator stopAnimating];
             eventTableView.hidden = NO;
            [CoreDataInterface saveEventList:[jsonDict objectForKey:@"Events"]];
             _isRefreshed=YES;
             NSLog(@"isRefreshed %@",(_isRefreshed)?@"YES":@"NO");
             GeofenceMonitor  * gfm = [GeofenceMonitor sharedObj];
             _noRequest = FALSE;

            [self refreshEventlist];
         }
     }];
}

- (void)aloneView:(BOOL)value {
    [self.aloneLabel setHidden:value ];
    [self.aloneImage setHidden:value];
    [self.createAndInviteLabel setHidden:value];
}

-(void)inviteSingleFriend:(UIButton *)inviteForEventButton{
    Events *eventInfo = [self getEventsFromEventId:[NSString stringWithFormat:@"%ld",(long)inviteForEventButton.tag]];
    [_activityIndicator startAnimating];
    NSString *eventId=[eventInfo eventid];
    
    NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/event/invite/%@/%@",kwebUrl,eventId,uid];
    [UtilitiesHelper getResponseFor:_friendToInviteInfo url:[NSURL URLWithString:urlString] requestType:@"POST" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {
         [_activityIndicator stopAnimating];
         if (success) {
             
             [CoreDataInterface saveEventList:[NSArray arrayWithObjects:jsonDict,nil]];
             [CoreDataInterface saveAll];
             
             Events *updatedEventInfo = [self getEventsFromEventId:[NSString stringWithFormat:@"%@",[jsonDict objectForKey:@"id"]]];

             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hoothere" message:@"An invitation is sent successfully to your friend." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alertView show];
             [_activityIndicator stopAnimating];
             [self.navigationController popViewControllerAnimated:NO];
             self.tabBarController.selectedIndex = 0;
             [[NSNotificationCenter defaultCenter] postNotificationName:@"kloadEventDetailsAfterSingleInvitation" object:updatedEventInfo];
         }
     }];
}

- (void)loadInvitedDetailsView:(NSNotification *)notification {
    self.tabBarController.selectedIndex = 0;
    Events *eventInfo = notification.object;
    EventDetailsViewController *eventDetailsView = [self.storyboard instantiateViewControllerWithIdentifier:@"eventDetailsView"];
    eventDetailsView.eventId = eventInfo.eventid;
    eventDetailsView.thisEvent=eventInfo;
    
    eventDetailsView.statistics=[UtilitiesHelper stringToDictionary:[eventInfo statistics]];
    eventDetailsView.hostId=[[UtilitiesHelper stringToDictionary:[eventInfo user]] objectForKey:@"id"];
    eventDetailsView.eventStatus=eventInfo.guestStatus;
    eventDetailsView.hostData=[UtilitiesHelper stringToDictionary:[eventInfo user]];
    [self.navigationController pushViewController:eventDetailsView animated:YES];
}

-(void)refreshEventlist{

    _listOfEvents = [[NSMutableArray alloc] init];
    _listOfCheckedInEvents = [[NSMutableArray alloc] init];

    NSMutableArray *list =  [CoreDataInterface searchObjectsInContext:@"Events" andPredicate:nil andSortkey:@"startDateTime" isSortAscending:YES];
    
    for (int i = 0; i < list.count; i++) {
        Events *eventInfo = [list objectAtIndex:i];
        if ([eventInfo.eventid isEqualToString:@"0"]) {
            continue;
        }
        if ([eventInfo.guestStatus isEqualToString:@"HT"]) {
            [_listOfCheckedInEvents addObject:eventInfo];
        }
        else {
            [_listOfEvents addObject:eventInfo];
        }
    }
    if (_listOfEvents.count > 0 || _listOfCheckedInEvents.count > 0) {
        _noEvents = FALSE;
    }
    else {
        _noEvents = TRUE;
    }
    [eventTableView reloadData];
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark Tableview Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (_listOfEvents.count > 0 && _listOfCheckedInEvents.count > 0) {
        return 2;
    }
    else {
        return 1;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    /* Create custom view to display section header... */
    if (_noEvents || _noRequest) {
        return nil;
    }
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 2, tableView.frame.size.width, 18)];
    [label setFont:[UIFont boldSystemFontOfSize:12]];
    label.textColor = [UIColor grayColor];
    NSString *string;
    if (_listOfCheckedInEvents.count > 0 && _listOfEvents.count > 0) {
        if (section == 0) {
            string = @"Checked-In Events";
        }
        else {
            string = @"Upcoming Events";
        }
    }
    else if (_listOfCheckedInEvents.count > 0) {
        string = @"Checked-In Events";
    }
    else {
        string = @"Upcoming Events";
    }
    
    /* Section header is in 0th index... */
    [label setText:string];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0]]; //your background color...
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_noEvents && _noRequest) {
        return 0;
    }
    else if (_noEvents) {
        return 1;
    }
    else {
        if (_listOfEvents.count > 0 && _listOfCheckedInEvents.count > 0) {
            if (section == 0) {
                return _listOfCheckedInEvents.count;
            }
            else {
                return _listOfEvents.count;
            }
        }
        else if (_listOfCheckedInEvents.count > 0) {
            return [_listOfCheckedInEvents count];
        }
        else {
            return [_listOfEvents count];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomTableViewCell *cell;
    static NSString *cellIdentifier;
    
    if (_noEvents) {
        cellIdentifier = @"noEventsCell";
        cell = (CustomTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    else {
        NSMutableArray *eventArray;
        
        if (_listOfEvents.count > 0 && _listOfCheckedInEvents.count > 0) {
            if (indexPath.section == 0) {
                eventArray = [[NSMutableArray alloc] initWithArray:_listOfCheckedInEvents];
            }
            else {
                eventArray = [[NSMutableArray alloc] initWithArray:_listOfEvents];
            }
        }
        else if (_listOfCheckedInEvents.count > 0) {
            eventArray = [[NSMutableArray alloc] initWithArray:_listOfCheckedInEvents];
        }
        else {
            eventArray = [[NSMutableArray alloc] initWithArray:_listOfEvents];
        }
        
        Events *eventInfo = [eventArray objectAtIndex:indexPath.row];
        
        cellIdentifier = @"hooThereCell";
        cell = (CustomTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if([_fromWhereCalled isEqualToString:@"HT"]){
            cell.accessoryType=UITableViewCellAccessoryNone;
            [cell.inviteForEventButton addTarget:self action:@selector(inviteSingleFriend:) forControlEvents:UIControlEventTouchUpInside];
            cell.inviteForEventButton.hidden=NO;
            cell.inviteForEventButton.tag = eventInfo.eventid.integerValue;
            cell.sendFriendRequestButton.hidden=YES;
            cell.statusImage.hidden = YES;
        }
        else
        {
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            cell.inviteForEventButton.hidden=YES;
            cell.sendFriendRequestButton.hidden=NO;
            cell.statusImage.hidden = NO;
        }
        
        if (eventInfo.coverImage !=nil && ![eventInfo.coverImage isEqual:[NSNull null]]) {
            
            NSDictionary *coverInfo = [UtilitiesHelper stringToDictionary:eventInfo.coverImage];
            NSString *imageUrl = [coverInfo objectForKey:@"thumbnailUrl"];
            if (imageUrl !=nil && ![imageUrl isEqual:[NSNull null]]) {
                [cell.eventImageview sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"event_icon.png"]];
                cell.eventImageview.layer.cornerRadius = cell.eventImageview.frame.size.width/2;
                cell.eventImageview.layer.masksToBounds = YES;
            }
        }
        else {
            [cell.eventImageview setImage:[UIImage imageNamed:@"event_icon.png"]];
            cell.eventImageview.layer.cornerRadius = 0;
            cell.eventImageview.layer.masksToBounds = NO;
        }
        
        NSDate *startDateTime = [NSDate dateWithTimeIntervalSince1970:[eventInfo.startDateTime doubleValue]/1000.0];
        
        cell.sendFriendRequestButton.tag = eventInfo.eventid.integerValue;
        cell.hootHereButton.tag = eventInfo.eventid.integerValue;
        cell.invitedButton.tag = eventInfo.eventid.integerValue;
        cell.goingThereButton.tag = eventInfo.eventid.integerValue;
        
        NSString *invitedStatus = eventInfo.guestStatus;
        NSLog(@"invited status ******* %@",invitedStatus);
        if ([invitedStatus isEqualToString:@"I"]) {
            [cell.sendFriendRequestButton addTarget:self action:@selector(acceptEventButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//            [cell.sendFriendRequestButton setBackgroundImage:[UIImage imageNamed:@"pending.png"] forState:UIControlStateNormal];
            cell.statusImage.image = [UIImage imageNamed:@"pending.png"];
        }
        else {
//            [cell.sendFriendRequestButton setBackgroundImage:[UIImage imageNamed:@"accpted.png"] forState:UIControlStateNormal];
            cell.statusImage.image = [UIImage imageNamed:@"accpted.png"];
        }
        
        if([eventInfo user]!=nil )
        {
            NSDictionary *hostInfo= [UtilitiesHelper stringToDictionary:[eventInfo user]];
            cell.hostNameLabel.text=[hostInfo objectForKey:@"firstName"];
        }
        cell.placeButton.tag = eventInfo.eventid.integerValue;
        
        if([eventInfo statistics]!=nil)
        {
            NSDictionary *statistics=[UtilitiesHelper stringToDictionary:[eventInfo statistics]];
            cell.invitedLabel.text=[NSString stringWithFormat:@"%@ Invited", [statistics objectForKey:@"invitedCount"]];
            cell.invitedLabel.text=[NSString stringWithFormat:@"%@ Invited", [statistics objectForKey:@"invitedCount"]];
            
            cell.goingLabel.text=[NSString stringWithFormat:@"%@ Going There",[statistics objectForKey:@"acceptedCount"]];
            cell.hoothereLabel.text=[NSString stringWithFormat:@"%@ Hoo There",[statistics objectForKey:@"hoothereCount"]];
        }
        
        cell.eventPlaceLabel.text = eventInfo.venueName;
        cell.eventNameLabel.text = eventInfo.name;
        [cell.orgainserNameButton addTarget:self
                                     action:@selector(hostNameClicked:)
                           forControlEvents:UIControlEventTouchUpInside];
        
        cell.orgainserNameButton.tag = eventInfo.eventid.integerValue;
        
        cell.eventDateLabel.text = (eventInfo.startDateTime.integerValue!=0)?[NSString stringWithFormat:@"%@ at %@ ",[EventHelper changeDateFormat:startDateTime editing:NO],[EventHelper changeTimeFormat:startDateTime ]]:@"Date not specified";
    }
    return cell;
}

- (void)acceptEventButtonClicked:(UIButton *)acceptEventButton {
    
    Events *eventInfo = [self getEventsFromEventId:[NSString stringWithFormat:@"%ld",(long)acceptEventButton.tag]];
    
    if ([eventInfo.guestStatus isEqualToString:@"I"]) {
        NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
        NSString *urlString = [NSString stringWithFormat:@"%@/user/%@/event/%@/accept",kwebUrl,uid,eventInfo.eventid];
        NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    @"INVITED",@"channel",
                                    nil];
        [UtilitiesHelper getResponseFor:dictionary url:[NSURL URLWithString:urlString] requestType:@"PUT" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
         {
             
             if (success) {
                 eventInfo.guestStatus = @"A";
             NSMutableDictionary *statistics= [[UtilitiesHelper stringToDictionary:[eventInfo statistics]] mutableCopy];
             NSInteger goingThereCount = [[statistics objectForKey:@"acceptedCount"] integerValue]+1;
             
             [statistics setObject:[NSString stringWithFormat:@"%ld",(long)goingThereCount] forKey:@"acceptedCount"];
             eventInfo.statistics = [NSString stringWithFormat:@"%@",statistics];                 [CoreDataInterface saveAll];
                 [self refreshEventlist];
             }
         }];
    }
}

-(void)hostNameClicked:(UIButton *)button{

   
        
        
        
        MyProfileViewController *myProfileView = [self.storyboard instantiateViewControllerWithIdentifier:@"myProfileView"];
        
    
    
        //myProfileView.isHost=YES;
    
    Events *eventInfo = [self getEventsFromEventId:[NSString stringWithFormat:@"%ld",(long)button.tag]];
    
        myProfileView.friendData=[UtilitiesHelper stringToDictionary:eventInfo.user];
        myProfileView.friendId=[myProfileView.friendData objectForKey:@"id"];
    myProfileView.isFromNavigation = TRUE;

//     NSLog(@"friend %i , my id %i",[myProfileView.friendId integerValue],[[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"] integerValue]);
    if([myProfileView.friendId integerValue]==[[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"] integerValue]){
    myProfileView.isUser=YES;
    
    }
    else 
    {
     myProfileView.isUser=NO;
        
        NSPredicate* entitySearchPredicate = [NSPredicate predicateWithFormat:@"(friendId == %@)",myProfileView.friendId];
        
        NSArray *retData =  [CoreDataInterface searchObjectsInContext:@"Friends" andPredicate:entitySearchPredicate andSortkey:@"friendId" isSortAscending:YES];
        
        if(retData.count>0)
            myProfileView.isFriend=YES;
        else
            myProfileView.isFriend=NO;
    }
        NSLog(@"hostData .... %@",myProfileView.friendData);
//        self.navigationItem.title=@"";
    myProfileView.fromWhereCalled=@"HD";
        [self.navigationController pushViewController:myProfileView  animated:YES];
        
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(![_fromWhereCalled isEqualToString:@"HT"]){
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if (_noEvents || _noRequest) {
            return;
        }
    
        NSMutableArray *eventArray;
        
        if (_listOfEvents.count > 0 && _listOfCheckedInEvents.count > 0) {
            if (indexPath.section == 0) {
                eventArray = [[NSMutableArray alloc] initWithArray:_listOfCheckedInEvents];
            }
            else {
                eventArray = [[NSMutableArray alloc] initWithArray:_listOfEvents];
            }
        }
        else if (_listOfCheckedInEvents.count > 0) {
            eventArray = [[NSMutableArray alloc] initWithArray:_listOfCheckedInEvents];
        }
        else {
            eventArray = [[NSMutableArray alloc] initWithArray:_listOfEvents];
        }
        
        Events *eventInfo = [eventArray objectAtIndex:indexPath.row];

        NSLog(@"list of Events %@",_listOfEvents);
        
        EventDetailsViewController *eventDetailsView = [self.storyboard instantiateViewControllerWithIdentifier:@"eventDetailsView"];
        eventDetailsView.eventId = eventInfo.eventid;
        eventDetailsView.statistics=[UtilitiesHelper stringToDictionary:[eventInfo statistics]];
        eventDetailsView.hostName=[[UtilitiesHelper stringToDictionary:[eventInfo user]] objectForKey:@"firstName"];
        
        eventDetailsView.hostId=[[UtilitiesHelper stringToDictionary:[eventInfo user]] objectForKey:@"id"];
        eventDetailsView.eventStatus=eventInfo.guestStatus;
        NSLog(@"eventStatus %@ ....",eventInfo.guestStatus);
        eventDetailsView.hostData=[UtilitiesHelper stringToDictionary:[eventInfo user]];
        [self.navigationController pushViewController:eventDetailsView animated:YES];
    }
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_noEvents) {
        return eventTableView.frame.size.height;
    }
    return 136;
}

#pragma Mark Button Methods --------------


- (IBAction)hootHereButtonClicked:(UIButton *)sender {
    Events *eventInfo = [self getEventsFromEventId:[NSString stringWithFormat:@"%ld",(long)sender.tag]];
    
    SeeAllViewController *seeAllView = [self.storyboard instantiateViewControllerWithIdentifier:@"seeAllView"];
    seeAllView.tag=1000;
    seeAllView.eventId = eventInfo.eventid;
    seeAllView.statistics = [UtilitiesHelper stringToDictionary:[eventInfo statistics]];;
    [self.navigationController pushViewController:seeAllView animated:YES];
}
- (IBAction)goingThereButtonClicked:(UIButton *)sender {
    Events *eventInfo = [self getEventsFromEventId:[NSString stringWithFormat:@"%ld",(long)sender.tag]];
    
    SeeAllViewController *seeAllView = [self.storyboard instantiateViewControllerWithIdentifier:@"seeAllView"];
    seeAllView.tag=2000;
    seeAllView.eventId = eventInfo.eventid;
    seeAllView.statistics = [UtilitiesHelper stringToDictionary:[eventInfo statistics]];;
    [self.navigationController pushViewController:seeAllView animated:YES];
}
- (IBAction)invitedButtonClicked:(UIButton *)sender {
    Events *eventInfo = [self getEventsFromEventId:[NSString stringWithFormat:@"%ld",(long)sender.tag]];
    
    SeeAllViewController *seeAllView = [self.storyboard instantiateViewControllerWithIdentifier:@"seeAllView"];
    seeAllView.tag=3000;
    seeAllView.eventId = eventInfo.eventid;
    seeAllView.statistics = [UtilitiesHelper stringToDictionary:[eventInfo statistics]];;
    [self.navigationController pushViewController:seeAllView animated:YES];
}

- (IBAction)placeButtonClicked:(UIButton *)button {
    Events *eventInfo = [self getEventsFromEventId:[NSString stringWithFormat:@"%ld",(long)button.tag]];
    
    CLLocationDegrees latitude = [[eventInfo latitude] doubleValue];
    CLLocationDegrees longitude =[[eventInfo longitude] doubleValue];
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
    
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:centerCoordinate addressDictionary:nil];
    MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:placemark];
    item.name = eventInfo.venueName;
    [item openInMapsWithLaunchOptions:nil];
}

- (Events *)getEventsFromEventId:(NSString *)eventId {
    
    NSPredicate* entitySearchPredicate = [NSPredicate predicateWithFormat:@"(eventid == %@)",eventId];
    
    NSArray *retData =  [CoreDataInterface searchObjectsInContext:@"Events" andPredicate:entitySearchPredicate andSortkey:@"eventid" isSortAscending:YES];
    
    Events * eventInfo = [retData objectAtIndex:0];
    
    return eventInfo;
}


@end
