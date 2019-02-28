//
//  PrimaryContentViewController.h
//  MapAnimationDemo
//
//  Created by Gill on 28/02/2019.
//  Copyright © 2019 Gill. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@protocol PanelPrimaryDelegate;

@interface PrimaryContentViewController : UIViewController <PanelPrimaryDelegate,MKMapViewDelegate>
@end
