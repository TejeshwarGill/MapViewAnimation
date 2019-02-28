//
//  SecondaryContentViewController.m
//  MapAnimationDemo
//
//  Created by Gill on 28/02/2019.
//  Copyright © 2019 Gill. All rights reserved.
//

#import "SecondaryContentViewController.h"
#import "PanelViewController.h"

@interface SecondaryContentViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation SecondaryContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.headerView];
    [self.view addSubview:self.tableView];
    self.view.backgroundColor = [UIColor whiteColor];

    [self.tableView setScrollEnabled:NO];
    self.tableView.bounces = NO;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"table view cell"];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.headerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 60);
    self.tableView.frame = CGRectMake(0, 60, self.view.bounds.size.width, self.view.bounds.size.height - 60 - TopInset);
}
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"table view cell"];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.text = [NSString stringWithFormat:@"Location Details - %ld", (long)indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

#pragma mark - PanelViewControllerDelegate
- (void)cPositionDidChange:(PanelViewController *)c {
    if (c.currentPosition == PanelPositionOpen) {
        [self.tableView setScrollEnabled:YES];
    } else {
        [self.tableView setScrollEnabled:NO];
    }
}

- (void)cDraggingProgress:(CGFloat)progress {
//    NSLog(@"dragging progress is %f", progress);
}

- (CGFloat)collapsedcHeight {
    return 68.0f;
}

- (CGFloat)partialRevealcHeight {
    return 264.0f;
}

- (NSSet<NSNumber *> *)supportPannelPosition {
    NSArray *array = @[@(PanelPositionCollapsed), @(PanelPositionPartiallyRevealed), @(PanelPositionOpen),@(PanelPositionClosed)];
    return [NSSet setWithArray:array];
}

- (UIVisualEffectView *)cBackgroundVisualEffectView {
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView *cBackgroundVisualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    cBackgroundVisualEffectView.clipsToBounds = YES;
    return cBackgroundVisualEffectView;
}

- (CGFloat)cCornerRadius {
    return 13.0f;
}

- (UIView *)backgroundDimmingView {
    UIView *backgroundDimmingView = [[UIView alloc] init];
    backgroundDimmingView.backgroundColor = [UIColor blackColor];
    return backgroundDimmingView;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.cScrollDelegate cScrollViewDidScroll:scrollView];
}

#pragma mark - Getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor clearColor];
    }
    return _tableView;
}

- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] init];
        _headerView.backgroundColor = [UIColor clearColor];
    }
    return _headerView;
}

@end
