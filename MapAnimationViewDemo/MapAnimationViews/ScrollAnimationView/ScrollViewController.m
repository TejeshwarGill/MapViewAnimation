//
//  ScrollViewController.m
//  MapAnimationDemo
//
//  Created by Gill on 28/02/2019.
//  Copyright © 2019 Gill. All rights reserved.
//

#import "ScrollViewController.h"

@implementation ScrollViewController

#pragma mark - Override
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.touchDelegate) {
        if ([self.touchDelegate shouldTouchPassthroughScrollView:self point:point]) {
            UIView *view = [self.touchDelegate viewToReceiveTouch:self point:point];
            CGPoint p = [view convertPoint:point fromView:self];
            return [view hitTest:p withEvent:event];
        }
    }
    return [super hitTest:point withEvent:event];
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    return [super touchesShouldCancelInContentView:view];
}
@end
