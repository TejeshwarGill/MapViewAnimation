//
//  ScrollViewController.h
//  MapAnimationDemo
//
//  Created by Gill on 28/02/2019.
//  Copyright © 2019 Gill. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ScrollViewController;

@protocol ScrollViewControllerDelegate

- (BOOL)shouldTouchPassthroughScrollView:(ScrollViewController *)scrollView
                                   point:(CGPoint)point;

- (UIView *)viewToReceiveTouch:(ScrollViewController *)scrollView
                         point:(CGPoint)point;
@end

@interface ScrollViewController : UIScrollView
@property (nonatomic, weak) id<ScrollViewControllerDelegate> touchDelegate;
@end
