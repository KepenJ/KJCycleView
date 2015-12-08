//
//  KJCycleView.h
//
//  Created by KepenJ on 15/12/8.
//  Copyright © 2015年 KepenJ. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol KJCycleViewDelegate;
@interface KJCycleView : UIView <UIScrollViewDelegate>
@property (nonatomic,strong) NSArray * imageArr;                //image source array
@property (nonatomic,assign) BOOL isMakeBottomRoundCorner;      //default is NO
@property (nonatomic,assign) BOOL isAutoScrol;                  //default is YES
@property (nonatomic,weak) id<KJCycleViewDelegate> delelgate;   //delegate
@end

@protocol KJCycleViewDelegate <NSObject>
@optional
- (void)kJCycleView:(KJCycleView *)target didTapViewsAtIndex:(NSInteger)index;
@end