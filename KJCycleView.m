//
//  KJCycleView.m
//
//  Created by KepenJ on 15/12/8.
//  Copyright © 2015年 KepenJ. All rights reserved.
//

#import "KJCycleView.h"
#define kCurveRadius                (120)
#define kImageTagBeyondValue        (100)
#define kTimeDelay                  (3)

@interface KJCycleView ()
{
    UIPageControl       *_pageControl;
    UIScrollView        *_scrollview;
    CGRect              _viewSize;
    CGFloat             _targetX;
    CGFloat             _previousTouchPoint;
    NSInteger           _currentPageIndex;
}
//auto scrol animation
- (void)autoScrollAnimation;
//tap method
- (void)tapTheViews;
//init the base views
- (void)configTheViewsWithFrame:(CGRect)rect ContentSize:(CGSize)contentSize;
// update the subviews
- (void)updateViewsWithArray:(NSArray *)array;
//make the view bottom round corner cycle
- (void)makeBottomRoundCorner;
//Judge the edge
- (void)scrollViewIsBouncesNow;
//reset pageControl
- (void)resetPageControl;
//change the images status
- (void)changeThePageControllWithOffset:(CGFloat)offset;
@end

@implementation KJCycleView
@synthesize isMakeBottomRoundCorner = _isMakeBottomRoundCorner;
@synthesize isAutoScrol = _isAutoScrol;
@synthesize imageArr = _imageArr;
@synthesize delelgate = _delelgate;

#pragma mark - Init
- (void)awakeFromNib {
    _isAutoScrol = YES;
    _previousTouchPoint= 0.0;
    _currentPageIndex = 0;
    _isMakeBottomRoundCorner = NO;
    self.backgroundColor = [UIColor clearColor];
    [self configTheViewsWithFrame:self.bounds ContentSize:CGSizeZero];
    [self updateViewsWithArray:nil];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _isAutoScrol = YES;
        _previousTouchPoint = 0.0;
        _currentPageIndex = 0;
        _isMakeBottomRoundCorner = NO;
        self.backgroundColor = [UIColor clearColor];
        [self configTheViewsWithFrame:frame ContentSize:CGSizeZero];
        [self updateViewsWithArray:nil];
    }
    return self;
}

#pragma mark - SetMehtod
-(void)setImageArr:(NSArray *)imageArr{
    if (imageArr) {
        //Config model for our
        NSMutableArray * tempImagesArr = [NSMutableArray arrayWithCapacity:imageArr.count];
        for (UIImage * image in imageArr) {
            [tempImagesArr addObject:image];
        }
        NSMutableArray *tempArray=[NSMutableArray arrayWithArray:tempImagesArr];
        [tempArray insertObject:[tempImagesArr objectAtIndex:([tempImagesArr count]-1)] atIndex:0];
        [tempArray addObject:[tempImagesArr objectAtIndex:0]];
        _imageArr = [NSArray arrayWithArray:tempArray];
    }
    [self updateViewsWithArray:_imageArr];
}
- (void)setIsMakeBottomRoundCorner:(BOOL)isMakeBottomRoundCorner {
    _isMakeBottomRoundCorner = isMakeBottomRoundCorner;
    if (isMakeBottomRoundCorner) {
        [self makeBottomRoundCorner];
    }
}
- (void)setIsAutoScrol:(BOOL)isAutoScrol {
    _isAutoScrol = isAutoScrol;
    if (isAutoScrol) {
        [self performSelector:@selector(autoScrollAnimation) withObject:nil afterDelay:kTimeDelay];
    }
    else {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoScrollAnimation) object:nil];
    }
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _previousTouchPoint = scrollView.contentOffset.x;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoScrollAnimation) object:nil];
}
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    [self changeThePageControllWithOffset:sender.contentOffset.x];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self scrollViewIsBouncesNow];
    [self performSelector:@selector(autoScrollAnimation) withObject:nil afterDelay:kTimeDelay];
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self scrollViewIsBouncesNow];
}
#pragma mark - AutoScroll
- (void)autoScrollAnimation {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoScrollAnimation) object:nil];
    _targetX = _scrollview.contentOffset.x + _scrollview.frame.size.width;
    [self scrollViewIsBouncesNow];
    [_scrollview setContentOffset:CGPointMake(_targetX, 0) animated:YES];
    [self changeThePageControllWithOffset:_targetX];
    [self performSelector:@selector(autoScrollAnimation) withObject:nil afterDelay:kTimeDelay];
}
#pragma mark - PrivateMethod
- (void)tapTheViews {
    if ([self.delelgate respondsToSelector:@selector(kJCycleView:didTapViewsAtIndex:)]) {
        [self.delelgate kJCycleView:self didTapViewsAtIndex:_currentPageIndex];
    }
}
- (void)configTheViewsWithFrame:(CGRect)rect ContentSize:(CGSize)contentSize {
    _viewSize = rect;
    if (!_scrollview) {
        //init UIScrollView
        _scrollview = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-kCurveRadius/2.0f)];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTheViews)];
        [_scrollview addGestureRecognizer:tap];
        _scrollview.pagingEnabled = YES;
        _scrollview.contentSize = contentSize;
        _scrollview.showsHorizontalScrollIndicator = NO;
        _scrollview.showsVerticalScrollIndicator = NO;
        _scrollview.scrollsToTop = NO;
        _scrollview.delegate = self;
    }
    [self addSubview:_scrollview];
    //Init UIPageConrol
    if  (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.frame = CGRectMake((self.frame.size.width-122)/2.0f,self.frame.size.height - 100, 122, 36);
        _pageControl.pageIndicatorTintColor = [UIColor grayColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
        _pageControl.backgroundColor = [UIColor clearColor];
        _pageControl.numberOfPages = 0;
        _pageControl.currentPage = 0;
        _pageControl.userInteractionEnabled = NO;
    }
    [self addSubview:_pageControl];
}
- (void)updateViewsWithArray:(NSArray *)array {
    if (array && array.count != 0) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoScrollAnimation) object:nil];
        
        for (UIView * view in self.subviews) {
            if (([view isKindOfClass:[UIImageView class]])) {
                [view removeFromSuperview];
            }
        }
        for (UIView * view in self.subviews) {
            if ([view isKindOfClass:[UIImageView class]]) {
                [view removeFromSuperview];
            }
        }
        for (int i =0; i<_imageArr.count ; i++) {
            UIImageView * imageview;
            UIImage * image = _imageArr[i];
            if (i == 0) {
                if (image) {
                    imageview = [[UIImageView alloc]initWithFrame:CGRectMake(0.0, 0.0,_scrollview.frame.size.width , _scrollview.frame.size.height)];
                    imageview.image = image;
                    imageview.backgroundColor = [UIColor grayColor];
                    imageview.tag = 0+kImageTagBeyondValue;
                    imageview.alpha = 0;
                    [self addSubview:imageview];
                }
            }
            else if (i == _imageArr.count-1) {
                if (image) {
                    imageview = [[UIImageView alloc]initWithFrame:CGRectMake(0.0, 0.0,_scrollview.frame.size.width , _scrollview.frame.size.height)];
                    imageview.image = image;
                    imageview.backgroundColor = [UIColor grayColor];
                    imageview.tag = _imageArr.count-1+kImageTagBeyondValue;
                    imageview.alpha = 0;
                    [self addSubview:imageview];
                }
            }
            else {
                if (image) {
                    imageview = [[UIImageView alloc]initWithFrame:CGRectMake(0.0, 0.0,_scrollview.frame.size.width , _scrollview.frame.size.height)];
                    imageview.image = image;
                    imageview.backgroundColor = [UIColor grayColor];
                    imageview.tag = i+kImageTagBeyondValue;
                    if (i != 1) {
                        imageview.alpha = 0;
                    }
                    else {
                        imageview.alpha = 1;
                    }
                    [self addSubview:imageview];
                }
            }
        }
        [_scrollview setContentSize:CGSizeMake(_scrollview.frame.size.width*self.imageArr.count,
                                               _scrollview.frame.size.height)];
        [self resetPageControl];
        _pageControl.backgroundColor = [UIColor clearColor];
        _pageControl.numberOfPages = self.imageArr.count - 2 ;
        _pageControl.currentPage = 0;
        [self addSubview:_scrollview];
        [self addSubview:_pageControl];
        if (_isAutoScrol) {
            [self performSelector:@selector(autoScrollAnimation) withObject:nil afterDelay:kTimeDelay];
        }
    }
}
- (void)makeBottomRoundCorner {
    CGRect rect = self.frame;
    CAShapeLayer * shapeLayer = [CAShapeLayer layer];
    [shapeLayer setFillColor:[UIColor whiteColor].CGColor];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0.0, 0.0);
    CGPathAddLineToPoint(path, NULL, rect.size.width, 0.0);
    CGPathAddLineToPoint(path, NULL, rect.size.width, rect.size.height-kCurveRadius);
    CGPathAddQuadCurveToPoint(path, NULL, rect.size.width/2.0f, rect.size.height, 0.0, rect.size.height-kCurveRadius);
    CGPathCloseSubpath(path);
    [shapeLayer setPath:path];
    CFRelease(path);
    self.layer.mask = shapeLayer;
}
- (void)scrollViewIsBouncesNow {
    if (_currentPageIndex == 0) {
        [_scrollview setContentOffset:CGPointMake(([self.imageArr count] - 2)*_viewSize.size.width,
                                                  0)];
    }
    if (_currentPageIndex == ([self.imageArr count] - 1)) {
        [_scrollview setContentOffset:CGPointMake(_viewSize.size.width,
                                                  0)];
        _targetX = _scrollview.contentOffset.x + _scrollview.frame.size.width;
    }
}
- (void)resetPageControl {
    [_scrollview setContentOffset:CGPointMake(_scrollview.frame.size.width,
                                              0)];
    _pageControl.backgroundColor = [UIColor clearColor];
    _pageControl.numberOfPages = self.imageArr.count - 2 ;
    _pageControl.currentPage = 0;
}
- (void)changeThePageControllWithOffset:(CGFloat)offset {
    CGFloat pageWidth = _scrollview.frame.size.width;
    int page = floor((_scrollview.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    _currentPageIndex = page;
    float old = _scrollview.frame.size.width*page;
    int new = _scrollview.contentOffset.x -old;
    float alpha = (new% (int)pageWidth) / pageWidth;
    
    UIView *nextPage;
    UIView *previousPage;
    UIView *currentPage;
    
    for (UIView * view in self.subviews) {
        if (![view isKindOfClass:[UIPageControl class]] && ![view isKindOfClass:[UIScrollView class]]) {
            if (view.tag != page+1+kImageTagBeyondValue || view.tag != page+kImageTagBeyondValue || view.tag != page-1+kImageTagBeyondValue) {
                view.alpha = 0;
            }
        }
    }
    if (page == 0) {
        nextPage = [self viewWithTag:page+1+kImageTagBeyondValue];
        previousPage = [self viewWithTag:_imageArr.count-1+kImageTagBeyondValue];
        currentPage = [self viewWithTag:page+kImageTagBeyondValue];
    }
    else if (page == _imageArr.count-1) {
        nextPage = [self viewWithTag:+kImageTagBeyondValue];
        previousPage = [self viewWithTag:page-1+kImageTagBeyondValue];
        currentPage = [self viewWithTag:page+kImageTagBeyondValue];
        
    }
    else {
        nextPage = [self viewWithTag:page+1+kImageTagBeyondValue];
        previousPage = [self viewWithTag:page-1+kImageTagBeyondValue];
        currentPage = [self viewWithTag:page+kImageTagBeyondValue];
    }
    if(_previousTouchPoint > _scrollview.contentOffset.x){
        if ([currentPage isKindOfClass:[UIImageView class]])
            currentPage.alpha = 1-alpha;
        if ([previousPage isKindOfClass:[UIImageView class]])
            previousPage.alpha = alpha;
        if ([nextPage isKindOfClass:[UIImageView class]])
            nextPage.alpha = alpha;
    }
    else {
        if ([currentPage isKindOfClass:[UIImageView class]])
            currentPage.alpha = 1-alpha;
        if ([nextPage isKindOfClass:[UIImageView class]])
            nextPage.alpha = alpha;
        if ([previousPage isKindOfClass:[UIImageView class]])
            previousPage.alpha = alpha;
    }
    long pageIndex = _currentPageIndex - 1;
    if (pageIndex >= [_imageArr count]) {
        pageIndex = 0;
    }
    if (pageIndex < 0) {
        pageIndex = [_imageArr count] - 1;
    }
    _pageControl.currentPage = pageIndex;
}
@end
