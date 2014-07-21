//
//  SubMenuCell.h
//  BookSystem
//
//  Created by Dream on 11-3-23.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIButtonEx.h"
@protocol SubMenuCellDelegate

- (void)cellSelected:(id)sender;

@end



@interface SubMenuCell : UIView {
    UIImageView *imgvPic,*imgvPap;
    UILabel *lblNameCN,*lblNameEn,*lblWeight,*lblPrice;
    
    id<SubMenuCellDelegate> delegate;
}
@property (nonatomic,assign) id<SubMenuCellDelegate> delegate;
@property (nonatomic,retain) UIImageView *imgvPic,*imgvPap;
@property (nonatomic,retain) UILabel *lblNameCN,*lblNameEn,*lblWeight,*lblPrice;

- (void)showData:(NSDictionary *)dict;
@end
