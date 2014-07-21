//
//  BSSubMenu.h
//  BookSystem
//
//  Created by Dream on 11-3-16.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBView.h"
#import "FBTransitionView.h"
#import "SubMenuCell.h"
#import "BSLogViewController.h"
#import "BSQueryViewController.h"

#define PrevPage       0
#define NextPage       1

#define kNumberOfFoodInPage     8
#define kSubmenTopButtonY       100

@interface BSSubMenu : UIViewController <SubMenuCellDelegate,FBTransitionViewDelegate>{
    NSArray *aryFBViews,*aryDict;
    int currentPage,totalPages;
    
	CGPoint ptCurr,ptPrev,ptOrigin;
	
	NSUInteger pageToShow;
	
//    NSTimer *timerADs;
	
	FBView *fbCurr,*fbNext;
	
    UIPanGestureRecognizer *panGesture;
	
	BOOL bTurned,bTurning;
    
    FBTransitionView *fbTrans;
    
    UIView *vBG;
    UIButton *btnMenu,*btnLog,*btnQuery;
    
    NSDictionary *dicInfo;
    
    BOOL bActivated;
    NSString *strBackground;
}
@property (nonatomic,retain) NSArray *aryDict,*aryFBViews;
@property (nonatomic,retain) NSDictionary *dicInfo;
@property (nonatomic,copy) NSString *strBackground;

- (void)genViews:(NSDictionary *)info activated:(BOOL)activated;
- (void)deleteViews;
- (void)addCurView;

@end
