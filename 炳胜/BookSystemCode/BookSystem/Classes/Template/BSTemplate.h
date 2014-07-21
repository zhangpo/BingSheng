//
//  BSTemplate.h
//  BookSystem
//
//  Created by Wu Stan on 12-5-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSDataProvider.h"

@interface BSTemplate : UIView{
    UIImageView *imgvBG;
    UIViewController *vcParent;
    
    NSDictionary *dicInfo;
    UIColor *pageColor;
    BOOL bActivated;
}
@property (nonatomic,retain) NSDictionary *dicInfo;
@property (nonatomic,assign) UIViewController *vcParent;
@property (nonatomic,retain) UIColor *pageColor;
@property BOOL bActivated;

- (id)initWithFrame:(CGRect)frame info:(NSDictionary *)info;

@end
