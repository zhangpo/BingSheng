//
//  WPhotoCell.m
//  Wabo
//
//  Created by Stan Wu on 11-9-20.
//  Copyright 2011年 CheersDigi. All rights reserved.
//

#import "WPhotoCell.h"
#import <QuartzCore/QuartzCore.h>


@implementation UIScrollView(TouchEvents)

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    [self.nextResponder touchesBegan:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesCancelled:touches withEvent:event];
    [self.nextResponder touchesCancelled:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    [self.nextResponder touchesEnded:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    [self.nextResponder touchesMoved:touches withEvent:event];
}

@end

@implementation WPhotoCell
@synthesize animationStyle;

//- (void)dealloc{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    
//    [super dealloc];
//}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.9f];
        
        // Initialization code
        imgvBG = [[UIImageView alloc] initWithFrame:self.bounds];
//        [imgvBG setImage:[UIImage imageNamed:@"photo-frame1.png"]];
        [self addSubview:imgvBG];
        [imgvBG release];
        

        
        scvPhoto = [[UIScrollView alloc] initWithFrame:self.bounds];
        scvPhoto.multipleTouchEnabled = YES;
        scvPhoto.exclusiveTouch = NO;
        scvPhoto.delegate = self;
        scvPhoto.backgroundColor = [UIColor clearColor];
        [self addSubview:scvPhoto];
        scvPhoto.maximumZoomScale = 5;
        scvPhoto.minimumZoomScale = 0.5;
        [scvPhoto release];
//        scvPhoto.hidden = YES;
        scvPhoto.zoomScale = 1;
        
        imgvPhoto = [[UIImageView alloc] init];
        [scvPhoto addSubview:imgvPhoto];
        [imgvPhoto release];
        
        
        lblStatus = [[UILabel alloc] initWithFrame:CGRectMake(50,self.frame.size.height-100, self.frame.size.width-100, 80)];
        lblStatus.textColor = [UIColor whiteColor];
        lblStatus.numberOfLines = 4;
        lblStatus.backgroundColor = [UIColor clearColor];
        lblStatus.textAlignment = UITextAlignmentCenter;
        lblStatus.shadowColor = [UIColor blackColor];//lblStatus.textColor;
        lblStatus.shadowOffset = CGSizeMake(0, 1);
        [self addSubview:lblStatus];
        [lblStatus release];
        lblStatus.hidden = YES;

        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        indicator.hidesWhenStopped = YES;
        indicator.center = CGPointMake(frame.size.width/2, frame.size.height/2);
        [self addSubview:indicator];
        [indicator release];
        [indicator startAnimating];
        [indicator stopAnimating];
        indicator.hidden = YES;
        
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

- (void)adjustSubviews:(UIInterfaceOrientation)orientation{
    if (UIInterfaceOrientationIsPortrait(orientation)){
        self.frame = CGRectMake(0, 0, 768, 1004);
    }else{
        self.frame = CGRectMake(0, 0, 1024, 748);
    }
    
    scvPhoto.frame = self.bounds;
    lblStatus.frame = CGRectMake(50,self.frame.size.height-100, self.frame.size.width-100, 80);
    [self scrollViewDidEndZooming:scvPhoto withView:self atScale:0];
}

- (void)orientationChanged:(NSNotification *)nsnotification{
    [self adjustSubviews:[UIApplication sharedApplication].statusBarOrientation];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)showInfo:(NSDictionary *)info{

    
    NSString *imgname = [info objectForKey:@"image"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:imgname];
    
    [imgvPhoto setImage:[UIImage imageWithContentsOfFile:path]];
    
    [imgvPhoto sizeToFit];
    
    [scvPhoto setContentSize:imgvPhoto.image.size];
    imgvPhoto.center = CGPointMake(scvPhoto.frame.size.width/2.0f, scvPhoto.frame.size.height/2.0f);
    
    
    lblStatus.hidden = NO;
    scvPhoto.hidden = NO;
    [indicator stopAnimating];
}

#pragma mark -
#pragma mark UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {    
    return imgvPhoto;
}
//
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
//    NSLog(@"\nFrame:%@\nOffset:%@\Scroll Bounds:%@,Size:%@",NSStringFromCGRect(imgvPhoto.frame),NSStringFromCGPoint(scvPhoto.contentOffset),NSStringFromCGRect(scvPhoto.bounds),NSStringFromCGSize(scvPhoto.contentSize));
//    float w = imgvPhoto.frame.size.width;
//    float h = imgvPhoto.frame.size.height;
//    float W = self.frame.size.width;
//    float H = self.frame.size.height;
//    
//    
//    //   [scvPhoto setContentSize:CGSizeMake(MAX(w,W),MAX(h,H))];
////    [scvPhoto setContentSize:imgvPhoto.frame.size];
//
//    imgvPhoto.center = CGPointMake(0.5f*MAX(w, W), 0.5f*MAX(h, H));

    
    CGSize boundsSize = scrollView.bounds.size;
    
    
    
    CGRect frameToCenter = imgvPhoto.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    [UIView animateWithDuration:0.2f animations:^{
        imgvPhoto.frame = frameToCenter;
    }];

    
}


- (NSDictionary *)dicInfo{
    return dicInfo;
}

- (void)setDicInfo:(NSDictionary *)dicInfo_{
    if (dicInfo_!=dicInfo){
        [dicInfo release];
        dicInfo = [dicInfo_ retain];
        
        if (dicInfo)
            [self showInfo:dicInfo];
    }
}







- (void)removeSelfFromSuperview{
    [UIView animateWithDuration:0.3f animations:^(void) {
        if (WImageViewAnimationStyleFlip==animationStyle)
            self.transform = CGAffineTransformMakeTranslation(self.frame.size.width, 0);
        else
            self.alpha = 0;
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    ptPrev = [touch locationInView:self];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint pt = [touch locationInView:self];
    if (abs(pt.x-ptPrev.x)<=kClickDistance && abs(pt.y-ptPrev.y)<=kClickDistance)
        [self removeSelfFromSuperview];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint pt = [touch locationInView:self];
    if (abs(pt.x-ptPrev.x)<=kClickDistance && abs(pt.y-ptPrev.y)<=kClickDistance)
        [self removeSelfFromSuperview];
}
@end
