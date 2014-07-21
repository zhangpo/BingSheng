//
//  BSTableButtion.h
//  BookSystem
//
//  Created by Dream on 11-7-11.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>



typedef enum{
    BSTableTypeOrdered,      //blue
    BSTableTypeEating,        //red点菜
    BSTableTypeEmpty,        //green
    BSTableTypeNoOrder,       //yellow
    BSTableTypeNotPaid      //purple
}BSTableType;

@class BSTableButton;

@protocol BSTableButtonDelegate

//- (void)tableClicked:(BSTableButton *)btn;
- (int)indexOfButtonCoveredPoint:(CGPoint)pt;

- (void)replaceOldTable:(int)oldIndex withNewTable:(int)newIndex;

@end

@interface BSTableButton : UIButton {
    BSTableType   tableType;
    
    NSString *tableTitle;
    
    id<BSTableButtonDelegate> delegate;
    
    BOOL isMoving;
    
    CGPoint ptStart;
    
    UIImageView *imgvCopy;
}


@property (nonatomic,assign) BSTableType tableType;
@property (nonatomic,copy) NSString *tableTitle;
@property (nonatomic,assign) id<BSTableButtonDelegate> delegate;
@end
