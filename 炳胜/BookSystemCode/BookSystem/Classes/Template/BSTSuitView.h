//
//  BSTSuitView.h
//  BookSystem
//
//  Created by Wu Stan on 12-6-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BSTemplate.h"
#import "BSShiftFoodViewController.h"



@interface BSTSuitView : BSTemplate<BSShiftFoodDelegate>{
    UIButton *btnSuit,*btnConfirm;
    UILabel *lblName,*lblPrice;
    UITableView *tvFoodList;
    BSShiftFoodViewController *vcShiftFood;
    
    NSDictionary *dicBookInfo;
}
@property (nonatomic,retain) NSDictionary *dicBookInfo;

@end
