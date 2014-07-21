//
//  BSOrderView.h
//  BookSystem
//
//  Created by Dream on 11-5-12.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSRotateView.h"

@protocol  OrderViewDelegate

- (void)chuckOrderWithOptions:(NSDictionary *)info;

@end

@interface BSOrderView : BSRotateView {
    UIButton *btnConfirm,*btnCancel;
    
    UITableView *tvAdditions;
    
    id<OrderViewDelegate> delegate;
}

@property (nonatomic,assign) id<OrderViewDelegate> delegate;


@end
