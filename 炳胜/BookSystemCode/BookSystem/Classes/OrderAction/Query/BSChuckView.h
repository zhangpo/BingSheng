//
//  BSChunkView.h
//  BookSystem
//
//  Created by Dream on 11-5-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSRotateView.h"

@protocol  ChuckViewDelegate

- (void)chuckOrderWithOptions:(NSDictionary *)info;

@end

@interface BSChuckView : BSRotateView <UIPickerViewDelegate,UIPickerViewDataSource>{
    UIButton *btnChunk,*btnCancel;
    UILabel *lblAcct,*lblPwd,*lblCount,*lblReason;
    UITextField *tfAcct,*tfPwd,*tfCount;
    UIPickerView *pickerReason;
    
    NSMutableArray *aryReasons;
    
    id<ChuckViewDelegate> delegate;
    int dSelected;
}
@property (nonatomic,retain) NSMutableArray *aryReasons;
@property (nonatomic,assign) id<ChuckViewDelegate> delegate;


@end
