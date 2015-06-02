//
//  SearchEventInfoViewController.m
//  Hoothere
//
//  Created by Abhishek Tyagi on 21/01/15.
//  Copyright (c) 2015 Quovantis Technologies. All rights reserved.
//

#import "SearchEventInfoViewController.h"
#import "EventHelper.h"
#import <MapKit/MapKit.h>
#import "UtilitiesHelper.h"
#import "EventDetailsViewController.h"
#import "WhoThereViewController.h"

@interface SearchEventInfoViewController ()

@end

@implementation SearchEventInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _activityIndicator = [UtilitiesHelper loadCustomActivityIndicatorWithYorigin:50 Xorigin:self.view.center.x-50];
    [self.view addSubview:_activityIndicator];
    [self.view bringSubviewToFront:_activityIndicator];
    [self getEventDetails];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getEventDetails:) name:@"kLoadSearchEventDetailsInformation" object:nil];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getEventDetails {
    
//    NSDictionary *eventDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:_thisEvent,@"event",_isPastEvent,@"pastEvent", nil];
//    NSDictionary *notificationObject = notification.object;
//    _isPastEvent = [[notificationObject objectForKey:@"pastEvent"] boolValue];
//    
//    _thisEvent = [[notificationObject objectForKey:@"event"] mutableCopy];
//    _eventIndex = [[notificationObject objectForKey:@"eventIndex"] integerValue];

    _eventId = [_thisEvent objectForKey:@"id"];
    if ([_thisEvent objectForKey:@"name"] != nil && ![[_thisEvent objectForKey:@"name"] isEqual:[NSNull null]]) {
        eventNameLabel.text = [_thisEvent objectForKey:@"name"];
    }
    else {
        eventNameLabel.text = @"";
    }
    self.statistics=[_thisEvent objectForKey:@"statistics"];
    self.hostData=[_thisEvent objectForKey:@"user"];
    self.hostId= [[_thisEvent objectForKey:@"user"] objectForKey:@"id"];
    [self createCustomViewForEventDetails];
}

- (void)createCustomViewForEventDetails {
    
    //createCustomViewForEventDetail
    
    float yOrigin = 35;//176;
    //Creating Description label.......
    if ([_thisEvent objectForKey:@"eventDescription"] != nil && ![[_thisEvent objectForKey:@"eventDescription"] isEqual:[NSNull null]]) {
        CGFloat descriptionLabelHeight = [self heigthWithWidth:290 andFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14] string:[_thisEvent objectForKey:@"eventDescription"]];
        [_scrollView addSubview:[self createLabelOfSize:CGRectMake(15, yOrigin, 290, descriptionLabelHeight) text:[_thisEvent objectForKey:@"eventDescription"] font:[UIFont fontWithName:@"HelveticaNeue-Light" size:14] fontColor:[UIColor grayColor] alignment:NSTextAlignmentLeft]];
        
        yOrigin = yOrigin + descriptionLabelHeight + 15;
    }
    
    if (![[_thisEvent objectForKey:@"eventType"] isEqual:[NSNull null]] && [_thisEvent objectForKey:@"eventType"] !=nil) {
        if ([[_thisEvent objectForKey:@"eventType"]  isEqualToString:@"PUB"]) {
            [self createEventTypeView:@"Public Event" yOrigin:yOrigin imageName:@"public_event.png"];
        }
        else {
            [self createEventTypeView:@"Private Event" yOrigin:yOrigin imageName:@"private_event.png"];
        }
    }
    
    yOrigin = yOrigin + 25;
    
    if ([_thisEvent objectForKey:@"address"] != nil && ![[_thisEvent objectForKey:@"address"] isEqual:[NSNull null]]) {
        [self createAddressLabelWithButton:yOrigin];
        CGFloat locationLabelHeight = [self heigthWithWidth:240 andFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:13] string:[_thisEvent objectForKey:@"address"]];
        
        yOrigin = yOrigin + locationLabelHeight + 25;
    }
    
    // Creating Time View
    [self createTimeView:yOrigin];
    
    yOrigin = yOrigin + 60;
    
    _scrollView.contentSize = CGSizeMake(320, yOrigin);
    
    if (_isPastEvent) {
        joinButton.hidden = YES;
        self.tabBarController.tabBar.hidden = NO;
    }
    else {
        self.tabBarController.tabBar.hidden = YES;
    }
}

- (void)createEventTypeView:(NSString *)text yOrigin:(float)yOrigin imageName:(NSString *)imageName {
    [_scrollView addSubview:[self createImageViewOfSize:CGRectMake(15, yOrigin+3, 10, 10) image:[UIImage imageNamed:imageName] cornerRadius:0 alpha:1 backgroundColor:[UIColor clearColor]]];
    [_scrollView addSubview:[self createLabelOfSize:CGRectMake(30, yOrigin, 240, 18) text:text font:[UIFont fontWithName:@"HelveticaNeue-Light" size:13] fontColor:[UIColor colorWithRed:89/255.0 green:152/255.0 blue:205/255.0 alpha:1] alignment:NSTextAlignmentLeft]];
    
}

- (void)createAddressLabelWithButton:(float)yOrigin {
    
    if ([_thisEvent objectForKey:@"address"] == nil || [[_thisEvent objectForKey:@"address"] isEqual:[NSNull null]]) {
        return;
    }
    //Creating Location Button
    CGFloat venueLabelHeight = [self heigthWithWidth:240 andFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:13] string:[NSString stringWithFormat:@"%@",[_thisEvent objectForKey:@"venueName"]]];
    CGFloat locationLabelHeight = [self heigthWithWidth:240 andFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12] string:[NSString stringWithFormat:@"%@",[_thisEvent objectForKey:@"address"]]];
    
    UIButton *locationButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    locationButton.frame = CGRectMake(15, yOrigin, 290, locationLabelHeight);
    [locationButton addTarget:self action:@selector(locationButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:locationButton];
    
    //Creating Location Imageview.......
    [_scrollView addSubview:[self createImageViewOfSize:CGRectMake(15, yOrigin+3, 10, 10) image:[UIImage imageNamed:@"location.png"] cornerRadius:0 alpha:1 backgroundColor:[UIColor clearColor]]];
    
    //Creating Location label.......
    [_scrollView addSubview:[self createLabelOfSize:CGRectMake(30, yOrigin, 240, venueLabelHeight) text:[NSString stringWithFormat:@"%@",[_thisEvent objectForKey:@"venueName"]] font:[UIFont fontWithName:@"HelveticaNeue-Light" size:13] fontColor:[UIColor colorWithRed:89/255.0 green:152/255.0 blue:205/255.0 alpha:1] alignment:NSTextAlignmentLeft]];
    
    [_scrollView addSubview:[self createLabelOfSize:CGRectMake(30, yOrigin+4+venueLabelHeight, 240, locationLabelHeight) text:[NSString stringWithFormat:@"%@",[_thisEvent objectForKey:@"address"]] font:[UIFont fontWithName:@"HelveticaNeue-Light" size:12] fontColor:[UIColor grayColor] alignment:NSTextAlignmentLeft]];
}

- (void)createTimeView:(float)yOrigin {
    //Creating Time Imageview
    
    NSString *startString = [_thisEvent objectForKey:@"startDateTime"];
    NSString *endString = [_thisEvent objectForKey:@"endDateTime"];

    if (startString == nil || [startString isEqual:[NSNull null]] || endString == nil || [endString isEqual:[NSNull null]]) {
        endString = @"0";
        startString = @"0";
        return;
    }
    [_scrollView addSubview:[self createImageViewOfSize:CGRectMake(15, yOrigin+2, 10, 10) image:[UIImage imageNamed:@"time.png"] cornerRadius:0 alpha:1 backgroundColor:[UIColor clearColor]]];
    
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:[startString doubleValue]/1000.0];
    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:[endString doubleValue]/1000.0];
    
    NSString *dateTimeString = ([startString doubleValue]!=0)?[NSString stringWithFormat:@"%@ at %@ till %@ at %@",[EventHelper changeDateFormat:startDate editing:NO],[EventHelper changeTimeFormat:startDate],[EventHelper changeDateFormat:endDate editing:NO],[EventHelper changeTimeFormat:endDate]]:@"Date not specified";
    
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

#pragma mark action methods---------

- (IBAction)joinButtonClicked:(id)sender {
    [_activityIndicator startAnimating];
    self.view.userInteractionEnabled = NO;
    NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    NSString *urlString = [NSString stringWithFormat:@"%@/user/%@/event/%@/accept",kwebUrl,uid,_eventId];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                @"SELF",@"channel",
                                nil];
    
    [UtilitiesHelper getResponseFor:dictionary url:[NSURL URLWithString:urlString] requestType:@"PUT" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {
         [_activityIndicator stopAnimating];
         self.view.userInteractionEnabled = YES;
         
         if (success) {
             
             [CoreDataInterface saveEventList:[NSArray arrayWithObjects:jsonDict, nil]];
             NSMutableDictionary *eventInfo = [_thisEvent mutableCopy];
             
             NSMutableDictionary *statistics= [[eventInfo objectForKey:@"statistics"] mutableCopy];
             NSInteger goingThereCount = [[statistics objectForKey:@"acceptedCount"] integerValue]+1;
             
             [statistics setObject:[NSString stringWithFormat:@"%ld",(long)goingThereCount] forKey:@"acceptedCount"];
             
             [eventInfo setObject:statistics forKey:@"statistics"];
             [eventInfo setObject:@"A" forKey:@"guestStatus"];
             
             [CoreDataInterface saveEventList:[NSArray arrayWithObjects:eventInfo, nil]];
             
             [CoreDataInterface saveAll];
             
             EventDetailsViewController *eventDetailsView = [self.storyboard instantiateViewControllerWithIdentifier:@"eventDetailsView"];
             eventDetailsView.eventId = [eventInfo objectForKey:@"id"];
             eventDetailsView.statistics=[eventInfo objectForKey:@"statistics"];
             eventDetailsView.hostName= [[eventInfo objectForKey:@"user"]objectForKey:@"fullName"];
             
             eventDetailsView.hostId=[[eventInfo objectForKey:@"user"] objectForKey:@"id"];
             eventDetailsView.hostData=[eventInfo objectForKey:@"user"];
             eventDetailsView.eventStatus = @"A";
             
             NSMutableArray *navigationViewsArray = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
             NSMutableArray *newArray = [[NSMutableArray alloc] init];
             
             for (int i = 0; i < navigationViewsArray.count ; i++) {
                 UIViewController *viewController = [navigationViewsArray objectAtIndex:i];
                 [newArray addObject:viewController];
                 
                 if ([viewController isKindOfClass:[WhoThereViewController class]]) {
                     NSLog(@"yes");
                     break;
                 }
             }
             [newArray addObject:eventDetailsView];
             [self.navigationController setViewControllers:newArray animated:YES];
             
             [_thisEvent setObject:@"A" forKey:@"guestStatus"];
             
             NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:_thisEvent,@"event",[NSNumber numberWithInteger:_eventIndex],@"eventIndex", nil];
             [[NSNotificationCenter defaultCenter] postNotificationName:@"kUpdateListOfSearchAndPastEvents" object:dictionary];
         }
     }];
}

- (void)locationButtonClicked {
    CLLocationDegrees latitude = [[_thisEvent objectForKey:@"latitude"] doubleValue];
    CLLocationDegrees longitude =[[_thisEvent objectForKey:@"longitude"] doubleValue];
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
    
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:centerCoordinate addressDictionary:nil];
    MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:placemark];
    item.name = [_thisEvent objectForKey:@"venueName"];
    [item openInMapsWithLaunchOptions:nil];
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
