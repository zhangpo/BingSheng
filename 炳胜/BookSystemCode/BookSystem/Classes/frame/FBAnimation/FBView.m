//
//  FBView.m
//  FlipBoardTurning
//
//  Created by Stan on 11-3-9.
//  Copyright 2011 GIK4. All rights reserved.
//

#import "FBView.h"
#import "MainMenuCell.h"
#import "SubMenuCell.h"
#import "BSAdView.h"
#import "BSDataProvider.h"

@interface FBView()

- (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect;

@end


@implementation FBView

@synthesize name = _name;
@synthesize parent,strImageName;


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        notifyParent = NO;
        NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docPath = [docPaths objectAtIndex:0];
        
        NSString *dicPath = [docPath stringByAppendingPathComponent:kBGFileName];
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:dicPath];
        if (!dic){
            dic = [NSDictionary dictionaryWithObject:@"defaultbg.jpg" forKey:@"name"];
            [dic writeToFile:dicPath atomically:NO];
        }
        
        NSString *name = [dic objectForKey:@"name"];
        NSString *imgPath = [docPath stringByAppendingPathComponent:name];
        
        UIImage *img = [[UIImage alloc] initWithContentsOfFile:imgPath];
        UIImageView *imgv = [[UIImageView alloc] initWithFrame:self.bounds];
        [imgv setImage:img];
        [img release];
        
        [self addSubview:imgv];
        [imgv release];
        

    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code.
 }
 */

- (void)dealloc {

    self.name = nil;
    self.strImageName = nil;
    
    [super dealloc];
}




#pragma mark -
#pragma mark Load Views


- (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect 
{   
	CGImageRef sourceImageRef = [image CGImage];   
	CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);   
	UIImage *newImage = [UIImage imageWithCGImage:newImageRef]; 
//	CGImageRelease(sourceImageRef);
    CGImageRelease(newImageRef);
    
	return newImage;   
}


#pragma mark -
#pragma mark Handle Touch Event
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
	NSLog(@"touchesBegan at fbview");
	UITouch *touch = [touches anyObject];
	pressPoint = [touch locationInView:self];
	
	[super touchesBegan:touches withEvent:event];
}



BOOL CGPointEqualToPointEx(CGPoint point1, CGPoint point2)
{
	CGFloat xx = fabs(point1.x - point2.x);
	CGFloat yy = fabs(point1.y - point2.y);
	return xx <= 3 && yy <= 3;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];
	if (CGPointEqualToPointEx(point, pressPoint) && !notifyParent)
	{
		NSLog(@"touchesMoved at FBView");
		[super touchesMoved:touches withEvent:event];	
	}
	else
	{
		if (!notifyParent)
		{
			notifyParent = TRUE;
			NSLog(@"touchesCancelled at FBView when moving");
			[super touchesCancelled:touches withEvent:event];
			[parent touchesBegan:touches withEvent:event];
		}
		[parent touchesMoved:touches withEvent:event];
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSLog(@"touchesEnded at FBView");
	
	[super touchesEnded:touches withEvent:event];
	[parent touchesEnded:touches withEvent:event];
	
	notifyParent = FALSE;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSLog(@"touchesCancelled at FBView");
	[super touchesCancelled:touches withEvent:event];
	[parent touchesCancelled:touches withEvent:event];
	notifyParent = FALSE;
}

- (void)drawInContext:(CGContextRef)ctx{
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextFillRect(ctx, self.bounds);
    
    for (UIView *view in self.subviews){
        float x = view.frame.origin.x;
        float y = view.frame.origin.y;
 //       float w = view.frame.size.width;
        float h = view.frame.size.height;
        
        if ([[view class] isSubclassOfClass:[MainMenuCell class]]){
            MainMenuCell *cellMain = (MainMenuCell *)view;
            [cellMain.imgvPic.image drawInRect:view.frame];
            CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5].CGColor);
            CGContextFillRect(ctx, CGRectMake(x, y+cellMain.imgvName.frame.origin.y, cellMain.imgvName.frame.size.width, cellMain.imgvName.frame.size.height));
            
            [cellMain.lblName drawTextInRect:CGRectMake(x+cellMain.lblName.frame.origin.x, y+cellMain.lblName.frame.origin.y, cellMain.lblName.frame.size.width, cellMain.lblName.frame.size.height)];
        }
        else if ([[view class] isSubclassOfClass:[SubMenuCell class]]){
            SubMenuCell *cellSub = (SubMenuCell *)view;
            CGContextSelectFont(ctx, [cellSub.lblWeight.font.fontName UTF8String], cellSub.lblWeight.font.pointSize, kCGEncodingFontSpecific);

            [cellSub.imgvPic.image drawInRect:CGRectMake(cellSub.frame.origin.x, cellSub.frame.origin.y, cellSub.imgvPic.frame.size.width, cellSub.imgvPic.frame.size.height)];
            [cellSub.imgvPap.image drawInRect:CGRectMake(cellSub.frame.origin.x+cellSub.imgvPap.frame.origin.x, cellSub.frame.origin.y+cellSub.imgvPap.frame.origin.y, cellSub.imgvPap.frame.size.width, cellSub.imgvPap.frame.size.height)];
            
            [cellSub.lblNameCN drawTextInRect:CGRectMake(x+cellSub.lblNameCN.frame.origin.x, y+cellSub.lblNameCN.frame.origin.y, cellSub.lblNameCN.frame.size.width, cellSub.lblNameCN.frame.size.height)];
            [cellSub.lblNameEn drawTextInRect:CGRectMake(x+cellSub.lblNameEn.frame.origin.x, y+cellSub.lblNameEn.frame.origin.y, cellSub.lblNameEn.frame.size.width, cellSub.lblNameEn.frame.size.height)];
            [cellSub.lblPrice drawTextInRect:CGRectMake(x+cellSub.lblPrice.frame.origin.x, y+cellSub.lblPrice.frame.origin.y, cellSub.lblPrice.frame.size.width, cellSub.lblPrice.frame.size.height)];
            [cellSub.lblWeight drawTextInRect:CGRectMake(x+cellSub.lblWeight.frame.origin.x, y+cellSub.lblWeight.frame.origin.y, cellSub.lblWeight.frame.size.width, cellSub.lblWeight.frame.size.height)];
        }
        else if ([[view class] isSubclassOfClass:[UIImageView class]]){
            UIImageView *imgv = (UIImageView *)view;
            [imgv.image drawInRect:imgv.frame];
        }
        else if ([[view class] isSubclassOfClass:[UIButton class]]){
            UIButton *btn = (UIButton *)view;
            if (btn.currentImage!=nil)
                [btn.currentImage drawInRect:btn.frame];
        }
        else if ([[view class] isSubclassOfClass:[UILabel class]]){
            UILabel *lbl = (UILabel *)view;
            [lbl drawTextInRect:lbl.frame];
        }
        else if ([[view class] isSubclassOfClass:[BSAdView class]]){
            BSAdView *vAD = (BSAdView *)view;
            [vAD.imgvAD.image drawInRect:vAD.frame];
            
        }
    }

}
@end
