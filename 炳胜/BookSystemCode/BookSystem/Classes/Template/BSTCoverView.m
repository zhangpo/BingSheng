//
//  BSTCover.m
//  BookSystem
//
//  Created by Wu Stan on 12-5-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BSTCoverView.h"
#import "BSDataProvider.h"
#import "BSConfigurationViewController.h"

@implementation BSTCoverView
@synthesize aryCover;

- (void)dealloc{
    self.aryCover = nil;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateCover) object:nil];
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame info:(NSDictionary *)info
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        coverIndex = 0;
        // Initialization code
        NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docPath = [docPaths objectAtIndex:0];
        
        self.aryCover = [info objectForKey:@"images"];
        if (!aryCover || 0==[aryCover count])
            self.aryCover = [NSArray arrayWithObject:@"cover1.jpg"];
        
//        NSLog(@"Covers :%@",aryCover);
        
        UIImage *imgCover = [UIImage imgWithContentsOfFile:[docPath stringByAppendingPathComponent:[aryCover objectAtIndex:0]]];
        
        imgvCover = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 768, 1004)];
        [imgvCover setImage:imgCover];
        [self addSubview:imgvCover];
        [imgvCover release];
        
        imgvCoverNext = [[UIImageView alloc] initWithFrame:imgvCover.frame];
        [self addSubview:imgvCoverNext];
        [imgvCoverNext release];
        imgvCoverNext.hidden = YES;
        
        
        UIImageView *imgvHome = [[UIImageView alloc] initWithFrame:CGRectMake(715, 10, 29, 27)];
        [imgvHome setImage:[UIImage imageNamed:@"home.png"]];
        [self addSubview:imgvHome];
        [imgvHome release];
        UIButton *btnHome = [UIButton buttonWithType:UIButtonTypeCustom];
        btnHome.frame = CGRectMake(0, 0, 58, 54);
        btnHome.center = CGPointMake(14.5, 13.5);
        [imgvHome addSubview:btnHome];
        imgvHome.userInteractionEnabled = YES;
        [btnHome addTarget:self action:@selector(showWebsite) forControlEvents:UIControlEventTouchUpInside];
        
        
        UILabel *lblSite = [[UILabel alloc] initWithFrame:CGRectMake(555, 25, 155, 20)];
        lblSite.font = [UIFont systemFontOfSize:12];
        lblSite.backgroundColor = [UIColor clearColor];
        lblSite.textColor = [UIColor whiteColor];
        lblSite.text = [dicInfo objectForKey:@"url"];
        [self addSubview:lblSite];
        [lblSite release];
        
        UIImageView *imgvCaption = [[UIImageView alloc] initWithFrame:CGRectMake(768-90, 660, 90, 40)];
        [self addSubview:imgvCaption];
        [imgvCaption release];
        imgvCaption.backgroundColor = [UIColor blackColor];
        lblCaption = [[UILabel alloc] initWithFrame:imgvCaption.bounds];
        lblCaption.textAlignment = UITextAlignmentCenter;
        lblCaption.font = [UIFont boldSystemFontOfSize:20];
        lblCaption.textColor = [UIColor whiteColor];
        lblCaption.backgroundColor = [UIColor blackColor];
        lblCaption.text = @"< 翻阅";
        [imgvCaption addSubview:lblCaption];
        [lblCaption release];
        lblCaption.tag = 1000;
        [lblCaption setTextWithChangeAnimation:@"< 翻阅"];
        [lblCaption setNeedsDisplay];
        
        //            [lblCaption startAnimation];
        //            [lblCaption startAnimation];
        
        lblAdText = [[UILabel alloc] initWithFrame:CGRectMake(25, 840, 690, 50)];
        lblAdText.font = [UIFont boldSystemFontOfSize:22];
        lblAdText.textAlignment = UITextAlignmentRight;
        lblAdText.backgroundColor = [UIColor clearColor];
        lblAdText.textColor = [UIColor whiteColor];
        lblAdText.shadowOffset = CGSizeMake(0, 2);
        lblAdText.shadowColor = [UIColor blackColor];
        lblAdText.numberOfLines = 2;
        lblAdText.lineBreakMode = UILineBreakModeWordWrap;
        [self addSubview:lblAdText];
        [lblAdText release];
        
        lblSource = [[UILabel alloc] initWithFrame:CGRectMake(25, 900, 690, 25)];
        lblSource.font = [UIFont systemFontOfSize:18];
        lblSource.textAlignment = UITextAlignmentRight;
        lblSource.backgroundColor = [UIColor clearColor];
        lblSource.textColor = [UIColor whiteColor];
        lblSource.shadowOffset = CGSizeMake(0, 2);
        lblSource.shadowColor = [UIColor blackColor];
        [self addSubview:lblSource];
        [lblSource release];
        
        UIImage *imgLogo = [UIImage imgWithContentsOfFile:[docPath stringByAppendingPathComponent:@"logo.jpg"]];
        UIImageView *imgvLogo = [[UIImageView alloc] initWithImage:imgLogo];
        imgvLogo.frame = CGRectMake(15, 15, imgvLogo.frame.size.width, imgvLogo.frame.size.height);
        [self addSubview:imgvLogo];
        [imgvLogo release];
        
        btnSetting = [UIButton buttonWithType:UIButtonTypeCustom];
        NSString *pathSetting = [[NSBundle mainBundle] pathForResource:@"setting" ofType:@"png"];
        UIImage *imgSetting = [[UIImage alloc] initWithContentsOfFile:pathSetting];
        [btnSetting setImage:imgSetting forState:UIControlStateNormal];
        [imgSetting release];
        [btnSetting sizeToFit];
        btnSetting.center = CGPointMake(768-btnSetting.frame.size.width/2.0f, 1004-btnSetting.frame.size.height/2.0f);
        [self addSubview:btnSetting];
        [btnSetting addTarget:self action:@selector(showSetting:) forControlEvents:UIControlEventTouchUpInside];
        
        if (!self.bActivated)
            btnSetting.hidden = YES;
        
        UILabel *lbl = [UILabel createLabelWithFrame:CGRectMake(0, 1004-20, 768, 20) font:[UIFont systemFontOfSize:14] textColor:[UIColor whiteColor]];
        lbl.backgroundColor = [UIColor colorWithWhite:0 alpha:.5];
        lbl.textAlignment = UITextAlignmentCenter;
        [self addSubview:lbl];
        lbl.text = [NSString UUIDString];
        if (self.bActivated)
            lbl.text = nil;
        
        
        
        [self animateCover];
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
- (void)animateCover{
    if (imgvCover.isAnimating || imgvCoverNext.isAnimating){
        @autoreleasepool {
//            NSLog(@"My Superview:%@",self.superview);
            
            [self performSelector:@selector(animateCover) withObject:nil afterDelay:7];
            return;
        }
        
    }
    
    else { 
        @autoreleasepool {
            coverIndex++;
            if (coverIndex>=[aryCover count])
                coverIndex = 0;
            
            NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *docPath = [docPaths objectAtIndex:0];
            NSString *name = [aryCover objectAtIndex:coverIndex];// objectForKey:@"cover"];
            NSString *path = [docPath stringByAppendingPathComponent:name];
            
            if (imgvCover.hidden){
                [imgvCover setImage:[UIImage imgWithContentsOfFile:path]];
                [self insertSubview:imgvCover belowSubview:imgvCoverNext];
                imgvCover.alpha = 1;
                imgvCover.hidden = NO;
                //            imgvCover.transform = CGAffineTransformIdentity;
                [UIView animateWithDuration:3.0f delay:0 options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction animations:^{
                    //                imgvCover.alpha = 1;
                    imgvCoverNext.alpha = 0;
                }completion:^(BOOL finished) {
                    imgvCoverNext.hidden = YES;
                    
                    [UIView animateWithDuration:7 delay:0 options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction animations:^{
                        CGAffineTransform rotate = CGAffineTransformMakeRotation(0.00);
                        CGAffineTransform moveLeft = CGAffineTransformMakeTranslation(coverIndex%2==0?0.9:1.1,coverIndex%2==0?0.9:1.1);
                        CGAffineTransform combo1 = CGAffineTransformConcat(rotate, moveLeft);
                        
                        CGAffineTransform zoomOut = CGAffineTransformMakeScale(1.1,1.1);
                        CGAffineTransform transform = CGAffineTransformConcat(zoomOut, combo1);
                        imgvCover.transform =  CGAffineTransformIsIdentity(imgvCover.transform)?transform:CGAffineTransformIdentity;
                    } completion:^(BOOL finished) {
                        if ([self isKindOfClass:[BSTCoverView class]])
                            [self performSelector:@selector(animateCover) withObject:nil afterDelay:7];
                    }];
                }];
            }else{
                [imgvCoverNext setImage:[UIImage imgWithContentsOfFile:path]];
                imgvCoverNext.alpha = 1;
                [self insertSubview:imgvCoverNext belowSubview:imgvCover];
                imgvCoverNext.hidden = NO;
                //            imgvCoverNext.transform = CGAffineTransformIdentity;
                [UIView animateWithDuration:3.0f delay:0 options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction animations:^{
                    //                imgvCoverNext.alpha = 1;
                    imgvCover.alpha = 0;
                }completion:^(BOOL finished) {
                    imgvCover.hidden = YES;
                    
                    [UIView animateWithDuration:7 delay:0 options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction animations:^{
                        CGAffineTransform rotate = CGAffineTransformMakeRotation(0.00);
                        CGAffineTransform moveLeft = CGAffineTransformMakeTranslation(coverIndex%2==0?0.9:1.1,coverIndex%2==0?0.9:1.1);
                        CGAffineTransform combo1 = CGAffineTransformConcat(rotate, moveLeft);
                        
                        CGAffineTransform zoomOut = CGAffineTransformMakeScale(1.1,1.1);
                        CGAffineTransform transform = CGAffineTransformConcat(zoomOut, combo1);
                        imgvCoverNext.transform = CGAffineTransformIsIdentity(imgvCoverNext.transform)?transform:CGAffineTransformIdentity;
                    } completion:^(BOOL finished) {
                        if ([self isKindOfClass:[BSTCoverView class]])
                            [self performSelector:@selector(animateCover) withObject:nil afterDelay:7];
                    }];
                }];
        }
        
        }
        
        
    }
}

- (void)showWebsite{
    if ([dicInfo objectForKey:@"url"])
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@",[dicInfo objectForKey:@"url"]]]];
}

- (void)setBActivated:(BOOL)activate{
    bActivated = activate;
    btnSetting.hidden = !activate;
}

- (void)showSetting:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowSetting" object:nil];
    
    
}

@end
