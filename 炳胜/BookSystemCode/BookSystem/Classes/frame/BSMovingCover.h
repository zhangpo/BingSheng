//
//  BSMovingCover.h
//  BookSystem
//
//  Created by Wu Stan on 12-4-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSDataProvider.h"

@interface BSMovingCover : UIView{
    NSArray *aryCovers;
    UIImageView *imgvBG,*imgvFirst,*imgvSecond;
}
@property (nonatomic,retain) NSArray *aryCovers;

- (void)setImage:(UIImage *)img;
- (void)startAnimation;
- (void)stopAnimation;

@end
