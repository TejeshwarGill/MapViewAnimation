//
//  ViewController.m
//  MapAnimationDemo
//
//  Created by Gill on 28/02/2019.
//  Copyright © 2019 Gill. All rights reserved.
//

#import "ViewController.h"
#import "PanelViewController.h"
#import "PrimaryContentViewController.h"
#import "SecondaryContentViewController.h"

@interface ViewController ()
@property (nonatomic, strong) PanelViewController *PannelViewController;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PrimaryContentViewController *p = [PrimaryContentViewController new];
    SecondaryContentViewController *d = [SecondaryContentViewController new];
    self.PannelViewController = [[PanelViewController alloc] initWithPrimaryContentViewController:p contentViewController:d];
    
    d.cScrollDelegate = self.PannelViewController;
    
    [self addChildViewController:self.PannelViewController];
    self.PannelViewController.view.frame = self.view.bounds;
    [self.view addSubview:self.PannelViewController.view];
}

@end

