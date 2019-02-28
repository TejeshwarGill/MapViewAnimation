//
//  PanelViewController.h
//  MapAnimationDemo
//
//  Created by Gill on 28/02/2019.
//  Copyright © 2019 Gill. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PanelPosition) {
    PanelPositionClosed,
    PanelPositionCollapsed,
    PanelPositionPartiallyRevealed,
    PanelPositionOpen,
};

@class PanelViewController;

static CGFloat TopInset = 20.0f;

@protocol PanelDelegate <NSObject>
@property (nonatomic, strong) UIView *view;

- (void)cPositionDidChange:(PanelViewController *)c;
@optional
- (void)cDraggingProgress:(CGFloat)progress;//0 - 1

- (CGFloat)collapsedcHeight;
- (CGFloat)partialRevealcHeight;
- (NSSet <NSNumber *> *)supportPannelPosition;

- (UIVisualEffectView *)cBackgroundVisualEffectView;
- (CGFloat)cCornerRadius;
- (UIView *)backgroundDimmingView;
@end

@protocol PanelPrimaryDelegate <NSObject>
@property (nonatomic, strong) UIView *view;
@end

@protocol PanelScrollViewDelegate
- (void)cScrollViewDidScroll:(UIScrollView *)scrollView;
@end

@interface PanelViewController : UIViewController <PanelScrollViewDelegate>

@property (nonatomic, assign) PanelPosition currentPosition;
@property (nonatomic, assign) BOOL shouldScrollcScrollView;

- (instancetype)initWithPrimaryContentViewController:(id<PanelPrimaryDelegate>)primaryContentViewController
                         contentViewController:(id<PanelDelegate>)contentViewController;
@end


