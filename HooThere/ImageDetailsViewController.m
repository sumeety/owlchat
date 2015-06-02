//
//  ImageDetailsViewController.m
//  Hoothere
//
//  Created by Abhishek Tyagi on 23/01/15.
//  Copyright (c) 2015 Quovantis Technologies. All rights reserved.
//

#import "ImageDetailsViewController.h"
#import "UtilitiesHelper.h"
#import "UIImageView+WebCache.h"
#import "EventHelper.h"
#import <Social/Social.h>

@interface ImageDetailsViewController ()

@end

@implementation ImageDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabBarController.tabBar.hidden = YES;

    self.automaticallyAdjustsScrollViewInsets = NO;

    _activityIndicator = [UtilitiesHelper loadCustomActivityIndicatorWithYorigin:self.view.center.y -80 Xorigin:self.view.center.x-50];
    [self.view addSubview:_activityIndicator];
    [self.view bringSubviewToFront:_activityIndicator];
    
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonClicked)];
    self.navigationItem.rightBarButtonItem = actionButton;
    
    uploaderImageView.layer.masksToBounds = YES;
    uploaderImageView.layer.cornerRadius = 8;
    [self loadImages];
}

- (void)actionButtonClicked {
    NSDictionary *dictionaryInfo = [[_listOfImages objectAtIndex:_imageIndex] objectForKey:@"user"];
    
    [self loadActionSheetForImage:dictionaryInfo];
}



- (void)loadImages {
    NSUInteger numberPages = _listOfImages.count;
    
    _imagesScrollview.contentSize =
    CGSizeMake(CGRectGetWidth(_imagesScrollview.frame) * numberPages, CGRectGetHeight(_imagesScrollview.frame));
    
    [self gotoPage:_imageIndex];
    
    [self loadImageDetails:_imageIndex];
}

- (void)gotoPage:(NSInteger)index
{
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:index - 1];
    [self loadScrollViewWithPage:index];
    [self loadScrollViewWithPage:index + 1];
    
    // update the scroll view to the appropriate page
    CGRect bounds = _imagesScrollview.bounds;
    bounds.origin.x = CGRectGetWidth(bounds) * index;
    bounds.origin.y = 0;
    [_imagesScrollview scrollRectToVisible:bounds animated:NO];
}

- (void)fetchListOfHootThereFriends {
    [_activityIndicator startAnimating];
    [self.view endEditing:YES];
    
    NSString *userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/friends/%@/getAll?page=0",kwebUrl,userId];
    
    [UtilitiesHelper fetchListOfHootThereFriends:[NSURL URLWithString:urlString] requestType:@"GET" complettionBlock:^(BOOL success,NSDictionary *jsonDict){
        
        [_activityIndicator stopAnimating];
        
        if (success) {
            //_listOfFriends = [jsonDict objectForKey:@"Friends"];
            _listOfImages = [[jsonDict objectForKey:@"eventAlbum"] mutableCopy];
            NSUInteger numberPages = _listOfImages.count;
            
            _imagesScrollview.contentSize =
            CGSizeMake(CGRectGetWidth(_imagesScrollview.frame) * numberPages, CGRectGetHeight(_imagesScrollview.frame));
            _imageIndex = 0;
            [self loadScrollViewWithPage:_imageIndex];
            [self loadScrollViewWithPage:_imageIndex+1];
            [self loadImageDetails:_imageIndex];
        }
        
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.tabBarController.tabBar.hidden = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    self.tabBarController.tabBar.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark scrollview, page control

- (void)loadImageDetails:(NSInteger)index {
    if (index >= _listOfImages.count)
        return;
    
    NSDictionary *dictionaryInfo = [[_listOfImages objectAtIndex:index] objectForKey:@"user"];
    
    id imageName = [dictionaryInfo objectForKey:@"profile_picture"];
    
    nameLabel.text = [dictionaryInfo objectForKey:@"fullName"];
    
    if (imageName != nil && ![imageName isEqual:[NSNull null]]) {
        NSString *imageUrl = [NSString stringWithFormat:@"%@/user/%@/thumbnail",kwebUrl,[dictionaryInfo objectForKey:@"id"]];
        [uploaderImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]];
    }
    
    NSDate *uploadedDate = [NSDate dateWithTimeIntervalSince1970:[[[_listOfImages objectAtIndex:index] objectForKey:@"uploadedOn" ] doubleValue]/1000.0];
    
    if([[[_listOfImages objectAtIndex:index] objectForKey:@"uploadedOn" ] doubleValue]!=0) {
        dateLabel.text = [NSString stringWithFormat:@"%@ at %@",[EventHelper changeDateFormat:uploadedDate editing:NO],[EventHelper changeTimeFormat:uploadedDate]];
    }
    else {
        dateLabel.text = @"Not Specified";
    }
}

- (void)loadScrollViewWithPage:(NSInteger)index
{
    if (index >= _listOfImages.count)
        return;
    
    for (UIImageView *subImageView in _imagesScrollview.subviews) {
        NSLog(@"Tag -- subview : %ld and imageindex : %ld",(long)subImageView.tag, (long)_imageIndex);
        if (subImageView.tag == index) {
            [subImageView removeFromSuperview];
            break;
        }
    }
    
    NSDictionary *dictionaryInfo = [_listOfImages objectAtIndex:index];
    
    UIImageView *currentImageView = [[UIImageView alloc] init];
    currentImageView.tag = index;
    CGRect frame = _imagesScrollview.frame;
    frame.origin.x = CGRectGetWidth(frame) * index;
    frame.origin.y = 0;
    currentImageView.frame = frame;
    
    NSString *imageUrl = [dictionaryInfo objectForKey:@"imageUrl"];
    
    if (imageUrl != nil && ![imageUrl isEqual:[NSNull null]]) {
        [currentImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]];
    }
    currentImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [_imagesScrollview addSubview:currentImageView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = CGRectGetWidth(_imagesScrollview.frame);
    NSUInteger page = floor((_imagesScrollview.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    _imageIndex = page;
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    [self loadImageDetails:page];

}

#pragma mark Delete, Set event Image and other methods

- (void)loadActionSheetForImage:(NSDictionary *)dictionary {
    NSString *uploaderId = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"id"]];
    
    BOOL isUploader = [self checkUserIsUploader:uploaderId];
    BOOL isHost = [self checkUserIsHost];

    if (isHost && isUploader) {
        _actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save Image", @"Share Image", @"Set As Event Image", @"Delete Image", nil];
    }
    else if (isUploader) {
        _actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save Image", @"Share Image", @"Delete Image", nil];
    }
    else {
        _actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save Image", @"Share Image", nil];
    }
    [_actionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([title isEqualToString:@"Delete Image"]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hoothere" message:@"Are you sure you want to delete this image from event album?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Ya Sure", nil];
        [alertView show];
    }
    else if ([title isEqualToString:@"Set As Event Image"]) {
        [self setAsEventImage];
    }
    else if ([title isEqualToString:@"Save Image"]) {
        [self saveImageInPhoneGallery];
    }
    else if ([title isEqualToString:@"Share Image"]) {
        [self shareThisImage];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if ([title isEqualToString:@"Ya Sure"]) {
        [_activityIndicator startAnimating];
        self.view.userInteractionEnabled = NO;
        NSString *userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
        
        NSString *urlString = [NSString stringWithFormat:@"%@/event/%@/delete/%@?userId=%@",kwebUrl,[_thisEvent objectForKey:@"id"],[[_listOfImages objectAtIndex:_imageIndex] objectForKey:@"name"],userId];
        
        [UtilitiesHelper getResponseFor:nil url:[NSURL URLWithString:urlString] requestType:@"DELETE" complettionBlock:^(BOOL success,NSDictionary *jsonDict){
            self.view.userInteractionEnabled = YES;

            [_activityIndicator stopAnimating];
            
            if (success) {
                if (_imageIndex == _listOfImages.count-1) {
                    [_listOfImages removeObjectAtIndex:_imageIndex];
                    _imageIndex = _imageIndex - 1;
                }
                else {
                    [_listOfImages removeObjectAtIndex:_imageIndex];
                    
                }
                NSMutableArray *updatedList = [[NSMutableArray alloc] initWithArray:_listOfImages];

                [self updateImageViewScrollView:updatedList];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kUpdateListOfEventAlbumImages" object:_listOfImages];
            
        }];
    }
}

- (void)updateImageViewScrollView:(NSMutableArray *)updatedList {
    if (updatedList.count == 0) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    ImageDetailsViewController *imageDetailsView = [self.storyboard instantiateViewControllerWithIdentifier:@"imageDetailsView"];
    imageDetailsView.title = [_thisEvent objectForKey:@"name"];
    imageDetailsView.listOfImages = updatedList;
    imageDetailsView.thisEvent = _thisEvent;
    imageDetailsView.imageIndex = _imageIndex;
    
    NSMutableArray *navigationViewsArray = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
    [navigationViewsArray removeLastObject];
    [navigationViewsArray addObject:imageDetailsView];

    [self.navigationController setViewControllers:navigationViewsArray animated:NO];
}

- (void)setAsEventImage {
    [_activityIndicator startAnimating];
    self.view.userInteractionEnabled = NO;
    NSString *userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    
    NSDictionary *imageInfo = [_listOfImages objectAtIndex:_imageIndex];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/event/%@/setEventImage/%@?userId=%@",kwebUrl,[_thisEvent objectForKey:@"id"],[imageInfo objectForKey:@"name"],userId];
    
    [UtilitiesHelper getResponseFor:nil url:[NSURL URLWithString:urlString] requestType:@"PUT" complettionBlock:^(BOOL success,NSDictionary *jsonDict){
        
        [_activityIndicator stopAnimating];
        self.view.userInteractionEnabled = YES;
        
        if (success) {
            NSLog(@"Image set as");
            if (_isEventSaved) {
                NSPredicate* entitySearchPredicate = [NSPredicate predicateWithFormat:@"(eventid == %@)",[_thisEvent objectForKey:@"id"]];
                
                NSArray *retData =  [CoreDataInterface searchObjectsInContext:@"Events" andPredicate:entitySearchPredicate andSortkey:@"eventid" isSortAscending:YES];
                
                Events *eventInfo;
                
                if (retData.count > 0) {
                    eventInfo = [retData objectAtIndex:0];
                    eventInfo.coverImage = [NSString stringWithFormat:@"%@",imageInfo];
                    [CoreDataInterface saveAll];
                }
            }
            else {
                [_thisEvent setObject:imageInfo forKey:@"coverImage"];
                
                NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:_thisEvent,@"event",[NSNumber numberWithInteger:_eventIndex],@"eventIndex", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"kUpdateListOfSearchAndPastEvents" object:dictionary];
            }
        }
    }];
}

- (void)saveImageInPhoneGallery {
    
    UIImage *currentImage;
    for (UIImageView *subImageView in _imagesScrollview.subviews) {
        NSLog(@"Tag -- subview : %ld and imageindex : %ld",(long)subImageView.tag, (long)_imageIndex);
        if (subImageView.tag == _imageIndex) {
            currentImage = subImageView.image;
            UIImageWriteToSavedPhotosAlbum(currentImage,
                                           self,
                                           @selector(savedPhotoImage:didFinishSavingWithError:contextInfo:),
                                           nil);
            break;
        }
    }
}

- (void)   savedPhotoImage:(UIImage *)image
  didFinishSavingWithError:(NSError *)error
               contextInfo:(void *)contextInfo
{
    NSString *message = @"This image has been saved to your Photos album";
    if (error) {
        message = [error localizedDescription];
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hoothere"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)shareThisImage {
    UIImage *currentImage;
    for (UIImageView *subImageView in _imagesScrollview.subviews) {
        NSLog(@"Tag -- subview : %ld and imageindex : %ld",(long)subImageView.tag, (long)_imageIndex);
        if (subImageView.tag == _imageIndex) {
            currentImage = subImageView.image;
            
            break;
        }
    }
    
    NSData *imageData = UIImagePNGRepresentation(currentImage);
    
    if (imageData.length > 10) {
//        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
//        [controller setInitialText:@""];
//        [controller addImage:currentImage];
//        [self presentViewController:controller animated:YES completion:Nil];
        NSArray *activityItems = @[@"", currentImage];

        UIActivityViewController *activityController =
        [[UIActivityViewController alloc]
         initWithActivityItems:activityItems
         applicationActivities:nil];
        
        [self presentViewController:activityController
                           animated:YES completion:nil];
    }
}

- (BOOL)checkUserIsUploader:(NSString *)uploaderId {
    BOOL isUploader = FALSE;
    
    NSString *userId=[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"] ];
    
    if ([userId isEqualToString:uploaderId]) {
        isUploader = TRUE;
    }
    return isUploader;
}

- (BOOL)checkUserIsHost {
    BOOL isHost = FALSE;
    
    NSString *hostId = @"";
    
    id userInfo = [_thisEvent objectForKey:@"user"];
    
    if ([userInfo isKindOfClass:[NSDictionary class]]) {
        hostId = [NSString stringWithFormat:@"%@",[userInfo objectForKey:@"id"]];
    }
    else if ([userInfo isKindOfClass:[NSString class]]) {
        hostId = [NSString stringWithFormat:@"%@",[[UtilitiesHelper stringToDictionary:userInfo] objectForKey:@"id"]];
    }

    
    NSString *userId=[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"] ];

    
    if ([hostId isEqualToString:userId]) {
        isHost = TRUE;
    }
    return isHost;
}

@end
