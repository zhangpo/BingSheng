//
//  BSSubMenu.m
//  BookSystem
//
//  Created by Dream on 11-3-16.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BSSubMenu.h"
#import "BSAdView.h"
#import "CVLocalizationSetting.h"
#import "BSMenuView.h"

@implementation BSSubMenu
@synthesize aryDict,aryFBViews;
@synthesize dicInfo;
@synthesize strBackground;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        bTurning = NO;
    }
    return self;
}

- (void)dealloc
{
    self.dicInfo = nil;
    self.strBackground = nil;
    
    [panGesture release];
    [aryFBViews release];
    self.aryDict = nil;
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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
    self.view.backgroundColor = [UIColor whiteColor];
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
    btnMenu.center = CGPointMake(384, kSubmenTopButtonY);
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
    btnLog.center = CGPointMake(270, kSubmenTopButtonY);//270 498
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
    btnQuery.center = CGPointMake(498, kSubmenTopButtonY);
    btnQuery.hidden = NO;
    [btnQuery addTarget:self action:@selector(showQuery) forControlEvents:UIControlEventTouchUpInside];
    
    if (!bActivated)
        btnMenu.hidden = YES;
    
    BSMenuView *vMenu = [[BSMenuView alloc] initWithFrame:CGRectMake(0, 0, 768, 45)];
    [self.view addSubview:vMenu];
    [vMenu release];
    [vMenu setSelectedIndex:[[self.dicInfo objectForKey:@"index"] intValue]];
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
- (FBView *)fbviewForIndex:(NSInteger)index{
    
    NSArray *ary = self.aryFBViews;
    NSDictionary *info = self.dicInfo;
    int i = index;
    NSString *recommend = [info objectForKey:@"recommend"];
    NSArray *aryRecommend = nil;
    if ([recommend length]>0)
        aryRecommend = [recommend componentsSeparatedByString:@"&"];
    int dRecommend = [aryRecommend count];
    
    FBView *fb = nil;
    
    
    
    if (i<dRecommend){
        fb = [[FBView alloc] initWithFrame:CGRectMake(0, 0, 768, 1004)];
        NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docPath = [docPaths objectAtIndex:0];
        
        
        
        
        
        NSString *recomPath = [docPath stringByAppendingPathComponent:[[[aryRecommend objectAtIndex:i] componentsSeparatedByString:@","] objectAtIndex:0]];
        UIImageView *imgvRecommend = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 768, 1004)];
        UIImage *imgRecommend = [[UIImage alloc] initWithContentsOfFile:recomPath];
        [imgvRecommend setImage:imgRecommend];
        [imgRecommend release];
        [fb addSubview:imgvRecommend];
        [imgvRecommend release];
        fb.tag = i;
        
        
        UIButton *btnFB = [UIButton buttonWithType:UIButtonTypeCustom];
        btnFB.frame = CGRectMake(0, 0, 768, 1004);
        
        NSArray *aryCount = [[aryRecommend objectAtIndex:i] componentsSeparatedByString:@","];
        int  strCount;
        if ([aryCount count]>1){
            for (NSDictionary *dic in ary){
                if ([[dic objectForKey:@"ITEM"] isEqualToString:[aryCount objectAtIndex:1]]){
                    strCount = [ary indexOfObject:dic];
                }                                                                         
            }
        }
        else
            strCount = 0;
        btnFB.tag = strCount;
        
        [btnFB addTarget:self action:@selector(cellSelected:) forControlEvents:UIControlEventTouchUpInside];
        [fb addSubview:btnFB];
        
        UIButton *btnContents = [UIButton buttonWithType:UIButtonTypeCustom];
        btnContents.frame = CGRectMake(13, kSubmenTopButtonY-24, 102, 49);
        [btnContents setBackgroundImage:[UIImage imageNamed:@"btnContents.png"] forState:UIControlStateNormal];
        [btnContents setTitle:@"返回" forState:UIControlStateNormal];
        [btnContents setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnContents addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        [fb addSubview:btnContents];
    }
    else{
        NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docPath = [docPaths objectAtIndex:0];
        
        fb = [[FBView alloc] initWithFrame:CGRectMake(0, 0, 768, 1004)];
        fb.backgroundColor = [UIColor whiteColor];
        fb.parent = self;
        
        UIImage *imgBG = [UIImage imageWithContentsOfFile:[docPath stringByAppendingPathComponent:self.strBackground]];
        if (imgBG){
            UIImageView *imgvBG = [[UIImageView alloc] initWithFrame:fb.bounds];
            [imgvBG setImage:imgBG];
            [fb addSubview:imgvBG];
            [imgvBG release];
        }
        
        UIButton *btnContents = [UIButton buttonWithType:UIButtonTypeCustom];
        btnContents.frame = CGRectMake(13, kSubmenTopButtonY-24, 102, 49);
        [btnContents setBackgroundImage:[UIImage imageNamed:@"btnContents.png"] forState:UIControlStateNormal];
        [btnContents setTitle:@"返回" forState:UIControlStateNormal];
        [btnContents setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnContents addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        [fb addSubview:btnContents];
        
        BSAdView *vAD = [[BSAdView alloc] initWithFrame:CGRectMake(0, 1004-55, 768, 55)];
        vAD.opaque = YES;
        [fb addSubview:vAD];
        [vAD release];
        
        //        UIImageView *imgvAD = [[UIImageView alloc] initWithFrame:CGRectMake(0, 1004-55, 768, 55)];
        //        imgvAD.opaque = YES;
        //        [imgvAD setImage:[UIImage imageNamed:@"adsub.png"]];
        //        [fb addSubview:imgvAD];
        //        [imgvAD release];
        UILabel *lblPage = [[UILabel alloc] initWithFrame:CGRectMake(0, 900, 768, 32)];
        lblPage.textAlignment = UITextAlignmentCenter;
        lblPage.textColor = [UIColor grayColor];
        lblPage.backgroundColor = [UIColor clearColor];
        lblPage.text = [NSString stringWithFormat:@"Page %d Of %d",i+1-dRecommend,totalPages-dRecommend];
        [lblPage sizeToFit];
        lblPage.center = CGPointMake(384, 930);
        [fb addSubview:lblPage];
        [lblPage release];
        
        for (int j=(i-dRecommend)*kNumberOfFoodInPage;j<(i-dRecommend)*kNumberOfFoodInPage+kNumberOfFoodInPage && j<[ary count];j++){
            int row = j/2-(i-dRecommend)*kNumberOfFoodInPage/2;
            int column = j%2;
            NSDictionary *dataDict = [ary objectAtIndex:j];
            SubMenuCell *cell = [[SubMenuCell alloc] initWithFrame:CGRectMake(15+column*373, 170+row*185, 355, 160)];
            cell.tag = j;
            cell.delegate = self;
            [cell showData:dataDict];
            [fb addSubview:cell];
            [cell release];
        }
        fb.tag = i;
        
    }
    
    fb.tag = index;
    return [fb autorelease];
    
}

- (FBView *)prevView{
    if (currentPage>0)
        //        return [self.aryFBViews objectAtIndex:currentPage-1];
        return [self fbviewForIndex:currentPage-1];
    else
        return nil;
}

- (FBView *)currView{
    if ([self.aryFBViews count]>0)
        return [self fbviewForIndex:currentPage];
    //        return [self.aryFBViews objectAtIndex:currentPage];
    else
        return nil;
}

- (FBView *)nextView{
    if (currentPage<totalPages-1)
        //        return [self.aryFBViews objectAtIndex:currentPage+1];
        return [self fbviewForIndex:currentPage+1];
    else
        return nil;
}

- (void)pageTurned:(NSDictionary *)info{
    int page = [[info objectForKey:@"page"] intValue];
	if (page==0 && currentPage>0)
		currentPage--;
	else if (page==1 && currentPage<totalPages-1)
		currentPage++;
}



- (void)genViews:(NSDictionary *)info activated:(BOOL)activated{
    bActivated = activated;
    self.strBackground = [info objectForKey:@"background"];
    
    NSArray *ary = [info objectForKey:@"array"];
    self.aryFBViews = ary;
    NSString *recommend = [info objectForKey:@"recommend"];
    NSArray *aryRecommend = nil;
    if ([recommend length]>0)
        aryRecommend = [recommend componentsSeparatedByString:@"&"];
    int dRecommend = [aryRecommend count];
    NSMutableArray *mut = [[NSMutableArray alloc] init];
    int count = [ary count];
    int mode = count%kNumberOfFoodInPage;
    int pageCount;
    if (mode==0)
        pageCount = count/kNumberOfFoodInPage+dRecommend;
    else
        pageCount = count/kNumberOfFoodInPage+1+dRecommend;
    totalPages = pageCount;
    [mut release];
}




- (void)turnEnded:(BOOL)turned{
    if (turned){
        [vBG insertSubview:fbNext belowSubview:fbTrans];
        [fbCurr removeFromSuperview];
        //        if (pageToShow==PrevPage && pageToShow>0)
        //            currentPage--;
        //        else if (pageToShow==NextPage && currentPage<[aryFBViews count]-1)
        //            currentPage++;
        fbCurr = fbNext;
    }
    
    [fbTrans removeFromSuperview];
    [fbTrans release];
    fbTrans = nil;
    fbCurr = nil;
    fbNext = nil;
    
    for (UIView *v in vBG.subviews){
        if ([v isKindOfClass:[FBView class]]){
            if (v.tag!=currentPage)
                [v removeFromSuperview];
        }
    }
    
    bTurning = NO;
    
    //    for (int i=0;i<[aryFBViews count];i++){
    //        FBView *fbfb = [aryFBViews objectAtIndex:i];
    //        if (fbfb && fbfb.superview)
    //            currentPage = fbfb.tag;
    //    }
    if (bActivated)
        btnMenu.hidden = NO;
    [vBG addGestureRecognizer:panGesture];
}


//Gesture Handeler
- (void)handlePan:(UIPanGestureRecognizer *)gesture{
    if (bTurning)
        return;
    
    CGPoint translate = [gesture translationInView:self.view];
	if (gesture.state == UIGestureRecognizerStateBegan)
    {
//        NSLog(@"begin current page:%d",currentPage);
        if ([gesture numberOfTouches]<1)
            return;
        btnMenu.hidden = YES;
        btnLog.hidden = YES;
        btnQuery.hidden = YES;
        ptOrigin = [gesture locationOfTouch:0 inView:self.view];
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
        ptCurr = [gesture locationOfTouch:0 inView:self.view];
        
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
        //        if (bTurning)
        //            return;
        bTurning = YES;
        [vBG removeGestureRecognizer:panGesture];
//        NSLog(@"end current page:%d",currentPage);
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

- (void)goBack{
    //    [timerADs invalidate];
    //    [self.navigationController performSelector:@selector(SubToMain)];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cellSelected:(id)sender{
    
    UIView *v = (UIView *)sender;
    
    NSLog(@"Sub Menu Item:%d Selected",v.tag);
    
    [self.navigationController performSelector:@selector(setCurrentCellIndex:) withObject:[NSNumber numberWithInt:v.tag]];
    [self.navigationController performSelector:@selector(showContent)];
}



- (void)deleteViews{
    //    [timerADs invalidate];
    for (UIView *v in self.view.subviews){
        [v removeFromSuperview];
    }
    
    [aryFBViews release];
    aryFBViews = nil;
}

- (void)addCurView{
    [vBG addSubview:[self currView]];
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
            btnLog.center = CGPointMake(270, kSubmenTopButtonY);
            btnQuery.transform = CGAffineTransformMakeScale(1.0, 1.0);
            btnQuery.center = CGPointMake(498, kSubmenTopButtonY);
        }];
    }
    
}

- (void)showLog{
    BSLogViewController *vcMyMenu = [[BSLogViewController alloc] init];
    [self.navigationController pushViewController:vcMyMenu animated:YES];
//    vcMyMenu.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//    [self presentModalViewController:vcMyMenu animated:YES];
}

- (void)showQuery{
    BSQueryViewController *vcQuery = [[BSQueryViewController alloc] init];
    [self.navigationController pushViewController:vcQuery animated:YES];
//    vcQuery.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//    [self presentModalViewController:vcQuery animated:YES];
}


- (void)favorClicked:(UIButton *)btn{
    
}
@end
