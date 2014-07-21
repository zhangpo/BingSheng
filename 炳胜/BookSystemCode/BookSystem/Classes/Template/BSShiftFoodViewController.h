//
//  BSShiftFoodViewController.h
//  BookSystem
//
//  Created by Wu Stan on 12-6-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//width 540 height 580
@protocol BSShiftFoodDelegate

- (void)packageChanged:(NSDictionary *)info;

@end

@interface BSShiftFoodViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>{
    UIButton *btnSuit,*btnConfirm;
    UITableView *tvFoodList;
    
    NSDictionary *dicFood,*dicPackageInfo,*dicInfo;
    NSMutableDictionary *dicBookInfo;
    NSArray *aryShiftFood;
    id<BSShiftFoodDelegate> delegate;
    BOOL bBlockAction;
}
@property (nonatomic,retain) NSDictionary *dicFood,*dicPackageInfo,*dicInfo;
@property (nonatomic,retain) NSMutableDictionary *dicBookInfo;
@property (nonatomic,retain) NSArray *aryShiftFood;
@property (nonatomic,assign) id<BSShiftFoodDelegate> delegate;

@end
