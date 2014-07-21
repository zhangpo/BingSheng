//
//  BookSystemViewController.m
//  BookSystem
//
//  Created by Dream on 11-3-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BookSystemViewController.h"
#import "BSMainMenu.h"
#import "BSDataProvider.h"
#import "BSTCategoryDetailView.h"
#import "BSTCoverView.h"
#import "BSTFoodDetailView.h"
#import "BSTRecommandView.h"
#import "BSTAdView.h"
#import "BSTSuitView.h"
#import "BSTFoodListView.h"
#import "BSTCategoryListView.h"
#import "BSConfigurationViewController.h"
#import "SVProgressHUD.h"

@implementation BookSystemViewController

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [scvContent release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    [scvContent clearInvisiblePage];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([[[UIDevice currentDevice] systemVersion]floatValue]>=7.0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
//        viewController.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
        self.navigationController.navigationBar.translucent = NO;
        [self setNeedsStatusBarAppearanceUpdate];
    }
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    bActivated = [[BSDataProvider sharedInstance] activated];//激活
    bActivated=YES;
//    timerADs = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(updateADs) userInfo:nil repeats:YES];

    [self.navigationController setNavigationBarHidden:YES];
//    self.view.frame = CGRectMake(0, 0, 768, 1004);
    self.view.backgroundColor = [UIColor blackColor];
    
    NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docPath = [docPaths objectAtIndex:0];
    
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:[docPath stringByAppendingPathComponent:@"cover.png"]];
    
    imgvCover = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 768, 1004)];
    imgvCover.backgroundColor = [UIColor blackColor];
//    [imgvCover setImage:img];
    [img release];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    lbl.backgroundColor = [UIColor clearColor];

    lbl.font = [UIFont boldSystemFontOfSize:22];
    lbl.text = @"正在生成缓存文件，请稍候";
    lbl.textColor = [UIColor whiteColor];
    [lbl sizeToFit];
    lbl.center = CGPointMake(384, 702);
    [imgvCover addSubview:lbl];
    [lbl release];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [indicator startAnimating];
    indicator.center = CGPointMake(384, 512);
    [imgvCover addSubview:indicator];
    [indicator release];
    
    [self.view addSubview:imgvCover];
    [imgvCover release];
    

    
    
    [NSThread detachNewThreadSelector:@selector(downloading) toTarget:self withObject:nil];
    
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSubMenu:) name:@"JumpToSubMenu" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showContent:) name:@"JumpToContent" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSetting) name:@"ShowSetting" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showFoodDetailView:) name:@"ShowFoodDetail" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showClassDetailView:) name:@"ShowClassDetail" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCategoryDetail:) name:@"ShowCategoryDetail" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jumpToPage:) name:@"JumpToPage" object:nil];

//	EPGLDemo *demo = [[EPGLDemo alloc] init];
//	demo.view.frame = CGRectMake(0, 0, 768, 1004);
//	[self.view addSubview:demo.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageConfigChanged) name:@"PageConfigChanged" object:nil];
    
    if (bActivated)
        [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(refreshRecommendList) userInfo:nil repeats:YES];
}

- (void)refreshRecommendList{
    if (!isRefreshRecommendList){
        isRefreshRecommendList = YES;
        [NSThread detachNewThreadSelector:@selector(refreshRecommend) toTarget:self withObject:nil];
    }
    
}

- (void)refreshRecommend{
    @autoreleasepool {
        [[BSDataProvider sharedInstance] updateRecommendList];
        
        isRefreshRecommendList = NO;
    }
}

- (void)pageConfigChanged{
    scvContent.userInteractionEnabled = NO;
    
    NSArray *oldary = [[[BSDataProvider sharedInstance] allPages] retain];
    [BSDataProvider reloadCurrentPageConfig];
    
    int currentIndex = dCurrentIndex;
    int newIndex = dCurrentIndex;
    int first = -1;
    int last = -1;
    for (int i=0;i<oldary.count;i++){
        if ([[[oldary objectAtIndex:i] objectForKey:@"type"] isEqualToString:@"推荐菜"]){
            if (-1==first)
                first = i;
            last = i;
        }
    }
    [oldary release];
    
    NSArray *ary = [[BSDataProvider sharedInstance] allPages];
    if (currentIndex>last){
        int delta = currentIndex-last;
        int index = -1;
        
        
        for (int i=0;i<ary.count;i++){
            if ([[[ary objectAtIndex:i] objectForKey:@"type"] isEqualToString:@"推荐菜"])
                index = i;
        }
        newIndex = index+delta;
        
    }else if (currentIndex>=first && currentIndex<=last){
        int newfirst = -1;
        int newlast = -1;
        for (int i=0;i<ary.count;i++){
            if ([[[ary objectAtIndex:i] objectForKey:@"type"] isEqualToString:@"推荐菜"]){
                if (-1==newfirst)
                    newfirst = i;
                newlast = i;
            }
        }
        
        if (!(currentIndex>=newfirst && currentIndex<=newlast))
            newIndex = 0;
    }else
        newIndex = 0;
    
    viewType = BSViewTypeClassDetail;
    ary = BSViewTypeClassDetail==viewType?[[BSDataProvider sharedInstance] allPages]:[[BSDataProvider sharedInstance] allDetailPages];
    scvContent.pageCount = ary.count;
    
    [scvContent reloadData];
    [scvContent turnToPage:BSViewTypeClassDetail==viewType?newIndex:currentIndex];
    
    scvContent.userInteractionEnabled = YES;
}

- (void)jumpToPage:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    
    int page = [[userInfo objectForKey:@"page"] intValue];
    [self reloadTemplateViewsWithIndex:page viewType:BSViewTypeClassDetail];
}

- (void)downloading{
    @autoreleasepool {
        BSDataProvider *dp = [BSDataProvider sharedInstance];
        
        //    [dp pChucki:nil];
        [dp getCachedFile];
        
        bs_dispatch_sync_on_main_thread(^{
            if (bActivated){
                [imgvCover removeFromSuperview];
                NSArray *ary = viewType==BSViewTypeClassDetail?[[BSDataProvider sharedInstance] allPages]:[[BSDataProvider sharedInstance] allDetailPages];
                
                scvContent = [[ABScrollPageView alloc] initWithFrame:CGRectMake(0,0, 768, 1004)];
                scvContent.pageControl.hidden = YES;
                [self.view addSubview:scvContent];
                
                scvContent.pageCount = [ary count];
                [scvContent setDelegate:self];
                [scvContent performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                [self.view bringSubviewToFront:vRecommendGrid];
                //        for (int i=0;i<ary.count;i++)
                //            [scvContent loadPage:i];
                
                vMenu = [[BSMenuView alloc] initWithFrame:CGRectMake(0, 0, 768, 45)];
                [self.view addSubview:vMenu];
                [vMenu release];
                vMenu.delegate = self;
                vMenu.hidden = YES;
//                    [self showMenu];
                NSDictionary *buttonConfig = [[BSDataProvider sharedInstance] buttonConfig];
                NSDictionary *resourceConfig = [[BSDataProvider sharedInstance] resourceConfig];
                btnLog = [UIButton buttonWithType:UIButtonTypeCustom];
                [btnLog setBackgroundImage:[UIImage imageWithContentsOfFile:[[[resourceConfig objectForKey:@"button"] objectForKey:@"log"] documentPath]] forState:UIControlStateNormal];
                [btnLog addTarget:self action:@selector(showLog) forControlEvents:UIControlEventTouchUpInside];
//                btnLog.frame = CGRectFromString([buttonConfig objectForKey:@"log"]);
                btnLog.frame =CGRectMake(510, 55, 97, 42);
                [self.view addSubview:btnLog];
                btnLog.hidden = YES;
                btnLog.titleLabel.font = [UIFont systemFontOfSize:15];
                //    btnLog.layer.shadowColor = [UIColor redColor].CGColor;
                //    btnLog.layer.shadowOpacity = 0.5f;
                //    btnLog.layer.shadowOffset = CGSizeMake(0, 0);
                
                btnQuery = [UIButton buttonWithType:UIButtonTypeCustom];
                [btnQuery setBackgroundImage:[UIImage imageWithContentsOfFile:[[[resourceConfig objectForKey:@"button"] objectForKey:@"query"] documentPath]] forState:UIControlStateNormal];
                [btnQuery addTarget:self action:@selector(showQuery) forControlEvents:UIControlEventTouchUpInside];
//                btnQuery.frame = CGRectFromString([buttonConfig objectForKey:@"query"]);
                btnQuery.frame = CGRectMake(630, 55, 97, 42);
                [self.view addSubview:btnQuery];
                btnQuery.hidden = YES;
                btnQuery.titleLabel.font = [UIFont systemFontOfSize:15];
            }else{
                NSDictionary *dict = [[BSDataProvider sharedInstance] allPages].count>0?[[[BSDataProvider sharedInstance] allPages] objectAtIndex:0]:nil;
                
                BSTemplate *vTemplate = nil;
                if (dict){
                    NSString *type = [dict objectForKey:@"type"];
                    //        if ([type isEqualToString:@"类别"]){
                    //            vTemplate = (BSTemplate *)[[[BSTCategoryDetailView alloc] initWithFrame:CGRectMake(0, 0, 768, 1004) info:dict] autorelease];
                    //        }else
                    if ([type isEqualToString:@"封面"]){
                        vTemplate = (BSTemplate *)[[[BSTCoverView alloc] initWithFrame:CGRectMake(0, 0, 768, 1004) info:dict] autorelease];
                    }else if ([type isEqualToString:@"类别列表"]){
                        vTemplate = (BSTemplate *)[[[BSTCategoryListView alloc] initWithFrame:CGRectMake(0, 0, 768, 1004) info:dict] autorelease];
                    }
                    else if ([type isEqualToString:@"广告"]){
                        vTemplate = (BSTemplate *)[[[BSTAdView alloc] initWithFrame:CGRectMake(0, 0, 768, 1004) info:dict] autorelease];
                    }else if ([type isEqualToString:@"推荐菜"]){
                        vTemplate = (BSTemplate *)[[[BSTRecommandView alloc] initWithFrame:CGRectMake(0, 0, 768, 1004) info:dict] autorelease];
                    }else if ([type isEqualToString:@"套餐"]){
                        vTemplate = (BSTemplate *)[[[BSTSuitView alloc] initWithFrame:CGRectMake(0, 0, 768, 1004) info:dict] autorelease];
                    }else if ([type isEqualToString:@"菜品列表"]){
                        vTemplate = (BSTemplate *)[[[BSTFoodListView alloc] initWithFrame:CGRectMake(0, 0, 768, 1004) info:dict] autorelease];
                    }else if ([type isEqualToString:@"菜品详情"]){
                        vTemplate = (BSTemplate *)[[[BSTFoodDetailView alloc] initWithFrame:CGRectMake(0, 0, 768, 1004) info:dict] autorelease];
                    }
                    vTemplate.bActivated = bActivated;
                    vTemplate.vcParent = self;
                    
                    [self.view addSubview:vTemplate];
                    [vTemplate release];
                }
            }
            
            
        });
    }
}


- (void)showLog{
    BSLogViewController *vcMyMenu = [[BSLogViewController alloc] init];
//    vcMyMenu.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//    [self presentModalViewController:vcMyMenu animated:YES];
    [self.navigationController pushViewController:vcMyMenu animated:YES];
    [vcMyMenu release];
}

- (void)showQuery{
    BSQueryViewController *vcQuery = [[BSQueryViewController alloc] init];
//    vcQuery.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//    [self presentModalViewController:vcQuery animated:YES];
    [self.navigationController pushViewController:vcQuery animated:YES];
    [vcQuery release];
}
     
#pragma mark - ABScrollPageView Delegate
- (UIView *)scrollPageView:(id)scrollPageView viewForPageAtIndex:(NSUInteger)index{
    NSLog(@"[%@ %@]:%d",NSStringFromClass([self class]),NSStringFromSelector(_cmd),index);
    BSTemplate *vTemplate = (BSTemplate *)[(ABScrollPageView *)scrollPageView dequeueReusablePage:index];
    if (!vTemplate){
        NSArray *ary = viewType==BSViewTypeClassDetail?[[BSDataProvider sharedInstance] allPages]:[[BSDataProvider sharedInstance] allDetailPages];
        NSDictionary *dict = [ary objectAtIndex:index];
        NSString *type = [dict objectForKey:@"type"];
//        if ([type isEqualToString:@"类别"]){
//            vTemplate = (BSTemplate *)[[[BSTCategoryDetailView alloc] initWithFrame:CGRectMake(0, 0, 768, 1004) info:dict] autorelease];
//        }else 
        if ([type isEqualToString:@"封面"]){
            vTemplate = (BSTemplate *)[[[BSTCoverView alloc] initWithFrame:CGRectMake(0, 0, 768, 1004) info:dict] autorelease];
        }else if ([type isEqualToString:@"类别列表"]){
            vTemplate = (BSTemplate *)[[[BSTCategoryListView alloc] initWithFrame:CGRectMake(0, 0, 768, 1004) info:dict] autorelease];
        }
        else if ([type isEqualToString:@"广告"]){
            vTemplate = (BSTemplate *)[[[BSTAdView alloc] initWithFrame:CGRectMake(0, 0, 768, 1004) info:dict] autorelease];
        }else if ([type isEqualToString:@"推荐菜"]){
            vTemplate = (BSTemplate *)[[[BSTRecommandView alloc] initWithFrame:CGRectMake(0, 0, 768, 1004) info:dict] autorelease];
        }else if ([type isEqualToString:@"套餐"]){
            vTemplate = (BSTemplate *)[[[BSTSuitView alloc] initWithFrame:CGRectMake(0, 0, 768, 1004) info:dict] autorelease];
        }else if ([type isEqualToString:@"菜品列表"]){
            vTemplate = (BSTemplate *)[[[BSTFoodListView alloc] initWithFrame:CGRectMake(0, 0, 768, 1004) info:dict] autorelease];
        }else if ([type isEqualToString:@"菜品详情"]){
            vTemplate = (BSTemplate *)[[[BSTFoodDetailView alloc] initWithFrame:CGRectMake(0, 0, 768, 1004) info:dict] autorelease];
        }
        vTemplate.bActivated = bActivated;
        vTemplate.vcParent = self;
    }
    
    return vTemplate;
}

- (void)showPage:(NSUInteger)index{
    [scvContent turnToPage:index];
}

- (void)didScrollToPageAtIndex:(NSUInteger)index{
    dCurrentIndex = index;
    
    NSArray *ary = BSViewTypeClassDetail==viewType?[[BSDataProvider sharedInstance] allPages]:[[BSDataProvider sharedInstance] allDetailPages];
    if (index<ary.count){
        NSDictionary *pageInfo = [ary objectAtIndex:index];
        
        NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentPageConfig"];
        
        [[NSUserDefaults standardUserDefaults] setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentPageConfig"] forKey:@"CurrentPageConfig"];
        if ([[dic objectForKey:@"layout"] isEqualToString:@"PageConfig_zxtf.plist"] && index != 0) {
            
            NSString *classid = [pageInfo objectForKey:@"classid"];
            for (int i=0;i<[vMenu.aryClass count];i++){
                if ([classid isEqualToString:[[vMenu.aryClass objectAtIndex:i] objectForKey:@"classid"]]){
                    [vMenu changeButtonIndex:i];
                }
            }
            vMenu.hidden = NO;
        }else{
            vMenu.hidden = YES;
        }

//        if (![[pageInfo objectForKey:@"hideMenu"] boolValue]){
//            vMenu.hidden = NO;
//            NSString *classid = [pageInfo objectForKey:@"classid"];
//            for (int i=0;i<[vMenu.aryClass count];i++){
//                if ([classid isEqualToString:[[vMenu.aryClass objectAtIndex:i] objectForKey:@"classid"]]){
//                    [vMenu changeButtonIndex:i];
//                }
//            }
//        }
//        else
//            vMenu.hidden = YES;
        
        NSString *pagetype = [pageInfo objectForKey:@"type"];
        if (![pagetype isEqualToString:@"菜品列表"] && ![pagetype isEqualToString:@"菜品详情"])
            [vMenu deselectMenu];
        
        btnLog.hidden = !(![[pageInfo objectForKey:@"hideButton"] boolValue] && bActivated);
        btnQuery.hidden = btnLog.hidden;
        if (index != 0) {
            vMenu.hidden = NO;
            btnLog.hidden = NO;
            btnQuery.hidden = btnLog.hidden;
        }
        
    }
}

- (void)reloadTemplateViewsWithIndex:(NSInteger)index viewType:(BSViewType)vt{
    if (viewType!=vt){
        viewType = vt;
        NSArray *ary = BSViewTypeClassDetail==viewType?[[BSDataProvider sharedInstance] allPages]:[[BSDataProvider sharedInstance] allDetailPages];
        scvContent.pageCount = ary.count;
        [scvContent reloadData];
    }
    
    if (BSViewTypeClassDetail==viewType){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showFoodDetailView:) name:@"ShowFoodDetail" object:nil];

    }
    [scvContent turnToPage:index];
    
}

- (void)showFoodDetailView:(NSNotification *)notification{
    
    
    NSDictionary *food = [notification userInfo];
    int index = 0;
    NSArray *ary = [[BSDataProvider sharedInstance] allDetailPages];
    for (int i=0;i<[ary count];i++){
        if ([[[ary objectAtIndex:i] objectForKey:@"ITCODE"] isEqualToString:[food objectForKey:@"ITCODE"]]){
            index = i;
        }
    }
    
    [self reloadTemplateViewsWithIndex:index viewType:BSViewTypeFoodDetail];
}


- (void)showClassDetailView:(NSNotification *)notification{
    NSDictionary *food = [notification userInfo];
    
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    NSArray *ary = [dp pageList];

    

    int index = 0;
    
    for (int i=0;i<[ary count];i++){
        NSDictionary *dict = [ary objectAtIndex:i];
        
        if ([[dict objectForKey:@"type"] isEqualToString:@"菜品列表"]){
            NSArray *foods = [dict objectForKey:@"foods"];

            for (NSDictionary *foodinlist in foods){
                if ([[foodinlist objectForKey:@"ITCODE"] isEqualToString:[food objectForKey:@"ITCODE"]])
                    index = i;
            }
            
             
        }
    }
    
    [self reloadTemplateViewsWithIndex:index viewType:BSViewTypeClassDetail];
}


- (void)showCategoryDetail:(NSNotification *)notification{
    NSDictionary *foodInfo = [notification userInfo];
    NSDictionary *classdict = [[BSDataProvider sharedInstance] getClassByID:[[notification userInfo] objectForKey:@"classid"]];
    
    BOOL isBig = [[classdict objectForKey:@"isbig"] boolValue];
    BSViewType vt = isBig?BSViewTypeFoodDetail:BSViewTypeClassDetail;
    int index = -1;
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    NSArray *ary = isBig?[dp allDetailPages]:[dp pageList];
    
    if (isBig){
        for (int i=0;i<[ary count];i++){
            NSDictionary *dict = [ary objectAtIndex:i];
            
            if ([[dict objectForKey:@"type"] isEqualToString:@"菜品列表"]){
                NSArray *foods = [dict objectForKey:@"foods"];
                
                for (NSDictionary *foodinlist in foods){
                    NSDictionary *fooddetail = [dp getFoodByCode:[foodinlist objectForKey:@"ITCODE"]];
                    if ([[fooddetail objectForKey:@"GRPTYP"] isEqualToString:[classdict objectForKey:@"classid"]]){
                        index = i;
                        break;
                    }
                }
            }
            if (index>0)
                break;
        }
    }else{
        if (![foodInfo objectForKey:@"ITCODE"]){
            for (int i=0;i<[ary count];i++){
                NSDictionary *dict = [ary objectAtIndex:i];
                if ([[dict objectForKey:@"type"] isEqualToString:@"菜品列表"] && [[dict objectForKey:@"classid"] isEqualToString:[foodInfo objectForKey:@"classid"]]){
                    index = i;
                    break;
                }
            }
        }else{
            for (int i=0;i<[ary count];i++){
                NSDictionary *dict = [ary objectAtIndex:i];
                if ([[dict objectForKey:@"type"] isEqualToString:@"菜品列表"]){
                    NSArray *foods = [dict objectForKey:@"foods"];
                    for (NSDictionary *foodinlist in foods){
                        NSString *itcode = [[[foodinlist objectForKey:@"ITCODE"] componentsSeparatedByString:@","] objectAtIndex:0];
                        if ([itcode isEqualToString:[foodInfo objectForKey:@"ITCODE"]]){
                            index = i;
                            break;
                        }
                    }
                }
                if (index>0)
                    break;
            }
        }
        
    }
    
    if (index>0)
        [self reloadTemplateViewsWithIndex:index viewType:vt];
}

- (void)showRecommendGrid:(NSNotification *)notification{
    NSArray *ary = [[notification userInfo] objectForKey:@"foods"];
    vRecommendGrid.aryFoods = ary;
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
    return (UIInterfaceOrientationPortrait==interfaceOrientation || UIInterfaceOrientationPortraitUpsideDown==interfaceOrientation);
}


- (void)showSetting{
    BSConfigurationViewController *vcConfiguration = [[BSConfigurationViewController alloc] init];
    UINavigationController *vcNav = [[UINavigationController alloc] initWithRootViewController:vcConfiguration];
    [vcConfiguration release];
    vcNav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:vcNav animated:YES];
    [vcNav release];
}
@end
