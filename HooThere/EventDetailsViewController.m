 //
//  EventDetailsViewController.m
//  HooThere
//
//  Created by Abhishek Tyagi on 10/10/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import "EventDetailsViewController.h"
#import "EditEventViewController.h"
#import "EventHelper.h"
#import "ResizeImage.h"
#import "HomeViewController.h"
#import <MapKit/MapKit.h>
#import "UIImageView+WebCache.h"
#import "WhoThereViewController.h"
#import "EventInfoViewController.h"
#import "EventAlbumViewController.h"
#import "SearchEventDetailsViewController.h"
#import "GroupChatViewController.h"
@interface EventDetailsViewController ()

@end

@implementation EventDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCountForGuestLabel:) name:@"kUpdateCountForGuestStatus" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCountForGuestLabel:) name:@"kAutoCheckInCheckOutHappened" object:nil];

    // Do any additional setup after loading the view.
    _imageViewArray=[[NSMutableArray alloc]init];
    hostImageView.layer.masksToBounds = YES;
    hostImageView.layer.cornerRadius = 20;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        _activityIndicator = [UtilitiesHelper loadCustomActivityIndicatorWithYorigin:self.view.center.y -80 Xorigin:self.view.center.x-50];
    }
    else {
        _activityIndicator = [UtilitiesHelper loadCustomActivityIndicatorWithYorigin:self.view.center.x-80 Xorigin:self.view.center.y -50];
    }
    [self.view addSubview:_activityIndicator];
    [self.view bringSubviewToFront:_activityIndicator];
    
    
    
//    if (_getEventFromServer) {
//        [self getEventDetailsFromServer];
//        hostNameLabel.hidden = YES;
//    }
//    else {
        [self getEventDetails];
        [self getHostImage];
        hostNameLabel.text = self.hostName;
//    }
    
    acceptButton.layer.cornerRadius=3;
    inviteFriendsButton.layer.cornerRadius=3;
    
    hostImageView.image=[UIImage imageNamed:@"defaultpic_small.png"];
}

- (BOOL)checkEventIsPastEvent:(double)endDateTime {
    BOOL isPastEvent = FALSE;
    NSDate *date  = [NSDate date];
    double today = [date timeIntervalSince1970] * 1000;
    if (endDateTime < 0) {
        endDateTime = endDateTime * (-1);
    }
    if (today > endDateTime) {
        isPastEvent = TRUE;
    }
    return isPastEvent;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.tabBarController.tabBar.hidden = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kDisablePanGestureRequest" object:nil userInfo:nil];
    
//    NSPredicate* entitySearchPredicate = [NSPredicate predicateWithFormat:@"(eventid == %@)",self.eventId];
//    
//    NSArray *retData =  [CoreDataInterface searchObjectsInContext:@"Events" andPredicate:entitySearchPredicate andSortkey:@"eventid" isSortAscending:YES];
//    
//    if (retData.count > 0) {
//        _thisEvent = [retData objectAtIndex:0];
//        
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"kLoadEventDetailsInformation" object:_thisEvent userInfo:nil];
//    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    if (_getEventFromServer) {
//        return;
//    }
    NSPredicate* entitySearchPredicate = [NSPredicate predicateWithFormat:@"(eventid == %@)",self.eventId];
    
    NSArray *retData =  [CoreDataInterface searchObjectsInContext:@"Events" andPredicate:entitySearchPredicate andSortkey:@"eventid" isSortAscending:YES];
    
    if (retData.count > 0) {
        _thisEvent = [retData objectAtIndex:0];
   }
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: @"infoEmbedded"]) {
        EventInfoViewController * eventInfoView = (EventInfoViewController *) [segue destinationViewController];
        eventInfoView.thisEvent = _thisEvent;
        eventInfoView.canLoad = TRUE;
//        eventInfoView.thisEvent =
        // do something with the AlertView's subviews here...
    }
    if ([segueName isEqualToString: @"eventAlbum"]) {
        EventAlbumViewController * eventAlbumView = (EventAlbumViewController *) [segue destinationViewController];
        NSMutableDictionary *eventInfo = [[UtilitiesHelper setUserDetailsDictionaryFromCoreDataWithInfo:_thisEvent type:nil] mutableCopy] ;
        [eventInfo setObject:_thisEvent.eventid forKey:@"id"];
        eventAlbumView.thisEvent = eventInfo;
        eventAlbumView.canLoad = TRUE;
        // do something with the AlertView's subviews here...
    }
}

- (void)getEventDetails {
    NSPredicate* entitySearchPredicate = [NSPredicate predicateWithFormat:@"(eventid == %@)",self.eventId];
    
    NSArray *retData =  [CoreDataInterface searchObjectsInContext:@"Events" andPredicate:entitySearchPredicate andSortkey:@"eventid" isSortAscending:YES];
    
    if (retData.count > 0) {
        _thisEvent = [retData objectAtIndex:0];

        locationNameLabel.text = _thisEvent.venueName;
        
        NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:[_thisEvent.startDateTime doubleValue]/1000.0];

        if(_thisEvent.startDateTime.doubleValue!=0) {
            eventStartDateLabel.text = [NSString stringWithFormat:@"%@ at %@",[EventHelper changeDateFormat:startDate editing:NO],[EventHelper changeTimeFormat:startDate]];
        }
        else {
            eventStartDateLabel.text = @" ";
        }
        [self setCountForGuestLabel];
        
        NSString *uid = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"]];

        if ([uid isEqualToString:self.hostId]) {
            UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editButtonClicked)];
            self.navigationItem.rightBarButtonItem = editButton;
        }
    }
}

- (void)setCountForGuestLabel {
    lblHooThere.text = [NSString stringWithFormat:@"%@",[self.statistics objectForKey:@"hoothereCount"]];
    
    lblGoingThere.text = [NSString stringWithFormat:@"%@",[self.statistics objectForKey:@"acceptedCount"]];
    lblInvited.text = [NSString stringWithFormat:@"%@",[self.statistics objectForKey:@"invitedCount"]];
    lblHooCame.text = [NSString stringWithFormat:@"%@",[self.statistics objectForKey:@"hooCameCount"]];
}

- (void)updateCountForGuestLabel:(NSNotification *)notification {
    NSDictionary *stats = notification.object;
    
    if ([_thisEvent.eventid isEqualToString:[stats objectForKey:@"id"]]) {
        self.statistics = stats;
        [self setCountForGuestLabel];
    }
}

-(void)getHostImage{
    id imageName = [_hostData objectForKey:@"profile_picture" ];
    UIImage* defaultImage = [UIImage imageNamed:@"defaultpic_small.png"];

    if (imageName != nil && ![imageName isEqual:[NSNull null]]) {
        NSString *imageUrl = [NSString stringWithFormat:@"%@/user/%@/thumbnail",kwebUrl,[_hostData objectForKey:@"id"]];
        [hostImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:defaultImage];
    }
}

-(BOOL) checkHostAndUserRelation{
    NSString *userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    NSInteger userInt=[userId integerValue];
    NSInteger hostInt=[self.hostId integerValue];
    if(userInt==hostInt )
        return YES;
    else
        return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)editButtonClicked {
    EditEventViewController *editEventView = [self.storyboard instantiateViewControllerWithIdentifier:@"editEventView"];
    editEventView.thisEvent = _thisEvent;
    
    [self.navigationController pushViewController:editEventView animated:YES];
}

- (IBAction)detailInfoButtonClicked:(id)sender {
    albumView.hidden = YES;
    detailInfoView.hidden = NO;
    detailsInfoIcon.image = [UIImage imageNamed:@"info_icon_fill.png"];
    albumIcon.image = [UIImage imageNamed:@"gallery_icon.png"];
}

- (IBAction)albumButtonClicked:(id)sender {
    albumView.hidden = NO;
    detailInfoView.hidden = YES;
    detailsInfoIcon.image = [UIImage imageNamed:@"info_icon.png"];
    albumIcon.image = [UIImage imageNamed:@"gallery_icon_fill.png"];
}

- (IBAction)friendsButtonClicked:(UIButton *)button {
    
    SeeAllViewController *seeAllView = [self.storyboard instantiateViewControllerWithIdentifier:@"seeAllView"];
    seeAllView.tag = button.tag;
    seeAllView.eventId = _thisEvent.eventid;
    seeAllView.statistics = self.statistics;
    [self.navigationController pushViewController:seeAllView animated:YES];
}

- (IBAction)locationButtonClicked:(id)sender {
    CLLocationDegrees latitude = [[_thisEvent latitude] doubleValue];
    CLLocationDegrees longitude =[[_thisEvent longitude] doubleValue];
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
    
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:centerCoordinate addressDictionary:nil];
    MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:placemark];
    item.name = _thisEvent.venueName;
    [item openInMapsWithLaunchOptions:nil];
}

- (IBAction)organiserNameClicked:(id)sender {
    MyProfileViewController *myProfileView = [self.storyboard instantiateViewControllerWithIdentifier:@"myProfileView"];
        
    NSLog(@"Host Data : %@",_hostData);
    myProfileView.friendData = _hostData;
    myProfileView.isFromNavigation = TRUE;
    myProfileView.friendId=[myProfileView.friendData objectForKey:@"id"];
    if([myProfileView.friendId integerValue]==[[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"] integerValue]){
        myProfileView.isUser=YES;
    }
    else
    {
        myProfileView.isUser=NO;
            
        NSPredicate* entitySearchPredicate = [NSPredicate predicateWithFormat:@"(friendId == %@)",myProfileView.friendId];
            
        NSArray *retData =  [CoreDataInterface searchObjectsInContext:@"Friends" andPredicate:entitySearchPredicate andSortkey:@"friendId" isSortAscending:YES];
            
        if(retData.count>0){
            myProfileView.isFriend=YES;}
        else {
            myProfileView.isFriend=NO;}
    }
        NSLog(@"hostData .... %@",myProfileView.friendData);

    myProfileView.fromWhereCalled=@"ED";
    myProfileView.eventId=_eventId;
    myProfileView.statistics=_statistics;
    myProfileView.hostId=_hostId;
    myProfileView.hostName=_hostName;
    
    [self.navigationController pushViewController:myProfileView  animated:YES];
         
}

@end
