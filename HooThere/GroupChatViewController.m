//
//  GroupChatViewController.m
//  Hoothere
//
//  Created by UnoiaTech on 02/04/15.
//  Copyright (c) 2015 Quovantis Technologies. All rights reserved.
//

#import "GroupChatViewController.h"
#import "GroupChatInfoViewController.h"
#import "GroupChatTableViewCell.h"
#import "AppDelegate.h"
@interface GroupChatViewController ()

@end

@implementation GroupChatViewController
{
     NSMutableArray *turnSockets;
    NSMutableArray *results,*occupantArray;
    UIView *footerView;
}
- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
     _chatTableView.delegate=self;
    turnSockets = [[NSMutableArray alloc] init];
    self.title=[NSString stringWithFormat:@"%@",_groupName];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
  //  results=[[NSMutableArray alloc]init];
    occupantArray=[[NSMutableArray alloc]init];
    
   // UIBarButtonItem *rightBarButton=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"info.png"] style:UIBarButtonItemStylePlain target:self action:@selector(chatInfo)];
   // self.navigationItem.rightBarButtonItem=rightBarButton;
    
  
    
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    UIImage *cameraImage = [UIImage imageNamed:@"camera_image.png"];
    UIButton *cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cameraBtn.bounds = CGRectMake( 0, 0, cameraImage.size.width, cameraImage.size.height );
    [cameraBtn setImage:cameraImage forState:UIControlStateNormal];
    [cameraBtn addTarget:self action:@selector(selectImage) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *faceBtn = [[UIBarButtonItem alloc] initWithCustomView:cameraBtn];
    [barItems addObject:faceBtn];
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [barItems addObject:flexSpace];
    
    _messageTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 170, 32)];
    _messageTextField.borderStyle=UITextBorderStyleNone;
    _messageTextField.placeholder=@"Type a message...";
     _messageTextField.delegate=self;
    [_messageTextField setFont:[UIFont systemFontOfSize:14]];
    _messageTextField.layer.borderColor=[UIColor colorWithRed:85.0/255 green:85.0/255 blue:85.0/255 alpha:1].CGColor;
    [_messageTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    UIBarButtonItem * barItem = [[UIBarButtonItem alloc] initWithCustomView:_messageTextField] ;
    [barItems addObject:barItem];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [barItems addObject:flexibleSpace];
    
    _sendMessageBttn= [[UIBarButtonItem alloc]initWithTitle:@"send" style:UIBarButtonItemStylePlain target:self action:@selector(sendMessage)];
    _sendMessageBttn.tintColor=[UIColor colorWithRed:142.0/255 green:58.0/255 blue:173.0/255 alpha:1];
    [barItems addObject:_sendMessageBttn];

    [_keyboardToolbar setItems:barItems animated:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    UITapGestureRecognizer *tapRec = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(tapToResign:)];
    [self.view addGestureRecognizer: tapRec];
    
    
    UIImage *backBtnImage=[UIImage imageNamed:@"back_nav"];
    UIButton *backBarBttn=[UIButton buttonWithType:UIButtonTypeCustom];
    [backBarBttn setImage:backBtnImage forState:UIControlStateNormal];
    backBarBttn.frame=CGRectMake(0, 0, backBtnImage.size.width, backBtnImage.size.height);
    [backBarBttn setImageEdgeInsets:UIEdgeInsetsMake(0, -30, 0, 0)];
    [backBarBttn addTarget:self action:@selector(backTapped) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarBtnItem=[[UIBarButtonItem alloc]initWithCustomView:backBarBttn];
    self.navigationItem.leftBarButtonItem=backBarBtnItem;
    
    UIImage *infoBtnImage=[UIImage imageNamed:@"info_owlChat.png"];
    UIButton *infoBarBttn=[UIButton buttonWithType:UIButtonTypeCustom];
    [infoBarBttn setImage:infoBtnImage forState:UIControlStateNormal];
    infoBarBttn.frame=CGRectMake(0, 0, infoBtnImage.size.width, infoBtnImage.size.height);
    [infoBarBttn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [infoBarBttn addTarget:self action:@selector(chatInfo) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *infoBarBtnItem=[[UIBarButtonItem alloc]initWithCustomView:infoBarBttn];
    self.navigationItem.rightBarButtonItem=infoBarBtnItem;
     //   [self setupGroupChat];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupGroupChat];
    
    if (![self.fromView isEqualToString:@"chatViewController"]) {
        [AppDel joinMultiUserChatRoom:self.title];
          NSLog(@"room with app delegate JID %@",[AppDel xmppRoom].roomJID);
    }

    if (results.count<1) {
      [self loadChatHistoryWithUserName];
        [_chatTableView reloadData];
    }
    else {
        [self reloadChat];
    }
}
-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    [AppDel leaveGroup];
 //   NSLog(@"view disappear ");
    //
}
#pragma Mark Show/Hide toolBar with Keyboard
-(void)keyboardWillShow:(NSNotification *) notification {
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    CGRect frame=self.keyboardToolbar.frame;
    frame.origin.y=self.view.frame.size.height-270.0;
    _chatTableView.frame=CGRectMake(0, 0,self.view.frame.size.width, _chatTableView.frame.size.height-kbSize.height+14);
    self.keyboardToolbar.frame=frame;
    [UIView commitAnimations];
}

-(void)keyboardWillHide:(NSNotification *)notification {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    CGRect frame=self.keyboardToolbar.frame;
    frame.origin.y=self.view.frame.size.height-48;
    _chatTableView.frame=CGRectMake(0, 0,self.view.frame.size.width, self.view.frame.size.height-46);
    self.keyboardToolbar.frame=frame;
    [UIView commitAnimations];
}


-(void)tapToResign:(UITapGestureRecognizer *)recognizer {
    [_messageTextField resignFirstResponder];
}

-(void)chatInfo {
    GroupChatInfoViewController *chatInfoVC=[[GroupChatInfoViewController alloc]initWithNibName:@"GroupChatInfoViewController" bundle:nil];
    chatInfoVC.eventName=_groupName;
    chatInfoVC.room=[AppDel xmppRoom];
    [self.navigationController pushViewController:chatInfoVC animated:YES];
}


-(void)selectImage {
    [_messageTextField resignFirstResponder];
  /*  UIActionSheet *actionSheet=[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take a new photo",@"Choose from gallery", nil];
        actionSheet.tintColor=[UIColor colorWithRed:142.0/255 green:58.0/255 blue:173.0/255 alpha:1];
    [actionSheet showInView:self.view]; */
  
    // UIActionSheet no more supported with iOS8.
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alert.view setTintColor:[UIColor colorWithRed:142.0f/255 green:58.0f/255 blue:173.0f/255 alpha:1]];
    UIAlertAction *captureWithCam=[UIAlertAction actionWithTitle:@"Take a new photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self takeNewPhoto];
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *selectFromGallery=[UIAlertAction actionWithTitle:@"Choose from gallery" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self selectFromGallery];
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *cancelActionSheet=[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:captureWithCam];
    [alert addAction:selectFromGallery];
    [alert addAction:cancelActionSheet];
    [self presentViewController:alert animated:YES completion:nil];
}

// UIActionSheet for versions below iOS8
/*
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex==0) {
        [self takeNewPhoto];
    }
    else if (buttonIndex==1) {
        [self selectFromGallery];
    }
}
- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    for (UIView *subview in actionSheet.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            [button setTitleColor:[UIColor colorWithRed:142.0f/255 green:58.0f/255 blue:173.0f/255 alpha:1] forState:UIControlStateNormal];
        }
    }
}
*/
-(void)takeNewPhoto{
    
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.navigationBar.barStyle = UIBarStyleDefault;
        [self.navigationController presentViewController:picker animated:YES completion:nil];

    }
}

-(void)selectFromGallery {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *picker=[[UIImagePickerController alloc]init];
        picker.delegate=self;
        picker.allowsEditing=YES;
        picker.sourceType =UIImagePickerControllerSourceTypePhotoLibrary;
        picker.navigationBar.barStyle=UIBarStyleDefault;
        [self.navigationController presentViewController:picker animated:YES completion:nil];
    }
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage =[info valueForKey:UIImagePickerControllerOriginalImage];
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];

}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)sendMessage
{   NSString *messageStr =_messageTextField.text;
    
    if([messageStr length] > 0)
    {
       // XMPPJID *roomJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",self.title,kGroupChatDomain]];
         // _xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:_xmppRoomCoreDataStorage jid:roomJID
         //                                   dispatchQueue:dispatch_get_main_queue()];
         //[_xmppRoom   activate:[AppDel xmppStream]];
        //  [_xmppRoom   addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        [[AppDel xmppRoom]   sendMessageWithBody:messageStr];
        self.messageTextField.text=@"";
        [self reloadChat];
        [self performSelector:@selector(reloadChat) withObject:nil afterDelay:.2];
    }
    if (results.count<1) {
        [self loadChatHistoryWithUserName];
          [_chatTableView reloadData];
    }
    else {
        [self reloadChat];
        [self performSelector:@selector(reloadChat) withObject:nil afterDelay:.2];
    }
   [self loadChatHistoryWithUserName];
    [_chatTableView reloadData];
}

-(void)groupMessageReceived:(NSMutableDictionary *)messageReceived{

    [occupantArray addObject:messageReceived];
    if (results.count<1) {
        [self performSelector:@selector(reloadChat) withObject:nil afterDelay:.2];
        [self loadChatHistoryWithUserName];
        [_chatTableView reloadData];
    }
    else {
        [self reloadChat];
        [self performSelector:@selector(reloadChat) withObject:nil afterDelay:.2];
    }
    [self loadChatHistoryWithUserName];
    [_chatTableView reloadData];
}
-(void)newMessageReceived:(NSMutableDictionary *)messageContent{
    
}

#pragma Mark UITextField Delegate/DataSource

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    NSLog(@"text field delegate calling");
   /* if (textField.text.length==0) {
        _sendMessageBttn.title=@"options";
    }
    else {
        _sendMessageBttn.title=@"send";
    } */
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
   /* if (textField.text.length==0) {
        _sendMessageBttn.title=@"options";
        return YES;
    }
    else {
        _sendMessageBttn.title=@"send";
        return YES;
    } */
    return YES;
}

-(void)textFieldDidChange:(UITextField *)textField {
    
        _sendMessageBttn.title=@"send";
}



#pragma Mark UITableViewDelegate/UITableViewDataSource methods 

static CGFloat padding = 20.0;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *messageDict = (NSMutableDictionary *) [results objectAtIndex:indexPath.row];
    GroupChatTableViewCell *cell  =  (GroupChatTableViewCell *) [tableView dequeueReusableCellWithIdentifier:nil];
    if(cell)
        cell = nil;
    
    if (cell == nil) {
        //  cell  = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell=[[GroupChatTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    _chatTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    NSString *outGoing=[[messageDict valueForKey:@"isFromMe"] stringValue];
    NSString *message =[NSString stringWithFormat:@"%@",[messageDict valueForKey:@"body"]];
    NSString *occupantName=[NSString stringWithFormat:@"%@ : %@",[[messageDict valueForKey:@"jidStr"] lastPathComponent],message];

    CGSize  textSize = { 260.0, 10000.0 };
    NSMutableParagraphStyle *paragraphStyle=[[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode=NSLineBreakByWordWrapping;
    
    CGRect textRect=[message boundingRectWithSize:textSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13],NSParagraphStyleAttributeName:paragraphStyle.copy} context:nil];
    CGRect textRect1=[occupantName boundingRectWithSize:textSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13],NSParagraphStyleAttributeName:paragraphStyle.copy} context:nil];
    
    textRect.size.width += (padding/2);
    textRect1.size.width +=(padding/2);
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.userInteractionEnabled = NO;

    if (indexPath.row == results.count-1) {
        cell.separatorInset = UIEdgeInsetsMake(0.f, cell.bounds.size.width, 0.f, 0.f);
    }
    
    if ([outGoing isEqualToString:@"1"]) {
        cell.messageContentView.text=message;
        [cell.messageContentView setFrame:CGRectMake(320 - textRect.size.width - padding,
                                                     padding*2,
                                                     textRect.size.width,
                                                     textRect.size.height+3)];
        cell.senderAndTimeLabel.frame= CGRectMake(80, cell.messageContentView.frame.size.height+45, 300,20);
        cell.messageContentView.textAlignment=NSTextAlignmentLeft;
        
        [cell.labelBackgroundView setFrame:CGRectMake(cell.messageContentView.frame.origin.x - padding/2,
                                              cell.messageContentView.frame.origin.y - padding/2,
                                              textRect.size.width+padding,
                                              textRect.size.height+padding)];
        cell.labelBackgroundView.backgroundColor=[UIColor colorWithRed:142.0/255 green:52.0/255 blue:173.0/255 alpha:1];
    }
    else if ([outGoing isEqualToString:@"0"])
    {
        cell.messageContentView.text=occupantName;
        [cell.messageContentView setFrame:CGRectMake(padding, padding*2, textRect1.size.width, textRect1.size.height+3)];
        cell.senderAndTimeLabel.frame= CGRectMake(-75, cell.messageContentView.frame.size.height+45, 300,20);
        cell.messageContentView.textAlignment=NSTextAlignmentLeft;
        [cell.labelBackgroundView setFrame:CGRectMake( cell.messageContentView.frame.origin.x - padding/2,
                                              cell.messageContentView.frame.origin.y - padding/2,
                                              textRect1.size.width+padding,
                                              textRect1.size.height+padding)];
        cell.labelBackgroundView.backgroundColor=[UIColor lightGrayColor];
    }
    
    NSString *time=[messageDict valueForKey:@"localTimestamp"];
    NSString *timeNew=[NSString stringWithFormat:@"%@",time];
    NSRange range=[timeNew rangeOfString:@"+"];
    NSString *newTime=[timeNew substringToIndex:range.location];
    
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
    cell.senderAndTimeLabel.text =[NSString stringWithFormat:@"%@",dateStr];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dict = (NSDictionary *)[results objectAtIndex:indexPath.row];
    NSString *msg = [dict valueForKey:@"body"];
    CGSize  textSize = { 260.0, 10000.0 };
    NSMutableParagraphStyle *paragraphStyle=[[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode=NSLineBreakByWordWrapping;
    
    CGRect textRect=[msg boundingRectWithSize:textSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13],NSParagraphStyleAttributeName:paragraphStyle.copy} context:nil];
    
    textRect.size.height += padding*2;
    
    CGFloat height = textRect.size.height < 65 ? 65 : textRect.size.height;
    return height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [results count];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    footerView=[[UIView alloc] initWithFrame:CGRectMake(0,0,320,1)];
    footerView.backgroundColor=[UIColor clearColor];
    return footerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 30.0f;
}

#pragma Mark Retrieve Chat History From CoreData

- (void)loadChatHistoryWithUserName
{
    NSString *userJid=[NSString stringWithFormat:@"%@@%@",self.title,kGroupChatDomain];
  //  _xmppRoomCoreDataStorage=[XMPPRoomCoreDataStorage sharedInstance];
    NSManagedObjectContext *moc = [_xmppRoomCoreDataStorage mainThreadManagedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XMPPRoomMessageCoreDataStorageObject"
                                                         inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    
    [request setEntity:entityDescription];
    NSString *predicateFrmt = @"roomJIDStr == %@";
    
    NSPredicate *predicateName = [NSPredicate predicateWithFormat:predicateFrmt,userJid];
    request.predicate = predicateName;
    NSError *error = nil;

    NSArray *messagesS = [moc executeFetchRequest:request error:&error];
    results=[NSMutableArray arrayWithArray:messagesS];
  /*  for (XMPPRoomMessageCoreDataStorageObject *message in messagesS) {
        NSLog(@"messageStr param is %@",message.message);
        NSXMLElement *element = [[NSXMLElement alloc] initWithXMLString:message.message.body error:nil];
        NSLog(@"to param is %@",[element attributeStringValueForName:@"from"]);
        //   NSLog(@"NSCore object id param is %@",message.objectID);
        NSLog(@"bareJid param is %@",message.jid);
        NSLog(@"roomJid param is %@",message.roomJID);
        NSLog(@"body param is %@",message.body);
        NSLog(@"timestamp param is %@",message.localTimestamp);
        NSLog(@"outgoing param is %d",message.isFromMe );
     //   [results addObject:message];
                }*/
    [_chatTableView reloadData];
}
-(void) reloadChat{
    [self loadChatHistoryWithUserName];
    [_chatTableView reloadData];
    if (results.count>1) {
        NSIndexPath *topIndexPath=[NSIndexPath indexPathForRow:results.count-1 inSection:0];
        [_chatTableView scrollToRowAtIndexPath:topIndexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
}
-(void)backTapped {
    [AppDel leaveGroup];
    [_xmppRoom deactivate];
    [_xmppRoom removeDelegate:self delegateQueue:dispatch_get_main_queue()];
    [[self xmppStream] removeDelegate:self delegateQueue:dispatch_get_main_queue()];
    [[self xmppRoster] removeDelegate:self delegateQueue:dispatch_get_main_queue()];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)setupGroupChat {
    XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",self.title,kGroupChatDomain]];
    TURNSocket *turnSocket = [[TURNSocket alloc] initWithStream:[AppDel xmppStream] toJID:jid];
    [turnSockets addObject:turnSocket];
    [turnSocket startWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [AppDel goOnline];
    self.xmppStream.hostPort = 5222;
    AppDelegate *del = [self appDelegate];
    del.messageDelegate = self;
    
    [[AppDel xmppRoster] setAutoFetchRoster:YES];
    [[AppDel xmppRoster] setAutoAcceptKnownPresenceSubscriptionRequests:YES];
    
    [[AppDel xmppStream] addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [[AppDel xmppRoster] addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppReconnect activate:[AppDel xmppStream]];
    NSLog(@"xmppStream UserName %@",[AppDel xmppStream].myJID);
    [xmppMessageArchivingModule setClientSideMessageArchivingOnly:YES];
    _xmppRoomCoreDataStorage =[XMPPRoomCoreDataStorage sharedInstance];
    [self loadChatHistoryWithUserName];
    [_chatTableView reloadData];
}

@end
