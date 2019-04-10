//
//  UIScrollView+HeaderAndFooter.m
//  ZMjRefresh
//
//  Created by zjl on 2018/12/28.
//  Copyright © 2018年 zjl. All rights reserved.
//

#import "UIScrollView+HeaderAndFooter.h"
#import "MJRefresh.h"
#import "LYEmptyViewHeader.h"
@implementation UIScrollView (HeaderAndFooter)

static void *pagaIndexKey = &pagaIndexKey;
- (void)setPageIndex:(NSInteger)pageIndex{
    objc_setAssociatedObject(self, &pagaIndexKey, @(pageIndex), OBJC_ASSOCIATION_ASSIGN);
}

- (NSInteger)pageIndex
{
    return [objc_getAssociatedObject(self, &pagaIndexKey) integerValue];
}

static void *RefreshBlockKey = &RefreshBlockKey;
- (void)setRefreshBlock:(RefreshBlock)RefreshBlock{
    objc_setAssociatedObject(self, &RefreshBlockKey, RefreshBlock, OBJC_ASSOCIATION_COPY);
}

- (RefreshBlock)refreshBlock
{
    return objc_getAssociatedObject(self, &RefreshBlockKey);
}

static void *LoadMoreBlockKey = &LoadMoreBlockKey;
- (void)setLoadMoreBlock:(LoadMoreBlock)loadMoreBlock{
    objc_setAssociatedObject(self, &LoadMoreBlockKey, loadMoreBlock, OBJC_ASSOCIATION_COPY);
}

- (LoadMoreBlock)loadMoreBlock
{
    return objc_getAssociatedObject(self, &LoadMoreBlockKey);
}

static void *imageNameKey = &imageNameKey;
- (void)setImageName:(NSString *)imageName {
    objc_setAssociatedObject(self, &imageNameKey, imageName, OBJC_ASSOCIATION_COPY);
}

- (NSString *)imageName
{
    return objc_getAssociatedObject(self, &imageNameKey);
}

static void *titleKey = &titleKey;
- (void)setEmptyTitle:(NSString *)emptyTitle {
    objc_setAssociatedObject(self, &titleKey, emptyTitle, OBJC_ASSOCIATION_COPY);
}

- (NSString *)emptyTitle
{
    return objc_getAssociatedObject(self, &titleKey);
}


- (void)addHeaderWithHeaderWithBeginRefresh:(BOOL)beginRefresh animation:(BOOL)animation refreshBlock:(void(^)(NSInteger pageIndex))refreshBlock{
    
    __weak typeof(self) weakSelf = self;
    self.refreshBlock = refreshBlock;
    
    MJRefreshNormalHeader * header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf resetPageNum];
        
        if (weakSelf.refreshBlock) {
            weakSelf.refreshBlock(weakSelf.pageIndex);
        }
        [weakSelf endHeaderRefresh];
    }];
    
    if (beginRefresh && animation) {
        //有动画的刷新
        [self beginHeaderRefresh];
    }else if (beginRefresh && !animation){
        //刷新，但是没有动画
        [self.mj_header executeRefreshingCallback];
    }
    
//    header.mj_h = 70.0;
    self.mj_header = header;
    self.ly_emptyView = [LYEmptyView emptyViewWithImage:[UIImage imageNamed:self.imageName] titleStr:self.emptyTitle detailStr:@""];
}

- (void)addFooterWithWithHeaderWithAutomaticallyRefresh:(BOOL)automaticallyRefresh loadMoreBlock:(void(^)(NSInteger pageIndex))loadMoreBlock{
    
    self.loadMoreBlock = loadMoreBlock;
    
    if (automaticallyRefresh) {
        MJRefreshAutoNormalFooter * footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            self.pageIndex += 1;
            if (self.loadMoreBlock) {
                self.loadMoreBlock(self.pageIndex);
            }
            [self endFooterRefresh];
        }];
        
        footer.automaticallyRefresh = automaticallyRefresh;
        
//        footer.stateLabel.font = [UIFont systemFontOfSize:13.0];
//        footer.stateLabel.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];
//        [footer setTitle:@"加载中…" forState:MJRefreshStateRefreshing];
//        [footer setTitle:@"这是我的底线啦~" forState:MJRefreshStateNoMoreData];
        
        self.mj_footer = footer;
    }
    else{
        MJRefreshBackNormalFooter * footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            self.pageIndex += 1;
            if (self.loadMoreBlock) {
                self.loadMoreBlock(self.pageIndex);
            }
            [self endFooterRefresh];
        }];
        
//        footer.stateLabel.font = [UIFont systemFontOfSize:13.0];
//        footer.stateLabel.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];
//        [footer setTitle:@"加载中…" forState:MJRefreshStateRefreshing];
//        [footer setTitle:@"这是我的底线啦~" forState:MJRefreshStateNoMoreData];
        
        self.mj_footer = footer;
    }
    
}

-(void)beginHeaderRefresh {
    
    [self resetPageNum];
    [self.mj_header beginRefreshing];
}

- (void)resetPageNum {
    self.pageIndex = 1;
}

- (void)resetNoMoreData {
    
    [self.mj_footer resetNoMoreData];
}

-(void)endHeaderRefresh {
    
    [self.mj_header endRefreshing];
    [self resetNoMoreData];
}

-(void)endFooterRefresh {
    [self.mj_footer endRefreshing];
}

@end
