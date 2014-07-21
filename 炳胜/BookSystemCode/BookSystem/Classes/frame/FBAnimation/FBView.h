//
//  FBView.h
//  FlipBoardTurning
//
//  Created by Stan on 11-3-9.
//  Copyright 2011 GIK4. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define kRotatePrev     0
#define kRotateNext     1
#define kTopButtonY     80



@interface FBView : UIView {
    
	CGFloat _angleRotated;
	

	
	id parent;
    CGPoint pressPoint;
    BOOL notifyParent;
	
	NSString *_name;
	NSString *strImageName;
}


@property (nonatomic,assign) id parent;
@property (nonatomic,copy) NSString *name,*strImageName;

- (void)drawInContext:(CGContextRef)ctx;


@end
