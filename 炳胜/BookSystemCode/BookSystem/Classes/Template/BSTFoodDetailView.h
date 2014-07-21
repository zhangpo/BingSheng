//
//  BSTFoodDetailView.h
//  BookSystem
//
//  Created by Wu Stan on 12-5-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BSTemplate.h"
#import "FBView.h"
#import "BSAddtionView.h"
#import "UIButtonEx.h"
#import "BSCommentView.h"

@class AVPlayer;
@interface BSTFoodDetailView : BSTemplate<AdditionViewDelegate,UIActionSheetDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UITableViewDelegate,UITableViewDataSource>{
    UIButton *btnCount,*btnUnit,*btnFujia;
    BSAddtionView *vAddition;
    UIPopoverController *pop,*vcPop;
    UITextView *tvFoodComment;
    BSCommentView *vCommentFood;
    UIButtonEx *btnCCC;
    UIView *vLogin;
    UIImageView *imgvOrdered;
    UILabel *lblPrice,*lblUnit;
    
    BOOL bShowButton;
    float fFoodCount;
    int dAddition;
    NSArray *aryAddition;
    NSString *strUnitKey,*strPriceKey;
    AVPlayer *vPlayer;
}
@property (nonatomic,retain) NSArray *aryAddition;
@property (nonatomic,copy) NSString *strUnitKey,*strPriceKey;

@end
