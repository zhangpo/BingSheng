//
//  MainMenuCell.h
//  BookSystem
//
//  Created by Dream on 11-3-16.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIButtonEx.h"
#import <QuartzCore/QuartzCore.h>

@protocol MainMenuCellDelegate

- (void)cellSelected:(id)sender;

@end

@interface MainMenuCell : UIView {
    UIButtonEx *btnCover;
    UIImageView *imgvPic,*imgvName;
    UILabel *lblName;
    id<MainMenuCellDelegate> delegate;
}
@property (nonatomic,assign) id<MainMenuCellDelegate> delegate;
@property (nonatomic,retain) UIImageView *imgvPic,*imgvName;
@property (nonatomic,retain) UILabel *lblName;

- (id)initWithInfo:(NSDictionary *)info pageColor:(UIColor *)color;

@end
