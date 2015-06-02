//
//  ChatViewController.m
//  Bindle
//
//  Created by UnoiaTech on 30/03/15.
//  Copyright (c) 2015 UnoiaTech. All rights reserved.
//

#import "ChatViewController.h"
#import "SettingsViewController.h"
@interface ChatViewController ()

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *leftBarBttn=[[UIBarButtonItem alloc]initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(closeTapped)];
    self.navigationItem.leftBarButtonItem=leftBarBttn;
    leftBarBttn.tintColor=[UIColor colorWithRed:43.0/255 green:177.0/255 blue:138.0/255 alpha:1];
    UIBarButtonItem *rightBarBttn=[[UIBarButtonItem alloc]initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(settingsTapped)];
        rightBarBttn.tintColor=[UIColor colorWithRed:43.0/255 green:177.0/255 blue:138.0/255 alpha:1];
    self.navigationItem.rightBarButtonItem=rightBarBttn;
    self.title=@"#originally";
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)closeTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)settingsTapped {
    SettingsViewController *settingsVC=[[SettingsViewController alloc]initWithNibName:@"SettingsViewController" bundle:nil];
    [self.navigationController pushViewController:settingsVC animated:YES];
}
@end
