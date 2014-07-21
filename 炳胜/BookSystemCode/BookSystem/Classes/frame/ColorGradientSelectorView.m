//
//  ColorGradientSelectorView.m
//  Wabo
//
//  Created by Stan Wu on 11-9-26.
//  Copyright 2011年 CheersDigi. All rights reserved.
//

#import "ColorGradientSelectorView.h"
#import "ColorPickerView.h"

@implementation ColorGradientSelectorView
@synthesize middleColor,selectedColor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawGradientInContext:(CGContextRef)ctx{
    
    if (middleColor){
        const CGFloat *components = CGColorGetComponents(middleColor.CGColor);
        CGFloat red = components[0];
        CGFloat green = components[1];
        CGFloat blue = components[2];
        CGFloat alpha = components[3];
        
        if (0!=alpha){
            CGGradientRef myGradient;
            CGColorSpaceRef myColorSpace;
            size_t locationCount = 3;
            CGFloat locationList[] = {0.0, 0.5, 1.0};
            CGFloat colorList[] = {
                1.0, 1.0, 1.0, 1.0, //red, green, blue, alpha 
                red, green, blue, 1.0, 
                0.0, 0.0, 0.0, 1.0
            };
            
            myColorSpace = CGColorSpaceCreateDeviceRGB();
            myGradient = CGGradientCreateWithColorComponents(myColorSpace, colorList, locationList, locationCount);
            
            CGPoint startPoint, endPoint;
            startPoint.x = 0;
            startPoint.y = 0;
            endPoint.x = CGRectGetMaxX(self.bounds);
            endPoint.y = CGRectGetMaxY(self.bounds);
            CGContextDrawLinearGradient(ctx, myGradient, startPoint, endPoint,0);
            CGColorSpaceRelease(myColorSpace);
            CGGradientRelease(myGradient);
        }
        
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [self drawGradientInContext:ctx];
    imgdata = CGBitmapContextGetData(ctx);
    
}

- (void)getColorAtPoint:(CGPoint)pt{
    UIColor *color = [self getPixelColorAtLocation:pt];
		//offset locates the pixel in the data from x,y. 
		//4 for 4 bytes of data per pixel, w is width of one row of data.
	const float *fColor = CGColorGetComponents(color.CGColor);
    
//    float red =  fColor[0];
//    float green =  fColor[1]; 
//    float blue =  fColor[2]; 
    float alpha =  fColor[3];
    
//    UIColor *colorSel = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    
    if (alpha!=0){
        ColorPickerView *vPicker = (ColorPickerView *)self.superview.superview.superview;
        
        [vPicker.delegate colorSelected:color];
    }
    
	
}

- (void)dealloc{
    self.middleColor = nil;
    self.selectedColor = nil;
    
    [super dealloc];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    [self getColorAtPoint:[touch locationInView:self]];
    
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
}


// Please refer to iOS Developer Library for more details regarding the following two methods
- (UIColor*) getPixelColorAtLocation:(CGPoint)point {
	UIColor* color = nil;
    
    UIGraphicsBeginImageContext(self.frame.size);
    [self.layer renderInContext: UIGraphicsGetCurrentContext()];
    UIImage *retval = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
	CGImageRef inImage = retval.CGImage;
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


@end
