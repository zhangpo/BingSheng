//
//  BookSystemViewController.h
//  BookSystem
//
//  Created by Dream on 11-3-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "BSSubMenu.h"
#import "BSMainMenu.h"
#import "BSContent.h"
#import "ABScrollPageView.h"
#import "BSTemplate.h"
#import "BSMenuView.h"
#import "BSRecommendGridView.h"

typedef enum {
    BSViewTypeClassDetail,
    BSViewTypeFoodDetail
}BSViewType;

@interface BookSystemViewController : UIViewController<ABScrollPageViewDeleage,BSMenuViewDelegate>{
    ABScrollPageView *scvContent;
    BSMenuView *vMenu;
    UIImageView *imgvCover;
    UIButton *btnQuery,*btnLog;
    BSRecommendGridView *vRecommendGrid;

    BOOL bActivated,isRefreshRecommendList;
    
    BSViewType viewType;
    int dCurrentIndex;
}

@end
