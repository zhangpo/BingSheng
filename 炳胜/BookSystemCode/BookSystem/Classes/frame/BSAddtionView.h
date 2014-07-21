//
//  BSAddtionViewController.h
//  BookSystem
//
//  Created by Dream on 11-5-23.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSRotateView.h"
@protocol AdditionViewDelegate

- (void)additionSelected:(NSArray *)ary;

@end

@interface BSAddtionView : BSRotateView <UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>{
    UITableView *tv;
    UIButton *btnConfirm,*btnCancel;
    UITextField *tfAddition;
    
    NSDictionary *dicInfo;
    
    id<AdditionViewDelegate> delegate;
    
    NSMutableArray *arySelectedAddtions,*aryAdditions,*aryResult;
    
    UISearchBar *barAddition;
    UIView *vAddition;
    
    
}
@property (nonatomic,retain) NSDictionary *dicInfo;
@property (nonatomic,assign) id<AdditionViewDelegate> delegate;
@property (nonatomic,retain) NSMutableArray *arySelectedAddtions,*aryAdditions,*aryResult;

- (id)initWithFrame:(CGRect)frame info:(NSDictionary *)info;

@end
