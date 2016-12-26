//
//  XPAdCarouselView.h
//  XPAdCarouselView
//
//  Created by xp2012 on 2016/12/26.
//  Copyright © 2016年 xp. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XPAdCarouselViewDelegate <NSObject>

- (void)selectedCurrentCarouseView:(NSInteger)page;

@end

@interface XPAdCarouselView : UIView

@property (nonatomic, weak) id<XPAdCarouselViewDelegate> delegate;

/**
 设置数据
 
 @param dataArray 数据
 */
- (void)setAdDataToCarouseView:(NSArray *)dataArray;

/**
 停止定时器
 */
- (void)stopTimer;

@end
