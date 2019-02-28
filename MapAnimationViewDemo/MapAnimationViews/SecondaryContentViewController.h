//
//  SecondaryContentViewController.h
//  MapAnimationDemo
//
//  Created by Gill on 28/02/2019.
//  Copyright © 2019 Gill. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PanelViewController.h"

@protocol PanelDelegate;

@interface SecondaryContentViewController : UIViewController <PanelDelegate>
@property (nonatomic, weak) id<PanelScrollViewDelegate> cScrollDelegate;
@end
