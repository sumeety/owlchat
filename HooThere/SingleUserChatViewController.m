//
//  SingleUserChatViewController.m
//  Hoothere
//
//  Created by UnoiaTech on 23/04/15.
//  Copyright (c) 2015 Quovantis Technologies. All rights reserved.
//

#import "SingleUserChatViewController.h"
#import "SingleUserChatTableViewCell.h"
#import "SMMessageDelegate.h"
#import "AppDelegate.h"
#import "TURNSocket.h"
#import "XMPPStream.h"
@interface SingleUserChatViewController ()<TURNSocketDelegate>
{
    UITextView *messageTextView;;
    UIBarButtonItem *sendBtn;
    NSArray *coreDataChatList;
    NSMutableArray *turnSockets;
        UIView *footerView;
}
@end

@implementation SingleUserChatViewController

- (id) initWithUser:(NSString *) userName {
    
    if (self = [super init]) {
        
        _frndName = userName; // @ missing
        turnSockets = [[NSMutableArray alloc] init];
    }
    
    return self;
    
}

- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    _chatTableView.delegate=self;
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    messageTextView = [[UITextView alloc] initWithFrame:CGRectMake(20, 0, 230, 32)] ;
    messageTextView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    messageTextView.layer.cornerRadius=6.0;
    messageTextView.layer.borderWidth=0.2;
    [messageTextView setFont:[UIFont systemFontOfSize:17]];
    messageTextView.layer.borderColor=[UIColor blackColor].CGColor;
    UIBarButtonItem * barItem = [[UIBarButtonItem alloc] initWithCustomView:messageTextView] ;
    [barItems addObject:barItem];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [barItems addObject:flexibleSpace];
    sendBtn = [[UIBarButtonItem alloc]initWithTitle:@"Send" style:UIBarButtonItemStylePlain target:self action:@selector(sendMessage)];
    sendBtn.tintColor=[UIColor colorWithRed:142.0/255 green:58.0/255 blue:173.0/255 alpha:1];
    [barItems addObject:sendBtn];
    [self.toolBar setItems:barItems animated:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    UITapGestureRecognizer *tapToResign=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapToResign:)];
    [self.view addGestureRecognizer:tapToResign];
   
    UIImage *backBtnImage=[UIImage imageNamed:@"back_nav"];
    UIButton *backBarBttn=[UIButton buttonWithType:UIButtonTypeCustom];
    [backBarBttn setImage:backBtnImage forState:UIControlStateNormal];
    backBarBttn.frame=CGRectMake(0, 0, backBtnImage.size.width, backBtnImage.size.height);
    [backBarBttn setImageEdgeInsets:UIEdgeInsetsMake(0, -30, 0, 0)];
    [backBarBttn addTarget:self action:@selector(backTapped) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarBtnItem=[[UIBarButtonItem alloc]initWithCustomView:backBarBttn];
    self.navigationItem.leftBarButtonItem=backBarBtnItem;
    
/*    UIBarButtonItem *barBtttn=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back_nav"] style:UIBarButtonItemStylePlain target:self action:@selector(backTapped)];
    self.navigationItem.leftBarButtonItem=barBtttn; */
    [_chatTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.title=self.titleText;
    messageTextView.delegate=self;
    
    XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@%@",self.title,kDomainName]];
    
    TURNSocket *turnSocket = [[TURNSocket alloc] initWithStream:[AppDel xmppStream] toJID:jid];
    [turnSockets addObject:turnSocket];
    [turnSocket startWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [AppDel goOnline];
    [AppDel xmppStream].hostPort = 5222;
    AppDelegate *del = [self appDelegate];
    del.messageDelegate = self;
   // del.xmppStream = [[XMPPStream alloc]init];
    
    [[AppDel xmppRoster] setAutoFetchRoster:YES];
    [[AppDel xmppRoster] setAutoAcceptKnownPresenceSubscriptionRequests:YES];
    
    [[AppDel xmppStream] addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [[AppDel xmppRoster] addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [AppDel connect];
    
    [self loadChatHistoryWithUserName:_frndName];
    [[AppDel xmppReconnect] activate:[AppDel xmppStream]];
    
    del.xmppMessageArchivingCoreDataStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    del.xmppMessageArchivingModule = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:[XMPPMessageArchivingCoreDataStorage sharedInstance]];
    [[AppDel xmppMessageArchivingModule] setClientSideMessageArchivingOnly:YES];
   // [[AppDel xmppMessageArchivingModule] activate:[AppDel xmppStream]];

   [_chatTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (coreDataChatList.count<1) {
        [self loadChatHistoryWithUserName:_frndName];
        [_chatTableView reloadData];
    }
    else {
        [self loadChatHistoryWithUserName:_frndName];
        [_chatTableView reloadData];
        NSIndexPath *topIndexPath=[NSIndexPath indexPathForRow:coreDataChatList.count-1 inSection:0];
        [_chatTableView scrollToRowAtIndexPath:topIndexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }

}

-(void)backTapped {
    AppDelegate *del = [self appDelegate];
    del.messageDelegate=nil;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)keyboardWillShow:(NSNotification *) notification {
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    CGRect frame=self.toolBar.frame;
    frame.origin.y=self.view.frame.size.height-270.0;
    _chatTableView.frame=CGRectMake(0, 0,self.view.frame.size.width, _chatTableView.frame.size.height-kbSize.height);
    self.toolBar.frame=frame;
    [UIView commitAnimations];
}

-(void)keyboardWillHide:(NSNotification *)notification {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    CGRect frame=self.toolBar.frame;
    frame.origin.y=self.view.frame.size.height-48;
    _chatTableView.frame=CGRectMake(0, 0,self.view.frame.size.width, self.view.frame.size.height-60);
    self.toolBar.frame=frame;
    [UIView commitAnimations];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)tapToResign:(UITapGestureRecognizer *)recoganizer {
    [messageTextView resignFirstResponder];
}
-(void)sendMessage {
    NSString *messageStr = messageTextView.text;
    
    if([messageStr length] > 0)
    {
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:messageStr];
        
        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
        
        [message addAttributeWithName:@"type" stringValue:@"chat"];
        XMPPJID *jid=[XMPPJID jidWithString:[NSString stringWithFormat:@"%@%@",_frndName,kDomainName]];
        [message addAttributeWithName:@"to"stringValue:[jid full]];
        [message addChild:body];
        [[AppDel xmppStream] sendElement:message];
 //       [self sendPushNotfication];
        [self loadChatHistoryWithUserName:_frndName];
        [_chatTableView reloadData];
        messageTextView.text = @"";
        
        NSString *userJid = [NSString stringWithFormat:@"%@%@",self.title,kDomainName];
        XMPPMessageArchivingCoreDataStorage *storage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
        NSManagedObjectContext *moc = [storage mainThreadManagedObjectContext];
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject"
                                                             inManagedObjectContext:moc];
        NSFetchRequest *request = [[NSFetchRequest alloc]init];
        NSString *predicateFrmt = @"bareJidStr == %@";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFrmt, userJid];
        request.predicate = predicate;
        [request setEntity:entityDescription];
        NSError *error;
        NSArray *messagesS = [moc executeFetchRequest:request error:&error];
        [self print:[[NSMutableArray alloc]initWithArray:messagesS]];
    }
    if (coreDataChatList.count<1) {
        [self loadChatHistoryWithUserName:_frndName];
        [_chatTableView reloadData];
        
    }
    else {
        [self loadChatHistoryWithUserName:_frndName];
        [_chatTableView reloadData];
        NSIndexPath *topIndexPath=[NSIndexPath indexPathForRow:coreDataChatList.count-1 inSection:0];
        [_chatTableView scrollToRowAtIndexPath:topIndexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
    [self loadChatHistoryWithUserName:_frndName];
    [_chatTableView reloadData];
}

-(void)print:(NSMutableArray*)messageS{
    /*
     for (XMPPMessageArchiving_Message_CoreDataObject *message in messageS) {
     NSXMLElement *element = [[NSXMLElement alloc] initWithXMLString:message.messageStr error:nil];
     NSLog(@"to param is %@",[element attributeStringValueForName:@"to"]);
     NSLog(@"NSCore object id param is %@",message.objectID);
     NSLog(@"bareJid param is %@",message.bareJid);
     NSLog(@"bareJidStr param is %@",message.bareJidStr);
     NSLog(@"body param is %@",message.body);
     NSLog(@"timestamp param is %@",message.timestamp);
     NSLog(@"outgoing param is %d",[message.outgoing intValue]);
     } */
}


#pragma mark -
#pragma mark Chat delegates

- (void)newMessageReceived:(NSMutableDictionary *)messageContent {
    // NSString *m = [messageContent objectForKey:@"msg"];
    // [messageContent setObject:[m substituteEmoticons] forKey:@"msg"];
    // [messageContent setObject:[NSString getCurrentTime] forKey:@"time"];
    [self loadChatHistoryWithUserName:_frndName];
    [_chatTableView reloadData];
    if (coreDataChatList.count<1) {
        [self loadChatHistoryWithUserName:_frndName];
        [_chatTableView reloadData];
        
    }
    else {
        [self loadChatHistoryWithUserName:_frndName];
        [_chatTableView reloadData];
        NSIndexPath *topIndexPath=[NSIndexPath indexPathForRow:coreDataChatList.count-1 inSection:0];
        [_chatTableView scrollToRowAtIndexPath:topIndexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
    [_chatTableView reloadData];
}
-(void)groupMessageReceived:(NSMutableDictionary *)messageReceived{
}
#pragma mark Table view delegates

static CGFloat padding = 20.0;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //  static NSString *CellIdentifier = @"SMMessageViewTableCell";
    NSMutableDictionary *messageDict = (NSMutableDictionary *) [coreDataChatList objectAtIndex:indexPath.row];
    
    SingleUserChatTableViewCell *cell  =  (SingleUserChatTableViewCell *) [tableView dequeueReusableCellWithIdentifier:nil];
    if(cell)
        cell = nil;
    
    if (cell == nil) {
        //  cell  = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell=[[SingleUserChatTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    _chatTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    NSString *outGoing=[[messageDict valueForKey:@"outgoing"] stringValue];
    NSString *message = [messageDict valueForKey:@"body"];
    
    CGSize  textSize = { 260.0, 10000.0 };
    NSMutableParagraphStyle *paragraphStyle=[[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode=NSLineBreakByWordWrapping;
    
    CGRect textRect=[message boundingRectWithSize:textSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13],NSParagraphStyleAttributeName:paragraphStyle.copy} context:nil];
    cell.messageContentView.text =message;
    textRect.size.width += (padding/2);
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.userInteractionEnabled = NO;

    
    if (indexPath.row == coreDataChatList.count-1) {
        cell.separatorInset = UIEdgeInsetsMake(0.f, cell.bounds.size.width, 0.f, 0.f);
    }
    
    if ([outGoing isEqualToString:@"1"]) {
     
        [cell.messageContentView setFrame:CGRectMake(320 - textRect.size.width - padding,
                                                     padding*2,
                                                     textRect.size.width,
                                                     textRect.size.height)];
        cell.senderAndTimeLabel.frame= CGRectMake(80, cell.messageContentView.frame.size.height+45, 300,20);
        [cell.labelBackgroundView setFrame:CGRectMake(cell.messageContentView.frame.origin.x - padding/2,
                                                      cell.messageContentView.frame.origin.y - padding/2,
                                                      textRect.size.width+padding,
                                                      textRect.size.height+padding)];
        cell.labelBackgroundView.backgroundColor=[UIColor colorWithRed:142.0/255 green:52.0/255 blue:173.0/255 alpha:1];
    }
    else if ([outGoing isEqualToString:@"0"])
    {
        
        [cell.messageContentView setFrame:CGRectMake(padding, padding*2, textRect.size.width, textRect.size.height)];
        cell.senderAndTimeLabel.frame= CGRectMake(-75, cell.messageContentView.frame.size.height+45, 300,20);
        
        [cell.labelBackgroundView setFrame:CGRectMake( cell.messageContentView.frame.origin.x - padding/2,
                                                      cell.messageContentView.frame.origin.y - padding/2,
                                                      textRect.size.width+padding,
                                                      textRect.size.height+padding)];
        cell.labelBackgroundView.backgroundColor=[UIColor lightGrayColor];
    }
    
    NSString *time=[messageDict valueForKey:@"timestamp"];
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
    
    NSDictionary *dict = (NSDictionary *)[coreDataChatList objectAtIndex:indexPath.row];
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
    return [coreDataChatList count];
    
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

- (void)loadChatHistoryWithUserName:(NSString *)userName
{
    NSString *userJid = [NSString stringWithFormat:@"%@%@",_frndName,kDomainName];
    NSString *userJid1= [NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults]valueForKey:@"user_name"],kDomainName];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    NSManagedObjectContext *context=[[self appDelegate].xmppMessageArchivingCoreDataStorage mainThreadManagedObjectContext];
    NSEntityDescription *messageEntity = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject" inManagedObjectContext:context];
    
    [request setEntity:messageEntity];
    [request setReturnsObjectsAsFaults:NO];
    NSString *predicateFrmt = @"bareJidStr == %@";
    NSString *predicateFrmt1 = @"streamBareJidStr == %@";
    NSPredicate *predicateName = [NSPredicate predicateWithFormat:predicateFrmt,userJid];
    NSPredicate *predicateSSID = [NSPredicate predicateWithFormat:predicateFrmt1,userJid1];
    
    NSArray *subPredicates = [NSArray arrayWithObjects:predicateName, predicateSSID, nil];
    
    NSPredicate *orPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
    
    request.predicate = orPredicate;
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSError *error = nil;
    coreDataChatList = [context executeFetchRequest:request error:&error];
    [_chatTableView reloadData];
}
@end
