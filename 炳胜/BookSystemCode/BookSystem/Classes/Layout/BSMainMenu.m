//
//  BSMainMenu.m
//  BookSystem
//
//  Created by Dream on 11-3-16.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BSMainMenu.h"
#import "BSDataProvider.h"
#import "BSLogViewController.h"
#import "BSQueryViewController.h"
#import "CVLocalizationSetting.h"
#import "BSConfigurationViewController.h"

@implementation BSMainMenu


@synthesize aryDict,aryFBViews,aryCover;
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)dealloc
{
    self.aryCover = nil;
    self.aryFBViews = nil;
    
    [fbCover release];
    [panGesture release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/
- (id)init{
    self = [super init];
    if (self!=nil){
 //       demo2 = [[Demo2Transition alloc] init];
//        vcFB = [[FBViewController alloc] init];
//		vcFB.frame = CGRectMake(0, 0, 768, 1004);
//		vcFB.delegate = self;
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    NSString *str = [NSString stringWithContentsOfFile:[path stringByAppendingPathComponent:kBGFileName] encoding:NSUTF8StringEncoding error:nil];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:str]];
    currentPage = 0;
    bTurning = NO;
    self.view.frame = CGRectMake(0, 0, 768, 1004);
    vBG = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:vBG];
    [vBG release];
    
    
	[vBG addSubview:[self currView]];
    
    panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    
    [vBG addGestureRecognizer:panGesture];
 //   [self.view addGestureRecognizer:swipeLeft];
  //  [self.view addGestureRecognizer:swipeRight];
    
//    [panGesture release];
    [swipeLeft release];
    [swipeRight release];
	
	
//	[self.view addSubview:vcFB.view];
//    fbMainMenu.frame = CGRectMake(0, 0, 768, 1004);
//    fbMainMenu.delegate = self;
//    [self.view addSubview:fbMainMenu.view];
//	[self presentModalViewController:fbMainMenu animated:NO];

    
    
    
    btnMenu = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:btnMenu];
    NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [docPaths objectAtIndex:0];
    UIImage *imgMenuNormal = [UIImage imageWithContentsOfFile:[docPath stringByAppendingPathComponent:@"BlueCircleNormal.png"]];
    UIImage *imgMenuPressed = [UIImage imageWithContentsOfFile:[docPath stringByAppendingPathComponent:@"BlueCirclePressed.png"]];
    if (!imgMenuNormal)
        imgMenuNormal = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"btntopnormal" ofType:@"png"]];
    if (!imgMenuPressed)
        imgMenuPressed = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"btntoppressed" ofType:@"png"]];
    [btnMenu setImage:imgMenuNormal forState:UIControlStateNormal];
    [btnMenu setImage:imgMenuPressed forState:UIControlStateHighlighted];
    [btnMenu sizeToFit];
    btnMenu.center = CGPointMake(384, kTopButtonY);
    [btnMenu addTarget:self action:@selector(showMyMenu) forControlEvents:UIControlEventTouchUpInside];
    
    btnLog = [UIButton buttonWithType:UIButtonTypeCustom];
    btnLog.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [self.view insertSubview:btnLog belowSubview:btnMenu];
    imgMenuNormal = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"btn2normal" ofType:@"png"]];
    imgMenuPressed = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"btn2pressed" ofType:@"png"]];
    [btnLog setBackgroundImage:imgMenuNormal forState:UIControlStateNormal];
    [btnLog sizeToFit];
    [btnLog setBackgroundImage:imgMenuPressed forState:UIControlStateHighlighted];
    [btnLog setTitle:[langSetting localizedString:@"OrderedFood"] forState:UIControlStateNormal];
    [imgMenuNormal release];
    [imgMenuPressed release];
    btnLog.center = CGPointMake(270, kTopButtonY);//270 498
    btnLog.hidden = NO;
    [btnLog addTarget:self action:@selector(showLog) forControlEvents:UIControlEventTouchUpInside];
    
    btnQuery = [UIButton buttonWithType:UIButtonTypeCustom];
    btnQuery.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [self.view insertSubview:btnQuery belowSubview:btnMenu];
    imgMenuNormal = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"btn2normal" ofType:@"png"]];
    imgMenuPressed = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"btn2pressed" ofType:@"png"]];
    [btnQuery setBackgroundImage:imgMenuNormal forState:UIControlStateNormal];
    [btnQuery sizeToFit];
    [btnQuery setBackgroundImage:imgMenuPressed forState:UIControlStateHighlighted];
    [btnQuery setTitle:[langSetting localizedString:@"QueryBill"] forState:UIControlStateNormal];
    [imgMenuNormal release];
    [imgMenuPressed release];
    btnQuery.center = CGPointMake(498, kTopButtonY);
    btnQuery.hidden = NO;
    [btnQuery addTarget:self action:@selector(showQuery) forControlEvents:UIControlEventTouchUpInside];
    
    if (!bActivated)
        btnMenu.hidden = YES;
    
    
    [self animateCover];
    [self changeAdText];
//    [NSTimer scheduledTimerWithTimeInterval:7 target:self selector:@selector(animateCover) userInfo:nil repeats:YES];
}

- (void)changeAdText{
    if (!fbCover.superview){
        [self performSelector:@selector(changeAdText) withObject:nil afterDelay:7];
        
        return;
    }else{
        coverIndex++;
        NSArray *aryAD= [[BSDataProvider sharedInstance] getCaptions];
        if (adIndex>=[aryAD count])
            adIndex = 0;

        lblAdText.text = [[[aryAD objectAtIndex:adIndex] objectForKey:@"text"] stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
        
        NSString *source = [[aryAD objectAtIndex:adIndex] objectForKey:@"source"];
        if (source)
            source = [NSString stringWithFormat:@"%@%@",@"来自",source];
        lblSource.text = source;
        
        [self performSelector:@selector(changeAdText) withObject:nil afterDelay:7];
    }
}

- (void)animateCover{
    if (!fbCover.superview || imgvCover.isAnimating){
        [self performSelector:@selector(animateCover) withObject:nil afterDelay:7];
        return;
    }
        
    else { 
        coverIndex++;
        if (coverIndex>=[aryCover count])
            coverIndex = 0;
        
        NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docPath = [docPaths objectAtIndex:0];
        NSString *name = [[aryCover objectAtIndex:coverIndex] objectForKey:@"cover"];
        NSString *path = [docPath stringByAppendingPathComponent:name];
        
        if (imgvCover.hidden){
            [imgvCover setImage:[UIImage imageWithContentsOfFile:path]];
            imgvCover.alpha = 0;
            imgvCover.hidden = NO;
//            imgvCover.transform = CGAffineTransformIdentity;
            [UIView animateWithDuration:3.0f delay:0 options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction animations:^{
                imgvCover.alpha = 1;
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
                    [self animateCover];
                }];
            }];
        }else{
            [imgvCoverNext setImage:[UIImage imageWithContentsOfFile:path]];
            imgvCoverNext.alpha = 0;
            imgvCoverNext.hidden = NO;
//            imgvCoverNext.transform = CGAffineTransformIdentity;
            [UIView animateWithDuration:3.0f delay:0 options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction animations:^{
                imgvCoverNext.alpha = 1;
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
                    [self animateCover];
                }];
            }];
        }
        
        
    }
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}


#pragma mark -
#pragma mark FBViewControllerDelegate
- (FBView *)fbviewAtIndex:(NSInteger)index{
    NSArray *ary = self.aryFBViews;
    int i = index;

    
    
        FBView *fb = [[FBView alloc] initWithFrame:CGRectMake(0, 0, 768, 1004)];
    fb.tag = index;
        fb.opaque = YES;
        fb.layer.opaque = YES;
		fb.backgroundColor = [UIColor whiteColor];
        fb.parent = self;
        if (0==i){
            [fbCover release];
            fbCover = nil;
            fbCover = [fb retain];
            
            NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *docPath = [docPaths objectAtIndex:0];
            
            self.aryCover = [[BSDataProvider sharedInstance] getCovers];
            if (!aryCover || 0==[aryCover count])
                self.aryCover = [NSArray arrayWithObject:@"cover.jpg"];
            
            UIImage *imgCover = [[UIImage alloc] initWithContentsOfFile:[docPath stringByAppendingPathComponent:@"cover.jpg"]];
            
            imgvCover = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 768, 1004)];
            [imgvCover setImage:imgCover];
            //            fb.backgroundColor = [UIColor colorWithPatternImage:imgCover];
            [imgCover release];
            [fb addSubview:imgvCover];
            [imgvCover release];
            
            imgvCoverNext = [[UIImageView alloc] initWithFrame:imgvCover.frame];
            [fb addSubview:imgvCoverNext];
            [imgvCoverNext release];
            imgvCoverNext.hidden = YES;
            
            
            UIImageView *imgvHome = [[UIImageView alloc] initWithFrame:CGRectMake(715, 10, 29, 27)];
            [imgvHome setImage:[UIImage imageNamed:@"home.png"]];
            [fb addSubview:imgvHome];
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
            lblSite.text = @"www.choicesoft.com.cn";
            [fb addSubview:lblSite];
            [lblSite release];
            
            UIImageView *imgvCaption = [[UIImageView alloc] initWithFrame:CGRectMake(768-90, 660, 90, 40)];
            [fb addSubview:imgvCaption];
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
            [fb addSubview:lblAdText];
            [lblAdText release];
            
            lblSource = [[UILabel alloc] initWithFrame:CGRectMake(25, 900, 690, 25)];
            lblSource.font = [UIFont systemFontOfSize:18];
            lblSource.textAlignment = UITextAlignmentRight;
            lblSource.backgroundColor = [UIColor clearColor];
            lblSource.textColor = [UIColor whiteColor];
            lblSource.shadowOffset = CGSizeMake(0, 2);
            lblSource.shadowColor = [UIColor blackColor];
            [fb addSubview:lblSource];
            [lblSource release];
            
            UIImage *imgLogo = [UIImage imageWithContentsOfFile:[docPath stringByAppendingPathComponent:@"logo.jpg"]];
            UIImageView *imgvLogo = [[UIImageView alloc] initWithImage:imgLogo];
            imgvLogo.frame = CGRectMake(15, 15, imgvLogo.frame.size.width, imgvLogo.frame.size.height);
            [fb addSubview:imgvLogo];
            [imgvLogo release];
            
            btnSetting = [UIButton buttonWithType:UIButtonTypeCustom];
            NSString *pathSetting = [[NSBundle mainBundle] pathForResource:@"setting" ofType:@"png"];
            UIImage *imgSetting = [[UIImage alloc] initWithContentsOfFile:pathSetting];
            [btnSetting setImage:imgSetting forState:UIControlStateNormal];
            [imgSetting release];
            [btnSetting sizeToFit];
            btnSetting.center = CGPointMake(768-btnSetting.frame.size.width/2.0f, 1004-btnSetting.frame.size.height/2.0f);
            [fb addSubview:btnSetting];
            [btnSetting addTarget:self action:@selector(showSetting:) forControlEvents:UIControlEventTouchUpInside];
            
            if (!bActivated)
                btnSetting.hidden = YES;
            
            
        }
        else{
            UILabel *lblPage = [[UILabel alloc] initWithFrame:CGRectMake(0, 951, 768, 32)];
            lblPage.textAlignment = UITextAlignmentCenter;
            lblPage.textColor = [UIColor grayColor];
            lblPage.backgroundColor = [UIColor clearColor];
            lblPage.text = [NSString stringWithFormat:@"Page %d Of %d",i,totalPages-1];
            [lblPage sizeToFit];
            lblPage.center = CGPointMake(384, 967);
            [fb addSubview:lblPage];
            [lblPage release];
            
            for (int j=(i-1)*9;j<(i-1)*9+9 && j<[aryDict count];j++){
                int row = j/3-(i-1)*3;
                int column = j%3;
                NSDictionary *dataDict = [ary objectAtIndex:j];
                MainMenuCell *cell = [[MainMenuCell alloc] initWithFrame:CGRectMake(15+column*250, 135+row*260, 235, 195)];
                cell.opaque = YES;
                cell.tag = j;
                cell.delegate = self;
//                [cell showData:dataDict];
                [fb addSubview:cell];
                [cell release];
            }
        }
        fb.tag = i;

    
    return [fb autorelease];
}

- (FBView *)prevView{
    /*
    if (currentPage>0)
        return [self.aryFBViews objectAtIndex:currentPage-1];
    else
        return nil;
     */
    if (currentPage>0){
        return [self fbviewAtIndex:currentPage-1];
    }
    else
        return nil;
}

- (FBView *)currView{
    if (fbCurr && fbCurr.tag==currentPage)
        return fbCurr;
    if ([self.aryFBViews count]>0)
        return [self fbviewAtIndex:currentPage];
    else
        return nil;
    return [self.aryFBViews objectAtIndex:currentPage];
}

- (FBView *)nextView{
   if (currentPage<totalPages-1)
       return [self fbviewAtIndex:currentPage+1];
//       return [self.aryFBViews objectAtIndex:currentPage+1];
    else
        return nil;
}




- (void)genViews:(NSArray *)ary activated:(BOOL)activated{
    bActivated = activated;
    
    self.aryDict = ary;
    NSMutableArray *mut = [[NSMutableArray alloc] init];
    int count = [ary count];
    int mode = count%9;
    int pageCount;
    if (mode==0)
        pageCount = count/9+1;
    else
        pageCount = count/9+2;
    totalPages = pageCount;
    self.aryFBViews = ary;
    [mut release];
    return;
    for (int i=0;i<pageCount;i++){
        FBView *fb = [[FBView alloc] initWithFrame:CGRectMake(0, 0, 768, 1004)];
        fb.opaque = YES;
        fb.layer.opaque = YES;
		fb.backgroundColor = [UIColor whiteColor];
        fb.parent = self;
        if (0==i){
            NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *docPath = [docPaths objectAtIndex:0];
            UIImage *imgCover = [[UIImage alloc] initWithContentsOfFile:[docPath stringByAppendingPathComponent:@"cover.jpg"]];
            
            imgvCover = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 768, 1004)];
            [imgvCover setImage:imgCover];
//            fb.backgroundColor = [UIColor colorWithPatternImage:imgCover];
            [imgCover release];
            [fb addSubview:imgvCover];
            [imgvCover release];

            
            UIImageView *imgvHome = [[UIImageView alloc] initWithFrame:CGRectMake(715, 10, 29, 27)];
            [imgvHome setImage:[UIImage imageNamed:@"home.png"]];
            [fb addSubview:imgvHome];
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
            lblSite.text = @"www.choicesoft.com.cn";
            [fb addSubview:lblSite];
            [lblSite release];
            
            
            
            btnSetting = [UIButton buttonWithType:UIButtonTypeCustom];
            NSString *pathSetting = [[NSBundle mainBundle] pathForResource:@"setting" ofType:@"png"];
            UIImage *imgSetting = [[UIImage alloc] initWithContentsOfFile:pathSetting];
            [btnSetting setImage:imgSetting forState:UIControlStateNormal];
            [imgSetting release];
            [btnSetting sizeToFit];
            btnSetting.center = CGPointMake(768-btnSetting.frame.size.width/2.0f, 1004-btnSetting.frame.size.height/2.0f);
            [fb addSubview:btnSetting];
            [btnSetting addTarget:self action:@selector(showSetting:) forControlEvents:UIControlEventTouchUpInside];
            
            if (!bActivated)
                btnSetting.hidden = YES;
            
            
        }
        else{
            UILabel *lblPage = [[UILabel alloc] initWithFrame:CGRectMake(0, 951, 768, 32)];
            lblPage.textAlignment = UITextAlignmentCenter;
            lblPage.textColor = [UIColor grayColor];
            lblPage.backgroundColor = [UIColor clearColor];
            lblPage.text = [NSString stringWithFormat:@"Page %d Of %d",i,pageCount-1];
            [lblPage sizeToFit];
            lblPage.center = CGPointMake(384, 967);
            [fb addSubview:lblPage];
            [lblPage release];
            
            for (int j=(i-1)*9;j<(i-1)*9+9 && j<count;j++){
                int row = j/3-(i-1)*3;
                int column = j%3;
                NSDictionary *dataDict = [ary objectAtIndex:j];
                MainMenuCell *cell = [[MainMenuCell alloc] initWithFrame:CGRectMake(15+column*250, 135+row*260, 235, 195)];
                cell.opaque = YES;
                cell.tag = j;
                cell.delegate = self;
//                [cell showData:dataDict];
                [fb addSubview:cell];
                [cell release];
            }
        }
        fb.tag = i;
        [mut addObject:fb];
        [fb release];
    }
    
    aryFBViews = [[NSArray alloc] initWithArray:mut];
    [mut release];

}



- (void)cellSelected:(id)sender{
    NSLog(@"cell selected");
    FBView *fb = (FBView *)sender;
    [self.navigationController performSelector:@selector(setCurrentIndex:) withObject:[NSNumber numberWithInt:fb.tag]];
    
    [self.navigationController performSelector:@selector(showSubMenu)];
}



- (void)turnEnded:(BOOL)turned{
    if (turned){
        [vBG insertSubview:fbNext belowSubview:fbTrans];
        [fbCurr removeFromSuperview];
        fbCurr = fbNext;
//        if (pageToShow==PrevPage && pageToShow>0)
//            currentPage--;
//        else if (pageToShow==NextPage && currentPage<[aryFBViews count]-1)
//            currentPage++;
    }

    [fbTrans removeFromSuperview];
    [fbTrans release];
    fbTrans = nil;
    fbCurr = nil;
    fbNext = nil;
    
    bTurning = NO;
    
    [vBG addGestureRecognizer:panGesture];
    
    if (bActivated)
        btnMenu.hidden = NO;
    
    for (UIView *v in vBG.subviews){
        if ([v isKindOfClass:[FBView class]]){
            if (v.tag!=currentPage){
                [v removeFromSuperview];
            }
        }
    }
    
    int pagecount = 0;
    for (UIView *v in vBG.subviews){
        if ([v isKindOfClass:[FBView class]]){
            pagecount++;
        }
    }
    
    int transcount = 0;
    for (UIView *v in vBG.subviews){
        if ([v isKindOfClass:[FBTransitionView class]]){
            transcount++;
        }
    }
//    NSLog(@"Total Page:%d;Total Trans:%d",pagecount,transcount);
    
    
    if (currentPage==0 || fbCover.superview){
        [lblCaption setTextWithChangeAnimation:@"< 翻阅"];
        [self performSelector:@selector(changeAdText)];
        [self performSelector:@selector(animateCover) withObject:nil afterDelay:7];
    }
}


//Gesture Handeler
- (void)handlePan:(UIPanGestureRecognizer *)gesture{
    if (bTurning)
        return;
    
    CGPoint translate = [gesture translationInView:vBG];
	if (gesture.state == UIGestureRecognizerStateBegan)
    {
//        NSLog(@"begin current page:%d",currentPage);
        btnMenu.hidden = YES;
        btnLog.hidden = YES;
        btnQuery.hidden = YES;
        if ([gesture numberOfTouches]<1)
            return;
        ptOrigin = [gesture locationOfTouch:0 inView:vBG];
        ptPrev = ptOrigin;
        if (ptOrigin.x<=384)
            pageToShow = PrevPage;
        else
            pageToShow = NextPage;
        if (pageToShow==PrevPage)
            fbNext = (FBView *)[self prevView];
        else
            fbNext = (FBView *)[self nextView];
        fbCurr = [self currView];
        
        
        if (!fbTrans){
            fbTrans = [[FBTransitionView alloc] initWithView:fbCurr toView:fbNext direction:pageToShow==PrevPage?-1:1];
            fbTrans.delegate = self;
        }
        
        else
            [fbTrans setView:fbCurr toView:fbNext direction:pageToShow==PrevPage?-1:1];
        [vBG addSubview:fbTrans];
    }
    else if (gesture.state != UIGestureRecognizerStateEnded)
    {
        if (bTurning)
            return;
        if ([gesture numberOfTouches]<1)
            return;
        ptCurr = [gesture locationOfTouch:0 inView:vBG];
        
        float delta = ptOrigin.x-384.0f;
        if (delta<0)
            delta = -delta;
        float distance = ptCurr.x-ptPrev.x;
        if (distance<0)
            distance = -distance;
        float angle = 2;
        if (delta!=0)
            angle = distance/delta*90.0f;
        if (pageToShow == NextPage)
        {
            if (ptCurr.x-ptPrev.x<0)
                [fbTrans rotateAngle:angle]; 
            else
                [fbTrans rotateAngle:-angle];
        }
        else
        {
            if (ptCurr.x-ptPrev.x<0)
                [fbTrans rotateAngle:-angle]; 
            else
                [fbTrans rotateAngle:angle];
        }
        ptPrev = ptCurr;
    }
    else
    {
//        if (bTurned)
//            return;
//        NSLog(@"end current page:%d",currentPage);
        bTurning = YES;
        [vBG removeGestureRecognizer:panGesture];
        if ((pageToShow==NextPage && translate.x>0) || (pageToShow==PrevPage && translate.x<0) || fbNext==nil)
            [fbTrans rotateLeft:NO];
        else{
           [fbTrans rotateLeft:YES];
            if (pageToShow==PrevPage)
                currentPage--;
            else
                currentPage++;
            if (currentPage<0)
                currentPage = 0;
            if (currentPage>[aryFBViews count]-1)
                currentPage = [aryFBViews count]-1;
        }
            
    }
    
    
}


- (void)handleSwipeLeft:(UISwipeGestureRecognizer *)gesture{
    
}

- (void)handleSwipeRight:(UISwipeGestureRecognizer *)gesture{
    
}

- (void)deleteViews{
    for (UIView *v in vBG.subviews){
        [v removeFromSuperview];
    }
    
    [aryFBViews release];
    aryFBViews = nil;
}

- (void)addCurView{
    [vBG addSubview:[self currView]];
}

- (void)showSetting:(id)sender{
    BSConfigurationViewController *vcConfiguration = [[BSConfigurationViewController alloc] init];
    UINavigationController *vcNav = [[UINavigationController alloc] initWithRootViewController:vcConfiguration];
    vcNav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:vcNav animated:YES];
}





- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (-1==buttonIndex)
        return;
    if (actionSheet.tag==1){
        BSSettingViewController *vc = nil;
        if (0==buttonIndex){
            vc = [[BSSettingViewController alloc] initWithType:BSSettingTypeFtp];
        }
        else if (1==buttonIndex){
            vc = [[BSSettingViewController alloc] initWithType:BSSettingTypeSocket];
        }
        else if (2==buttonIndex){
            vc = [[BSSettingViewController alloc] initWithType:BSSettingTypePDAID]; 
        }
        else if (3==buttonIndex){
            vc = [[BSSettingViewController alloc] initWithType:BSSettingTypeUpdate];
        }
        else if (4==buttonIndex){
            vc = (BSSettingViewController *)[[BSBGSettingViewController alloc] init];
        }else {
            BSConfigurationViewController *vcConfiguration = [[BSConfigurationViewController alloc] init];
            vc = (BSSettingViewController *)[[UINavigationController alloc] initWithRootViewController:vcConfiguration];
//            vc = (BSSettingViewController *)[[BSConfigurationViewController alloc] init];
        }
        if (buttonIndex!=4)
            vc.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentModalViewController:vc animated:YES];
    }
    else if (actionSheet.tag==2){
        
    }
    
}


- (void)showMyMenu{
    BOOL bShowButtons = !btnQuery.hidden;
    
    if (bShowButtons){
        btnLog.transform = CGAffineTransformMakeScale(1.0, 1.0);
        btnQuery.transform = CGAffineTransformMakeScale(1.0, 1.0);
        [UIView animateWithDuration:0.5f animations:^(void) {
            btnLog.transform = CGAffineTransformMakeScale(0.3, 1.0);
            btnLog.center = btnMenu.center;
            btnQuery.transform = CGAffineTransformMakeScale(0.3, 1.0);
            btnQuery.center = btnMenu.center;
        }completion:^(BOOL finished) {
            btnLog.hidden = YES;
            btnQuery.hidden = YES;
        }];
    }
    else{
        btnQuery.center = btnMenu.center;
        btnLog.center = btnMenu.center;
        btnQuery.transform = CGAffineTransformMakeScale(0.3, 1.0);
        btnLog.transform = CGAffineTransformMakeScale(0.3, 1.0);
        
        if (bActivated){
            btnLog.hidden = NO;
            btnQuery.hidden = NO; 
        }
        
        [UIView animateWithDuration:0.5f animations:^(void) {
            btnLog.transform = CGAffineTransformMakeScale(1.0, 1.0);
            btnLog.center = CGPointMake(270, kTopButtonY);
            btnQuery.transform = CGAffineTransformMakeScale(1.0, 1.0);
            btnQuery.center = CGPointMake(498, kTopButtonY);
        }];
    }
    
}

- (void)showLog{
    BSLogViewController *vcMyMenu = [[BSLogViewController alloc] init];
//    vcMyMenu.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.navigationController pushViewController:vcMyMenu animated:YES];
//    [self presentModalViewController:vcMyMenu animated:YES];
}

- (void)showQuery{
    BSQueryViewController *vcQuery = [[BSQueryViewController alloc] init];
//    vcQuery.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.navigationController pushViewController:vcQuery animated:YES];
//    [self presentModalViewController:vcQuery animated:YES];
}

- (void)showWebsite{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.choicesoft.com.cn"]];
}
@end
