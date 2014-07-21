//
//  FBTransitionView.m
//  BookSystem
//
//  Created by Dream on 11-3-23.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "FBTransitionView.h"
#import "FBView.h"
#import <mach/mach.h>

@implementation FBTransitionView
@synthesize delegate;
@synthesize fbCur,fbNext;
//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        // Initialization code
//    }
//    return self;
//}



- (id)initWithView:(FBView *)curr toView:(FBView *)next direction:(int)direct{
    self = [super initWithFrame:CGRectMake(0, 0, 768, 1004)];
    if (self){
        self.fbCur = curr;
        self.fbNext = next;
        NSLog(@"Curr:%d,Next:%d",[fbCur retainCount],[fbNext retainCount]);
        self.opaque = YES;
        float w = curr.bounds.size.width/2.0f;
        float h = curr.bounds.size.height;
        w = 384.0f;
        h = 1004.0f;
        
        direction = direct;
        _angle = 0;
        
        imgvCL = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
        imgvCR = [[UIImageView alloc] initWithFrame:CGRectMake(w, 0, w, h)];
        imgvNL = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
        imgvNR = [[UIImageView alloc] initWithFrame:CGRectMake(w, 0, w, h)];
        imgvCL.layer.anchorPoint = CGPointMake(1.0, 0.5);
        imgvCR.layer.anchorPoint = CGPointMake(0.0, 0.5);
        imgvNL.layer.anchorPoint = CGPointMake(1.0, 0.5);
        imgvNR.layer.anchorPoint = CGPointMake(0.0, 0.5);
        imgvCL.layer.position = CGPointMake(w, h/2.0f);
        imgvCR.layer.position = CGPointMake(w, h/2.0f);
        imgvNL.layer.position = CGPointMake(w, h/2.0f);
        imgvNR.layer.position = CGPointMake(w, h/2.0f);
        
        
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

        curr.layer.shouldRasterize = YES;

        UIGraphicsBeginImageContextWithOptions(curr.bounds.size,YES,0.0);
        [curr.layer renderInContext:UIGraphicsGetCurrentContext()];
//        [curr drawInContext:UIGraphicsGetCurrentContext()];
       
        UIImage *imgC = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();

        UIImage *cl = [self imageFromImage:imgC inRect:CGRectMake(0, 0, w, h)];
        UIImage *cr = [self imageFromImage:imgC inRect:CGRectMake(w, 0, w, h)];
        [imgvCL setImage:cl];
        [imgvCR setImage:cr];
        
        curr.layer.contents = nil;
        
        if (next!=nil){
            next.layer.shouldRasterize = YES;
            UIGraphicsBeginImageContextWithOptions(next.bounds.size,YES,0.0);
//            [next drawInContext:UIGraphicsGetCurrentContext()];
            [next.layer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *imgN = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            UIImage *nl = [self imageFromImage:imgN inRect:CGRectMake(0, 0, w, h)];
            UIImage *nr = [self imageFromImage:imgN inRect:CGRectMake(w, 0, w, h)];
            [imgvNL setImage:nl];
            [imgvNR setImage:nr];
            if (next.layer.contents)
                NSLog(@"Contents not nil");
            
            next.layer.contents = nil;
        }
        else{
            [imgvNL setImage:nil];
            [imgvNR setImage:nil];
            imgvNL.backgroundColor = [UIColor blackColor];
            imgvNR.backgroundColor = [UIColor blackColor];
        }
        
        imgvNL.layer.zPosition = -0.001f;
        imgvNR.layer.zPosition = -0.001f;
        
        [self.layer addSublayer:imgvNL.layer];
        [self.layer addSublayer:imgvNR.layer];
        [self.layer addSublayer:imgvCL.layer];
        [self.layer addSublayer:imgvCR.layer];
        
        [pool release];
        CATransform3D sublayerTransform = CATransform3DIdentity;
        sublayerTransform.m34 = -0.0001;
        [self.layer setSublayerTransform:sublayerTransform]; 
        

    }
    
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    self.delegate = nil;
    [imgvCL release];
    [imgvCR release];
    [imgvNL release];
    [imgvNR release];
    
    NSLog(@"Curr:%d,Next:%d",[fbCur retainCount],[fbNext retainCount]);

    self.fbCur = nil;
    self.fbNext = nil;
    [super dealloc];
}


- (void)beginRotate{
    [self.window addSubview:self];
}

- (void)rotateAngle:(float)angle{
    if (_angle >= 178 && angle>0)
		return;
	else if (_angle<=2 && angle<0)
		return;
	_angle += angle;
    if (_angle>=178)
        _angle = 178;
    if (_angle<=2)
        _angle = 2;
	if (direction<0) // turn to prev page
	{
		if (_angle >= 90)
		{
//			if ([self.nextFB.name isEqualToString:@"none"])
//				return;
			imgvCL.layer.transform = CATransform3DMakeRotation(M_PI/2, 0, 1, 0);
			imgvNR.layer.transform = CATransform3DMakeRotation(M_PI-M_PI/180*_angle,0,-1,0);
		}
		else
		{
			imgvCL.layer.transform = CATransform3DMakeRotation(M_PI/180*_angle, 0, 1, 0);
			imgvNR.layer.transform = CATransform3DMakeRotation(M_PI/2, 0, -1, 0);
		}
	}
	else
	{
		if (_angle >= 90)
		{
//			if ([self.nextFB.name isEqualToString:@"none"])
//				return;
            
			imgvCR.layer.transform = CATransform3DMakeRotation(M_PI/2, 0, -1, 0);
			imgvNL.layer.transform = CATransform3DMakeRotation(M_PI-M_PI/180*_angle,0,1,0);
		}
		else
		{
			imgvCR.layer.transform = CATransform3DMakeRotation(M_PI/180*_angle, 0, -1, 0);
			imgvNL.layer.transform = CATransform3DMakeRotation(M_PI/2, 0, 1, 0);
		}
		
	}

}

- (void)rotate:(NSNumber *)ang{
    float angle_roate = [ang floatValue];
    [self rotateAngle:angle_roate];
}

- (void)rotateLeft:(BOOL)finished{
    int speed = 100;
    float duration = 0.3f;
    float delta = 0.003f;
    if (finished){
        CGFloat degree = (180.0f-_angle)/(float)speed;
        for (int i=1;i<=speed-1;i++)
        {	
            
    //        [self rotateAngle:degree];
            [self performSelector:@selector(rotate:) withObject:[NSNumber numberWithFloat:degree] afterDelay:i*duration/(float)speed];
            if (i==speed-1)
            {
                //[self refreshPage];
                
                [self performSelector:@selector(rotateEnded:) withObject:[NSNumber numberWithBool:YES] afterDelay:duration+delta];
            }
        }  
        NSLog(@"turn finished");
    }
    else{
        CGFloat degree = -_angle/speed;
        for (int i=1;i<=speed-1;i++)
        {
//            [self rotateAngle:degree];
            [self performSelector:@selector(rotate:) withObject:[NSNumber numberWithFloat:degree] afterDelay:i*duration/(float)speed];
            if (i==speed-1)
            {
                //[self refreshPage];
                [self performSelector:@selector(rotateEnded:) withObject:[NSNumber numberWithBool:NO] afterDelay:duration+delta];
            }
        }
        NSLog(@"turn reversed");
    }

    
 
}

- (void)rotateEnded:(NSNumber *)turned{
    BOOL bTurned = [turned boolValue];
    [self.delegate turnEnded:bTurned];
    
}

- (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect 
{   
	CGImageRef sourceImageRef = [image CGImage];   
	CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);   
	UIImage *newImage = [UIImage imageWithCGImage:newImageRef]; 
//    CGImageRelease(sourceImageRef);
    CGImageRelease(newImageRef);
    
	return newImage;   
}

- (void)setView:(FBView *)curr toView:(FBView *)next direction:(int)direct{
    self.fbCur = curr;
    self.fbNext = next;
    float w = curr.bounds.size.width/2.0f;
    float h = curr.bounds.size.height;
    w = 384.0f;
    h = 1004.0f;
    direction = direct;
    _angle = 0;
    
    if ([[NSThread currentThread] isMainThread])
        NSLog(@"Is MainThread");
    else
        NSLog(@"No MainThread");
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    curr.layer.shouldRasterize = YES;
    UIGraphicsBeginImageContextWithOptions(curr.bounds.size,YES,0.0);
//    [curr drawInContext:UIGraphicsGetCurrentContext()];
    [curr.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *imgC = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImage *cl = [self imageFromImage:imgC inRect:CGRectMake(0, 0, w, h)];
    UIImage *cr = [self imageFromImage:imgC inRect:CGRectMake(w, 0, w, h)];
    [imgvCL setImage:cl];
    [imgvCR setImage:cr];
    
    curr.layer.contents = nil;
    if (next!=nil){
        next.layer.shouldRasterize = YES;
        UIGraphicsBeginImageContextWithOptions(next.bounds.size,YES,0.0);
//        [next drawInContext:UIGraphicsGetCurrentContext()];
        [next.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *imgN = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        UIImage *nl = [self imageFromImage:imgN inRect:CGRectMake(0, 0, w, h)];
        UIImage *nr = [self imageFromImage:imgN inRect:CGRectMake(w, 0, w, h)];
        [imgvNL setImage:nl];
        [imgvNR setImage:nr];
        
        next.layer.contents = nil;
    }
    else{
        [imgvNL setImage:nil];
        [imgvNR setImage:nil];
        imgvNL.backgroundColor = [UIColor blackColor];
        imgvNR.backgroundColor = [UIColor blackColor];
    }
    imgvCL.layer.transform = CATransform3DIdentity;
    imgvCR.layer.transform = CATransform3DIdentity;
    imgvNL.layer.transform = CATransform3DIdentity;
    imgvNR.layer.transform = CATransform3DIdentity;
    
    [pool release];
}

//test

@end
