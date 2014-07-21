//
//  BSMenuView.h
//  BookSystem
//
//  Created by Wu Stan on 12-4-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSDataProvider.h"

typedef enum {
    BSMenuStyleSub,
    BSMenuStyleContent
}BSMenuStyle;

#define kMenuCellWidth      96.0f

@protocol BSMenuViewDelegate

- (void)showPage:(NSUInteger)index;

@end

@interface BSMenuView : UIView<UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate>{
    UIScrollView *scvMenu;
    UIPopoverController *pop;
    NSArray *aryClass;
    BSMenuStyle menuStyle;
    id<BSMenuViewDelegate> delegate;
    
    NSMutableArray *aryItems;
}
@property (nonatomic,retain) NSArray *aryClass;
@property BSMenuStyle menuStyle;
@property (nonatomic,assign) id<BSMenuViewDelegate> delegate;
@property (nonatomic,retain) NSMutableArray *aryItems;

- (void)setSelectedIndex:(NSInteger)index;
- (void)changeButtonIndex:(NSInteger)index;
- (void)deselectMenu;

@end
