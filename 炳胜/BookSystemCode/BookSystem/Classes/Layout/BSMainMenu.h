//
//  BSMainMenu.h
//  BookSystem
//
//  Created by Dream on 11-3-16.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSSettingViewController.h"
#import "BSBGSettingViewController.h"
#import "MainMenuCell.h"
#import "FBView.h"
#import "FBTransitionView.h"
#import "UILabel+FSHighlightAnimationAdditions.h"

@interface BSMainMenu : UIViewController <MainMenuCellDelegate,FBTransitionViewDelegate,UIActionSheetDelegate>{
    NSArray *aryFBViews,*aryDict,*aryCover;
    int currentPage,totalPages;
    
	CGPoint ptCurr,ptPrev,ptOrigin;
	
	NSUInteger pageToShow;
	int coverIndex,adIndex;

	
	FBView *fbCurr,*fbNext,*fbCover;
	UIImageView *imgvCover,*imgvCoverNext;
    UILabel *lblAdText,*lblSource;
	
	BOOL bTurned,bTurning;
    
    FBTransitionView *fbTrans;
    
    UIPanGestureRecognizer *panGesture;
    
    UIButton *btnSetting;
    BSSettingViewController *vcSetting;
    UITextField *tfSetting;
    
    UIView *vBG;
    UIButton *btnMenu,*btnLog,*btnQuery;
    
    UILabel *lblCaption;
    
    BOOL bActivated;
}
@property (nonatomic,retain) NSArray *aryDict,*aryFBViews,*aryCover;

- (void)genViews:(NSArray *)ary activated:(BOOL)activated;
- (void)deleteViews;
- (void)addCurView;

- (FBView *)viewAtIndex:(int)i;
@end
