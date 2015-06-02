//
//  EditEventViewController.m
//  HooThere
//
//  Created by Abhishek Tyagi on 31/10/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import "EditEventViewController.h"
#import "UtilitiesHelper.h"
#import "EventHelper.h"
#import "CoreDataInterface.h"
#import "EventDetailsViewController.h"
#import "EventGeoFenceViewController.h"
#import "LocationHandler.h"
#import "SelectLocationTypeViewController.h"

@interface EditEventViewController ()

@end

@implementation EditEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveButtonClicked)];
    self.navigationItem.rightBarButtonItem = editButton;
    _isEditable = YES;
    [self checkForEditValidation];
    
    _activityIndicator = [UtilitiesHelper loadCustomActivityIndicatorWithYorigin:self.view.center.y -80 Xorigin:self.view.center.x-50];
    [self.view addSubview:_activityIndicator];
    [self.view bringSubviewToFront:_activityIndicator];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(hideKeyboard)];
    singleTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:singleTap];
    
    if ([_thisEvent.eventType isEqualToString:@"PVT"]) {
        settingsSwitch.on = NO;
    }
    else {
        settingsSwitch.on = YES;
    }
    [self loadDatePickerView];
    _scrollView.contentSize = CGSizeMake(320, 500);
    
    [self loadEventDetails];
}

- (void)viewWillAppear:(BOOL)animated {
    [streetAddress resignFirstResponder];
    self.tabBarController.tabBar.hidden = YES;
    [self.view endEditing:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.view endEditing:YES];
}

- (void)updateLocationInformation:(NSDictionary *)locationInfo {
    venueTextField.text = [locationInfo objectForKey:@"venue"];
    streetAddress.text = [locationInfo objectForKey:@"address"];
}

-(void)checkForEditValidation{
    double todayTimeStamp=[[NSDate date] timeIntervalSince1970];
    double eventStartDate=[_thisEvent.startDateTime doubleValue]/1000.0;
    if(eventStartDate<todayTimeStamp && eventStartDate !=0)
    {
        [nameTextField setEnabled:NO];
        [descriptionTextView setEditable:NO];
        [stateTextField setEnabled:NO];
        [cityTextField setEnabled:NO];
        [countryTextField setEnabled:NO];
        [zipCodeTextField setEnabled:NO];
        [streetAddress setEditable:NO];
        [venueTextField setEnabled:NO];
        [stateTextField setEnabled:NO];
        
        _setGeoFanceButton.hidden = YES;
    _isEditable=NO;
    }

}
- (void)loadEventDetails {
    nameTextField.text = _thisEvent.name;
    descriptionTextView.text = _thisEvent.eventDescription;
    

    NSDate *endDate =[NSDate dateWithTimeIntervalSince1970:[_thisEvent.endDateTime doubleValue]/1000.0];
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:[_thisEvent.startDateTime doubleValue]/1000.0];
    ;
    
    lblEventStart.text = (_thisEvent.startDateTime.integerValue!=0)?[NSString stringWithFormat:@"%@ %@",[EventHelper changeDateFormat:startDate editing:YES] ,[EventHelper changeTimeFormat:startDate]]:@"";
    lblEventEnds.text = (_thisEvent.endDateTime.integerValue!=0)?[NSString stringWithFormat:@"%@ %@",[EventHelper changeDateFormat:endDate editing:YES] ,[EventHelper changeTimeFormat:endDate]]:@"";
    
    if (lblEventStart.text.length > 0) {
        _eventStartDate = [EventHelper getDateFromString:lblEventStart.text];
    }
    if (lblEventEnds.text.length > 0) {
        _eventEndDate = [EventHelper getDateFromString:lblEventEnds.text];
    }

    venueTextField.text = _thisEvent.venueName;
    streetAddress.text = _thisEvent.address;
//    cityTextField.text = _thisEvent.city;
//    stateTextField.text = _thisEvent.state;
//    countryTextField.text = _thisEvent.country;
//    zipCodeTextField.text = _thisEvent.zipcode;

}


- (void)hideKeyboard {
    [self.view endEditing:YES];
    _startButton.layer.borderWidth=0.0f;
    _endButton.layer.borderWidth=0.0f;
    
    
    _datePicker.hidden=YES;
    _datePickerLabel.hidden=YES;
    streetAddress.hidden = NO;
    cityTextField.hidden = NO;
    stateTextField.hidden = NO;
    countryTextField.hidden = NO;
    zipCodeTextField.hidden = NO;
    _zipLabel.hidden=NO;
    _countyLabel.hidden=NO;
    _stateLabel.hidden=NO;
    _venueNameLabel.hidden=NO;
    _streetAddressLabel.hidden=NO;
    _cityLabel.hidden=NO;
    venueTextField.hidden=NO;
    
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

    _datePicker.hidden=YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
 _datePicker.hidden=YES;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) highlightSelectedButton:(UIButton *)selectedButton{
    
    selectedButton.layer.borderWidth=1.0f;
    
    selectedButton.layer.borderColor=[UIColor purpleColor].CGColor;
    
    
}

- (void)loadDatePickerView {
    _currentDateSelection = @"Start";
    [self.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    [self dateChanged:nil];
    
}

- (void)dateChanged:(id)sender
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, yyyy hh:mm a"];
    NSString *currentTime = [dateFormatter stringFromDate:self.datePicker.date];
    if ([_currentDateSelection isEqualToString:@"Start"]) {
        lblEventStart.text = currentTime;
        _eventStartDate = self.datePicker.date;
    }
    else {
        lblEventEnds.text = currentTime;
        _eventEndDate = self.datePicker.date;
    }
}

- (IBAction)startDateButtonClicked:(id)sender {
    [self.view endEditing:YES];
    if(!_isEditable){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Event has started, you can not change the timings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    _datePicker.hidden = NO;
    _datePickerLabel.hidden=NO;
    [self highlightSelectedButton:(UIButton *)sender];
     _endButton.layer.borderWidth=0.0f;
    
    
    if (lblEventStart.text.length > 0) {
        _datePicker.date = [EventHelper getDateFromString:lblEventStart.text];
    }    
  
    [self.view endEditing:YES];
    [self enterStartDate];
}

- (void)enterStartDate {
    _currentDateSelection = @"Start";
    messageLabel.text = @"Please select the start date of your event";
}

- (IBAction)endDateButtonClicked:(id)sender {
    
    [self.view endEditing:YES];

    _datePicker.hidden = NO;
    _datePickerLabel.hidden=NO;
     _startButton.layer.borderWidth=0.0f;
        if (lblEventEnds.text.length > 0) {
        _datePicker.date = [EventHelper getDateFromString:lblEventEnds.text];
    }
    [self highlightSelectedButton:(UIButton *)sender];
    if (_eventStartDate == nil || [_eventStartDate isEqual:[NSNull null]]) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hoothere" message:@"Please enter start date of an event." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    _currentDateSelection = @"End";
    messageLabel.text = @"Please select the end date of your event";
}

- (IBAction)setGeoFenceButtonClicked:(id)sender {
    if (![self checkFields]) {
        return;
    }
    
//    [self createUpdatedDict];
    [_activityIndicator startAnimating];
    [LocationHandler getLocationCoordinates:[NSString stringWithFormat:@"%@, %@",venueTextField.text,streetAddress.text] complettionBlock:^(BOOL success,NSDictionary *placeInfo)
     {
         [_activityIndicator stopAnimating];
         if (success) {
//             self.latitudeStr =
//             self.longitudeStr =
             EventGeoFenceViewController *eventGeoFenceView = [self.storyboard instantiateViewControllerWithIdentifier:@"eventGeoFenceView"];
             eventGeoFenceView.isEditing = YES;
             eventGeoFenceView.title = _thisEvent.name;
             eventGeoFenceView.thisEvent = _thisEvent;
             eventGeoFenceView.latitudeStr = [[[[placeInfo objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"] stringValue];;
             eventGeoFenceView.longitudeStr = [[[[placeInfo objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"] stringValue];
             [self .navigationController pushViewController:eventGeoFenceView animated:YES];
         }
     }];
}

- (IBAction)switchToggled:(UISwitch *)settingSwitch {
    
}

-(void)createUpdatedDict{
    
    if (settingsSwitch.on) {
        _thisEvent.eventType = @"PUB";
    }
    else {
        _thisEvent.eventType = @"PVT";
    }
    NSLog(@"startDateStr %@",lblEventStart.text);
     NSLog(@"endDateStr %@",lblEventEnds.text);
     _thisEvent.name=nameTextField.text;
     _thisEvent.eventDescription=descriptionTextView.text;
    _thisEvent.venueName= venueTextField.text ;
    _thisEvent.address= streetAddress.text;
    _thisEvent.startDateTime=[EventHelper createTimeStamp:lblEventStart.text withDateFormat:@"MMM dd, yyyy hh:mm a"];
    _thisEvent.endDateTime=[EventHelper createTimeStamp:lblEventEnds.text withDateFormat:@"MMM dd, yyyy hh:mm a"];
    _thisEvent.zipcode=zipCodeTextField.text;
    _thisEvent.guestStatus=_thisEvent.guestStatus;
}

-(BOOL)checkFields{

    NSDate *today = [NSDate date];
    
    BOOL startDateCheck = [EventHelper compareStartDate:_eventStartDate endDate:today endDateSelected:FALSE];
    
    if (venueTextField.text.length == 0 || streetAddress.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hoothere" message:@"Please fill all details about venue." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        return NO;
    }
    
    
    if (!startDateCheck && _isEditable) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hoothere" message:@"Please enter a valid start date of an event." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        return NO;
    }
    
    BOOL endDateCheck = [EventHelper compareStartDate:_eventEndDate endDate:_eventStartDate endDateSelected:TRUE];
    BOOL endDateCheck1 = [EventHelper compareStartDate:_eventEndDate endDate:[NSDate date] endDateSelected:TRUE];
    if (!endDateCheck || !endDateCheck1) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hoothere" message:@"Please enter a valid end date of an event." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        return NO;
    }
    return YES;
}

-(void)saveButtonClicked{
    if (![self checkFields]) {
        return;
    }
        NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/event/edit/%@",kwebUrl,_thisEvent.eventid];
    
    
    [self createUpdatedDict];
    [CoreDataInterface saveAll];
    NSMutableDictionary *changedEvent=[[UtilitiesHelper setUserDetailsDictionaryFromCoreDataWithInfo:_thisEvent type:nil] mutableCopy];
    [changedEvent removeObjectForKey:@"statistics"];
    [changedEvent removeObjectForKey:@"user"];
    [changedEvent removeObjectForKey:@"eventAlbum"];
    [changedEvent removeObjectForKey:@"coverImage"];
    [changedEvent removeObjectForKey:@"image"];

    [changedEvent setObject:[NSString stringWithFormat:@"%@",uid] forKey:@"modifiedBy"];
    
    [_activityIndicator startAnimating];
    
    NSLog(@"changedEvent %@",changedEvent);
    [self.view endEditing:YES];
    [UtilitiesHelper getResponseFor:changedEvent url:[NSURL URLWithString:urlString] requestType:@"PUT" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {
         //[_activityIndicator stopAnimating];
         [_activityIndicator stopAnimating];
         if (success) {
             [CoreDataInterface saveEventList:[NSArray arrayWithObject:jsonDict]];
             [CoreDataInterface saveAll];
             NSLog(@"Edit Event !!");
             EventDetailsViewController *eventDetailsView = [self.storyboard instantiateViewControllerWithIdentifier:@"eventDetailsView"];
             eventDetailsView.eventId = [jsonDict objectForKey:@"id"];
             eventDetailsView.statistics=[jsonDict objectForKey:@"statistics"];
             eventDetailsView.hostName = [[CoreDataInterface getInstanceOfMyInformation] firstName];
             eventDetailsView.hostId=uid;
             eventDetailsView.eventStatus = [jsonDict objectForKey:@"guestStatus"];
             eventDetailsView.hostData=[jsonDict objectForKey:@"user"];

             NSMutableArray *navigationViewsArray = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
             [navigationViewsArray removeLastObject];
             [navigationViewsArray removeLastObject];
             [navigationViewsArray addObject:eventDetailsView];
             [self.navigationController setViewControllers:navigationViewsArray animated:YES];
             //[self.navigationController pushViewController:eventDetailsView animated:YES];
         }
     }];
}

#pragma Mark Text View Delegate-------------------

- (void)keyboardWillShow:(NSNotification*)aNotification
{
    [self moveViewForKeyboard:aNotification up:YES];
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
    CGSize contentSize = CGSizeMake(300,500);
    self.scrollView.contentSize = contentSize;
    [self.scrollView setNeedsDisplay];
}

- (void)moveViewForKeyboard:(NSNotification*)aNotification up:(BOOL)up {
    NSDictionary* userInfo = [aNotification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame toView:nil];
    
    CGSize contentSize;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        contentSize = CGSizeMake(300, 500 + keyboardFrame.size.height);
    }
    else {
        contentSize = CGSizeMake(300, 1000);
    }
    _scrollView.contentSize = contentSize;
    [_scrollView setNeedsDisplay];
    [UIView commitAnimations];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _datePicker.hidden = YES;
    _datePickerLabel.hidden=YES;
    
    if (textField == cityTextField || textField == stateTextField || textField == countryTextField || textField == cityTextField) {
        
    }
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
//    [self hideActionForTextFields:NO];
}

#pragma Mark Text View Delegate-------------------

- (void)textViewDidBeginEditing:(UITextView *)textView {
    _datePicker.hidden = YES;
    _datePickerLabel.hidden=YES;
    
//    [self createUpdatedDict];
//    [CoreDataInterface saveAll];
    if (textView == streetAddress) {
//        streetAddress.text = @"";
//        streetAddress.textColor = [UIColor darkGrayColor];
        [self.view endEditing:YES];

        SelectLocationTypeViewController *selectLocationTypeView = [self.storyboard instantiateViewControllerWithIdentifier:@"selectLocationTypeView"];
        selectLocationTypeView.title = _thisEvent.name;
        selectLocationTypeView.thisEvent = _thisEvent;
        selectLocationTypeView.isEditing = YES;
        selectLocationTypeView.delegate = self;
        [self.navigationController pushViewController:selectLocationTypeView animated:YES];
        [streetAddress resignFirstResponder];
        return;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
//    [self hideActionForTextFields:NO];

    if (textView == streetAddress && streetAddress.text.length == 0) {
        streetAddress.text = @"Address";
        streetAddress.textColor = [UIColor lightGrayColor];
        return;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//    if (textField ==nameTextField) {
//        [descriptionTextView becomeFirstResponder];
//    }
//    else if (textField==venueTextField)
//        [streetAddress becomeFirstResponder];
//    else if(textField==cityTextField)
//        [stateTextField becomeFirstResponder];
//    else if(textField==stateTextField)
//        [countryTextField becomeFirstResponder];
//    else if(textField==countryTextField)
//        [zipCodeTextField becomeFirstResponder ];

    [self saveButtonClicked];
    return YES;
}




@end
