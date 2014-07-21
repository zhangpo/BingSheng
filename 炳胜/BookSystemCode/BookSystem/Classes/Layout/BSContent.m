//
//  BSContent.m
//  BookSystem
//
//  Created by Dream on 11-3-16.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BSContent.h"
#import "BSAddtionView.h"
#import "CVLocalizationSetting.h"
#import "BSCommentView.h"
#import "BSMenuView.h"

@implementation BSContent
@synthesize aryDict,aryFBViews;
@synthesize aryAddition;
@synthesize menuIndex;
@synthesize strUnitKey,strPriceKey;

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
    [pop release];
    [vcPop release];
    [aryFBViews release];
    [panGesture release];
    self.aryDict = nil;
    self.aryAddition = nil;
    self.strUnitKey = nil;
    self.strPriceKey = nil;
    
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
    
    BOOL bShowButton = [[NSUserDefaults standardUserDefaults] boolForKey:@"ShowButton"];
    
    
    NSDictionary *buttonConfig = [[BSDataProvider sharedInstance] buttonConfig];
    
    CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
    fFoodCount = 1;
    dAddition = 0;
    self.view.backgroundColor = [UIColor whiteColor];

    self.view.frame = CGRectMake(0, 0, 768, 1004);
    backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 1004)];
    [self.view addSubview:backView];
    [backView release];
    
    panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    
    [backView addGestureRecognizer:panGesture];
    //   [self.view addGestureRecognizer:swipeLeft];
    //  [self.view addGestureRecognizer:swipeRight];
    
//    [panGesture release];
    [swipeLeft release];
    [swipeRight release];
    
    
	[backView addSubview:[self currView]];
    fbCurr = [self currView];
    
    imgvOrder = [[UIImageView alloc] initWithFrame:CGRectMake(0, 1004-80, 768, 80)];
    [self.view addSubview:imgvOrder];
    [imgvOrder release];
    
    imgvOrder.userInteractionEnabled = YES;
    
    
    UILabel *lbl1 = [[UILabel alloc] initWithFrame:CGRectMake(16, 18, 100, 44)];
    lbl1.text = [langSetting localizedString:@"Count:"];// @"数量:";
    lbl1.backgroundColor = [UIColor clearColor];
    lbl1.font = [UIFont boldSystemFontOfSize:28];
    
    btnCount = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCount.frame = CGRectMake(116, 18, 80, 44);
    [btnCount setTitle:@"1.00" forState:UIControlStateNormal];
    btnCount.titleLabel.font = [UIFont boldSystemFontOfSize:28];
    [btnCount setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnCount addTarget:self action:@selector(countClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *imgNormal = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"btn1normal" ofType:@"png"]];
    UIImage *imgPressed = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"btn1pressed" ofType:@"png"]];
    
    UIButton *btnAdd = [UIButton buttonWithType:UIButtonTypeCustom];
    btnAdd.frame = CGRectMake(630, 18, 80, 44);
    [btnAdd setBackgroundImage:imgNormal forState:UIControlStateNormal];
    [btnAdd setBackgroundImage:imgPressed forState:UIControlStateHighlighted];
    btnAdd.center = CGPointMake(270, 40);
    btnAdd.titleLabel.font = [UIFont boldSystemFontOfSize:22];
    [btnAdd setTitle:@"+" forState:UIControlStateNormal];
    [btnAdd addTarget:self action:@selector(add) forControlEvents:UIControlEventTouchUpInside];
    btnAdd.hidden = !bShowButton;
    
    UIButton *btnMinus = [UIButton buttonWithType:UIButtonTypeCustom];
    btnMinus.frame = CGRectMake(630, 18, 80, 44);
    [btnMinus setBackgroundImage:imgNormal forState:UIControlStateNormal];
    [btnMinus setBackgroundImage:imgPressed forState:UIControlStateHighlighted];
    btnMinus.center = CGPointMake(370, 40);
    btnMinus.titleLabel.font = [UIFont boldSystemFontOfSize:22];
    [btnMinus setTitle:@"-" forState:UIControlStateNormal];
    [btnMinus addTarget:self action:@selector(reduce) forControlEvents:UIControlEventTouchUpInside];
    btnMinus.hidden = !bShowButton;
    
    UIButton *btnOK = [UIButton buttonWithType:UIButtonTypeCustom];
    btnOK.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    btnOK.frame = CGRectMake(630, 18, 80, 44);
    [btnOK setBackgroundImage:imgNormal forState:UIControlStateNormal];
    [btnOK setBackgroundImage:imgPressed forState:UIControlStateHighlighted];
    btnOK.center = CGPointMake(470, 40);
    [btnOK setTitle:[langSetting localizedString:@"OK"] forState:UIControlStateNormal];
    [btnOK addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
    
    btnFujia = [UIButton buttonWithType:UIButtonTypeCustom];
    btnFujia.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    btnFujia.frame = CGRectMake(630, 18, 80, 44);
    [btnFujia setBackgroundImage:imgNormal forState:UIControlStateNormal];
    [btnFujia setBackgroundImage:imgPressed forState:UIControlStateHighlighted];
    btnFujia.center = CGPointMake(570, 40);
    [btnFujia setTitle:[langSetting localizedString:@"Additions"] forState:UIControlStateNormal];
    [btnFujia addTarget:self action:@selector(setAddition) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btnComment = [UIButton buttonWithType:UIButtonTypeCustom];
    btnComment.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    btnComment.frame = CGRectMake(630, 18, 80, 44);
    [btnComment setBackgroundImage:imgNormal forState:UIControlStateNormal];
    [btnComment setBackgroundImage:imgPressed forState:UIControlStateHighlighted];
    btnComment.center = CGPointMake(670, 40);
//    [btnComment setTitle:[langSetting localizedString:@"Additions"] forState:UIControlStateNormal];
    [btnComment setTitle:@"分享菜品" forState:UIControlStateNormal];
    [btnComment addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    btnComment.hidden = !bShowButton;
    
    
//    UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
//    btnCancel.frame = CGRectMake(630, 18, 80, 44);
//    [btnCancel setBackgroundImage:imgNormal forState:UIControlStateNormal];
//    [btnCancel setBackgroundImage:imgPressed forState:UIControlStateHighlighted];
//    btnCancel.center = CGPointMake(670, 40);
//    [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
//    [btnCancel addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    
    [imgNormal release];
    [imgPressed release];
    
    [imgvOrder addSubview:lbl1];
    [lbl1 release];
    [imgvOrder addSubview:btnCount];
    
    [imgvOrder addSubview:btnAdd];
    [imgvOrder addSubview:btnMinus];
    [imgvOrder addSubview:btnOK];
    [imgvOrder addSubview:btnFujia];
    [imgvOrder addSubview:btnComment];
//    [imgvOrder addSubview:btnCancel];
    
    
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
    btnLog.frame = CGRectFromString([buttonConfig objectForKey:@"log"]);
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
    btnQuery.frame = CGRectFromString([buttonConfig objectForKey:@"query"]);
    btnQuery.hidden = NO;
    [btnQuery addTarget:self action:@selector(showQuery) forControlEvents:UIControlEventTouchUpInside];
    
    if (!bActivated){
        btnMenu.hidden = YES;
        imgvOrder.hidden = YES;
    }
    

    BSMenuView *vMenu = [[BSMenuView alloc] initWithFrame:CGRectMake(0, 0, 768, 45)];
    vMenu.menuStyle = BSMenuStyleContent;
    [self.view addSubview:vMenu];
    [vMenu release];
    [vMenu setSelectedIndex:menuIndex];

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
    int i = index;
    FBView *fb = [[FBView alloc] initWithFrame:CGRectMake(0, 0, 768, 1004)];
    fb.tag = index;
    fb.backgroundColor = [UIColor whiteColor];
    fb.parent = self;
    NSArray *ary = self.aryDict;// self.aryFBViews;
    
    UIButton *btnContents = [UIButton buttonWithType:UIButtonTypeCustom];
    btnContents.frame = CGRectMake(13, kTopButtonY-24, 102, 49);
    [btnContents setBackgroundImage:[UIImage imageNamed:@"btnContents.png"] forState:UIControlStateNormal];
    [btnContents setTitle:@"返回" forState:UIControlStateNormal];
    [btnContents setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnContents addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [fb addSubview:btnContents];
    
    NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [docPaths objectAtIndex:0];
    NSString *bigPath = [docPath stringByAppendingPathComponent:[[ary objectAtIndex:i] objectForKey:@"picBig"]];
    //        NSString *introPath = [docPath stringByAppendingPathComponent:[[ary objectAtIndex:i] objectForKey:@"intro"]];
    
    UIImage *imgPic = [[UIImage alloc] initWithContentsOfFile:bigPath];
    //        UIImage *imgIntro = [[UIImage alloc] initWithContentsOfFile:introPath];
    
    
    
    
    
    
    UIImageView *imgvPic = [[UIImageView alloc] initWithFrame:CGRectMake(15, 128, 737, 586)];
    [imgvPic setImage:imgPic];
    [imgPic release];
    [fb addSubview:imgvPic];
    [imgvPic release];
    imgvPic.tag = 333;
    
    UIButtonEx *btnPic = [UIButtonEx buttonWithType:UIButtonTypeCustom];
    btnPic.backgroundColor = [UIColor clearColor];
    btnPic.opaque = YES;
    [btnPic addTarget:self action:@selector(imageClicked:) forControlEvents:UIControlEventTouchUpInside];
    btnPic.frame = CGRectMake(15, 128, 737, 586);
    [fb addSubview:btnPic];
    btnPic.tag = i;
    
    UIButtonEx *btnPlay = [UIButtonEx buttonWithType:UIButtonTypeCustom];
    btnPlay.frame = CGRectMake(15+737-60, 128+586-62, 60, 62);
    [btnPlay setImage:[UIImage imageNamed:@"BSPlayButton.png"] forState:UIControlStateNormal];
    [fb addSubview:btnPlay];
    [btnPlay addTarget:self action:@selector(showVideo:) forControlEvents:UIControlEventTouchUpInside];
    btnPlay.tag = index;
    
    if (![[aryDict objectAtIndex:index] objectForKey:@"video"])
        btnPlay.hidden = YES;
    else
        btnPlay.hidden = NO;
    
    NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"textColor"];
    
    if (!colorData){
        colorData = [NSKeyedArchiver archivedDataWithRootObject:[UIColor blackColor]];
        [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:@"textColor"];
    }
    
    UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    
    UILabel *lblIntro = [[UILabel alloc] initWithFrame:CGRectMake(16, 738, 736, 209)];
    lblIntro.textColor = color;
    lblIntro.backgroundColor = [UIColor clearColor];
    lblIntro.lineBreakMode = UILineBreakModeWordWrap;
    lblIntro.numberOfLines = 0;
    lblIntro.text = [[[ary objectAtIndex:i] objectForKey:@"REMEMO"] stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    [fb addSubview:lblIntro];
    [lblIntro release];
    
    
    
    UILabel *lblPriceName = [[UILabel alloc] initWithFrame:CGRectMake(16, 725, 500, 50)];
    lblPriceName.userInteractionEnabled = YES;
    lblPriceName.lineBreakMode = UILineBreakModeCharacterWrap;
    lblPriceName.numberOfLines = 2;
    lblPriceName.backgroundColor = [UIColor clearColor];
    lblPriceName.font = [UIFont boldSystemFontOfSize:18];
    lblPriceName.textColor = color;
    lblPriceName.text = [NSString stringWithFormat:@"%@            %@/%@\n%@",[[ary objectAtIndex:i] objectForKey:@"DES"],[[ary objectAtIndex:i] objectForKey:[[NSUserDefaults standardUserDefaults] stringForKey:@"price"]],[[ary objectAtIndex:i] objectForKey:@"UNIT"],[[ary objectAtIndex:i] objectForKey:@"DESCE"]];
    [lblPriceName sizeToFit];
    UIButton *btnPriceName = [UIButton buttonWithType:UIButtonTypeCustom];
    btnPriceName.tag = 100+i;
    btnPriceName.frame = lblPriceName.bounds;
    [lblPriceName addSubview:btnPriceName];
    [btnPriceName addTarget:self action:@selector(changeUnit:) forControlEvents:UIControlEventTouchUpInside];

    
    if ([[[ary objectAtIndex:i] objectForKey:@"sPriceTyp"] boolValue])
        btnPriceName.hidden = NO;
    else
        btnPriceName.hidden = YES;
    NSLog(@"Show Button:%@",btnPriceName.hidden?@"NO":@"YES");
    
    
    UIButtonEx *btnComment = [UIButtonEx buttonWithType:UIButtonTypeRoundedRect];
    btnComment.tag = 2222;
    btnComment.frame = CGRectMake(768-15-250-30, 725, 280, 50);
    [fb addSubview:btnComment];
    [btnComment addTarget:self action:@selector(showComments:) forControlEvents:UIControlEventTouchUpInside];
    NSArray *comments = [[aryDict objectAtIndex:index] objectForKey:@"comments"];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 9, 280-183, 31)];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.textAlignment = UITextAlignmentRight;
    [btnComment addSubview:lbl];
    [lbl release];
    lbl.text = [NSString stringWithFormat:@"%d份评价",[comments count]];
    lbl.tag = 3333;
    
    int level = 0;
    for (NSDictionary *comment in comments){
        level += [[comment objectForKey:@"level"] intValue];
    }
    
    level = floorf(((float)level)/((float)([comments count]))+0.5f);
    
    BSCommentView *vComment = [[BSCommentView alloc] initWithFrame:CGRectMake(280-32*5-8-5, 9,  32*5+2*4, 31)];
    vComment.tag = 444;
    vComment.userInteractionEnabled = NO;
    [btnComment addSubview:vComment];
    [vComment release];
    if ([comments count]>0)
        vComment.level = level;
    else
        vComment.level = 0;
    
    
    [fb addSubview:lblPriceName];
    [lblPriceName release];
    
    fb.tag = i;
    
//    UILabel *lblPage = [[UILabel alloc] initWithFrame:CGRectMake(0, 984, 768, 20)];
//    lblPage.textAlignment = UITextAlignmentCenter;
//    lblPage.textColor = [UIColor grayColor];
//    lblPage.backgroundColor = [UIColor clearColor];
//    lblPage.text = [NSString stringWithFormat:@"Page %d Of %d",i+1,totalPages];
//    [lblPage sizeToFit];
//    lblPage.center = CGPointMake(384, 967);
//    [fb addSubview:lblPage];
//    [lblPage release];
    
    return [fb autorelease];
}

- (FBView *)prevView{
    if (currentPage>0){
        return [self fbviewForIndex:currentPage-1];
        
//        return [self.aryFBViews objectAtIndex:currentPage-1];
    }
    else
        return nil;
}

- (FBView *)currView{
    if ([aryFBViews count]>0)
        return [self fbviewForIndex:currentPage];
    else
        return nil;
    
    return [self.aryFBViews objectAtIndex:currentPage];
}

- (FBView *)nextView{
    if (currentPage<totalPages-1){
        return [self fbviewForIndex:currentPage+1];
        
//        return [self.aryFBViews objectAtIndex:currentPage+1];
    }
    else
        return nil;
}




- (void)genViews:(NSArray *)ary activated:(BOOL)activated{
    bActivated = activated;
    
//    NSMutableArray *mut = [[NSMutableArray alloc] init];
    int count = [ary count];

    totalPages = count;
    self.aryFBViews = ary;

}





- (void)turnEnded:(BOOL)turned{
    if (turned){
        fFoodCount = 1;
        dAddition = 0;
        self.aryAddition = nil;
        self.strUnitKey = @"UNIT";
        self.strPriceKey = @"PRICE";
        
        [backView insertSubview:fbNext belowSubview:fbTrans];
        [fbCurr removeFromSuperview];
        
        fbCurr = fbNext;

    }
    
    [fbTrans removeFromSuperview];
    [fbTrans release];
    fbTrans = nil;
    fbCurr = nil;
    fbNext = nil;
    
    for (UIView *vv in backView.subviews){
        if ([vv isKindOfClass:[FBView class]]){
            if (vv.tag!=currentPage)
                [vv removeFromSuperview];
        }
    }
    
    [btnCount setTitle:[NSString stringWithFormat:@"%.2f",fFoodCount] forState:UIControlStateNormal];
    
    bTurning = NO;
    
    if (bActivated){
        imgvOrder.hidden = NO;
        btnMenu.hidden = NO;
    }
    

    [backView addGestureRecognizer:panGesture];
}


//Gesture Handeler
- (void)handlePan:(UIPanGestureRecognizer *)gesture{
    if (bTurning)
        return;
    if (v!=nil)
        return;
    
    CGPoint translate = [gesture translationInView:self.view];
	if (gesture.state == UIGestureRecognizerStateBegan)
    {
        NSLog(@"begin current page:%d",currentPage);
        if ([gesture numberOfTouches]<1)
            return;
        if (vAddition && vAddition.superview){
            [vAddition removeFromSuperview];
            vAddition = nil;
        }
        btnMenu.hidden = YES;
        btnLog.hidden = YES;
        btnQuery.hidden = YES;
        imgvOrder.hidden = YES;
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
        [backView addSubview:fbTrans];
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
        if(bTurning)
            return;
        bTurning = YES;
        [backView removeGestureRecognizer:panGesture];
        NSLog(@"end current page:%d",currentPage);
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
//    [self.navigationController performSelector:@selector(ContentToSub)];
    
    [self.navigationController popViewControllerAnimated:YES];
    [self release];
}

- (void)cellSelected:(id)sender{
    NSLog(@"Sub Menu Items Selected");
}

- (void)imageClicked:(UIButton *)sender{
//    v = [[BSOrderView alloc] initWithDict:[self.aryDict objectAtIndex:sender.tag]];
//    v.delegate = self;
//    [backView addSubview:v];
//    [self.view bringSubviewToFront:v];
//    [v release];
    WPhotoCell *vPhotoCell = [[WPhotoCell alloc] initWithFrame:CGRectMake(0, 0, 768, 1004)];
    vPhotoCell.alpha = 0;
    vPhotoCell.animationStyle = WImageViewAnimationStyleCrossOver;
    [self.view addSubview:vPhotoCell];
    [vPhotoCell release];
    

    NSString *imgname = [[aryDict objectAtIndex:sender.tag] objectForKey:@"picBig"];
    vPhotoCell.dicInfo = [NSDictionary dictionaryWithObjectsAndKeys:imgname,@"image", nil];
    
    [UIView animateWithDuration:0.2f animations:^{
        vPhotoCell.alpha = 1; 
    }];
}

- (void)needsRemove{
    [v removeFromSuperview];
    v = nil;
}

- (void)setCurrentIndex:(int)dIndex{
    currentPage = dIndex;
    if (currentPage>[aryFBViews count]-1)
        currentPage = [aryFBViews count]-1;
    else if (currentPage<0)
        currentPage = 0;
}


#pragma mark Handle Order Events
- (void)setAddition{
    if (!vAddition){
        NSDictionary *dic = [self.aryDict objectAtIndex:currentPage];
        vAddition = [[BSAddtionView alloc] initWithFrame:CGRectMake(0, 0, 492, 354) info:dic];
        vAddition.delegate = self;
    }
    if (!vAddition.superview){
        vAddition.center = CGPointMake(btnFujia.center.x,924+btnFujia.center.y);
        [self.view addSubview:vAddition];
        [vAddition firstAnimation];
        [vAddition release];
    }
    else{
        [vAddition removeFromSuperview];
        vAddition = nil;
    }
    
}

- (void)add{
    fFoodCount = [btnCount.titleLabel.text floatValue];
    if (fFoodCount<0)
        fFoodCount = 1;
    fFoodCount+=1.0f;
    [btnCount setTitle:[NSString stringWithFormat:@"%.2f",fFoodCount] forState:UIControlStateNormal];
}

- (void)reduce{
    fFoodCount = [btnCount.titleLabel.text floatValue];
    if (fFoodCount>1){
        fFoodCount-=1.0f;
        [btnCount setTitle:[NSString stringWithFormat:@"%.2f",fFoodCount] forState:UIControlStateNormal];
    }
}

- (void)changeUnit:(UIButton *)btn{
    btnUnit = btn;
    NSArray *ary = self.aryDict;
    
    int index = btn.tag-100;
    NSDictionary *food = [ary objectAtIndex:index];
    
    UILabel *lblPriceName = (UILabel *)btn.superview;
    
    lblPriceName.text = [NSString stringWithFormat:@"%@            %@/%@\n%@",[food objectForKey:@"DES"],[food objectForKey:[[NSUserDefaults standardUserDefaults] stringForKey:@"price"]],[food objectForKey:@"UNIT"],[food objectForKey:@"DESCE"]];
    
    
    NSMutableArray *mutmut = [NSMutableArray array];
    for (int i=0;i<5;i++){
        NSString *unit = [food objectForKey:0==i?@"UNIT":[NSString stringWithFormat:@"UNIT%d",i+1]];
        NSString *price = [food objectForKey:0==i?@"PRICE":[NSString stringWithFormat:@"PRICE%d",i+1]];
        if (unit && [unit length]>0)
            [mutmut addObject:[NSDictionary dictionaryWithObjectsAndKeys:price,@"price",unit,@"unit", nil]];
    }
    
    if ([mutmut count]>1){
        int count = [mutmut count];
        
        NSMutableArray *mut = [NSMutableArray array];
        for (int j=0;j<[mutmut count];j++){
            NSString *title = [NSString stringWithFormat:@"%d/%@",[[[mutmut objectAtIndex:j] objectForKey:@"price"] intValue],[[mutmut objectAtIndex:j] objectForKey:@"unit"]];
            [mut addObject:title];
        }
        
        UIActionSheet *as = nil;
        if (2==count)
            as = [[UIActionSheet alloc] initWithTitle:@"请选择单位和价格" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:[mut objectAtIndex:0],[mut objectAtIndex:1],nil];
        else if (3==count)
            as = [[UIActionSheet alloc] initWithTitle:@"请选择单位和价格" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:[mut objectAtIndex:0],[mut objectAtIndex:1],[mut objectAtIndex:2],nil];
        else if (4==count)
            as = [[UIActionSheet alloc] initWithTitle:@"请选择单位和价格" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:[mut objectAtIndex:0],[mut objectAtIndex:1],[mut objectAtIndex:2],[mut objectAtIndex:3],nil];
        else if (5==count)
            as = [[UIActionSheet alloc] initWithTitle:@"请选择单位和价格" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:[mut objectAtIndex:0],[mut objectAtIndex:1],[mut objectAtIndex:2],[mut objectAtIndex:3],[mut objectAtIndex:4],nil];
                    
        [as showFromRect:btn.frame inView:btn.superview animated:YES];
//        [as showInView:self.view];
        [as release];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (0!=buttonIndex){
        NSArray *ary = self.aryDict;
        
        int index = btnUnit.tag-100;
        NSDictionary *food = [ary objectAtIndex:index];
        
        UILabel *lblPriceName = (UILabel *)btnUnit.superview;
        
        lblPriceName.text = [NSString stringWithFormat:@"%@            %@/%@\n%@",[food objectForKey:@"DES"],[food objectForKey:[[NSUserDefaults standardUserDefaults] stringForKey:@"price"]],[food objectForKey:@"UNIT"],[food objectForKey:@"DESCE"]];
        
        int j = 0;
        int mutIndex = buttonIndex-1;
        
        for (int i=0;i<5;i++){
            NSString *unit = [food objectForKey:0==i?@"UNIT":[NSString stringWithFormat:@"UNIT%d",i+1]];
            if (unit && [unit length]>0){
                if (j==mutIndex){
                    self.strUnitKey = 0==i?@"UNIT":[NSString stringWithFormat:@"UNIT%d",i+1];
                    self.strPriceKey = 0==i?@"PRICE":[NSString stringWithFormat:@"PRICE%d",i+1];
                    lblPriceName.text = [NSString stringWithFormat:@"%@            %@/%@\n%@",[food objectForKey:@"DES"],[food objectForKey:strPriceKey],[food objectForKey:strUnitKey],[food objectForKey:@"DESCE"]];
                    [lblPriceName sizeToFit];
                    btnUnit.frame = lblPriceName.bounds;
                }
                j++;
            }
                
        }
        
        
    }
}

- (void)confirm{
//    CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[self.aryDict objectAtIndex:currentPage] forKey:@"food"];
    [dict setObject:btnCount.titleLabel.text forKey:@"total"];
    

    
    
    if (self.aryAddition)
        [dict setObject:aryAddition forKey:@"addition"];
    
    if (self.strUnitKey){
        [dict setObject:strUnitKey forKey:@"unitKey"];
        [dict setObject:strPriceKey forKey:@"priceKey"];
    }
    
    [dp orderFood:dict];
    
    self.aryAddition = nil;
    self.strUnitKey = @"UNIT";
    self.strPriceKey = @"PRICE";
    
    
    UIImageView *imgv = [[UIImageView alloc] initWithFrame:CGRectMake(15, 128, 737, 586)];
    [self.view addSubview:imgv];
    [imgv release];
    NSString *imgname = [[aryDict objectAtIndex:currentPage] objectForKey:@"picBig"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:imgname];
    
    [imgv setImage:[UIImage imageWithContentsOfFile:path]];

    
    [UIView animateWithDuration:0.3f animations:^{
        imgv.frame = CGRectMake(364, kTopButtonY-20, 40, 40);
    }completion:^(BOOL finished) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[langSetting localizedString:@"Food Ordered"] delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
//        [alert show];
//        [alert release];
        
        [imgv removeFromSuperview];
    }];
}

- (void)cancel{
    self.aryAddition = nil;
}

- (void)additionSelected:(NSArray *)ary{
    self.aryAddition = ary;
    [vAddition removeFromSuperview];
    vAddition = nil;
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
    vcMyMenu.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:vcMyMenu animated:YES];
}

- (void)showQuery{
    BSQueryViewController *vcQuery = [[BSQueryViewController alloc] init];
    vcQuery.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:vcQuery animated:YES];
}

- (void)countClicked{
    if (!pop){
        UIViewController *vc = [[UIViewController alloc] init];
        
        
        
        
        UIPickerView *picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 120, 196)];
        picker.showsSelectionIndicator = YES;
        picker.delegate = self;
        picker.dataSource = self;
        picker.tag = 999;
        [vc.view addSubview:picker];
        [picker release]; 
        
//        NSLog(@"%f %f",picker.frame.size.width,picker.frame.size.height);
        pop = [[UIPopoverController alloc] initWithContentViewController:vc];
        [pop setPopoverContentSize:CGSizeMake(120, 196)];
        [vc release];
    }
    
    UIPickerView *pickerView = (UIPickerView *)[pop.contentViewController.view viewWithTag:999];
    
    int row = (int)fFoodCount;
    int component = (((int)(fFoodCount*10))%10);
    int count3 = (((int)(fFoodCount*100))%10);
    [pickerView selectRow:row inComponent:0 animated:NO];
    [pickerView selectRow:component inComponent:1 animated:NO];
    [pickerView selectRow:count3 inComponent:2 animated:NO];
    [pop presentPopoverFromRect:btnCount.frame inView:imgvOrder permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
}

#pragma mark UIPickerView Delegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [NSString stringWithFormat:@"%d",row];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 0==component?100:10;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    return 0==component?40:30;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    float value;
    
    int index0 = [pickerView selectedRowInComponent:0];
    int index1 = [pickerView selectedRowInComponent:1];
    int index2 = [pickerView selectedRowInComponent:2];
    
    value = index0+(float)index1*0.1f+(float)index2*0.01f;

    
    fFoodCount = value;
    [btnCount setTitle:[NSString stringWithFormat:@"%.2f",fFoodCount] forState:UIControlStateNormal];
}

- (void)showVideo:(UIButton *)btn{
    if (btn.tag<[aryDict count]){
        MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:[[aryDict objectAtIndex:btn.tag] objectForKey:@"video"]]];
        player.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
//        [self presentMoviePlayerViewControllerAnimated:player];
        [self presentModalViewController:player animated:YES];
        [player release];
//        player = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:[[aryDict objectAtIndex:btn.tag] objectForKey:@"video"]]];
//        player.controlStyle = MPMovieControlStyleEmbedded;
////        [player prepareToPlay];
//        [player.view setFrame:CGRectMake(15, 128, 737, 586)];
//        player.view.tag = 999;
//        [self.view addSubview:player.view];
//        [player play];
        
    }
}
//
//- (void)enterFullscreen{
//    MPMoviePlayerViewController *movieplayer = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:[[aryDict objectAtIndex:currentPage] objectForKey:@"video"]]];
//    movieplayer.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
//    [self presentMoviePlayerViewControllerAnimated:movieplayer];
//    [movieplayer release];
//    
//    [player.view removeFromSuperview];
//    [player release];
//    player = nil;
//
//}



- (void)showComments:(UIButton *)btn{
    [vcPop release];
    tvFoodComment = nil;
    vCommentFood = nil;
    btnCCC = (UIButtonEx *)btn;
    
    UIViewController *vcComments = [[UIViewController alloc] init];
    vcPop = [[UIPopoverController alloc] initWithContentViewController:vcComments];
    [vcPop setPopoverContentSize:CGSizeMake(435, 700)];
    [vcComments release];
    UITableView *tv = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 435, 700)];
    tv.delegate = self;
    tv.dataSource = self;
    [vcComments.view addSubview:tv];
    [tv release];
    
    [vcPop presentPopoverFromRect:btn.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}

#pragma mark -
#pragma mark UITableView Data Source & Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (0==indexPath.row){
        static NSString *identifier2 = @"CommentIdentifier";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier2];
        
        if (!cell){
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier2] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            BSCommentView *vcomment = [[BSCommentView alloc] initWithFrame:CGRectMake(10, 5, 0, 0)];
            vcomment.userInteractionEnabled = YES;
            [cell.contentView addSubview:vcomment];
            [vcomment release];
            vcomment.tag = 1111;
            
            UITextView *tv = [[UITextView alloc] initWithFrame:CGRectMake(10, 5+31+5, vcomment.frame.size.width, 50)];
            tv.layer.cornerRadius = 5;
            tv.layer.borderColor = [UIColor blackColor].CGColor;
            tv.layer.borderWidth = 1;
            [cell.contentView addSubview:tv];
            [tv release];
            tv.tag = 999;
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            btn.frame = CGRectMake(167, 100, 100, 35);
            [btn setTitle:@"评论菜品" forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(commentFood) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:btn];
            
        }
        
        tvFoodComment = (UITextView  *)[cell.contentView viewWithTag:999];
        vCommentFood = (BSCommentView *)[cell.contentView viewWithTag:1111];
        
        return cell;
        
    }else{
        static NSString *identifer = @"CellIdentifier";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
        
        if (!cell){
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer] autorelease];
            
            BSCommentView *vcomment = [[BSCommentView alloc] initWithFrame:CGRectMake(10, 10, 0, 0)];
            vcomment.userInteractionEnabled = NO;
            [cell.contentView addSubview:vcomment];
            [vcomment release];
            vcomment.tag = 100;
            
            UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectZero];
            [cell.contentView addSubview:lbl];
            [lbl release];
            lbl.tag = 201;
            
        }
        
        
        BSCommentView *vcomment = (BSCommentView *)[cell.contentView viewWithTag:100];
        UILabel *lbl = (UILabel *)[cell.contentView viewWithTag:201];
        
        NSDictionary *dict = [aryDict objectAtIndex:currentPage];
        NSArray *arycomments = [dict objectForKey:@"comments"];
        
        lbl.text = [[arycomments objectAtIndex:indexPath.row-1] objectForKey:@"comment"];
        if ([lbl.text length]==0)
            lbl.text = @"评论:";
        else
            lbl.text = [NSString stringWithFormat:@"评论:%@",lbl.text];
        
        int lines = floorf([lbl.text sizeWithFont:lbl.font].width/(vcomment.frame.size.width+20)+0.5f)+1;
        lbl.frame = CGRectMake(10, 10+vcomment.frame.size.height+10, vcomment.frame.size.width,[lbl.text sizeWithFont:lbl.font].height*lines);
        
        vcomment.level = [[[arycomments objectAtIndex:indexPath.row-1] objectForKey:@"level"] intValue];
        
        return cell;
    }
    
    
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSDictionary *dict = [aryDict objectAtIndex:currentPage];
    NSArray *arycomments = [dict objectForKey:@"comments"];
    
    return [arycomments count]+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (0==indexPath.row)
        return 140;
    
    NSDictionary *dict = [aryDict objectAtIndex:currentPage];
    NSArray *arycomments = [dict objectForKey:@"comments"];
    
    NSString *text = [[arycomments objectAtIndex:indexPath.row-1] objectForKey:@"comment"];
    if ([text length]==0)
        text = @"评论:";
    else
        text = [NSString stringWithFormat:@"评论:%@",text];
    
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:17]];

    int lines = floorf(size.width/(32*5+2*4)+0.5f)+1;
    
    return (20+31+size.height*lines);

}


- (void)commentFood{
    NSString *comment = tvFoodComment.text;
    NSString *level = [NSString stringWithFormat:@"%d",vCommentFood.level];
    NSString *itcode = [[aryDict objectAtIndex:currentPage] objectForKey:@"ITCODE"];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:comment,@"comment",level,@"level",itcode,@"itcode", nil];
    
    BOOL b = [[BSDataProvider sharedInstance] pCommentFood:dict];
    
    
    if (b){
        NSMutableDictionary *mut = [aryDict objectAtIndex:currentPage];
        NSMutableArray *mutary = [NSMutableArray arrayWithArray:[mut objectForKey:@"comments"]];
        [mutary insertObject:dict atIndex:0];
        [mut setObject:mutary forKey:@"comments"];
        
        [vcPop dismissPopoverAnimated:YES];
        
        
        
        UIButtonEx *btnComment = btnCCC;


        NSArray *comments = mutary;
        
        UILabel *lbl = (UILabel *)[btnComment viewWithTag:3333];
        lbl.text = [NSString stringWithFormat:@"%d份评价",[comments count]];
        
        int dlevel = 0;
        for (NSDictionary *comment in comments){
            dlevel += [[comment objectForKey:@"level"] intValue];
        }
        dlevel = floorf(dlevel/[comments count]+0.5f);
        
        BSCommentView *vComment = (BSCommentView *)[btnComment viewWithTag:444];
        if ([comments count]>0)
            vComment.level = dlevel;
        else
            vComment.level = 0;
        
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"发送评论失败,请稍候再重试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
    

    
}

- (void)share{
    if (!vLogin){
        vLogin = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 1004)];
        vLogin.backgroundColor = [UIColor clearColor];[UIColor colorWithWhite:0 alpha:0.4f];
        vLogin.hidden = YES;
        [self.view addSubview:vLogin];
        [vLogin release];
        
        UIImageView *imgv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 420, 260)];
        imgv.center = CGPointMake(384, 502);
        [vLogin addSubview:imgv];
        [imgv release];
        imgv.userInteractionEnabled = YES;
        imgv.backgroundColor = [UIColor colorWithWhite:.96 alpha:1];
        imgv.layer.cornerRadius = 10;
        imgv.layer.borderWidth = 1;
        imgv.layer.borderColor = [UIColor blackColor].CGColor;
//        imgv.layer.shadowOpacity = 0.5f;
//        imgv.layer.shadowOffset = CGSizeMake(5, 5);
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 420, 30)];
        lbl.textAlignment = UITextAlignmentCenter;
        lbl.backgroundColor = [UIColor clearColor];
        lbl.font = [UIFont boldSystemFontOfSize:22];
        [imgv addSubview:lbl];
        [lbl release];
        lbl.text = @"登陆新浪微博";
        
        lbl = [[UILabel alloc] initWithFrame:CGRectMake(40, 80, 100, 25)];
        lbl.backgroundColor = [UIColor clearColor];
        lbl.font = [UIFont systemFontOfSize:18];
        lbl.text = @"新浪账号:";
        [imgv addSubview:lbl];
        [lbl release];
        
        lbl = [[UILabel alloc] initWithFrame:CGRectMake(40, 125, 100, 25)];
        lbl.backgroundColor = [UIColor clearColor];
        lbl.font = [UIFont systemFontOfSize:18];
        lbl.text = @"登陆密码:";
        [imgv addSubview:lbl];
        [lbl release];
        
        UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(125, 80, 200, 25)];
        tf.borderStyle = UITextBorderStyleRoundedRect;
        [imgv addSubview:tf];
        [tf release];
        tf.font = [UIFont systemFontOfSize:15];
        tf.placeholder = @"邮箱、用户名或手机号码";
        
        tf = [[UITextField alloc] initWithFrame:CGRectMake(125, 125, 200, 25)];
        tf.borderStyle = UITextBorderStyleRoundedRect;
        [imgv addSubview:tf];
        [tf release];
        tf.font = [UIFont systemFontOfSize:15];
        tf.placeholder = @"6-18位数字、符号和字母的组合";
        
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(80, 190, 110, 32);
        btn.backgroundColor = [UIColor whiteColor];
        btn.layer.cornerRadius = 5;
        btn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        btn.layer.borderWidth = 1;
        [btn setTitle:@"登陆" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [imgv addSubview:btn];
        
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(230, 190, 110, 32);
        btn.backgroundColor = [UIColor whiteColor];
        btn.layer.cornerRadius = 5;
        btn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        btn.layer.borderWidth = 1;
        [btn setTitle:@"取消" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(removeLoginWindow) forControlEvents:UIControlEventTouchUpInside];
        [imgv addSubview:btn];
        
    }
    
    vLogin.alpha = 0;
    vLogin.hidden = NO;
    [UIView animateWithDuration:0.3f animations:^{
        vLogin.alpha = 1; 
    }];
}

- (void)removeLoginWindow{
    [UIView animateWithDuration:0.3f animations:^{
        vLogin.alpha = 0; 
    }completion:^(BOOL finished) {
        vLogin.hidden = YES;
    }];
}


@end
