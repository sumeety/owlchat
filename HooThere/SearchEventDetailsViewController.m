//
//  SearchEventDetailsViewController.m
//  Hoothere
//
//  Created by Abhishek Tyagi on 06/01/15.
//  Copyright (c) 2015 Quovantis Technologies. All rights reserved.
//

#import "SearchEventDetailsViewController.h"
#import "UtilitiesHelper.h"
#import "ResizeImage.h"
#import "EventHelper.h"
#import <MapKit/MapKit.h>
#import "HooThereNavigationController.h"
#import "HomeViewController.h"
#import "EventDetailsViewController.h"
#import "UIImageView+WebCache.h"
#import "WhoThereViewController.h"
#import "SearchEventInfoViewController.h"
#import "EventAlbumViewController.h"

@interface SearchEventDetailsViewController ()

@end

@implementation SearchEventDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _imageViewArray=[[NSMutableArray alloc]init];
    hostImageView.layer.masksToBounds = YES;
    hostImageView.layer.cornerRadius = 20;
    
    joinButton.layer.cornerRadius=3;
    
    hostImageView.image=[UIImage imageNamed:@"defaultpic_small.png"];
    [self getEventDetails];
    [self getHostImage];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.tabBarController.tabBar.hidden = NO;
}

-(void)getHostImage{
    
    id imageName = [_hostData objectForKey:@"profile_picture" ];
    
    //    UIImage* image = [UIImage imageNamed:@"defaultpic.png"];
    //    cell.iconImageview.image= [ResizeImage squareImageWithImage:image scaledToSize:CGSizeMake(100, 100)];
    
    if (imageName != nil && ![imageName isEqual:[NSNull null]]) {
        NSString *imageUrl = [NSString stringWithFormat:@"%@/user/%@/thumbnail",kwebUrl,[_hostData objectForKey:@"id"]];
        [UtilitiesHelper getImageFromServer:[NSURL URLWithString:imageUrl] complettionBlock:^(BOOL success,UIImage *image)
         {
             if (success) {
                 hostImageView.image = [ResizeImage squareImageWithImage:image scaledToSize:CGSizeMake(100, 100)];
             }
         }];
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: @"searchEventInfoView"]) {
        SearchEventInfoViewController * searchEventInfoView = (SearchEventInfoViewController *) [segue destinationViewController];
        searchEventInfoView.thisEvent = [_thisEvent mutableCopy];
        searchEventInfoView.isPastEvent = _isPastEvent;
        searchEventInfoView.eventIndex = _eventIndex;
//        searchEventInfoView.can
    }
    if ([segueName isEqualToString: @"searchEventAlbum"]) {
        EventAlbumViewController * eventAlbumView = (EventAlbumViewController *) [segue destinationViewController];
        eventAlbumView.thisEvent = [_thisEvent mutableCopy];
        eventAlbumView.eventIndex = _eventIndex;
        eventAlbumView.canLoad = TRUE;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    self.tabBarController.tabBar.hidden = YES;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kDisablePanGestureRequest" object:nil userInfo:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getEventDetails {

    _hostName = [[_thisEvent objectForKey:@"user"] objectForKey:@"fullName"];
    _hostId = [[_thisEvent objectForKey:@"user"] objectForKey:@"id"];
    _hostData = [_thisEvent objectForKey:@"user"];
    _eventId = [_thisEvent objectForKey:@"id"];
    self.statistics = [_thisEvent objectForKey:@"statistics"];
    
//    eventNameLabel.text = [_thisEvent objectForKey:@"name"];
    hostNameLabel.text = _hostName;
    if ([_thisEvent objectForKey:@"venueName"] != nil && ![[_thisEvent objectForKey:@"venueName"] isEqual:[NSNull null]]) {
        locationNameLabel.text = [_thisEvent objectForKey:@"venueName"];
    }
    else {
        locationNameLabel.text = @"";
    }
    
    NSString *startString = [_thisEvent objectForKey:@"startDateTime"];
    
    if (startString == nil || [startString isEqual:[NSNull null]] ) {
        startString = @"0";
    }
    
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:[startString doubleValue]/1000.0];
    
    if([startString doubleValue]!=0) {
        eventStartDateLabel.text = [NSString stringWithFormat:@"%@ at %@",[EventHelper changeDateFormat:startDate editing:NO],[EventHelper changeTimeFormat:startDate]];
    }
    else {
        eventStartDateLabel.text = @"Date not specified";
    }
        
    [self setCountForGuestLabel];
    
    NSDictionary *eventDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:_thisEvent,@"event",[NSNumber numberWithBool:_isPastEvent],@"pastEvent",[NSNumber numberWithInteger:_eventIndex],@"eventIndex", nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kLoadSearchEventDetailsInformation" object:eventDictionary userInfo:nil];
}

- (void)setCountForGuestLabel {
    lblHooThere.text = [NSString stringWithFormat:@"%@",[self.statistics objectForKey:@"hoothereCount"]];
    
    lblGoingThere.text = [NSString stringWithFormat:@"%@",[self.statistics objectForKey:@"acceptedCount"]];
    lblInvited.text = [NSString stringWithFormat:@"%@",[self.statistics objectForKey:@"invitedCount"]];
    lblHooCame.text = [NSString stringWithFormat:@"%@",[self.statistics objectForKey:@"hooCameCount"]];
}

#pragma Mark for Segue ------------------

- (IBAction)detailInfoButtonClicked:(id)sender {
    albumView.hidden = YES;
    detailInfoView.hidden = NO;
    detailsInfoIcon.image = [UIImage imageNamed:@"info_icon_fill.png"];
    albumIcon.image = [UIImage imageNamed:@"gallery_icon.png"];
}

- (IBAction)locationButtonClicked:(id)sender {
    CLLocationDegrees latitude = [[_thisEvent objectForKey:@"latitude"] doubleValue];
    CLLocationDegrees longitude =[[_thisEvent objectForKey:@"longitude"] doubleValue];
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
    
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:centerCoordinate addressDictionary:nil];
    MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:placemark];
    item.name = [_thisEvent objectForKey:@"venueName"];
    [item openInMapsWithLaunchOptions:nil];
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
    seeAllView.eventId = [_thisEvent objectForKey:@"id"];
    seeAllView.statistics = self.statistics;
    [self.navigationController pushViewController:seeAllView animated:YES];
}

- (IBAction)organiserNameClicked:(id)sender {
    
    
    
    MyProfileViewController *myProfileView = [self.storyboard instantiateViewControllerWithIdentifier:@"myProfileView"];
    
    
    myProfileView.friendData=self.hostData;
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
        
        if(retData.count>0)
            myProfileView.isFriend=YES;
        else
            myProfileView.isFriend=NO;
    }
    NSLog(@"hostData .... %@",myProfileView.friendData);
    //        self.navigationItem.title=@"";
    myProfileView.fromWhereCalled=@"ED";
    myProfileView.eventId=_eventId;
    myProfileView.statistics=_statistics;
    myProfileView.hostId=[_hostData objectForKey:@"id"];
    myProfileView.hostName= [_hostData objectForKey:@"fullName"];
    
    [self.navigationController pushViewController:myProfileView  animated:YES];
    
}

@end
