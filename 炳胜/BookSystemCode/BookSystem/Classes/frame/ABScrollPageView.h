//
//  CVScrollPageViewController.h
//  CapitalVueHD
//
//  Created by jishen on 9/4/10.
//  Copyright 2010 SmilingMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CVPageControlView.h"

#define CVSCROLLPAGE_INDICTOR_WIDTH  150
#define CVSCROLLPAGE_INDICTOR_HEIGHT 18

@protocol ABScrollPageViewDeleage


- (UIView *)scrollPageView:(id)scrollPageView viewForPageAtIndex:(NSUInteger)index;
- (void)didScrollToPageAtIndex:(NSUInteger)index;

@optional
- (NSInteger)numberOfPagesOfPageControl:(NSInteger)totalIndex;
- (NSInteger)indexOfPagesOfPageControl:(NSInteger)totalIndex;
- (NSUInteger)numberOfPagesInScrollPageView;

@end



@interface ABScrollPageView : UIView <UIScrollViewDelegate> {
	id<ABScrollPageViewDeleage> pageViewDelegate;
	NSUInteger pageCount;
	UIScrollView *scrollView;
	NSUInteger indicatorStyle;
	CVPageControlView *pageControl;
@private
	CGRect _pageControlFrame;
	
    NSMutableArray *viewControllers;
	NSMutableArray *arrayViewCache;
	
	// FIXME, cacheIndex should moved;
	NSUInteger cacheSize;
	NSUInteger cacheIndex;
	
    // To be used when scrolls originate from the UIPageControl
    BOOL pageControlUsed;
    

}

@property (nonatomic) CGRect pageControlFrame;
@property (nonatomic) NSUInteger pageCount;
@property (nonatomic) NSUInteger indicatorStyle;
@property (nonatomic,retain) UIScrollView *scrollView;
@property (nonatomic,retain) CVPageControlView *pageControl;

- (void)reloadData;
- (void)setDelegate:(id)delegate;
- (void)enqueueReusablePage:(UIView *)pageView atIndex:(NSUInteger)index;
- (UIView *)dequeueReusablePage:(NSUInteger)index;
- (void)clearReusablePage;
- (void)turnToPage:(NSInteger)page;
- (void)clearInvisiblePage;
- (void)loadPage:(NSInteger)index;

@end
