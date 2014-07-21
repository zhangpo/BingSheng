//
//  FBTransitionView.h
//  BookSystem
//
//  Created by Dream on 11-3-23.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "FBView.h"

#define PrevPage 0
#define NextPage 1

@protocol FBTransitionViewDelegate

- (void)turnEnded:(BOOL)turned;

@end


@interface FBTransitionView : UIView {
    int direction;  //unsigned:turn next,signed:turn prev
    UIImageView *imgvCL,*imgvCR,*imgvNL,*imgvNR,*imgvBG;
    
    float _angle;
    
    id<FBTransitionViewDelegate> delegate;
    
    FBView *fbCur,*fbNext;
}
@property (nonatomic,assign) id<FBTransitionViewDelegate> delegate;
@property (nonatomic,retain) FBView *fbCur,*fbNext;

- (id)initWithView:(UIView *)curr toView:(UIView *)next direction:(int)direct;
- (void)rotateAngle:(float)angle;
- (void)rotateLeft:(BOOL)finished;

- (void)setView:(UIView *)curr toView:(UIView *)next direction:(int)direct;

- (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect;

- (void)beginRotate;
@end
