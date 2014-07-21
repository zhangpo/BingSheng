//
//  BSContent.h
//  BookSystem
//
//  Created by Dream on 11-3-16.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBView.h"
#import "FBTransitionView.h"
#import "UIButtonEx.h"
#import "BSOrderView.h"
#import "BSAddtionView.h"
#import "BSDataProvider.h"
#import "BSQueryViewController.h"
#import "BSLogViewController.h"
#import "WPhotoCell.h"
#import "BSCommentView.h"
#import <MediaPlayer/MediaPlayer.h>

#define PrevPage       0
#define NextPage       1

@interface BSContent : UIViewController <FBTransitionViewDelegate,AdditionViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate>{
    NSArray *aryFBViews,*aryDict;
    int currentPage,totalPages;
    NSString *strUnitKey,*strPriceKey;
    
	CGPoint ptCurr,ptPrev,ptOrigin;
	
	NSUInteger pageToShow;
    
    UIPopoverController *vcPop;
	
//    MPMoviePlayerController *player;
	
	FBView *fbCurr,*fbNext;
	
    UIPanGestureRecognizer *panGesture;
	
	BOOL bTurned,bTurning;
    
    FBTransitionView *fbTrans;
    BSOrderView *v;
    
    
    
    
    UIImageView *imgvOrder;
    UIButton *btnCount,*btnUnit;
    
    UIView *backView;
//    WPhotoCell *vPhotoCell;
    
    float fFoodCount;
    int dAddition;
    NSArray *aryAddition;
    
    UIButton *btnFujia;
    
    BSAddtionView *vAddition;
    
    UIView *vBG;
    UIButton *btnMenu,*btnLog,*btnQuery;
    
    UIPopoverController *pop;
    
    UITextView *tvFoodComment;
    BSCommentView *vCommentFood;
    UIButtonEx *btnCCC;
    
    UIView *vLogin;
    
    
    BOOL bActivated;
    
    int menuIndex;
}
@property (nonatomic,retain) NSArray *aryDict,*aryFBViews;
@property (nonatomic,retain) NSArray *aryAddition;
@property int menuIndex;
@property (nonatomic,copy) NSString *strUnitKey,*strPriceKey;

- (void)genViews:(NSArray *)ary activated:(BOOL)activated;
- (void)setCurrentIndex:(int)dIndex;


@end