//
//  PrimaryContentViewController.m
//  MapAnimationDemo
//
//  Created by Gill on 28/02/2019.
//  Copyright © 2019 Gill. All rights reserved.
//

#import "PrimaryContentViewController.h"
#import "PanelViewController.h"

@interface PrimaryContentViewController ()
@property (nonatomic, strong) MKMapView *mapView;
@end

@implementation PrimaryContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMap];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)setupMap {
   
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _mapView.showsUserLocation = YES;
    _mapView.delegate = self;
    
    [self.view addSubview:_mapView];
}

@end
