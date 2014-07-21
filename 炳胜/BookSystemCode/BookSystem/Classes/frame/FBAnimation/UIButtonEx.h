//
//  UIButtonEx.h
//  BookSystem
//
//  Created by Dream on 11-3-23.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIButtonEx : UIButton {
    id parent;
    CGPoint pressPoint;
    BOOL notifyParent;
}
@property (nonatomic,assign) id parent;
@end
