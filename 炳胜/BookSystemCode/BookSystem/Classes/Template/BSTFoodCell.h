//
//  BSTFoodCell.h
//  BookSystem
//
//  Created by Wu Stan on 12-6-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSAddtionView.h"

#define kPadding 10

@interface BSTFoodCell : UIView<UITableViewDataSource,UITableViewDelegate,AdditionViewDelegate,UIPopoverControllerDelegate>{
    UIView *vFront,*vBack,*vRecommends,*vDetail;
    UIImageView *imgvOrdered;
    UIPopoverController *pop;
    
    NSDictionary *dicInfo;
    NSString *strUnitKey,*strPriceKey;
    NSMutableArray *aryAddition,*aryFood,*aryCount,*aryRecommends;
    float fCount;
    UIColor *pageColor;
}
@property (nonatomic,retain) NSDictionary *dicInfo;
@property (nonatomic,copy) NSString *strUnitKey,*strPriceKey;
@property (nonatomic,retain) NSMutableArray *aryAddition,*aryFood,*aryCount,*aryRecommends;
@property (nonatomic,retain) UIColor *pageColor;

- (id)initWithInfo:(NSDictionary *)info pageColor:(UIColor *)color;


@end
