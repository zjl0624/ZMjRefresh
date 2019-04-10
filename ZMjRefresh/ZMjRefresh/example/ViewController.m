//
//  ViewController.m
//  ZMjRefresh
//
//  Created by zjl on 2018/12/28.
//  Copyright © 2018年 zjl. All rights reserved.
//

#import "ViewController.h"
#import "UIScrollView+HeaderAndFooter.h"

static NSString * const cellIdentifier = @"cell";
static NSInteger const maxPage = 2;
@interface ViewController ()<UITableViewDataSource>
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initDataArray];
    [self initTableView];
}


- (void)initDataArray {
    self.dataArray = [[NSMutableArray alloc] init];
}

- (void)initTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 88, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    self.tableView.dataSource= self;
    self.tableView.imageName = @"cm_kong_icon";
    self.tableView.emptyTitle = @"空空如也";
    __weak __typeof(&*self)weakSelf = self;
    [self.tableView addHeaderWithHeaderWithBeginRefresh:YES animation:YES refreshBlock:^(NSInteger pageIndex) {
        [weakSelf requestData:YES];
    }];
    
    [self.tableView addFooterWithWithHeaderWithAutomaticallyRefresh:NO loadMoreBlock:^(NSInteger pageIndex) {
        if (pageIndex <= maxPage) {
            [weakSelf requestData:NO];
        }
        
    }];
    
    [self requestData:YES];
}


- (void)requestData:(BOOL)isNeedClear {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (isNeedClear) {
            [self.dataArray removeAllObjects];
        }
        for (NSInteger i = 1; i <= 5; i++) {
            [self.dataArray addObject:@(i)];
        }
        [self.tableView reloadData];
    });

}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.textLabel.text = [NSString stringWithFormat:@"第%@行",@(indexPath.row)];
    return cell;
}

@end
