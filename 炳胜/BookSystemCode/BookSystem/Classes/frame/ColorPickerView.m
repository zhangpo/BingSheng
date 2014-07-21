//
//  ColorPickerView.m
//  Wabo
//
//  Created by Stan Wu on 11-9-26.
//  Copyright 2011年 CheersDigi. All rights reserved.
//

#import "ColorPickerView.h"

static int color[] = {
    255,255,255,  175,175,175,  0,0,0,
    205,79,238,     0,247,105,  0,143,242,
    241,247,108,    255,198,86, 217,19,21
}; 

@interface ColorPickerView()

- (UIColor *)getPixelColorAtLocation:(CGPoint)point;
- (CGContextRef)createARGBBitmapContextFromImage:(CGImageRef)inImage;
@end

@implementation ColorPickerView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame delegate:(id<ColorPickerViewDelegate>)delegate_
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = delegate_;
        
        UIView *vSwitch = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:vSwitch];
        [vSwitch release];
        
        vCircle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 353, 354)];
        [vSwitch addSubview:vCircle];
        [vCircle release];
        
        vSquare = [[UIView alloc] initWithFrame:CGRectMake(15, 0, 320, 305)];
        [vSwitch addSubview:vSquare];
        [vSquare release];
        vSquare.hidden = YES;
        
        // add circle color picker
        imgvCircle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"colorpickercircle.png"]];
        [vCircle addSubview:imgvCircle];
        [imgvCircle release];
        
        float w = 0.5f*sqrtf(2.0f)*imgvCircle.bounds.size.width*0.606f-3;
        vGradient = [[ColorGradientSelectorView alloc] initWithFrame:CGRectMake(0, 0, w, w)];
        vGradient.center = imgvCircle.center;
        vGradient.middleColor = [delegate lastSelectedColor];
        [vCircle addSubview:vGradient];
        [vGradient release];
        vGradient.transform = CGAffineTransformMakeRotation(45*M_PI/180.0f);
        [vGradient setNeedsDisplay];
        
        // add square color picker
        for (int i=0;i<9;i++){
            float x = ((int)(i/3))*110.0f;
            float y = (i%3)*105.0f;
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(x, y, 100, 95);
            btn.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2f].CGColor;
            btn.layer.borderWidth = 2;
//            btn.layer.shadowOpacity = 0.3f;
//            btn.layer.shadowOffset = CGSizeMake(0, 0);
//            btn.layer.shadowRadius = 10;
            btn.backgroundColor = [UIColor colorWithRed:color[i*3]/255.0f green:color[i*3+1]/255.0f blue:color[i*3+2]/255.0f alpha:1.0];
            [btn addTarget:self action:@selector(colorSquareClicked:) forControlEvents:UIControlEventTouchUpInside];
            [vSquare addSubview:btn];
        }
        
        imgvPreColor = [[UIImageView alloc] initWithFrame:CGRectMake(0, 315, 40, 20)];
        imgvPreColor.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2f].CGColor;
        imgvPreColor.layer.borderWidth = 1.0f;
        imgvPreColor.backgroundColor = [delegate lastSelectedColor];
        [self addSubview:imgvPreColor];
        [imgvPreColor release];
        
        imgvCurrentColor = [[UIImageView alloc] initWithFrame:CGRectMake(0, 335, 40, 20)];
        imgvCurrentColor.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2f].CGColor;
        imgvCurrentColor.layer.borderWidth = 1.0f;
        imgvCurrentColor.backgroundColor = [delegate lastSelectedColor];
        [self addSubview:imgvCurrentColor];
        [imgvCurrentColor release];
        
        btnSwitch = [UIButton buttonWithType:UIButtonTypeCustom];
        btnSwitch.frame = CGRectMake(0, 0, 40, 40);
        btnSwitch.center = CGPointMake(323, 333);
        btnSwitch.imageEdgeInsets = UIEdgeInsetsMake(4, 4, 4, 4);
        [btnSwitch setImage:[UIImage imageNamed:@"circlepicker.png"] forState:UIControlStateNormal];
        [btnSwitch setImage:[UIImage imageNamed:@"squarepicker.png"] forState:UIControlStateSelected];
        [btnSwitch addTarget:self action:@selector(switchPanel) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnSwitch];
        
        
        
    }
    return self;
}

- (void)switchPanel{
    if (btnSwitch.selected){
        [UIView transitionFromView:vSquare toView:vCircle duration:0.3f options:UIViewAnimationOptionShowHideTransitionViews | UIViewAnimationOptionTransitionFlipFromRight | UIViewAnimationOptionCurveEaseInOut completion:^(BOOL finished) {

        }];
    }
    else{
        [UIView transitionFromView:vCircle toView:vSquare duration:0.3f options:UIViewAnimationOptionShowHideTransitionViews | UIViewAnimationOptionTransitionFlipFromLeft | UIViewAnimationOptionCurveEaseInOut completion:^(BOOL finished) {

        }];
    }
    
    btnSwitch.selected = !btnSwitch.selected;
}

- (void)colorSquareClicked:(UIButton *)btn{
    [delegate colorSelected:btn.backgroundColor];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    if (!vCircle.superview){
       [self touchesCancelled:touches withEvent:event];
        return;
    }
        
    
    
	UITouch* touch = [touches anyObject];
	CGPoint point = [touch locationInView:imgvCircle]; //where image was tapped
	UIColor *lastColor = [self getPixelColorAtLocation:point]; 
    const CGFloat *components = CGColorGetComponents(lastColor.CGColor);
    CGFloat alpha = components[3];
    if (0!=alpha){
        [delegate circleColorSelected:lastColor];
        vGradient.middleColor = lastColor;
        [vGradient setNeedsDisplay];
        
        imgvCurrentColor.backgroundColor = lastColor;
    }
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
    if (!vCircle.superview)
        return;
	UITouch* touch = [touches anyObject];
	CGPoint point = [touch locationInView:imgvCircle]; //where image was tapped
	UIColor *lastColor = [self getPixelColorAtLocation:point]; 
    const CGFloat *components = CGColorGetComponents(lastColor.CGColor);
    CGFloat alpha = components[3];
    if (0!=alpha){
        [delegate circleColorSelected:lastColor];
        vGradient.middleColor = lastColor;
        [vGradient setNeedsDisplay];
        
        imgvCurrentColor.backgroundColor = lastColor;
    }
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	UITouch* touch = [touches anyObject];
	CGPoint point = [touch locationInView:imgvCircle]; //where image was tapped
	UIColor *lastColor = [self getPixelColorAtLocation:point]; 
    const CGFloat *components = CGColorGetComponents(lastColor.CGColor);
    CGFloat alpha = components[3];
    if (0!=alpha){
        [delegate circleColorSelected:lastColor];
        vGradient.middleColor = lastColor;
        [vGradient setNeedsDisplay];
        
        imgvCurrentColor.backgroundColor = lastColor;
    }
}

// Please refer to iOS Developer Library for more details regarding the following two methods
- (UIColor*) getPixelColorAtLocation:(CGPoint)point {
	UIColor* color = nil;
	CGImageRef inImage = imgvCircle.image.CGImage;
	// Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
	CGContextRef contexRef = [self createARGBBitmapContextFromImage:inImage];
	if (contexRef == NULL) { return nil; /* error */ }
	
    size_t w = CGImageGetWidth(inImage);		// problem!
	size_t h = CGImageGetHeight(inImage);
	CGRect rect = {{0,0},{w,h}}; 
	
	// Draw the image to the bitmap context. Once we draw, the memory 
	// allocated for the context for rendering will then contain the 
	// raw image data in the specified color space.
	CGContextDrawImage(contexRef, rect, inImage); 
	
	// Now we can get a pointer to the image data associated with the bitmap
	// context.
	unsigned char* data = CGBitmapContextGetData (contexRef);
	if (data != NULL) {
		//offset locates the pixel in the data from x,y. 
		//4 for 4 bytes of data per pixel, w is width of one row of data.
		int offset = 4*((w*round(point.y))+round(point.x));
		int alpha =  data[offset]; 
		int red = data[offset+1]; 
		int green = data[offset+2]; 
		int blue = data[offset+3]; 
		NSLog(@"offset: %i colors: RGB A %i %i %i  %i",offset,red,green,blue,alpha);
		color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
	}
	
	// When finished, release the context
	CGContextRelease(contexRef); 
	// Free image data memory for the context
	if (data) { free(data); }
	
	return color;
}

- (CGContextRef) createARGBBitmapContextFromImage:(CGImageRef) inImage {
	
	CGContextRef    context = NULL;
	CGColorSpaceRef colorSpace;
	void *          bitmapData;
	int             bitmapByteCount;
	int             bitmapBytesPerRow;
	
	// Get image width, height. We'll use the entire image.
	size_t pixelsWide = CGImageGetWidth(inImage);
	size_t pixelsHigh = CGImageGetHeight(inImage);
	
	// Declare the number of bytes per row. Each pixel in the bitmap in this
	// example is represented by 4 bytes; 8 bits each of red, green, blue, and
	// alpha.
	bitmapBytesPerRow   = (pixelsWide * 4);
	bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
	
	// Use the generic RGB color space.
	//colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);  //deprecated
	colorSpace = CGColorSpaceCreateDeviceRGB();
	if (colorSpace == NULL)
	{
		fprintf(stderr, "Error allocating color space\n");
		return NULL;
	}
	
	// Allocate memory for image data. This is the destination in memory
	// where any drawing to the bitmap context will be rendered.
	bitmapData = malloc( bitmapByteCount );
	if (bitmapData == NULL) 
	{
		fprintf (stderr, "Memory not allocated!");
		CGColorSpaceRelease( colorSpace );
		return NULL;
	}
	
	// Create the bitmap context. We want pre-multiplied ARGB, 8-bits 
	// per component. Regardless of what the source image format is 
	// (CMYK, Grayscale, and so on) it will be converted over to the format
	// specified here by CGBitmapContextCreate.
	context = CGBitmapContextCreate (bitmapData,
									 pixelsWide,
									 pixelsHigh,
									 8,      // bits per component
									 bitmapBytesPerRow,
									 colorSpace,
									 kCGImageAlphaPremultipliedFirst);
	if (context == NULL)
	{
		free (bitmapData);
		fprintf (stderr, "Context not created!");
	}
	
	// Make sure and release colorspace before returning
	CGColorSpaceRelease( colorSpace );
	
	return context;
}

#pragma mark ColorGradientDelegate
- (void)colorSelected:(UIColor *)color{
    
}

@end
