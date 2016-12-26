//
//  XPAdCarouselView.m
//  XPAdCarouselView
//
//  Created by xp2012 on 2016/12/26.
//  Copyright © 2016年 xp. All rights reserved.
//

#import "XPAdCarouselView.h"
#import <SMPageControl.h>
#import <SDWebImage/SDWebImageManager.h>

#define DEFAULT_DELAY_TIME     3
#define PAGE_CONTROL_HEIGHT    15

@interface XPAdCarouselView ()<UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSArray *imageTotalArray;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSUInteger currentSelectedPage;
@property (nonatomic, strong) SMPageControl *pageControl;

@end

@implementation XPAdCarouselView

#pragma mark - Life cycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        [self initWithTheCarouselView];
        [self initWithAutoTimer];
    }
    return self;
}

#pragma mark - Private methods
- (void)initWithTheCarouselView {
    [self addSubview:self.scrollView];
    self.scrollView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    
    [self addSubview:self.pageControl];
    self.pageControl.frame = CGRectMake(0, self.bounds.size.height - PAGE_CONTROL_HEIGHT, self.bounds.size.width, PAGE_CONTROL_HEIGHT);
}

- (void)initWithAutoTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:DEFAULT_DELAY_TIME target:self selector:@selector(autoCarouselAdView) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)autoCarouselAdView {
    [self moveToTargetAdView:CGRectGetWidth(_scrollView.frame)*(self.currentSelectedPage + 1) withAnimated:YES];
    [self scrollViewDidScroll:_scrollView];
}

- (void)moveToTargetAdView:(CGFloat)offsetX withAnimated:(BOOL)animated {
    [_scrollView setContentOffset:CGPointMake(offsetX, 0) animated:animated];
}

- (void)tapTheImageViewBackground {
    [self stopTimer];
    if ([self.delegate respondsToSelector:@selector(selectedCurrentCarouseView:)]) {
        [self.delegate selectedCurrentCarouseView:self.currentSelectedPage];
    }
    [self initWithAutoTimer];
}

#pragma mark - setter/getter methods
- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.autoresizingMask = YES;
        _scrollView.scrollsToTop = NO;
    }
    return _scrollView;
}

- (SMPageControl *)pageControl
{
    if (!_pageControl) {
        _pageControl = [[SMPageControl alloc] initWithFrame:self.bounds];
        _pageControl.backgroundColor = [UIColor clearColor];
        _pageControl.userInteractionEnabled = NO;
        _pageControl.indicatorMargin = 5;
        _pageControl.currentPageIndicatorImage = [UIImage imageNamed:@"page_control_yellow"];
        _pageControl.pageIndicatorImage  = [UIImage imageNamed:@"page_controller_white"];
        _pageControl.currentPage = 0;
    }
    return _pageControl;
}

#pragma mark - Public methods
- (void)setAdDataToCarouseView:(NSArray *)dataArray {
    
    CGFloat contentWidth  = CGRectGetWidth(_scrollView.frame);
    CGFloat contentHeight = CGRectGetHeight(_scrollView.frame);
    if (dataArray.count == 1) { //如果只有一张图片
        CGRect imgRect = CGRectMake(0, 0, contentWidth, contentHeight);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imgRect];
        [_scrollView addSubview:imageView];
        //如果有缓存先从缓存中读取
        NSString *cacheImageKey = [NSString stringWithFormat:@"ADImage%@",[dataArray objectAtIndex:0]];
        UIImage *cacheImage = [[[SDWebImageManager sharedManager] imageCache] imageFromDiskCacheForKey:cacheImageKey];
        if (cacheImage) {
            imageView.image = cacheImage;
        }else{
            [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:[dataArray objectAtIndex:0]] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                imageView.image = image;
                [[[SDWebImageManager sharedManager] imageCache] storeImage:image forKey:cacheImageKey toDisk:YES];
            }];
        }
        //一张图片需要停止掉定时器
        [self stopTimer];
        return;
    }else if (dataArray.count == 0) { //为空时也要停止掉定时器
        [self stopTimer];
        return;
    }
    
    /* 超过一张图片的处理 */
    self.pageControl.numberOfPages = dataArray.count;
    //生成dataArray.count + 2 个数据
    NSMutableArray *totalArray = [dataArray mutableCopy];
    [totalArray insertObject:[dataArray lastObject] atIndex:0];
    [totalArray addObject:[dataArray firstObject]];
    
    self.scrollView.contentSize = CGSizeMake(contentWidth * totalArray.count, contentHeight);
    
    //排序方式是，比如有5张图片，那么排序是：5-1-2-3-4-5-1
    for (NSInteger i = 0; i < totalArray.count; i++) {
        CGRect imgRect = CGRectMake(contentWidth * i, 0, contentWidth, contentHeight);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imgRect];
        if (i == 0) { //
            //如果有缓存先从缓存中读取
            NSString *cacheImageKey = [NSString stringWithFormat:@"ADImage%@",[totalArray objectAtIndex:totalArray.count-2]];
            UIImage *cacheImage = [[[SDWebImageManager sharedManager] imageCache] imageFromDiskCacheForKey:cacheImageKey];
            if (cacheImage) {
                imageView.image = cacheImage;
            }else{
                [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:[totalArray objectAtIndex:totalArray.count-2]] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                    imageView.image = image;
                    [[[SDWebImageManager sharedManager] imageCache] storeImage:image forKey:cacheImageKey toDisk:YES];
                }];
            }
        }else if (i == totalArray.count-1) {
            //如果有缓存先从缓存中读取
            NSString *cacheImageKey = [NSString stringWithFormat:@"ADImage%@",[totalArray objectAtIndex:1]];
            UIImage *cacheImage = [[[SDWebImageManager sharedManager] imageCache] imageFromDiskCacheForKey:cacheImageKey];
            if (cacheImage) {
                imageView.image = cacheImage;
            }else{
                [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:[totalArray objectAtIndex:1]] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                    imageView.image = image;
                    [[[SDWebImageManager sharedManager] imageCache] storeImage:image forKey:cacheImageKey toDisk:YES];
                }];
            }
        }else{
            //如果有缓存先从缓存中读取
            NSString *cacheImageKey = [NSString stringWithFormat:@"ADImage%@",[totalArray objectAtIndex:i]];
            UIImage *cacheImage = [[[SDWebImageManager sharedManager] imageCache] imageFromDiskCacheForKey:cacheImageKey];
            if (cacheImage) {
                imageView.image = cacheImage;
            }else{
                [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:[totalArray objectAtIndex:i]] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                    imageView.image = image;
                    [[[SDWebImageManager sharedManager] imageCache] storeImage:image forKey:cacheImageKey toDisk:YES];
                }];
            }
        }
        
        [_scrollView addSubview:imageView];
        //点击图片
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTheImageViewBackground)];
        imageView.userInteractionEnabled = YES;
        [imageView addGestureRecognizer:singleTap];
    }
    _scrollView.contentOffset = CGPointMake(CGRectGetWidth(_scrollView.frame), 0);
    
    self.imageTotalArray = [totalArray copy];
}

- (void)stopTimer {
    if (self.timer.isValid) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

#pragma mark - UIScrollViewDelegate methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat contentoffset_x = scrollView.contentOffset.x;
    
    CGFloat itemWidth = CGRectGetWidth(scrollView.frame);
    
    NSInteger nextPage = (scrollView.contentOffset.x + itemWidth * 0.5) / itemWidth;
    
    //
    if (contentoffset_x >= itemWidth * (self.imageTotalArray.count - 1)) { //处理向右滚动时
        contentoffset_x = itemWidth;
        _scrollView.contentOffset = CGPointMake(contentoffset_x, 0);
    }else if (contentoffset_x <= 0) { //处理向左滚动时
        contentoffset_x = itemWidth * (self.imageTotalArray.count - 2);
        _scrollView.contentOffset = CGPointMake(contentoffset_x, 0);
    }
    
    self.currentSelectedPage = nextPage;
    if (nextPage == 0) {
        self.currentSelectedPage = self.imageTotalArray.count-2;
    }else if (nextPage == self.imageTotalArray.count-1) {
        self.currentSelectedPage = 1;
    }
    
    self.pageControl.currentPage = self.currentSelectedPage - 1;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //拖动时停止掉定时器
    [self stopTimer];
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //拖动完成重新生成新的定时器
    [self initWithAutoTimer];
}

- (void)dealloc {
    NSLog(@"轮播视图释放掉了");
}

@end
