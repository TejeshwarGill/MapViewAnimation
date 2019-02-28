//
//  PanelViewController.m
//  MapAnimationDemo
//
//  Created by Gill on 28/02/2019.
//  Copyright © 2019 Gill. All rights reserved.
//

#import "PanelViewController.h"
#import "ScrollViewController.h"

static CGFloat DefaultCollapsedHeight = 68.0f;
static CGFloat DefaultPartialRevealHeight = 264.0f;

static CGFloat BounceOverflowMargin = 20.0f;
static CGFloat DefaultDimmingOpacity = 0.5f;

static CGFloat DefaultShadowOpacity = 0.1f;
static CGFloat DefaultShadowRadius = 3.0f;

@interface PanelViewController () <UIScrollViewDelegate, UIGestureRecognizerDelegate, ScrollViewControllerDelegate>
@property (nonatomic, assign) CGPoint lastDragTargetContentOffSet;
@property (nonatomic, assign) BOOL isAnimatingcPosition;

@property (nonatomic, strong) UIPanGestureRecognizer *pan;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic, strong) UIView *primaryContentContainer;
@property (nonatomic, strong) UIView *cContentContainer;
@property (nonatomic, strong) ScrollViewController *cScrollView;
@property (nonatomic, strong) UIView *cShadowView;

@property (nonatomic, strong) UIVisualEffectView *cBackgroundVisualEffectView;

@property (nonatomic, strong) UIView *backgroundDimmingView;

@property (nonatomic, strong) id <PanelPrimaryDelegate>primaryContentViewController;
@property (nonatomic, strong) id <PanelDelegate>contentViewController;

@property (nonatomic, strong) NSSet <NSNumber *> *supportedPostions;
@end

@implementation PanelViewController

- (instancetype)initWithPrimaryContentViewController:(id<PanelPrimaryDelegate>)primaryContentViewController contentViewController:(id<PanelDelegate>)contentViewController {
    self = [super init];
    if (self) {
        self.primaryContentViewController = primaryContentViewController;
        self.contentViewController = contentViewController;
    }
    return self;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.lastDragTargetContentOffSet = CGPointZero;
    
    [self.cScrollView addSubview:self.cShadowView];
    
    if (self.cBackgroundVisualEffectView) {
        [self.cScrollView insertSubview:self.cBackgroundVisualEffectView aboveSubview:self.cShadowView];
        self.cBackgroundVisualEffectView.layer.cornerRadius = [self p_cornerRadius];
    }
    
    [self.cScrollView addSubview:self.cContentContainer];
    
    self.cScrollView.showsVerticalScrollIndicator = NO;
    self.cScrollView.showsHorizontalScrollIndicator = NO;
    self.cScrollView.bounces = NO;
    self.cScrollView.canCancelContentTouches = YES;
    self.cScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.cScrollView.touchDelegate = self;
    
    self.cShadowView.layer.shadowOpacity = DefaultShadowOpacity;
    self.cShadowView.layer.shadowRadius = DefaultShadowRadius;
    self.cShadowView.backgroundColor = [UIColor clearColor];
    
    
    self.pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizerAction:)];
    self.pan.delegate = self;
    [self.cScrollView addGestureRecognizer:self.pan];
    
    [self.view addSubview:self.primaryContentContainer];
    [self.view addSubview:self.backgroundDimmingView];
    [self.view addSubview:self.cScrollView];
    
}

- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
    [self.primaryContentContainer addSubview:self.primaryContentViewController.view];
    [self.primaryContentContainer sendSubviewToBack:self.primaryContentViewController.view];
    
    [self.cContentContainer addSubview:self.contentViewController.view];
    [self.cContentContainer sendSubviewToBack:self.contentViewController.view];
    
    self.primaryContentContainer.frame = self.view.bounds;
    
    CGFloat safeAreaTopInset;
    CGFloat safeAreaBottomInset;
    
    if (@available(iOS 11.0, *)) {
        safeAreaTopInset = self.view.safeAreaInsets.top;
        safeAreaBottomInset = self.view.safeAreaInsets.bottom;
    } else {
        safeAreaTopInset = self.topLayoutGuide.length;
        safeAreaBottomInset = self.bottomLayoutGuide.length;
    }
    
    if (@available(iOS 11.0, *)) {
        self.cScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.cScrollView.contentInset = UIEdgeInsetsMake(0, 0, self.bottomLayoutGuide.length, 0);
    }
    NSMutableArray <NSNumber *> *cStops = [[NSMutableArray alloc] init];
    
    if ([self.supportedPostions containsObject:@(PanelPositionCollapsed)]) {
        [cStops addObject:@([self collapsedHeight])];
    }
    
    if ([self.supportedPostions containsObject:@(PanelPositionPartiallyRevealed)]) {
        [cStops addObject:@([self partialRevealcHeight])];
    }
    
    if ([self.supportedPostions containsObject:@(PanelPositionOpen)]) {
        [cStops addObject:@(self.cScrollView.bounds.size.height - TopInset - safeAreaTopInset)];
    }
    
    CGFloat lowestStop = [[cStops valueForKeyPath:@"@min.floatValue"] floatValue];
    
    if ([self.supportedPostions containsObject:@(PanelPositionOpen)]) {
        self.cScrollView.frame = CGRectMake(0, TopInset + safeAreaTopInset, self.view.bounds.size.width, self.view.bounds.size.height - TopInset - safeAreaTopInset);
    } else {
        CGFloat adjustedTopInset = [self.supportedPostions containsObject:@(PanelPositionPartiallyRevealed)] ? [self partialRevealcHeight] : [self collapsedHeight];
        self.cScrollView.frame = CGRectMake(0, self.view.bounds.size.height - adjustedTopInset, self.view.bounds.size.width, adjustedTopInset);
    }
    
    self.cContentContainer.frame = CGRectMake(0, self.cScrollView.bounds.size.height - lowestStop, self.cScrollView.bounds.size.width, self.cScrollView.bounds.size.height + BounceOverflowMargin);
    
    if (self.cBackgroundVisualEffectView) {
        self.cBackgroundVisualEffectView.frame = self.cContentContainer.frame;
    }
    
    self.cShadowView.frame = self.cContentContainer.frame;
    
    self.cScrollView.contentSize = CGSizeMake(self.cScrollView.bounds.size.width, (self.cScrollView.bounds.size.height - lowestStop) + self.cScrollView.bounds.size.height - safeAreaBottomInset);
    
    self.backgroundDimmingView.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height + self.cScrollView.contentSize.height);
    
    if ([self p_needsCornerRadius]) {
        CGFloat cornerRadius = [self p_cornerRadius];
        CGPathRef path = [UIBezierPath bezierPathWithRoundedRect:self.cContentContainer.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(cornerRadius, cornerRadius)].CGPath;
        
        CAShapeLayer *layer = [[CAShapeLayer alloc] init];
        layer.path = path;
        layer.frame = self.cContentContainer.bounds;
        layer.fillColor = [UIColor whiteColor].CGColor;
        layer.backgroundColor = [UIColor clearColor].CGColor;
        self.cContentContainer.layer.mask = layer;
        self.cShadowView.layer.shadowPath = path;
        
        self.cScrollView.transform = CGAffineTransformIdentity;
        self.cContentContainer.transform = self.cScrollView.transform;
        self.cShadowView.transform = self.cScrollView.transform;
        
        [self p_maskBackgroundDimmingView];
    }
    
    [self.backgroundDimmingView setHidden:NO];
    [self p_setcPosition:PanelPositionCollapsed animated:NO];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView != self.cScrollView) { return; }
    
    NSMutableArray <NSNumber *> *cStops = [[NSMutableArray alloc] init];
    
    if ([self.supportedPostions containsObject:@(PanelPositionCollapsed)]) {
        [cStops addObject:@([self collapsedHeight])];
    }
    
    if ([self.supportedPostions containsObject:@(PanelPositionPartiallyRevealed)]) {
        [cStops addObject:@([self partialRevealcHeight])];
    }
    
    if ([self.supportedPostions containsObject:@(PanelPositionOpen)]) {
        [cStops addObject:@(self.cScrollView.bounds.size.height)];
    }
    
    CGFloat lowestStop = [[cStops valueForKeyPath:@"@min.floatValue"] floatValue];
    
    
    if ([self.contentViewController respondsToSelector:@selector(cDraggingProgress:)]) {
        
        CGFloat safeAreaTopInset;
        
        if (@available(iOS 11.0, *)) {
            safeAreaTopInset = self.view.safeAreaInsets.top;
        } else {
            safeAreaTopInset = self.topLayoutGuide.length;
        }
        
        CGFloat spaceToDrag = self.cScrollView.bounds.size.height - safeAreaTopInset - lowestStop;
        
        CGFloat dragProgress = fabs(scrollView.contentOffset.y) / spaceToDrag;
        if (dragProgress - 1 > FLT_EPSILON) { //in case greater than 1
            dragProgress = 1.0f;
        }
        NSString *p = [NSString stringWithFormat:@"%.2f", dragProgress];
        [self.contentViewController cDraggingProgress:p.floatValue];
    }
    
    if ((scrollView.contentOffset.y - [self p_bottomSafeArea]) > ([self partialRevealcHeight] - lowestStop)) {
        CGFloat progress;
        CGFloat fullRevealHeight = self.cScrollView.bounds.size.height;
        
        if (fullRevealHeight == [self partialRevealcHeight]) {
            progress = 1.0;
        } else {
            progress = (scrollView.contentOffset.y - ([self partialRevealcHeight] - lowestStop)) / (fullRevealHeight - [self partialRevealcHeight]);
        }
        self.backgroundDimmingView.alpha = progress * DefaultDimmingOpacity;
        [self.backgroundDimmingView setUserInteractionEnabled:YES];
    } else {
        if (self.backgroundDimmingView.alpha >= 0.01) {
            self.backgroundDimmingView.alpha = 0.0;
            [self.backgroundDimmingView setUserInteractionEnabled:NO];
        }
    }
    
    self.backgroundDimmingView.frame = [self p_backgroundDimmingViewFrameForcPosition:scrollView.contentOffset.y + lowestStop];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == self.cScrollView) {
        
        [self p_setcPosition:[self p_postionToMoveFromPostion:self.currentPosition lastDragTargetContentOffSet:self.lastDragTargetContentOffSet scrollView:self.cScrollView supportedPosition:self.supportedPostions] animated:YES];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (scrollView == self.cScrollView) {
        self.lastDragTargetContentOffSet = CGPointMake(targetContentOffset->x, targetContentOffset->y);
        *targetContentOffset = scrollView.contentOffset;
    }
}

#pragma mark - UIPanGestureRecognizer
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)panGestureRecognizerAction:(UIPanGestureRecognizer *)getsutre {
    
    if (!self.shouldScrollcScrollView) { return; }
    
    if (getsutre.state == UIGestureRecognizerStateChanged) {
        CGPoint old = [getsutre translationInView:self.cScrollView];
        if (old.y < 0) { return; }
        CGPoint p = CGPointMake(0, self.cScrollView.frame.size.height - old.y - [self collapsedHeight]);
        self.lastDragTargetContentOffSet = p;
        [self.cScrollView setContentOffset:p];
    } else if (getsutre.state == UIGestureRecognizerStateEnded) {
        self.shouldScrollcScrollView = NO;
        [self p_setcPosition:[self p_postionToMoveFromPostion:self.currentPosition lastDragTargetContentOffSet:self.lastDragTargetContentOffSet scrollView:self.cScrollView supportedPosition:self.supportedPostions] animated:YES];
    }
}

#pragma mark - cScrollViewDelegate

- (void)cScrollViewDidScroll:(UIScrollView *)scrollView {
  
    if (CGPointEqualToPoint(scrollView.contentOffset, CGPointZero)) {
        self.shouldScrollcScrollView = YES;
        [scrollView setScrollEnabled:NO];
        
    } else {
        self.shouldScrollcScrollView = NO;
        [scrollView setScrollEnabled:YES];
    }
}

#pragma mark - ScrollViewControllerDelegate
- (BOOL)shouldTouchPassthroughScrollView:(ScrollViewController *)scrollView
                                   point:(CGPoint)point {
    
    CGPoint p = [self.cContentContainer convertPoint:point fromView:scrollView];
    return !CGRectContainsPoint(self.cContentContainer.bounds, p);
}

- (UIView *)viewToReceiveTouch:(ScrollViewController *)scrollView
                         point:(CGPoint)point {
    if (self.currentPosition == PanelPositionOpen && self.backgroundDimmingView) {
        return self.backgroundDimmingView;
    }
    return self.primaryContentContainer;
}


#pragma mark - Getter and Setter
- (void)setPrimaryContentViewController:(id<PanelPrimaryDelegate>)primaryContentViewController {
    
    if (!primaryContentViewController) { return; }
    _primaryContentViewController = primaryContentViewController;
}

- (void)setContentViewController:(id<PanelDelegate>)contentViewController {
    if (!contentViewController) { return; }
    _contentViewController = contentViewController;
}

- (UIView *)cContentContainer {
    if (!_cContentContainer) {
        _cContentContainer = [[UIView alloc] initWithFrame:self.view.bounds];
        _cContentContainer.backgroundColor = [UIColor clearColor];
    }
    return _cContentContainer;
}

- (UIView *)cShadowView {
    if (!_cShadowView) {
        _cShadowView = [[UIView alloc] init];
    }
    return _cShadowView;
}

- (UIView *)primaryContentContainer {
    if (!_primaryContentContainer) {
        _primaryContentContainer = [[UIView alloc] initWithFrame:self.view.bounds];
        _primaryContentContainer.backgroundColor = [UIColor clearColor];
    }
    return _primaryContentContainer;
}

- (ScrollViewController *)cScrollView {
    if (!_cScrollView) {
        _cScrollView = [[ScrollViewController alloc] initWithFrame:self.cContentContainer.bounds];
        _cScrollView.delegate = self;
    }
    return _cScrollView;
}

- (UIView *)backgroundDimmingView {
    if (!_backgroundDimmingView) {
        if ([self.contentViewController respondsToSelector:@selector(backgroundDimmingView)]) {
            _backgroundDimmingView = [self.contentViewController backgroundDimmingView];
        }
        [_backgroundDimmingView setUserInteractionEnabled:NO];
        _backgroundDimmingView.alpha = 0.0;
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(p_dimmingTapGestureRecognizer:)];
        [_backgroundDimmingView addGestureRecognizer:_tapGestureRecognizer];
    }
    return _backgroundDimmingView;
}

- (UIVisualEffectView *)cBackgroundVisualEffectView {
    if (!_cBackgroundVisualEffectView) {
        if ([self.contentViewController respondsToSelector:@selector(cBackgroundVisualEffectView)]) {
            _cBackgroundVisualEffectView = [self.contentViewController cBackgroundVisualEffectView];
        }
    }
    return _cBackgroundVisualEffectView;
}

- (CGFloat)collapsedHeight {
    CGFloat collapsedHeight = DefaultCollapsedHeight;
    
    if ([self.contentViewController respondsToSelector:@selector(collapsedcHeight)]) {
        collapsedHeight = [self.contentViewController collapsedcHeight];
    }
    
    return collapsedHeight;
}

- (CGFloat)partialRevealcHeight {
    CGFloat partialRevealcHeight = DefaultPartialRevealHeight;
    if ([self.contentViewController respondsToSelector:@selector(partialRevealcHeight)]) {
        partialRevealcHeight = [self.contentViewController partialRevealcHeight];
    }
    return partialRevealcHeight;
}

- (void)setCurrentPosition:(PanelPosition)currentPosition {
    _currentPosition = currentPosition;
    [_contentViewController cPositionDidChange:self];
}

- (NSSet<NSNumber *> *)supportedPostions {
    if (!_supportedPostions) {
        if ([_contentViewController respondsToSelector:@selector(supportPannelPosition)]) {
            _supportedPostions = [_contentViewController supportPannelPosition];
        }
        if (!_supportedPostions) {
            NSArray *array = @[@(PanelPositionOpen), @(PanelPositionClosed), @(PanelPositionCollapsed), @(PanelPositionPartiallyRevealed)];
            _supportedPostions = [NSSet setWithArray:array];
        }
    }
    return _supportedPostions;
}

#pragma mark - Private Mehtods

- (void)p_maskBackgroundDimmingView {
    
    if (!self.backgroundDimmingView) { return; }
    
    CGFloat cornerRadius = [self p_cornerRadius];
    CGFloat cutoutHeight = 2 * cornerRadius;
    CGFloat maskHeight = self.backgroundDimmingView.bounds.size.height - cutoutHeight - self.cScrollView.contentSize.height;
    CGFloat maskWidth = self.backgroundDimmingView.bounds.size.width;
    CGRect cRect = CGRectMake(0, maskHeight, maskWidth, self.cContentContainer.bounds.size.height);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:cRect byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    
    [path appendPath:[UIBezierPath bezierPathWithRect:self.backgroundDimmingView.bounds]];
    [layer setFillRule:kCAFillRuleEvenOdd];
    
    layer.path = path.CGPath;
    self.backgroundDimmingView.layer.mask = layer;
}

- (CGFloat)p_bottomSafeArea {
    CGFloat safeAreaBottomInset;
    if (@available(iOS 11.0, *)) {
        safeAreaBottomInset = self.view.safeAreaInsets.bottom;
    } else {
        safeAreaBottomInset = self.bottomLayoutGuide.length;
    }
    return safeAreaBottomInset;
}

- (void)p_dimmingTapGestureRecognizer:(UITapGestureRecognizer *)tapGesture {
    if (tapGesture == self.tapGestureRecognizer) {
        if (self.tapGestureRecognizer.state == UIGestureRecognizerStateEnded) {
            [self p_setcPosition:PanelPositionCollapsed animated:YES];
        }
    }
}

- (CGRect)p_backgroundDimmingViewFrameForcPosition:(CGFloat)position {
    
    CGFloat cutoutHeight = 2 * [self p_cornerRadius];
    CGRect backgroundDimmingViewFrame = self.backgroundDimmingView.frame;
    backgroundDimmingViewFrame.origin.y = 0 - position + cutoutHeight;
    return backgroundDimmingViewFrame;
}

- (PanelPosition)p_postionToMoveFromPostion:(PanelPosition)currentPosition
                   lastDragTargetContentOffSet:(CGPoint)lastDragTargetContentOffSet
                                    scrollView:(UIScrollView *)scrollView
                             supportedPosition:(NSSet <NSNumber *> *)supportedPosition {
    
    NSMutableArray <NSNumber *> *cStops = [[NSMutableArray alloc] init];
    CGFloat currentcPositionStop = 0.0f;
    
    if ([supportedPosition containsObject:@(PanelPositionCollapsed)]) {
        CGFloat collapsedHeight = [self collapsedHeight];
        [cStops addObject:@(collapsedHeight)];
        if (currentPosition == PanelPositionCollapsed) {
            currentcPositionStop = collapsedHeight;
        }
    }
    
    if ([supportedPosition containsObject:@(PanelPositionPartiallyRevealed)]) {
        CGFloat partialHeight = [self partialRevealcHeight];
        [cStops addObject:@(partialHeight)];
        if (currentPosition == PanelPositionPartiallyRevealed) {
            currentcPositionStop = partialHeight;
        }
    }
    
    if ([supportedPosition containsObject:@(PanelPositionOpen)]) {
        CGFloat openHeight = scrollView.bounds.size.height;
        [cStops addObject:@(openHeight)];
        if (currentPosition == PanelPositionOpen) {
            currentcPositionStop = openHeight;
        }
    }
    
    CGFloat lowestStop = [[cStops valueForKeyPath:@"@min.floatValue"] floatValue];
    CGFloat distanceFromBottomOfView = lowestStop + lastDragTargetContentOffSet.y;
    CGFloat currentClosestStop = lowestStop;
    
    PanelPosition cloestValidcPosition = currentPosition;
    
    for (NSNumber *currentStop in cStops) {
        if (fabs(currentStop.floatValue - distanceFromBottomOfView) < fabs(currentClosestStop - distanceFromBottomOfView)) {
            currentClosestStop = currentStop.integerValue;
        }
    }
    
    if (fabs(currentClosestStop - (scrollView.frame.size.height)) <= FLT_EPSILON &&
        [supportedPosition containsObject:@(PanelPositionOpen)]) {
        
        cloestValidcPosition = PanelPositionOpen;
        
    } else if (fabs(currentClosestStop - [self collapsedHeight]) <= FLT_EPSILON &&
               [supportedPosition containsObject:@(PanelPositionCollapsed)]) {
        
        cloestValidcPosition = PanelPositionCollapsed;
        
    } else if ([supportedPosition containsObject:@(PanelPositionPartiallyRevealed)]){
        
        cloestValidcPosition = PanelPositionPartiallyRevealed;
    }
    
    return cloestValidcPosition;
}

- (void)p_setcPosition:(PanelPosition)position
                   animated:(BOOL)animated {
    
    if (![self.supportedPostions containsObject:@(position)]) {
        return;
    }
    
    CGFloat stopToMoveTo;
    CGFloat lowestStop = [self collapsedHeight];
    if (position == PanelPositionCollapsed) {
        stopToMoveTo = lowestStop;
    } else if (position == PanelPositionPartiallyRevealed) {
        stopToMoveTo = [self partialRevealcHeight];
    } else if (position == PanelPositionOpen) {
        if (self.backgroundDimmingView) {
            stopToMoveTo = self.cScrollView.frame.size.height;
        } else {
            stopToMoveTo = self.cScrollView.frame.size.height - DefaultShadowRadius;
        }
    } else {
        stopToMoveTo = 0.0f;
    }
    
    self.isAnimatingcPosition = YES;
    self.currentPosition = position;
    
    __weak typeof (self) weakSelf = self;
    [UIView animateWithDuration:0.3 delay:0.0 usingSpringWithDamping:0.75 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [weakSelf.cScrollView setContentOffset:CGPointMake(0, stopToMoveTo - lowestStop) animated:NO];
        
        if (weakSelf.backgroundDimmingView) {
            weakSelf.backgroundDimmingView.frame = [weakSelf p_backgroundDimmingViewFrameForcPosition:stopToMoveTo];
        }
        
    } completion:^(BOOL finished) {
        weakSelf.isAnimatingcPosition = NO;
    }];
}

- (BOOL)p_needsCornerRadius {
    return [self p_cornerRadius] > FLT_EPSILON;
}

- (CGFloat)p_cornerRadius {
    if ([self.contentViewController respondsToSelector:@selector(cCornerRadius)]) {
        return [self.contentViewController cCornerRadius];
    }
    return 0.0f;
}

@end

