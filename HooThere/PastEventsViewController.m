//
//  PastEventsViewController.m
//  Hoothere
//
//  Created by Abhishek Tyagi on 29/01/15.
//  Copyright (c) 2015 Quovantis Technologies. All rights reserved.
//

#import "PastEventsViewController.h"
#import "CustomTableViewCell.h"
#import "EventHelper.h"
#import "SearchEventDetailsViewController.h"
#import <MapKit/MapKit.h>
#import "UIImageView+WebCache.h"

@interface PastEventsViewController ()

@end

@implementation PastEventsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateEventList:) name:@"kUpdateListOfSearchAndPastEvents" object:nil];

    // Do any additional setup after loading the view.
    _activityIndicator = [UtilitiesHelper loadCustomActivityIndicatorWithYorigin:self.view.center.y -80 Xorigin:self.view.center.x-50];
    [self.view addSubview:_activityIndicator];
    [self.view bringSubviewToFront:_activityIndicator];
    
    [self getPastEventsList];
}

- (void)updateEventList:(NSNotification *)notification {
    NSDictionary *notificationObject = notification.object;
    
    NSDictionary *eventInfo = [notificationObject objectForKey:@"event"];
    NSInteger eventIndex = [[notificationObject objectForKey:@"eventIndex"] integerValue];
    
    [_listOfEvents replaceObjectAtIndex:eventIndex withObject:eventInfo];
    [self.tableView reloadData];
}

- (void)getPastEventsList {
    [_activityIndicator startAnimating];
    NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/user/%@/pastEvents",kwebUrl,uid];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [UtilitiesHelper getResponseFor:nil url:[NSURL URLWithString:urlString] requestType:@"GET" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {
         [_activityIndicator stopAnimating];
         if (success) {
             
             _listOfEvents = [[NSMutableArray alloc] initWithArray:[jsonDict objectForKey:@"Events"]];
             
             if (!_listOfEvents.count > 0) {
                 _noEvents = TRUE;
             }
             else {
                 _noEvents = FALSE;
             }
             [self.tableView reloadData];
             NSLog(@"List of friends %@",_listOfEvents);
             [self.activityIndicator stopAnimating];
         }
     }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (_noEvents) {
        return 1;
    }
    else {
        return [_listOfEvents count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomTableViewCell *cell;
    static NSString *cellIdentifier;
    if (_noEvents) {
        cellIdentifier = @"noEventsCell";
        cell = (CustomTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    else {
        cellIdentifier = @"hooThereCell";
        cell = (CustomTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        NSDictionary *eventInfo = [_listOfEvents objectAtIndex:indexPath.row];
        NSLog(@"Crash at row : %ld and %@",(long)indexPath.row,[eventInfo objectForKey:@"id"]);

        if ([eventInfo objectForKey:@"name"] != nil && ![[eventInfo objectForKey:@"name"] isEqual:[NSNull null]]) {
            cell.eventNameLabel.text = [eventInfo objectForKey:@"name"];
        }
        else {
            cell.eventNameLabel.text = @"";
        }
        cell.eventHostNameLabel.text = [[eventInfo objectForKey:@"user"] objectForKey:@"fullName"];
        cell.hootHereButton.tag = indexPath.row;
        cell.invitedButton.tag = indexPath.row;
        cell.goingThereButton.tag = indexPath.row;
        cell.placeButton.tag = indexPath.row;
        cell.orgainserNameButton.tag = indexPath.row;
        if ([eventInfo objectForKey:@"venueName"] != nil && ![[eventInfo objectForKey:@"venueName"] isEqual:[NSNull null]]) {
            cell.eventPlaceLabel.text = [eventInfo objectForKey:@"venueName"];
        }
        else {
            cell.eventPlaceLabel.text = @"";
        }
        
        NSDictionary *statistics = [eventInfo objectForKey:@"statistics"];
        
        cell.invitedLabel.text=[NSString stringWithFormat:@"%@ Invited", [statistics objectForKey:@"invitedCount"]];
        
        cell.goingLabel.text=[NSString stringWithFormat:@"%@ Going There",[statistics objectForKey:@"acceptedCount"]];
        cell.hoothereLabel.text=[NSString stringWithFormat:@"%@ Hoo Came",[statistics objectForKey:@"hooCameCount"]];
        NSDate *startDateTime;
        if ([eventInfo objectForKey:@"startDateTime"] != nil && ![[eventInfo objectForKey:@"startDateTime"] isEqual:[NSNull null]]) {
            startDateTime = [NSDate dateWithTimeIntervalSince1970:[[eventInfo objectForKey:@"startDateTime"] doubleValue]/1000.0];
            cell.eventDateLabel.text = ([[eventInfo objectForKey:@"startDateTime"] integerValue]!=0)?[NSString stringWithFormat:@"%@ at %@ ",[EventHelper changeDateFormat:startDateTime editing:NO],[EventHelper changeTimeFormat:startDateTime ]]:@"Date not specified";
        }
        else {
            cell.eventDateLabel.text = @"Date not specified";
        }
        
        NSDictionary *coverInfo = [eventInfo objectForKey:@"coverImage"];
        if (coverInfo !=nil && ![coverInfo isEqual:[NSNull null]]) {
            
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
        
        cell.statusLabel.hidden = YES;
        cell.inviteForEventButton.hidden = YES;
        cell.inviteForEventButton.tag = indexPath.row;
        
        NSString *guestStatus = [eventInfo objectForKey:@"guestStatus"];
        
        if ([guestStatus isEqual:[NSNull null]] || guestStatus == nil || [guestStatus isEqualToString:@""]) {
            cell.inviteForEventButton.hidden = NO;
            cell.statusImage.hidden= YES;
        }
        else if ([guestStatus isEqualToString:@"I"]) {
            cell.statusImage.hidden=NO;
            cell.statusImage.image=[UIImage imageNamed:@"pastInvited.png"];
        }
        else if ([guestStatus isEqualToString:@"A"]) {
            cell.statusImage.hidden=NO;
            cell.statusImage.image=[UIImage imageNamed:@"pastAccepted.png"];
        }
        else if([guestStatus isEqualToString:@"HC"]) {
            cell.statusImage.hidden=NO;
            cell.statusImage.image=[UIImage imageNamed:@"pastWent-there.png"];
        }
        else{
            
        }
        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_noEvents) {
        return;
    }
    NSDictionary *eventInfo = [_listOfEvents objectAtIndex:indexPath.row];
        
    SearchEventDetailsViewController *searchEventDetailsView = [self.storyboard instantiateViewControllerWithIdentifier:@"searchEventDetailsView"];
    searchEventDetailsView.title = @"Event Details";
    searchEventDetailsView.thisEvent = eventInfo;
    searchEventDetailsView.isPastEvent = YES;
    searchEventDetailsView.eventIndex = indexPath.row;
    [self.navigationController pushViewController:searchEventDetailsView animated:YES];
        return;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_noEvents) {
        return 44;
    }
    return 136;
}

#pragma Mark Button Methods --------------


- (IBAction)hooCameButtonClicked:(UIButton *)sender {
    NSDictionary *eventInfo = [_listOfEvents objectAtIndex:sender.tag];
    NSString *eventId = [NSString stringWithFormat:@"%@",[eventInfo objectForKey:@"id"]];
    [self loadSeeAllViewForEventId:eventId statistics:[eventInfo objectForKey:@"statistics"] tag:4000];
}
- (IBAction)goingThereButtonClicked:(UIButton *)sender {
    NSDictionary *eventInfo = [_listOfEvents objectAtIndex:sender.tag];
    
    NSString *eventId = [NSString stringWithFormat:@"%@",[eventInfo objectForKey:@"id"]];
    [self loadSeeAllViewForEventId:eventId statistics:[eventInfo objectForKey:@"statistics"] tag:2000];
}
- (IBAction)invitedButtonClicked:(UIButton *)sender {
    NSDictionary *eventInfo = [_listOfEvents objectAtIndex:sender.tag];
    
    NSString *eventId = [NSString stringWithFormat:@"%@",[eventInfo objectForKey:@"id"]];
    [self loadSeeAllViewForEventId:eventId statistics:[eventInfo objectForKey:@"statistics"] tag:3000];
}

- (void)loadSeeAllViewForEventId:(NSString *)eventId statistics:(NSDictionary *)statistics tag:(NSInteger)tag {
    SeeAllViewController *seeAllView = [self.storyboard instantiateViewControllerWithIdentifier:@"seeAllView"];
    seeAllView.tag=tag;
    seeAllView.eventId = eventId;
    seeAllView.statistics = statistics;
    [self.navigationController pushViewController:seeAllView animated:YES];
}

- (IBAction)organiserNameClicked:(UIButton *)button {
    MyProfileViewController *myProfileView = [self.storyboard instantiateViewControllerWithIdentifier:@"myProfileView"];
    
    NSDictionary *eventInfo = [_listOfEvents objectAtIndex:button.tag];
    
    myProfileView.friendData=[eventInfo objectForKey:@"user"];
    myProfileView.isFromNavigation = TRUE;
    myProfileView.friendId=[[eventInfo objectForKey:@"user"] objectForKey:@"id"];
    //     NSLog(@"friend %i , my id %i",[myProfileView.friendId integerValue],[[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"] integerValue]);
    if([myProfileView.friendId integerValue]==[[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"] integerValue]){
        myProfileView.isUser=YES;
    }
    else
    {
        myProfileView.isUser=NO;
        NSPredicate* entitySearchPredicate = [NSPredicate predicateWithFormat:@"(friendId == %@)",[[eventInfo objectForKey:@"user"] objectForKey:@"id"]];
        
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

- (IBAction)placeButtonClicked:(UIButton *)button {
    NSDictionary *eventInfo = [_listOfEvents objectAtIndex:button.tag];
    
    CLLocationDegrees latitude = [[eventInfo objectForKey:@"latitude"] doubleValue];
    CLLocationDegrees longitude =[[eventInfo objectForKey:@"longitude"] doubleValue];
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
    
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:centerCoordinate addressDictionary:nil];
    MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:placemark];
    item.name = [eventInfo objectForKey:@"venueName"];
    [item openInMapsWithLaunchOptions:nil];
    //    NSString *urlString = [NSString stringWithFormat:@"http://maps.apple.com/?ll=%@,%@&z=13",eventInfo.latitude,eventInfo.longitude];
    //    NSURL *url = [NSURL URLWithString:urlString];
    //    [[UIApplication sharedApplication] openURL:url];
}

@end
