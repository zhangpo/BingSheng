//
//  BSSendView.h
//  BookSystem
//
//  Created by Dream on 11-5-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSRotateView.h"

@protocol  SendViewDelegate

- (void)sendOrderWithOptions:(NSDictionary *)info;


@end

@interface BSSendView : BSRotateView <UITextFieldDelegate>{
    UIButton *btnSendNow,*btnSendWait,*btnCancel;
    
    UILabel *lblAcct,*lblPwd,*lblTable,*lblPeople;
    
    UITextField *tfAcct,*tfPwd,*tfTable,*tfPeople;
    
    id<SendViewDelegate> delegate;
}

@property (nonatomic,assign) id<SendViewDelegate> delegate;

@end
