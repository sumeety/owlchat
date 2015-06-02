//
//  UserListViewController.m
//  Hoothere
//
//  Created by UnoiaTech on 27/05/15.
//  Copyright (c) 2015 Quovantis Technologies. All rights reserved.
//

#import "UserListViewController.h"
#import "UtilitiesHelper.h"
#import "CoreDataInterface.h"
#import "MessageTableViewCell.h"
#import "SingleUserChatViewController.h"
@interface UserListViewController ()

@end

@implementation UserListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _listOfFriends =[[NSMutableArray alloc]init];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    self.title=@"Select Friend";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        _activityIndicator = [UtilitiesHelper loadCustomActivityIndicatorWithYorigin:self.view.center.y -80 Xorigin:self.view.center.x-50];
    }
    else {
        _activityIndicator = [UtilitiesHelper loadCustomActivityIndicatorWithYorigin:self.view.center.x-80 Xorigin:self.view.center.y -50];
    }
    [self.view addSubview:_activityIndicator];
    [self.view bringSubviewToFront:_activityIndicator];
     [self getListofFriends];
    
    UIImage *backBtnImage=[UIImage imageNamed:@"back_nav"];
    UIButton *backBarBttn=[UIButton buttonWithType:UIButtonTypeCustom];
    [backBarBttn setImage:backBtnImage forState:UIControlStateNormal];
    backBarBttn.frame=CGRectMake(0, 0, backBtnImage.size.width, backBtnImage.size.height);
    [backBarBttn setImageEdgeInsets:UIEdgeInsetsMake(0, -30, 0, 0)];
    [backBarBttn addTarget:self action:@selector(backTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarBtnItem=[[UIBarButtonItem alloc]initWithCustomView:backBarBttn];
    self.navigationItem.leftBarButtonItem=backBarBtnItem;
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
   
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getListofFriends {
    NSLog(@"GET FRIEND LIST");
    [_activityIndicator startAnimating];
    
    NSMutableArray *friends =  [CoreDataInterface searchObjectsInContext:@"Friends" andPredicate:nil andSortkey:@"firstName" isSortAscending:YES];
      NSLog(@" %d",_listOfFriends.count);
    for (int i = 0; i < friends.count; i++) {
        Friends *contactInfo = [friends objectAtIndex:i];
        if ([[contactInfo status] isEqualToString:@"F"])  {
            [_listOfFriends addObject:contactInfo];
          
        }
    }
    [_activityIndicator stopAnimating];
    [_tableView reloadData];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"%d",_listOfFriends.count);
    return _listOfFriends.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *CellIdentifier = @"MessageTableViewCell";
    
    NSDictionary *cellData=[_listOfFriends objectAtIndex:indexPath.row];
    
    MessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"MessageTableViewCell" owner:nil options:nil];
        cell = (MessageTableViewCell*)[topLevelObjects objectAtIndex:0];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    [cell.textLabel setHidden:YES];
    
    [cell.userFrndImage setImage:[UIImage imageNamed:@"defaultpic.png"]];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.frndName.text=[cellData valueForKey:@"fullName"];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id contactInfo;
    MessageTableViewCell *cell= (MessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    contactInfo = [_listOfFriends objectAtIndex:indexPath.row];
    NSLog(@"contact info is %@",contactInfo);
    SingleUserChatViewController *singleUserChatVC=[[SingleUserChatViewController alloc]initWithUser:cell.frndName.text];
    singleUserChatVC.titleText=cell.frndName.text;
    singleUserChatVC.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:singleUserChatVC animated:YES];
}

-(void)backTapped:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
