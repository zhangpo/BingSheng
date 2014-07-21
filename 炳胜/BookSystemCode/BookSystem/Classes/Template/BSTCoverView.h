//
//  BSTCover.h
//  BookSystem
//
//  Created by Wu Stan on 12-5-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSTemplate.h"
#import "FBTransitionView.h"
#import "UILabel+FSHighlightAnimationAdditions.h"

@interface BSTCoverView : BSTemplate{
    UIButton *btnSetting;
    UILabel *lblCaption,*lblAdText,*lblSource;
    UIImageView *imgvCover,*imgvCoverNext;
    
    
    NSArray *aryCover;
    int coverIndex;
}
@property (nonatomic,retain) NSArray *aryCover;

- (void)animateCover;

@end
