//
//  UIButtonEx.m
//  BookSystem
//
//  Created by Dream on 11-3-23.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "UIButtonEx.h"


@implementation UIButtonEx
@synthesize parent;

#pragma mark -
#pragma mark Handle Touch Event
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
	NSLog(@"touchesBegan at button");
	UITouch *touch = [touches anyObject];
	pressPoint = [touch locationInView:self];
	
	[super touchesBegan:touches withEvent:event];
}


BOOL CGPtEqualToPtEx(CGPoint point1, CGPoint point2)
{
	CGFloat xx = fabs(point1.x - point2.x);
	CGFloat yy = fabs(point1.y - point2.y);
	return xx <= 3 && yy <= 3;
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];
	if (CGPtEqualToPtEx(point, pressPoint) && !notifyParent)
	{
		NSLog(@"touchesMoved at button");
		[super touchesMoved:touches withEvent:event];	
	}
	else
	{
		if (!notifyParent)
		{
			notifyParent = TRUE;
			NSLog(@"touchesCancelled at button");
			[super touchesCancelled:touches withEvent:event];
			[parent touchesBegan:touches withEvent:event];
		}
		[parent touchesMoved:touches withEvent:event];
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSLog(@"touchesEnded at button");
	
	[super touchesEnded:touches withEvent:event];
	[parent touchesEnded:touches withEvent:event];
	
	notifyParent = FALSE;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSLog(@"touchesCancelled at button");
	[super touchesCancelled:touches withEvent:event];
	[parent touchesCancelled:touches withEvent:event];
	notifyParent = FALSE;
}

- (void)dealloc{
    self.parent = nil;
    
    [super dealloc];
}
@end
