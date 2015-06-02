//
//  EventAlbumViewController.m
//  Hoothere
//
//  Created by Abhishek Tyagi on 20/01/15.
//  Copyright (c) 2015 Quovantis Technologies. All rights reserved.
//

#import "EventAlbumViewController.h"
#import "UtilitiesHelper.h"
#import "ResizeImage.h"
#import "UIImageView+WebCache.h"
#import "CollectionViewCell.h"
#import "ImageDetailsViewController.h"

@interface EventAlbumViewController ()

@end

@implementation EventAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getEventDetails:) name:@"kLoadEventDetailsInformation" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateEventAlbumCollectionView:) name:@"kUpdateListOfEventAlbumImages" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getEventDetails:) name:@"kLoadSearchEventDetailsInformation" object:nil];


    _activityIndicator = [UtilitiesHelper loadCustomActivityIndicatorWithYorigin:10 Xorigin:self.view.center.x-50];
    [self.view addSubview:_activityIndicator];
    [self.view bringSubviewToFront:_activityIndicator];
    if (_canLoad) {
        [self getEventDetails];
    }
//    NSDictionary *uploadPictureDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"",@"", nil];
//
//    // Do any additional setup after loading the view.
//    _listOfImages = [[NSMutableArray alloc] initWithObjects:uploadPictureDictionary, nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getEventDetails {
    
//    if ([notification.object isKindOfClass:[Events class]]) {
//        Events *eventInfo = notification.object;
//        _thisEvent =[[UtilitiesHelper setUserDetailsDictionaryFromCoreDataWithInfo:eventInfo type:nil] mutableCopy] ;
//        [_thisEvent setObject:eventInfo.eventid forKey:@"id"];
//        _isEventSaved = TRUE;
//    }
//    else if ([notification.object isKindOfClass:[NSDictionary class]]) {
//        NSDictionary *notificationObject = notification.object;
//        _thisEvent = [[notificationObject objectForKey:@"event"] mutableCopy];
//        _isEventSaved = FALSE;
//        _eventIndex = [[notificationObject objectForKey:@"eventIndex"] integerValue];
//    }
    
    NSPredicate* entitySearchPredicate = [NSPredicate predicateWithFormat:@"(eventid == %@)",[_thisEvent objectForKey:@"id"]];
    
    NSArray *retData =  [CoreDataInterface searchObjectsInContext:@"Events" andPredicate:entitySearchPredicate andSortkey:@"eventid" isSortAscending:YES];
    
    if (retData.count > 0) {
        _isEventSaved = TRUE;
    }
    else {
        _isEventSaved = FALSE;
    }
    
    if ([_thisEvent objectForKey:@"guestStatus" ] !=nil && ![[_thisEvent objectForKey:@"guestStatus" ] isEqual:[NSNull null]]) {
        if (![[_thisEvent objectForKey:@"guestStatus" ]  isEqualToString:@"I"]) {
            _canUpload = TRUE;
        }
    }
    else {
        _canUpload = FALSE;
    }
    
    [self getEventImages];
}

- (void)setCanUploadValue:(NSNotification *)notification {
    
}

- (void)getEventImages {
    NSString *urlString = [NSString stringWithFormat:@"%@/event/%@/getAlbum",kwebUrl,[_thisEvent objectForKey:@"id"]];
    NSLog(@"Get Album API %@",urlString);
    [UtilitiesHelper fetchListOfHootThereFriends:[NSURL URLWithString:urlString] requestType:@"GET" complettionBlock:^(BOOL success,NSDictionary *jsonDict){
        
        if (success) {
            NSLog(@"response from server %@ ",jsonDict);
            [self loadImages:jsonDict];
        }
        
    }];
}

- (void)updateEventAlbumCollectionView:(NSNotification *)notification {
    _listOfImages = [[NSMutableArray alloc] init];
    _listOfImages = notification.object;
    if (_canUpload) {
        NSDictionary *uploadPictureDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"",@"", nil];
        [_listOfImages insertObject:uploadPictureDictionary atIndex:0];
    }
    [eventAlbumView reloadData];
}

- (void)loadImages:(NSDictionary *)dictionary {
    _listOfImages = [[NSMutableArray alloc] init];
    _listOfImages = [[dictionary objectForKey:@"eventAlbum"] mutableCopy];
    if (_canUpload) {
        NSDictionary *uploadPictureDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"",@"", nil];
        [_listOfImages insertObject:uploadPictureDictionary atIndex:0];
    }
    [eventAlbumView reloadData];
}

#pragma mark C0llectionview Delegate-------------

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _listOfImages.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"albumCell";

    CollectionViewCell *cell = (CollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    NSDictionary *contactInfo = [_listOfImages objectAtIndex:indexPath.row];
    
    if (_canUpload && indexPath.row == 0) {
        
        cell.albumImageView.image = [UIImage imageNamed:@"take_photo.png"];
        
        return cell;
    }
    
    UIImage* image = [UIImage imageNamed:@"default_gallery.png"];
    image = [ResizeImage squareImageWithImage:image scaledToSize:CGSizeMake(100, 100)];
    cell.albumImageView.image = image;
    
    NSString *imageUrl = [contactInfo objectForKey:@"thumbnailUrl"];
    if (imageUrl != nil &&  ![imageUrl isEqual:[NSNull null]]) {
        [cell.albumImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:image];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(104, 104);
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 4;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];

    if (_canUpload && indexPath.row == 0) {
        [self cameraButtonClicked];
    return;
    }
    
    NSMutableArray *imageList = [[NSMutableArray alloc] initWithArray:_listOfImages];
    
    ImageDetailsViewController *imageDetailsView = [self.storyboard instantiateViewControllerWithIdentifier:@"imageDetailsView"];
    imageDetailsView.title = [_thisEvent objectForKey:@"name"];
    if (_canUpload) {
        imageDetailsView.imageIndex = indexPath.row-1;
        [imageList removeObjectAtIndex:0];
    }
    else {
        imageDetailsView.imageIndex = indexPath.row;
    }
    imageDetailsView.eventIndex = _eventIndex;
    imageDetailsView.listOfImages = imageList;
    imageDetailsView.thisEvent = _thisEvent;
    imageDetailsView.isEventSaved = _isEventSaved;
    [self.navigationController pushViewController:imageDetailsView animated:YES];
}

#pragma mark upload image methods and delegates ---------

- (void)cameraButtonClicked {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Choose from Library", @"Take Picture", nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    pickerController = [[UIImagePickerController alloc]  init];
    pickerController.allowsEditing = NO;
    pickerController.delegate = self;
    
    if (buttonIndex == 0) {
        pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:pickerController animated:YES completion:nil];
    }
    else if (buttonIndex == 1) {
        pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:pickerController animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [self uploadImageToEventAlbum:img];
    
    [self dismissViewControllerAnimated:pickerController completion:nil];
}

- (void)uploadImageToEventAlbum:(UIImage *)image {
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
    self.view.userInteractionEnabled = NO;
    [_activityIndicator startAnimating];
    UIImage *scaledImage = [self resizeImage:image];
    NSData *imageData = UIImagePNGRepresentation(scaledImage);
    
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                imageData,@"file",
                                @"I", @"type",nil];
    NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/event/%@/upload?userId=%@&caption=%@",kwebUrl,[_thisEvent objectForKey:@"id"],uid,@""];
    
    [UtilitiesHelper getResponseFor:dictionary url:[NSURL URLWithString:urlString] requestType:@"POST" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {
         self.view.userInteractionEnabled = YES;

         [_activityIndicator stopAnimating];
         app.networkActivityIndicatorVisible = NO;
         if (success) {
             [self loadImages:jsonDict];
         }
     }];
}

-(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width
{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(UIImage*)resizeImage:(UIImage*)sourceImage;
{
    float oldWidth = sourceImage.size.width;
    float oldHeight = sourceImage.size.height;
    float scaleFactor = 1;
    float newHeight = 1;
    float newWidth = 1;
    if (oldHeight > oldWidth && oldHeight > 600) {
        scaleFactor = 600/oldHeight;
        newHeight = 600;
        newWidth = oldWidth * scaleFactor;
    }
    else if (oldWidth > oldHeight && oldWidth > 600) {
        scaleFactor = 600/oldWidth;
        newWidth = 600;
        newHeight = oldHeight * scaleFactor;
    }
    else {
        newWidth = oldWidth;
        newHeight = oldHeight;
    }
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


@end
