//
//  EventInfoViewController.m
//  Hoothere
//
//  Created by Abhishek Tyagi on 20/01/15.
//  Copyright (c) 2015 Quovantis Technologies. All rights reserved.
//

#import "EventInfoViewController.h"
#import "EventHelper.h"
#import <MapKit/MapKit.h>
#import "UtilitiesHelper.h"
#import "EventDetailsViewController.h"
#import "WhoThereViewController.h"
#import "NotificationViewController.h"

@interface EventInfoViewController ()

@end

@implementation EventInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getEventDetails:) name:@"kLoadEventDetailsInformation" object:nil];
    
    _activityIndicator = [UtilitiesHelper loadCustomActivityIndicatorWithYorigin:50 Xorigin:self.view.center.x-50];
    [self.view addSubview:_activityIndicator];
    [self.view bringSubviewToFront:_activityIndicator];
    // Do any additional setup after loading the view.
    if (_canLoad) {
        [self getEventDetails];
    }
    else {
        acceptButton.hidden = YES;
        inviteFriendsButton.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
}

//- (void)removeAllSubviews {
//    for (id subview in _scrollView.subviews) {
//        <#statements#>
//    }
//}

- (void)getEventDetails {
//    [self removeAllSubviews];

//    _thisEvent = notification.object;
    eventNameLabel.text = _thisEvent.name;
    self.statistics=[UtilitiesHelper stringToDictionary:[_thisEvent statistics]];
    self.hostData=[UtilitiesHelper stringToDictionary:[_thisEvent user]];
    self.hostId=[[UtilitiesHelper stringToDictionary:[_thisEvent user]] objectForKey:@"id"];
    [self validateAcceptAndCheckInButtons];
    [self createCustomViewForEventDetails];
}

- (void)validateAcceptAndCheckInButtons {
    if([self checkHostAndUserRelation]) {
//        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleDone target:self action:@selector(editButtonClicked)];
//        self.navigationItem.rightBarButtonItem = editButton;
        
        [self changeAcceptToCheckInButton];
    }
    else {
        self.navigationItem.rightBarButtonItem=nil;
        
        if(![_thisEvent.guestStatus isEqualToString:@"I"]) {
            acceptButton.titleLabel.textColor=[UIColor redColor];
            [self changeAcceptToCheckInButton];
        }
        else{
            [acceptButton setTitle:@"Accept" forState:UIControlStateNormal];
            [acceptButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            acceptButton.layer.backgroundColor=[[UIColor alloc] initWithRed:0.255f green:0.815f blue:0.43f alpha:1.0f] .CGColor;
            acceptButton.layer.borderWidth=0.0f;
        }
    }
}

-(void) changeAcceptToCheckInButton{
    [acceptButton setTitle:@"Check-In" forState:UIControlStateNormal];
    [acceptButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    acceptButton.layer.backgroundColor=[UIColor whiteColor].CGColor;
    acceptButton.layer.borderWidth=1.0f;
    
    double startDateTime = [_thisEvent.startDateTime doubleValue];
    BOOL isEventStart = [self checkEventIsStartedOrNot:startDateTime];
    if (!isEventStart) {
        acceptButton.alpha = 1;
        acceptButton.enabled = YES;
        acceptButton.layer.borderColor=[UIColor grayColor].CGColor;
    }
    else {
        acceptButton.alpha = 1;
        acceptButton.enabled = YES;
        acceptButton.layer.borderColor=[UIColor purpleColor].CGColor;
    }
    
    if ([_thisEvent.guestStatus isEqualToString:@"HT"]) {
        [acceptButton setTitle:@"Checked-In" forState:UIControlStateNormal];
        acceptButton.alpha = 0.5;
        acceptButton.enabled = NO;
        acceptButton.layer.borderColor=[UIColor grayColor].CGColor;
    }
}

- (BOOL)checkEventIsStartedOrNot:(double)startDateTime {
    BOOL isEventStart = FALSE;
    NSDate *date  = [NSDate date];
    double today = [date timeIntervalSince1970] * 1000;
    if (today > startDateTime) {
        isEventStart = TRUE;
    }
    return isEventStart;
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

- (void)createCustomViewForEventDetails {
    
    float yOrigin = 35;//176;
    //Creating Description label.......
    if (_thisEvent.eventDescription.length > 0) {
        CGFloat descriptionLabelHeight = [self heigthWithWidth:290 andFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14] string:_thisEvent.eventDescription];
        [_scrollView addSubview:[self createLabelOfSize:CGRectMake(15, yOrigin, 290, descriptionLabelHeight) text:_thisEvent.eventDescription font:[UIFont fontWithName:@"HelveticaNeue-Light" size:14] fontColor:[UIColor grayColor] alignment:NSTextAlignmentLeft]];
        
        yOrigin = yOrigin + descriptionLabelHeight + 15;
    }
    
    if ([_thisEvent.eventType isEqualToString:@"PUB"]) {
        [self createEventTypeView:@"Public Event" yOrigin:yOrigin imageName:@"public_event.png"];
    }
    else {
        [self createEventTypeView:@"Private Event" yOrigin:yOrigin imageName:@"private_event.png"];
    }
    yOrigin = yOrigin + 25;

    if (_thisEvent.address.length > 0) {
        [self createAddressLabelWithButton:yOrigin];
        CGFloat locationLabelHeight = [self heigthWithWidth:240 andFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:13] string:_thisEvent.address];
        
        yOrigin = yOrigin + locationLabelHeight + 25;
    }
    //Creating Place View.......
    
    // Creating Time View
    [self createTimeView:yOrigin];

//    yOrigin = yOrigin + 20;
//    
//    [self createEndTimeView:yOrigin];
    
    yOrigin = yOrigin + 60;
    
    _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, yOrigin);
    [_scrollView flashScrollIndicators];
}

- (void)createEventTypeView:(NSString *)text yOrigin:(float)yOrigin imageName:(NSString *)imageName {
    [_scrollView addSubview:[self createImageViewOfSize:CGRectMake(15, yOrigin+3, 12, 12) image:[UIImage imageNamed:imageName] cornerRadius:0 alpha:1 backgroundColor:[UIColor clearColor]]];
    [_scrollView addSubview:[self createLabelOfSize:CGRectMake(30, yOrigin, 240, 18) text:text font:[UIFont fontWithName:@"HelveticaNeue-Light" size:13] fontColor:[UIColor darkGrayColor] alignment:NSTextAlignmentLeft]];
}

- (void)createAddressLabelWithButton:(float)yOrigin {
    if (!_thisEvent.address.length > 0) {
        return;
    }
    //Creating Location Button
    CGFloat venueLabelHeight = [self heigthWithWidth:240 andFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:13] string:[NSString stringWithFormat:@"%@",_thisEvent.venueName]];
    CGFloat locationLabelHeight = [self heigthWithWidth:240 andFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12] string:[NSString stringWithFormat:@"%@",_thisEvent.address]];

    UIButton *locationButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    locationButton.frame = CGRectMake(15, yOrigin, 290, locationLabelHeight);
    [locationButton addTarget:self action:@selector(locationButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:locationButton];
    //Creating Location Imageview.......
    
    [_scrollView addSubview:[self createImageViewOfSize:CGRectMake(15, yOrigin+3, 10, 10) image:[UIImage imageNamed:@"location.png"] cornerRadius:0 alpha:1 backgroundColor:[UIColor clearColor]]];
    
    //Creating Location label.......
    [_scrollView addSubview:[self createLabelOfSize:CGRectMake(30, yOrigin, 240, venueLabelHeight) text:[NSString stringWithFormat:@"%@",_thisEvent.venueName] font:[UIFont fontWithName:@"HelveticaNeue-Light" size:13] fontColor:[UIColor colorWithRed:89/255.0 green:152/255.0 blue:205/255.0 alpha:1] alignment:NSTextAlignmentLeft]];
    
    [_scrollView addSubview:[self createLabelOfSize:CGRectMake(30, yOrigin+4+venueLabelHeight, 240, locationLabelHeight) text:[NSString stringWithFormat:@"%@",_thisEvent.address] font:[UIFont fontWithName:@"HelveticaNeue-Light" size:12] fontColor:[UIColor grayColor] alignment:NSTextAlignmentLeft]];
}

- (void)locationButtonClicked {
    CLLocationDegrees latitude = [[_thisEvent latitude] doubleValue];
    CLLocationDegrees longitude =[[_thisEvent longitude] doubleValue];
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
    
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:centerCoordinate addressDictionary:nil];
    MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:placemark];
    item.name = _thisEvent.venueName;
    [item openInMapsWithLaunchOptions:nil];
}

- (void)createTimeView:(float)yOrigin {
    //Creating Time Imageview
    [_scrollView addSubview:[self createImageViewOfSize:CGRectMake(15, yOrigin+2, 10, 10) image:[UIImage imageNamed:@"time.png"] cornerRadius:0 alpha:1 backgroundColor:[UIColor clearColor]]];
    
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:[_thisEvent.startDateTime doubleValue]/1000.0];
    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:[_thisEvent.endDateTime doubleValue]/1000.0];
    
    NSString *dateTimeString = (_thisEvent.startDateTime.integerValue!=0)?[NSString stringWithFormat:@"%@ at %@ till %@ at %@",[EventHelper changeDateFormat:startDate editing:NO],[EventHelper changeTimeFormat:startDate],[EventHelper changeDateFormat:endDate editing:NO],[EventHelper changeTimeFormat:endDate]]:@"Date not specified";
    
    CGFloat dateTimeHeightLabel = [self heigthWithWidth:290 andFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12] string:dateTimeString];

    //Creating Time label.......
    UILabel *dateTimeLabel = [self createLabelOfSize:CGRectMake(30, yOrigin, 290, dateTimeHeightLabel) text:dateTimeString font:[UIFont fontWithName:@"HelveticaNeue-Light" size:12] fontColor:[UIColor grayColor] alignment:NSTextAlignmentLeft];
    
    NSRange range = [dateTimeString rangeOfString:@"till"];
    if (range.location == NSNotFound) {
        NSLog(@"string was not found");
        dateTimeLabel.text = dateTimeString;
    } else {
        NSLog(@"position %lu", (unsigned long)range.location);
        NSMutableAttributedString *coloredText = [[NSMutableAttributedString alloc] initWithString:dateTimeString];
        
//        [coloredText addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(range.location,4)];
        [coloredText addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:12] range:NSMakeRange(range.location,4)];
        dateTimeLabel.attributedText = coloredText;
    }
    [_scrollView addSubview:dateTimeLabel];
}


- (void)createEndTimeView:(float)yOrigin {
    //Creating Time Imageview
    [_scrollView addSubview:[self createImageViewOfSize:CGRectMake(15, yOrigin+5, 10, 10) image:[UIImage imageNamed:@"time.png"] cornerRadius:0 alpha:1 backgroundColor:[UIColor clearColor]]];
    
    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:[_thisEvent.endDateTime doubleValue]/1000.0                          ];
    
    //Creating Time label.......
    [_scrollView addSubview:[self createLabelOfSize:CGRectMake(30, yOrigin, 240, 20) text:(_thisEvent.endDateTime.integerValue!=0)?[NSString stringWithFormat:@"%@ at %@",[EventHelper changeDateFormat:endDate editing:NO],[EventHelper changeTimeFormat:endDate]]:@" " font:[UIFont fontWithName:@"HelveticaNeue-Light" size:12] fontColor:[UIColor grayColor] alignment:NSTextAlignmentLeft]];
}

- (IBAction)inviteFriendButtonClicked:(id)sender {
    InviteFriendsViewController *inviteFriendsView = [self.storyboard instantiateViewControllerWithIdentifier:@"inviteFriendsView"];
    inviteFriendsView.thisEvent = _thisEvent;
    inviteFriendsView.hostId=_hostId;
    inviteFriendsView.hostData=_hostData;
    inviteFriendsView.fromWhereCalled = 1;
    [self.navigationController pushViewController:inviteFriendsView animated:YES];
}

#pragma mark action methods---------

- (IBAction)acceptButtonClicked:(id)sender {

    NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    NSString *urlString = [NSString stringWithFormat:@"%@/user/%@/event/%@/accept",kwebUrl,uid,_thisEvent.eventid];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                @"INVITED",@"channel",
                                nil];
    if(![self checkHostAndUserRelation]){
        NSString *invitedStatus = _thisEvent.guestStatus;
        NSLog(@"invited status ******* %@",invitedStatus);
        if ([invitedStatus isEqualToString:@"I"]) {
            [_activityIndicator startAnimating];

            [UtilitiesHelper getResponseFor:dictionary url:[NSURL URLWithString:urlString] requestType:@"PUT" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
             {
                 [_activityIndicator stopAnimating];
                 
                 if (success) {
//                     [self changeAcceptToCheckInButton];
//                     NSInteger count=[[self.statistics objectForKey:@"acceptedCount"] integerValue]+1;
                     
//                     [_goingStatsLabel setText:[NSString stringWithFormat:@"%li Going There" ,(long)count]];
                     // _goingStatsLabel.text=[NSString stringWithFormat:@"%i " ,count];
                     NSMutableDictionary *statistics= [self.statistics mutableCopy];
                     NSInteger goingThereCount = [[statistics objectForKey:@"acceptedCount"] integerValue]+1;
                     NSInteger invitedCount = [[statistics objectForKey:@"invitedCount"] integerValue]-1;
                     
                     [statistics setObject:[NSString stringWithFormat:@"%ld",(long)goingThereCount] forKey:@"acceptedCount"];
                     [statistics setObject:[NSString stringWithFormat:@"%ld",(long)invitedCount] forKey:@"invitedCount"];
                     _thisEvent.statistics = [NSString stringWithFormat:@"%@",statistics];
                     _thisEvent.guestStatus = @"A";
                     [CoreDataInterface saveAll];
//                     //                     [self getGuestList];
                     
                     [self updateEventDetails];
                 }
             }];
        }
        else {
            [self checkInButtonclicked];
        }
    }
    else
    {
        [self checkInButtonclicked];
    }
}

- (void)updateEventDetails {
    EventDetailsViewController *eventDetailsView = [self.storyboard instantiateViewControllerWithIdentifier:@"eventDetailsView"];
    eventDetailsView.eventId = _thisEvent.eventid;
    eventDetailsView.statistics=[UtilitiesHelper stringToDictionary:[_thisEvent statistics]];
    eventDetailsView.hostName=[[UtilitiesHelper stringToDictionary:[_thisEvent user]] objectForKey:@"firstName"];
    
    eventDetailsView.hostId=[[UtilitiesHelper stringToDictionary:[_thisEvent user]] objectForKey:@"id"];
    eventDetailsView.eventStatus=_thisEvent.guestStatus;
    eventDetailsView.hostData=[UtilitiesHelper stringToDictionary:[_thisEvent user]];
    NSMutableArray *navigationViewsArray = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < navigationViewsArray.count ; i++) {
        UIViewController *viewController = [navigationViewsArray objectAtIndex:i];
        [newArray addObject:viewController];
        
        if ([viewController isKindOfClass:[WhoThereViewController class]] || [viewController isKindOfClass:[NotificationViewController class]]) {
            NSLog(@"yes");
            break;
        }
    }
    [newArray addObject:eventDetailsView];
    [self.navigationController setViewControllers:newArray animated:NO];
}

- (void)checkInButtonclicked {
    double startDateTime = [_thisEvent.startDateTime doubleValue];
    BOOL isEventStart = [self checkEventIsStartedOrNot:startDateTime];
    if (!isEventStart) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Check-In not allowed" message:@"This event is not started yet." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    else {
        [_activityIndicator startAnimating];
        //    [self.navigationController popViewControllerAnimated:YES];
        NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
        NSString *urlString = [NSString stringWithFormat:@"%@/event/%@/checkin",kwebUrl,_thisEvent.eventid];
        
        NSDictionary *postDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  uid ,@"id",
                                  @"MANUAL",@"checkInType",
                                  nil];
        
        [UtilitiesHelper getResponseFor:postDict url:[NSURL URLWithString:urlString] requestType:@"PUT" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
         {
             [_activityIndicator stopAnimating];
             if (success) {
                 NSMutableDictionary *statistics= [[UtilitiesHelper stringToDictionary:[_thisEvent statistics]] mutableCopy];
                 NSInteger goingThereCount = [[statistics objectForKey:@"acceptedCount"] integerValue];
                 NSInteger hooThereCount = [[statistics objectForKey:@"hoothereCount"] integerValue];
                 NSInteger hooCameCount = [[statistics objectForKey:@"hooCameCount"] integerValue];

                 if ([_thisEvent.guestStatus isEqualToString:@"A"]) {
                     goingThereCount = goingThereCount - 1;
                 }
                 
                 if ([_thisEvent.guestStatus isEqualToString:@"HC"]) {
                     hooCameCount = hooCameCount - 1;
                 }
                 
                 hooThereCount = hooThereCount + 1;
                 
                 [statistics setObject:[NSString stringWithFormat:@"%ld",(long)goingThereCount] forKey:@"acceptedCount"];
                 [statistics setObject:[NSString stringWithFormat:@"%ld",(long)hooThereCount] forKey:@"hoothereCount"];
                 [statistics setObject:[NSString stringWithFormat:@"%ld",(long)hooCameCount] forKey:@"hooCameCount"];

                 _thisEvent.statistics = [NSString stringWithFormat:@"%@",statistics];
                 _thisEvent.guestStatus = @"HT";
                 
                 NSString *message = [NSString stringWithFormat:@"You have successfully checked into %@",_thisEvent.name];
                 
                 //             [acceptButton setTitle:@"Checked-In" forState:UIControlStateNormal];
                 //             acceptButton.alpha = 0.5;
                 //             acceptButton.enabled = NO;
                 //             acceptButton.layer.borderColor=[UIColor grayColor].CGColor;
                 
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hoothere" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                 [alertView show];
                 
                 [self updateEventDetails];
             }
             [CoreDataInterface saveAll];
         }];
    }
}

#pragma mark Utilities---------

- (UILabel*)createLabelOfSize:(CGRect)frame text:(NSString *)text font:(UIFont *)font fontColor:(UIColor *)fColor alignment:(NSTextAlignment)alignment{
    
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    if (text.length > 0) {
        label.text = text;
    }
    label.textColor = fColor;
    label.font = font;
    label.textAlignment = alignment;
    label.numberOfLines = 0;
    return label;
}

- (UIImageView *)createImageViewOfSize:(CGRect)frame image:(UIImage*)image cornerRadius:(CGFloat)cornerRadius alpha:(CGFloat)alpha backgroundColor:(UIColor*)bColor{
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.alpha = alpha;
    imageView.backgroundColor = bColor;
    imageView.layer.masksToBounds = YES;
    imageView.image = image;
    imageView.layer.cornerRadius = cornerRadius;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    return imageView;
}

- (CGFloat)heigthWithWidth:(CGFloat)width andFont:(UIFont *)font string:(NSString *)string
{
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:string];
    [attrStr addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [string length])];
    CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    return rect.size.height;
}

@end
