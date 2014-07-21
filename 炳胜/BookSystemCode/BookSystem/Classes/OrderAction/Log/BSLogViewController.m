//
//  BSLogViewController.m
//  BookSystem
//
//  Created by Dream on 11-5-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BSLogViewController.h"
#import "CVLocalizationSetting.h"
#import "BSTableViewController.h"
#import "SVProgressHUD.h"
#import "BSCacheViewController.h"
#import "BSHistoryViewController.h"


@implementation BSLogViewController
{
    NSString *_fileName;
    NSString *_table;
    BOOL _isSave;
}

@synthesize aryCommon,arySelectedFood;
@synthesize strUser;
@synthesize aryUploading;



- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.aryUploading = nil;
    self.strUser = nil;
    self.arySelectedFood = nil;
    [_table release];
    
    [popSearch release];
    [footerView release];
    footerView = nil;
    [vHeader release];
    vHeader = nil;
    self.aryCommon = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark -  Upload Using FTP
-(void) requestCompleted:(WRRequest *) request{
    CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    //called if 'request' is completed successfully
    NSLog(@"%@ completed!", request);
    [request release];
    
    BOOL bSucceed = YES;
    
    NSString *title;
    if (bSucceed){
        title = [langSetting localizedString:@"Send Succeeded"];//@"传菜成功";
    
        [BSDataProvider sharedInstance].userTable=nil;
        NSMutableArray *ary = [dp orderedFood];
        
        NSMutableArray *aryMut = [NSMutableArray arrayWithArray:ary];
        int count = [ary count];
        NSMutableArray *arry1=[NSMutableArray array];
        for (int i=0; i<count; i++) {
            NSDictionary *dic = [aryMut objectAtIndex:i];
            NSString *flag = [dic objectForKey:@"sendFlag"];
            if (![flag isEqualToString:@"0"]) {
                [arry1 addObject:dic];
//                [ary removeObject:dic];
            }
        }
        if (_isSave==NO) {
            [[BSDataProvider sharedInstance] historyFoods:arry1 withName:_table];
            _isSave=YES;
        }else
            _isSave=NO;
        
        for (int i=0; i<count; i++) {
            NSDictionary *dic = [aryMut objectAtIndex:i];
            NSString *flag = [dic objectForKey:@"sendFlag"];
            if (![flag isEqualToString:@"0"]) {
                [ary removeObject:dic];
            }
        }
        //        [ary removeAllObjects];
        [arySelectedFood removeAllObjects];
        [dp saveOrders];
        [tvOrder reloadData];
        [self performSelector:@selector(updateTitle)];
        self.aryCommon = [NSArray array];
    }
    else
        title = [langSetting localizedString:@"Send Failed"];//@"传菜失败";
    bs_dispatch_sync_on_main_thread(^{
        [SVProgressHUD showSuccessWithStatus:title];
    });
    
    
    //    [SVProgressHUD dismissWithSuccess:title afterDelay:2];
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
    //    [alert show];
    //    [alert release];
    
}

-(void) requestFailed:(WRRequest *) request{
    
    //called after 'request' ends in error
    //we can print the error message
    NSLog(@"%@", request.error.message);
    [request release];
    
    CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
    
    //called if 'request' is completed successfully
    NSLog(@"%@ completed!", request);
    [request release];
    
    NSString *title = [langSetting localizedString:@"Send Failed"];//@"传菜失败";
    
    //    [SVProgressHUD dismissWithError:title afterDelay:2];
    bs_dispatch_sync_on_main_thread(^{
        [SVProgressHUD showErrorWithStatus:title];
    });
    
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
    //    [alert show];
    //    [alert release];
    
}

-(BOOL) shouldOverwriteFileWithRequest:(WRRequest *)request {
    
    //if the file (ftp://xxx.xxx.xxx.xxx/space.jpg) is already on the FTP server,the delegate is asked if the file should be overwritten
    //'request' is the request that intended to create the file
    return YES;
    
}
- (void)uploadFood:(NSString *)str{
    bs_dispatch_sync_on_main_thread(^{
        NSString *settingPath = [@"setting.plist" documentPath];
        NSDictionary *didict= [NSDictionary dictionaryWithContentsOfFile:settingPath];
        NSString *ftpurl = nil;
        if (didict!=nil)
            ftpurl = [didict objectForKey:@"url"];
        
        if (!ftpurl)
            ftpurl = kPathHeader;
        WRRequestUpload *uploader = [[WRRequestUpload alloc] init];
        uploader.delegate = self;
        uploader.hostname = [ftpurl hostName];
        uploader.username = [[ftpurl account] objectForKey:@"username"];
        uploader.password = [[ftpurl account] objectForKey:@"password"];
        
        uploader.sentData = [str dataUsingEncoding:NSUTF8StringEncoding];
        NSString *filename = [NSString stringWithFormat:@"%@%lf",[NSString UUIDString],[[NSDate date] timeIntervalSince1970]];
        _fileName=filename;
        uploader.path = [NSString stringWithFormat:@"/orders/2/%@-%@.order",[[BSDataProvider sharedInstance] padID],[filename MD5]];
        [uploader start];
    });
}

- (void)uploadFoodToo:(NSString *)str{
    bs_dispatch_sync_on_main_thread(^{
        NSString *settingPath = [@"setting.plist" documentPath];
        NSDictionary *didict= [NSDictionary dictionaryWithContentsOfFile:settingPath];
        NSString *ftpurl = nil;
        if (didict!=nil)
            ftpurl = [didict objectForKey:@"url"];
        
        if (!ftpurl)
            ftpurl = kPathHeader;
        WRRequestUpload *uploader1 = [[WRRequestUpload alloc] init];
        uploader1.delegate = self;
        uploader1.hostname = [ftpurl hostName];
        uploader1.username = [[ftpurl account] objectForKey:@"username"];
        uploader1.password = [[ftpurl account] objectForKey:@"password"];
        
        uploader1.sentData = [str dataUsingEncoding:NSUTF8StringEncoding];
        
//        NSString *filename = [NSString stringWithFormat:@"%@%lf",[NSString UUIDString],[[NSDate date] timeIntervalSince1970]];
        
        uploader1.path = [NSString stringWithFormat:@"/orders/1/%@-%@.order",[[BSDataProvider sharedInstance] padID],[_fileName MD5]];
        [uploader1 start];
    });
}


#pragma mark - View lifecycle

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [BSDataProvider sharedInstance].userTable=nil;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.arySelectedFood = [NSMutableArray array];
    
    CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
    
    
    NSMutableDictionary *mut = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentOrder"]];
    [mut removeObjectForKey:@"name"];
    [[NSUserDefaults standardUserDefaults] setObject:mut forKey:@"CurrentOrder"];
    
    footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 688, 110)];
    footerView.backgroundColor = [UIColor clearColor];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSendtab:) name:msgSendTab object:nil];
    
    UIImageView *imgvBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 768, 1004)];
    UIImage *imgBG = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"logbg" ofType:@"png"]];
    [imgvBG setImage:imgBG];
    [imgBG release];
    [self.view addSubview:imgvBG];
    [imgvBG release];
    
    NSString *pathNormal = [[NSBundle mainBundle] pathForResource:@"cv_rotation_normal_button" ofType:@"png"];
    NSString *pathSelected = [[NSBundle mainBundle] pathForResource:@"cv_rotation_highlight_button" ofType:@"png"];
    UIImage *imgNormal = [[UIImage alloc] initWithContentsOfFile:pathNormal];
    UIImage *imgSelected = [[UIImage alloc] initWithContentsOfFile:pathSelected];
    //    139 54 50, 23, 100, 20)
    
    
    btnQuanXuan = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnQuanXuan setBackgroundImage:imgNormal forState:UIControlStateNormal];
    [btnQuanXuan sizeToFit];
    [btnQuanXuan setBackgroundImage:imgSelected forState:UIControlStateHighlighted];
    [btnQuanXuan setTitle:@"全选/反选" forState:UIControlStateNormal];
    [btnQuanXuan setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnQuanXuan.titleLabel.font = [UIFont systemFontOfSize:13];
    btnQuanXuan.titleEdgeInsets = UIEdgeInsetsMake(23, 30, 11, 30);
    [btnQuanXuan addTarget:self action:@selector(quanClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnQuanXuan];
    
    btnCache = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnCache setBackgroundImage:imgNormal forState:UIControlStateNormal];
    [btnCache sizeToFit];
    [btnCache setBackgroundImage:imgSelected forState:UIControlStateHighlighted];
    [btnCache setTitle:@"菜品缓存" forState:UIControlStateNormal];
    [btnCache setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnCache.titleLabel.font = [UIFont systemFontOfSize:13];
    btnCache.titleEdgeInsets = UIEdgeInsetsMake(23, 30, 11, 30);
    [btnCache addTarget:self action:@selector(cacheClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnCache];
    
    btnTable = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnTable setBackgroundImage:imgNormal forState:UIControlStateNormal];
    [btnTable setBackgroundImage:imgSelected forState:UIControlStateHighlighted];
    [btnTable sizeToFit];
    [btnTable addTarget:self action:@selector(tableClicked) forControlEvents:UIControlEventTouchUpInside];
    
    btnSend = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSend setBackgroundImage:imgNormal forState:UIControlStateNormal];
    [btnSend setBackgroundImage:imgSelected forState:UIControlStateHighlighted];
    [btnSend sizeToFit];
    [btnSend addTarget:self action:@selector(sendClicked) forControlEvents:UIControlEventTouchUpInside];
    UIButton *btnHistory = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnHistory setBackgroundImage:imgNormal forState:UIControlStateNormal];
    [btnHistory setBackgroundImage:imgSelected forState:UIControlStateHighlighted];
    [btnHistory sizeToFit];
    [btnHistory addTarget:self action:@selector(historyClicked) forControlEvents:UIControlEventTouchUpInside];
    
    
    btnCommon = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnCommon setBackgroundImage:imgNormal forState:UIControlStateNormal];
    [btnCommon setBackgroundImage:imgSelected forState:UIControlStateHighlighted];
    [btnCommon sizeToFit];
    [btnCommon addTarget:self action:@selector(commonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    
    btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack setBackgroundImage:imgNormal forState:UIControlStateNormal];
    [btnBack setBackgroundImage:imgSelected forState:UIControlStateHighlighted];
    [btnBack sizeToFit];
    [btnBack addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    [imgNormal release];
    [imgSelected release];
    
    //139 54
    
    //    btnSend.center = CGPointMake(384, 1004-27);
    //    btnTable.center = CGPointMake(btnSend.center.x-111, btnSend.center.y);
    //    btnCache.center = CGPointMake(btnSend.center.x-111*2, btnSend.center.y);
    //    btnCommon.center = CGPointMake(btnSend.center.x+111, btnSend.center.y);
    //    btnBack.center = CGPointMake(btnSend.center.x+111*2, btnSend.center.y);
    
    
    btnSend.center = CGPointMake(768/2, 1004-27);
    btnHistory.center=CGPointMake(btnSend.center.x+111, 1004-27);
    btnTable.center = CGPointMake(btnSend.center.x-111, 1004-27);
    btnCache.center = CGPointMake(btnTable.center.x-111, btnTable.center.y);
    btnQuanXuan.center = CGPointMake(btnTable.center.x-111*2, btnTable.center.y);
    btnCommon.center = CGPointMake(btnSend.center.x+111*2, btnSend.center.y);
    btnBack.center = CGPointMake(btnSend.center.x+111*3, btnSend.center.y);
    [self.view addSubview:btnTable];
    [self.view addSubview:btnSend];
    [self.view addSubview:btnHistory];
    [self.view addSubview:btnCommon];
    [self.view addSubview:btnBack];
    
    //    UILabel *lblQuan = [[UILabel alloc] initWithFrame:CGRectMake(50, 23, 100, 20)];
    //	lblQuan.backgroundColor = [UIColor clearColor];
    //	lblQuan.font = [UIFont boldSystemFontOfSize:13];
    //	lblQuan.textColor = [UIColor whiteColor];
    //	lblQuan.text = @"反选/全选";
    //	lblQuan.userInteractionEnabled = NO;
    //	[btnQuanXuan addSubview:lblQuan];
    //	[lblQuan release];
    
    UILabel *lblTable = [[UILabel alloc] initWithFrame:CGRectMake(50, 23, 100, 20)];
	lblTable.backgroundColor = [UIColor clearColor];
	lblTable.font = [UIFont boldSystemFontOfSize:13];
	lblTable.textColor = [UIColor whiteColor];
	lblTable.text = [langSetting localizedString:@"Table"];
	lblTable.userInteractionEnabled = NO;
	[btnTable addSubview:lblTable];
	[lblTable release];
    
    UILabel *labelNews = [[UILabel alloc] initWithFrame:CGRectMake(50, 23, 100, 20)];
	labelNews.backgroundColor = [UIColor clearColor];
	labelNews.font = [UIFont boldSystemFontOfSize:13];
	labelNews.textColor = [UIColor whiteColor];
	labelNews.text = [langSetting localizedString:@"Send"];
	labelNews.userInteractionEnabled = NO;
	[btnSend addSubview:labelNews];
	[labelNews release];
	
	UILabel *labelBalanceSheet = [[UILabel alloc] initWithFrame:CGRectMake(36, 23, 100, 20)];
	labelBalanceSheet.backgroundColor = [UIColor clearColor];
	labelBalanceSheet.font = [UIFont boldSystemFontOfSize:13];
	labelBalanceSheet.textColor = [UIColor whiteColor];
	labelBalanceSheet.text = [langSetting localizedString:@"Common Additions"];
	labelBalanceSheet.userInteractionEnabled = NO;
	[btnCommon addSubview:labelBalanceSheet];
	[labelBalanceSheet release];
	
	UILabel *labelIncomeStatement = [[UILabel alloc] initWithFrame:CGRectMake(50, 23, 100, 20)];
	labelIncomeStatement.backgroundColor = [UIColor clearColor];
	labelIncomeStatement.font = [UIFont boldSystemFontOfSize:13];
    //	labelIncomeStatement.textAlignment = UITextAlignmentCenter;
	labelIncomeStatement.textColor = [UIColor whiteColor];
	labelIncomeStatement.text = [langSetting localizedString:@"Back"];
	labelIncomeStatement.userInteractionEnabled = NO;
	[btnBack addSubview:labelIncomeStatement];
	[labelIncomeStatement release];
    UILabel *labelIncomeHistory = [[UILabel alloc] initWithFrame:CGRectMake(50, 23, 100, 20)];
	labelIncomeHistory.backgroundColor = [UIColor clearColor];
	labelIncomeHistory.font = [UIFont boldSystemFontOfSize:13];
    //	labelIncomeStatement.textAlignment = UITextAlignmentCenter;
	labelIncomeHistory.textColor = [UIColor whiteColor];
	labelIncomeHistory.text = @"历史账单";
	labelIncomeHistory.userInteractionEnabled = NO;
	[btnHistory addSubview:labelIncomeHistory];
	[labelIncomeHistory release];
    
    lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, 14, 900, 50)];
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.textColor = [UIColor whiteColor];
    lblTitle.font = [UIFont systemFontOfSize:17];
    [self.view addSubview:lblTitle];
    [lblTitle release];
    [self performSelector:@selector(updateTitle)];
    
    //    btnTemp = [UIButton buttonWithType:UIButtonTypeContactAdd];
    //    [btnTemp addTarget:self action:@selector(tempClicked) forControlEvents:UIControlEventTouchUpInside];
    //    btnTemp.center = CGPointMake(515, 38);
    //    [self.view addSubview:btnTemp];
    
    tvOrder = [[UITableView alloc] initWithFrame:CGRectMake(40, 75, 688, 890)];
    tvOrder.tableFooterView = footerView;
    tvOrder.delegate = self;
    tvOrder.dataSource = self;
    [self.view insertSubview:tvOrder belowSubview:btnSend];
    [tvOrder release];
    tvOrder.backgroundColor = [UIColor clearColor];
    
    //    CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
    if (!vHeader){
        vHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 688, 20)];
        
        UILabel *lblName = [[UILabel alloc] initWithFrame:CGRectMake(150-kNoPhotoOffset, 0, 145, 20)];
        lblName.textAlignment = UITextAlignmentCenter;
        lblName.backgroundColor = [UIColor clearColor];
        lblName.font = [UIFont boldSystemFontOfSize:16];
        lblName.text = [langSetting localizedString:@"FoodName"];
        [vHeader addSubview:lblName];
        [lblName release];
        UILabel *lblline = [[UILabel alloc] initWithFrame:CGRectMake(295-kNoPhotoOffset, 2, 2, 16)];
        lblline.backgroundColor = [UIColor blackColor];
        [vHeader addSubview:lblline];
        [lblline release];
        
        UILabel *lblCount = [[UILabel alloc] initWithFrame:CGRectMake(297-kNoPhotoOffset, 0, 110, 20)];
        lblCount.textAlignment = UITextAlignmentCenter;
        lblCount.backgroundColor = [UIColor clearColor];
        lblCount.font = [UIFont boldSystemFontOfSize:16];
        lblCount.text = [langSetting localizedString:@"Count"];
        [vHeader addSubview:lblCount];
        [lblCount release];
        lblline = [[UILabel alloc] initWithFrame:CGRectMake(407-kNoPhotoOffset, 2, 2, 16)];
        lblline.backgroundColor = [UIColor blackColor];
        [vHeader addSubview:lblline];
        [lblline release];
        
        UILabel *lblPrice = [[UILabel alloc] initWithFrame:CGRectMake(409-kNoPhotoOffset, 0, 80, 20)];
        lblPrice.textAlignment = UITextAlignmentCenter;
        lblPrice.backgroundColor = [UIColor clearColor];
        lblPrice.font = [UIFont boldSystemFontOfSize:16];
        lblPrice.text = [langSetting localizedString:@"Price"];;
        [vHeader addSubview:lblPrice];
        [lblPrice release];
        lblline = [[UILabel alloc] initWithFrame:CGRectMake(489-kNoPhotoOffset, 2, 2, 16)];
        lblline.backgroundColor = [UIColor blackColor];
        [vHeader addSubview:lblline];
        [lblline release];
        
        UILabel *lblUnit = [[UILabel alloc] initWithFrame:CGRectMake(491-kNoPhotoOffset, 0, 80, 20)];
        lblUnit.textAlignment = UITextAlignmentCenter;
        lblUnit.backgroundColor = [UIColor clearColor];
        lblUnit.font = [UIFont boldSystemFontOfSize:16];
        lblUnit.text = [langSetting localizedString:@"Unit"];
        [vHeader addSubview:lblUnit];
        [lblUnit release];
        lblline = [[UILabel alloc] initWithFrame:CGRectMake(573-kNoPhotoOffset, 2, 2, 16)];
        lblline.backgroundColor = [UIColor blackColor];
        [vHeader addSubview:lblline];
        [lblline release];
        
        UILabel *lblTotal = [[UILabel alloc] initWithFrame:CGRectMake(575-kNoPhotoOffset, 0, 80, 20)];
        lblTotal.textAlignment = UITextAlignmentCenter;
        lblTotal.backgroundColor = [UIColor clearColor];
        lblTotal.font = [UIFont boldSystemFontOfSize:16];
        lblTotal.text = [langSetting localizedString:@"Subtotal"];
        [vHeader addSubview:lblTotal];
        [lblTotal release];
        lblline = [[UILabel alloc] initWithFrame:CGRectMake(655-kNoPhotoOffset, 2, 2, 16)];
        lblline.backgroundColor = [UIColor blackColor];
        [vHeader addSubview:lblline];
        [lblline release];
        
        NSString *countpath = [[NSBundle mainBundle] pathForResource:@"LogCellCountBtn" ofType:@"png"];
        UIImage *img = [[UIImage alloc] initWithContentsOfFile:countpath];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.frame = CGRectMake(0, 0, 123, 20);
        [btn setBackgroundImage:img forState:UIControlStateNormal];
        [img release];
        [btn setTitle:[langSetting localizedString:@"DeleteAll"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(deleteAll) forControlEvents:UIControlEventTouchUpInside];
        [vHeader addSubview:btn];
        
        
        img = [UIImage imageWithContentsOfFile:countpath];
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.frame = CGRectMake(596, 0, 100, 20);
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        [btn setBackgroundImage:img forState:UIControlStateNormal];
        [btn setTitle:@"全部叫起/即起" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(selectAll) forControlEvents:UIControlEventTouchUpInside];
        [vHeader addSubview:btn];
    }
    
    tvOrder.tableHeaderView = vHeader;
    
    
    
    
    barSearch = [[UISearchBar alloc] initWithFrame:CGRectMake(545, 20, 190, 40)];
    barSearch.backgroundColor = [UIColor clearColor];
    barSearch.tintColor = [UIColor clearColor];
    //   barSearch.barStyle = UIBarStyleBlackTranslucent;
    barSearch.delegate = self;
    [self.view addSubview:barSearch];
    [barSearch release];
    
    BSSearchViewController *vcSearch = [[BSSearchViewController alloc] init];
    vcSearch.delegate = self;
    popSearch = [[UIPopoverController alloc] initWithContentViewController:vcSearch];
    [vcSearch release];
    [popSearch setPopoverContentSize:CGSizeMake(275, 360)];
    
    UIImageView *imgvCommon = [[UIImageView alloc] initWithFrame:CGRectMake(11, 870, 748, 90)];
    pathNormal = [[NSBundle mainBundle] pathForResource:@"CommonCover" ofType:@"png"];
    imgNormal = [[UIImage alloc] initWithContentsOfFile:pathNormal];
    [imgvCommon setImage:imgNormal];
    [imgNormal release];
    [self.view addSubview:imgvCommon];
    [imgvCommon release];
    
    lblCommon = [[UILabel alloc] initWithFrame:CGRectMake(35, 15+30, 733, 30)];
    lblCommon.backgroundColor = [UIColor clearColor];
    lblCommon.textColor = [UIColor whiteColor];
    lblCommon.font = [UIFont systemFontOfSize:14];
    [imgvCommon addSubview:lblCommon];
    [lblCommon release];
    lblCommon.text = [langSetting localizedString:@"Additions:"];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadFoods) name:@"RefreshOrderStatus" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShowed:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHidden:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)keyboardShowed:(NSNotification *)note{
    
    
    
    
    CGRect keyboardframe = [[[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    tvOrder.frame = CGRectMake(40, 75, 688, 890-keyboardframe.size.height+40);
    
    
    
    if (fEdittingCellPosition>tvOrder.contentOffset.y+tvOrder.frame.size.height)
        tvOrder.contentOffset = CGPointMake(0, fEdittingCellPosition-tvOrder.frame.size.height);
}

- (void)keyboardHidden:(NSNotification *)note{
    tvOrder.frame = CGRectMake(40, 75, 688, 890);
}

- (void)selectAll{
    if (arySelectedFood.count>0){
        [arySelectedFood removeAllObjects];
    }else{
        [arySelectedFood addObjectsFromArray:[[BSDataProvider sharedInstance] orderedFood]];
    }
    
    [tvOrder reloadData];
}
- (void)reloadFoods{
    
    [tvOrder reloadData];
    [self performSelector:@selector(updateTitle)];
}


- (void)cacheClicked{
    BSCacheViewController *vcCache = [[BSCacheViewController alloc] init];
    UINavigationController *vcNav = [[UINavigationController alloc] initWithRootViewController:vcCache];
    [vcCache release];
    vcNav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:vcNav animated:YES];
    [vcNav release];
}
- (void)historyClicked{
    BSHistoryViewController *vcCache = [[BSHistoryViewController alloc] init];
    UINavigationController *vcNav = [[UINavigationController alloc] initWithRootViewController:vcCache];
    [vcCache release];
    vcNav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:vcNav animated:YES];
    [vcNav release];
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
	return (UIInterfaceOrientationIsPortrait(interfaceOrientation));
}


- (NSArray *)seperatedByType:(NSArray *)foods{
    NSMutableDictionary *mut = [NSMutableDictionary dictionary];
    for (int i=0;i<foods.count;i++){
        NSDictionary *dict = [foods objectAtIndex:i];
        BOOL ispack = [[dict objectForKey:@"isPack"] boolValue];
        if (ispack){
            if (![mut objectForKey:@"pack"]){
                [mut setObject:[NSMutableArray array] forKey:@"pack"];
            }
            
            [[mut objectForKey:@"pack"] addObject:dict];
        }else{
            NSString *classid = [[dict objectForKey:@"food"] objectForKey:@"CLASS"];
            
            if (![mut objectForKey:classid]){
                [mut setObject:[NSMutableArray array] forKey:classid];
            }
            
            [[mut objectForKey:classid] addObject:dict];
        }
    }
    
    NSMutableArray *mutary = [NSMutableArray array];
    for (NSString *key in mut.allKeys){
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[mut objectForKey:key],@"foods",key,@"classid", nil];
        [mutary addObject:dic];
    }
    return [NSArray arrayWithArray:mutary];
}

#pragma mark -
#pragma mark TableView Delegate & DataSource


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"CellIdentifier";
    BSLogCell *cell = (BSLogCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell){
        cell = [[[BSLogCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
        cell.delegate = self;
    }
    
    cell.tag = indexPath.section*100+indexPath.row;
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    NSArray *ary = [self seperatedByType:[dp orderedFood]];
    NSDictionary *dic = [[[ary objectAtIndex:indexPath.section] objectForKey:@"foods"] objectAtIndex:indexPath.row];
    
    [cell setInfo:dic];
    cell.indexPath = indexPath;
    BOOL bInArray = NO;
    for (NSDictionary *food in arySelectedFood){
        if ([[food objectForKey:@"OrderTimeCount"] intValue]==[[cell.dicInfo objectForKey:@"OrderTimeCount"] intValue]){
            bInArray = YES;
            break;
        }
    }
    
    cell.bSelected = bInArray;
    
    
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    NSArray *ary = [self seperatedByType:[dp orderedFood]];
    
    return [ary count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    NSArray *ary = [[[self seperatedByType:[dp orderedFood]] objectAtIndex:section] objectForKey:@"foods"];
    
    return [ary count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    NSArray *ary = [self seperatedByType:[dp orderedFood]];
    NSString *classid = [[ary objectAtIndex:section] objectForKey:@"classid"];
    NSDictionary *dic = [dp getClassByID:classid];
    
    return [dic objectForKey:@"DES"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 110;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    BSLogCell *cell = (BSLogCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    BOOL bInArray = NO;
    NSDictionary *foodIn = nil;
    for (NSDictionary *food in arySelectedFood){
        if ([[food objectForKey:@"OrderTimeCount"] intValue]==[[cell.dicInfo objectForKey:@"OrderTimeCount"] intValue]){
            bInArray = YES;
            foodIn = food;
            break;
        }
    }
    
    if (bInArray){
        [arySelectedFood removeObject:foodIn];
        cell.bSelected = NO;
    }else {
        [arySelectedFood addObject:cell.dicInfo];
        cell.bSelected = YES;
    }
}
/*
 
 - (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
 CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
 if (!vHeader){
 vHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 688, 20)];
 
 UILabel *lblName = [[UILabel alloc] initWithFrame:CGRectMake(150, 0, 145, 20)];
 lblName.textAlignment = UITextAlignmentCenter;
 lblName.backgroundColor = [UIColor clearColor];
 lblName.font = [UIFont boldSystemFontOfSize:16];
 lblName.text = [langSetting localizedString:@"FoodName"];
 [vHeader addSubview:lblName];
 [lblName release];
 UILabel *lblline = [[UILabel alloc] initWithFrame:CGRectMake(295, 2, 2, 16)];
 lblline.backgroundColor = [UIColor blackColor];
 [vHeader addSubview:lblline];
 [lblline release];
 
 UILabel *lblCount = [[UILabel alloc] initWithFrame:CGRectMake(297, 0, 110, 20)];
 lblCount.textAlignment = UITextAlignmentCenter;
 lblCount.backgroundColor = [UIColor clearColor];
 lblCount.font = [UIFont boldSystemFontOfSize:16];
 lblCount.text = [langSetting localizedString:@"Count"];
 [vHeader addSubview:lblCount];
 [lblCount release];
 lblline = [[UILabel alloc] initWithFrame:CGRectMake(407, 2, 2, 16)];
 lblline.backgroundColor = [UIColor blackColor];
 [vHeader addSubview:lblline];
 [lblline release];
 
 UILabel *lblPrice = [[UILabel alloc] initWithFrame:CGRectMake(409, 0, 80, 20)];
 lblPrice.textAlignment = UITextAlignmentCenter;
 lblPrice.backgroundColor = [UIColor clearColor];
 lblPrice.font = [UIFont boldSystemFontOfSize:16];
 lblPrice.text = [langSetting localizedString:@"Price"];;
 [vHeader addSubview:lblPrice];
 [lblPrice release];
 lblline = [[UILabel alloc] initWithFrame:CGRectMake(489, 2, 2, 16)];
 lblline.backgroundColor = [UIColor blackColor];
 [vHeader addSubview:lblline];
 [lblline release];
 
 UILabel *lblTotal = [[UILabel alloc] initWithFrame:CGRectMake(491, 0, 80, 20)];
 lblTotal.textAlignment = UITextAlignmentCenter;
 lblTotal.backgroundColor = [UIColor clearColor];
 lblTotal.font = [UIFont boldSystemFontOfSize:16];
 lblTotal.text = [langSetting localizedString:@"Subtotal"];
 [vHeader addSubview:lblTotal];
 [lblTotal release];
 lblline = [[UILabel alloc] initWithFrame:CGRectMake(571, 2, 2, 16)];
 lblline.backgroundColor = [UIColor blackColor];
 [vHeader addSubview:lblline];
 [lblline release];
 
 NSString *countpath = [[NSBundle mainBundle] pathForResource:@"LogCellCountBtn" ofType:@"png"];
 UIImage *img = [[UIImage alloc] initWithContentsOfFile:countpath];
 UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
 [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
 btn.frame = CGRectMake(0, 0, 123, 20);
 [btn setBackgroundImage:img forState:UIControlStateNormal];
 [img release];
 [btn setTitle:[langSetting localizedString:@"DeleteAll"] forState:UIControlStateNormal];
 [btn addTarget:self action:@selector(deleteAll) forControlEvents:UIControlEventTouchUpInside];
 [vHeader addSubview:btn];
 }
 
 return vHeader;
 }
 */
#pragma mark -
#pragma mark LogCellDelegate
- (void)cell:(BSLogCell *)cell selectFood:(NSInteger)flag{
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    int section = cell.tag/100;
    int row = cell.tag%100;
    
    NSMutableArray *ary = [dp orderedFood];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[[[[self seperatedByType:ary] objectAtIndex:section] objectForKey:@"foods"] objectAtIndex:row]];
    int index = [ary indexOfObject:[[[[self seperatedByType:ary] objectAtIndex:section] objectForKey:@"foods"] objectAtIndex:row]];
    NSString *f = [dic objectForKey:@"sendFlag"];
    if ([f isEqualToString:@"1"]){
        [dic setObject:@"0" forKey:@"sendFlag"];
        [ary replaceObjectAtIndex:index withObject:dic];
        cell.butSelect.hidden = YES;
    }
    else{
        [dic setObject:@"1" forKey:@"sendFlag"];
        [ary replaceObjectAtIndex:index withObject:dic];
        [tvOrder reloadData];
        cell.butSelect.hidden = NO;
    }
    [tvOrder reloadData];
    [dp saveOrders];
    
    //    [self performSelector:@selector(updateTitle)];
}

- (void)cell:(BSLogCell *)cell countChanged:(float)count{
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    int section = cell.tag/100;
    int row = cell.tag%100;
    
    NSMutableArray *ary = [dp orderedFood];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[[[[self seperatedByType:ary] objectAtIndex:section] objectForKey:@"foods"] objectAtIndex:row]];
    int index = [ary indexOfObject:[[[[self seperatedByType:ary] objectAtIndex:section] objectForKey:@"foods"] objectAtIndex:row]];
    
    if (count>0){
        [dic setObject:[NSString stringWithFormat:@"%.2f",count] forKey:@"total"];
        
        [ary replaceObjectAtIndex:index withObject:dic];
    }
    else{
        [ary removeObjectAtIndex:index];
    }
    [tvOrder reloadData];
    [dp saveOrders];
    
    [self performSelector:@selector(updateTitle)];
}

- (void)cell:(BSLogCell *)cell priceChanged:(float)price{
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    int section = cell.tag/100;
    int row = cell.tag%100;
    
    NSMutableArray *ary = [dp orderedFood];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[[[[self seperatedByType:ary] objectAtIndex:section] objectForKey:@"foods"] objectAtIndex:row]];
    int index = [ary indexOfObject:[[[[self seperatedByType:ary] objectAtIndex:section] objectForKey:@"foods"] objectAtIndex:row]];
    
    NSMutableDictionary *dicFood = [NSMutableDictionary dictionaryWithDictionary:[dic objectForKey:@"food"]];
    [dicFood setObject:[NSString stringWithFormat:@"%.2f",price] forKey:[dic objectForKey:@"priceKey"]];
    
    [dic setObject:dicFood forKey:@"food"];
    [ary replaceObjectAtIndex:index withObject:dic];
    
    
    
    [dp saveOrders];
    
    [self performSelector:@selector(updateTitle)];
}

- (void)cell:(BSLogCell *)cell additionChanged:(NSMutableArray *)additions{
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    int section = cell.tag/100;
    int row = cell.tag%100;
    
    NSMutableArray *ary = [dp orderedFood];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[[[[self seperatedByType:ary] objectAtIndex:section] objectForKey:@"foods"] objectAtIndex:row]];
    int index = [ary indexOfObject:[[[[self seperatedByType:ary] objectAtIndex:section] objectForKey:@"foods"] objectAtIndex:row]];
    
    if (!additions)
        [dic removeObjectForKey:@"addition"];
    else
        [dic setObject:additions forKey:@"addition"];
    
    [ary replaceObjectAtIndex:index withObject:dic];
    
    
    [tvOrder reloadData];
    //    [tvOrder reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    
    
    [dp saveOrders];
    
    [self performSelector:@selector(updateTitle)];
}

- (void)unitOfCellChanged:(BSLogCell *)cell{
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    cellEditing = cell;
    
    int section = cell.tag/100;
    int row = cell.tag%100;
    
    NSMutableArray *ary = [dp orderedFood];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[[[[self seperatedByType:ary] objectAtIndex:section] objectForKey:@"foods"] objectAtIndex:row]];
    NSDictionary *food = [dic objectForKey:@"food"];
    
    cell.tfPrice.text = [NSString stringWithFormat:@"%@",[food objectForKey:[[NSUserDefaults standardUserDefaults] stringForKey:@"price"]]] ;
    cell.lblUnit.text = [NSString stringWithFormat:@"元/%@",[food objectForKey:@"UNIT"]];
    
    
    
    
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
            NSString *title = [NSString stringWithFormat:@"%.2f/%@",[[[mutmut objectAtIndex:j] objectForKey:@"price"] floatValue],[[mutmut objectAtIndex:j] objectForKey:@"unit"]];
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
        
        [as showFromRect:cell.lblUnit.frame inView:cell.contentView animated:YES];
        //        [as showInView:self.view];
        [as release];
    }
}

- (void)beingEditting:(BSLogCell *)cell{
    NSIndexPath *indexPath = cell.indexPath;
    
    int sections = [self numberOfSectionsInTableView:tvOrder];
    int section = indexPath.section;
    int row = indexPath.row;
    
    if (sections>0){
        float y = 0;
        for (int i=0;i<section;i++){
            y += 30;
            int rows = [self tableView:tvOrder numberOfRowsInSection:i];
            for (int j=0;j<rows;j++){
                y += 110;
            }
        }
        
        y += 30;
        for (int j=0;j<=row;j++){
            y += 110;
        }
        
        fEdittingCellPosition = y;
    }
}

- (void)endEditting:(BSLogCell *)cell{
    
}


- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (0!=buttonIndex){
        BSDataProvider *dp = [BSDataProvider sharedInstance];
        int section = cellEditing.tag/100;
        int row = cellEditing.tag%100;
        
        NSMutableArray *ary = [dp orderedFood];
        NSMutableDictionary *dic = nil;
        NSDictionary *order = nil;
        
        NSArray *groups = [self seperatedByType:ary];
        id group = [groups objectAtIndex:section];
        if ([group isKindOfClass:[NSArray class]])
            order = [group objectAtIndex:row];
        else
            order = [[group objectForKey:@"foods"] objectAtIndex:row];
        dic = [NSMutableDictionary dictionaryWithDictionary:order];
        int index = [ary indexOfObject:order];
        NSDictionary *food = [dic objectForKey:@"food"];
        
        cellEditing.tfPrice.text = [NSString stringWithFormat:@"%@",[food objectForKey:[[NSUserDefaults standardUserDefaults] stringForKey:@"price"]]] ;
        cellEditing.lblUnit.text = [NSString stringWithFormat:@"元/%@",[food objectForKey:@"UNIT"]];
        
        
        
        int j = 0;
        int mutIndex = buttonIndex-1;
        
        NSString *strUnitKey=nil,*strPriceKey = nil;
        
        for (int i=0;i<5;i++){
            NSString *unit = [food objectForKey:0==i?@"UNIT":[NSString stringWithFormat:@"UNIT%d",i+1]];
            if (unit && [unit length]>0){
                if (j==mutIndex){
                    strUnitKey = 0==i?@"UNIT":[NSString stringWithFormat:@"UNIT%d",i+1];
                    strPriceKey = 0==i?@"PRICE":[NSString stringWithFormat:@"PRICE%d",i+1];
                    [dic setObject:strUnitKey forKey:@"unitKey"];
                    [dic setObject:strPriceKey forKey:@"priceKey"];
                    cellEditing.tfPrice.text = [NSString stringWithFormat:@"%@",[food objectForKey:[[NSUserDefaults standardUserDefaults] stringForKey:@"price"]]] ;
                    cellEditing.lblUnit.text = [NSString stringWithFormat:@"元/%@",[food objectForKey:@"UNIT"]];
                }
                j++;
            }
            
        }
        
        [ary replaceObjectAtIndex:index withObject:dic];
        
        
        [tvOrder reloadData];
        
        
        [dp saveOrders];
        
        [self performSelector:@selector(updateTitle)];
        
        
    }
}

#pragma mark Bottom Buttons Events
- (void)back{
    //    [self dismissModalViewControllerAnimated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)sendClicked{
    CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
    if (!vSend)
    {
        [self dismissViews];
        BSDataProvider *dp = [BSDataProvider sharedInstance];
        NSArray *aryMut = [dp orderedFood];
        
        NSMutableArray *ary = [NSMutableArray array];
        for (NSDictionary *dic in aryMut) {
            NSString *flag = [dic objectForKey:@"sendFlag"];
            if (![flag isEqualToString:@"0"]) {
                [ary addObject:dic];
            }
        }
        
        if ([ary count]>0){
            vSend = [[BSSendView alloc] initWithFrame:CGRectMake(0, 0, 492, 354)];
            vSend.delegate = self;
            vSend.center = btnSend.center;
            [self.view addSubview:vSend];
            [vSend release];
            [vSend firstAnimation];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Error"] message:[langSetting localizedString:@"NoFoodOrderedAlert"] delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }
    else{
        [vSend removeFromSuperview];
        vSend = nil;
    }
    
}

- (void)commonClicked{
    if (!vCommon){
        [self dismissViews];
        vCommon = [[BSCommonView alloc] initWithFrame:CGRectMake(0, 0, 492, 354) info:self.aryCommon];
        vCommon.delegate = self;
        vCommon.center = btnCommon.center;
        [self.view addSubview:vCommon];
        [vCommon release];
        [vCommon firstAnimation];
    }
    else{
        [vCommon removeFromSuperview];
        vCommon = nil;
    }
}
#pragma mark CommonView Delegate
- (void)setCommon:(NSArray *)ary{
    CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
    if (!ary){
        [vCommon removeFromSuperview];
        vCommon = nil;
        [self performSelector:@selector(updateTitle)];
        return;
    }
    self.aryCommon = ary;
    if ([aryCommon count]>0){
        lblCommon.text = [langSetting localizedString:@"CommonAdditions:"];//@"公共附加项:";
        NSMutableString *strMut = [NSMutableString string];
        [strMut appendString:[langSetting localizedString:@"CommonAdditions:"]];
        for (int i=0;i<[aryCommon count];i++){
            [strMut appendString:@"    "];
            [strMut appendString:[[aryCommon objectAtIndex:i] objectForKey:@"DES"]];
        }
        lblCommon.text = strMut;
    }
    else
        lblCommon.text = [langSetting localizedString:@"CommonAdditions:"];
    [vCommon removeFromSuperview];
    vCommon = nil;
    [self performSelector:@selector(updateTitle)];
}

#pragma mark SendView Delegate
- (void)sendOrderWithOptions:(NSDictionary *)info{
    
    if (!info)
    {
        [vSend removeFromSuperview];
        vSend = nil;
        return;
    }
    [vSend removeFromSuperview];
    vSend = nil;
    [SVProgressHUD showProgress:-1 status:@"正在查询是否沽清"];
    //     [SVProgressHUD showWithStatus:@"正在上传菜品"];
    [NSThread detachNewThreadSelector:@selector(checkFood:) toTarget:self withObject:info];
    
}

- (void)checkFood:(NSDictionary *)info{
    @autoreleasepool {
        BSDataProvider *dp = [BSDataProvider sharedInstance];
        
        NSMutableArray *jiqi = [NSMutableArray array];
        NSMutableArray *jiaoqi = [NSMutableArray array];
        NSArray *aryMut = [self seperatedByType:[dp orderedFood]];
        
        NSMutableArray *ary = [NSMutableArray array];
        for (NSDictionary *dic in aryMut) {
            NSArray *a = [dic objectForKey:@"foods"];
            NSString *flag = [[a objectAtIndex:0] objectForKey:@"sendFlag"];
            if (![flag isEqualToString:@"0"]) {
                [ary addObject:dic];
            }
        }
        
        NSDictionary *dict = [dp checkFoodAvailable:ary info:info];
        
#warning 此处去掉沽清 ，直接将沽清的返回值改为yes
        BOOL bResult = [[dict objectForKey:@"Result"] boolValue];
        //        BOOL bResult = YES;
        if (bResult){
            bs_dispatch_sync_on_main_thread(^{
                for (int i=0;i<[ary count];i++){
                    NSArray *foods = [[ary objectAtIndex:i] objectForKey:@"foods"];
                    for (int j=0;j<foods.count;j++){
                        NSDictionary *dicfood = [foods objectAtIndex:j];
                        BOOL isselected = NO;
                        for (NSDictionary *dictselected in arySelectedFood){
                            if ([[dicfood objectForKey:@"OrderTimeCount"] intValue]==[[dictselected objectForKey:@"OrderTimeCount"] intValue]){
                                isselected = YES;
                                break;
                            }
                        }
                        if (isselected)
                            [jiaoqi addObject:[foods objectAtIndex:j]];
                        else
                            [jiqi addObject:[foods objectAtIndex:j]];
                    }
                }
                
                
                
                NSMutableDictionary *mutDic = [NSMutableDictionary dictionaryWithDictionary:info];
                if (self.aryCommon){
                    [mutDic setValue:self.aryCommon forKey:@"common"];
                    self.strUser = [info objectForKey:@"user"];
                    [mutDic setValue:[info objectForKey:@"user"] forKey:@"user"];
                    [mutDic setValue:[info objectForKey:@"pwd"] forKey:@"pwd"];
                }
#warning 多选发送
                
                NSMutableDictionary *mutfood = [NSMutableDictionary dictionary];
                if ([jiaoqi count]>0)
                    [mutfood setObject:jiaoqi forKey:@"Y"];
                if ([jiqi count]>0)
                    [mutfood setObject:jiqi forKey:@"N"];
                NSLog(@"%@",[mutfood objectForKey:@"N"]);
                NSMutableArray *aryN = [NSMutableArray array];
                NSMutableArray *aryY = [NSMutableArray array];
                for (NSDictionary *dic in [mutfood objectForKey:@"N"]) {
                    NSString *flag = [dic objectForKey:@"sendFlag"];
                    if (![flag isEqualToString:@"0"]) {
                        [aryN addObject:dic];
                    }
                }
                for (NSDictionary *dic in [mutfood objectForKey:@"Y"]) {
                    NSString *flag = [dic objectForKey:@"sendFlag"];
                    if (![flag isEqualToString:@"0"]) {
                        [aryY addObject:dic];
                    }
                }
                [mutfood setObject:aryN forKey:@"N"];
                [mutfood setObject:aryY forKey:@"Y"];
                [mutfood setObject:mutDic forKey:@"options"];
                [SVProgressHUD showWithStatus:@"菜品没有沽清,正在上传菜品"];
                [self sendOrder:mutfood];
            });
        }else{
            bs_dispatch_sync_on_main_thread(^{
                [SVProgressHUD dismiss];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[dict objectForKey:@"Message"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
                [alert release];
            });
        }
        
        
    }
}

- (void)sendOrder:(NSDictionary *)info{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
    
    NSArray *jiqi = [info objectForKey:@"N"];
    NSArray *jiaoqi = [info objectForKey:@"Y"];
    NSString *strjiqi = nil;
    NSString *strjiaoqi = nil;
    
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithDictionary:[info objectForKey:@"options"]];
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    if (jiqi){
        [options setObject:@"N" forKey:@"type"];
        strjiqi = [dp pSendTab:jiqi options:options];
    }
    
    if (jiaoqi){
        [options setObject:@"Y" forKey:@"type"];
        strjiaoqi = [dp pSendTab:jiaoqi options:options];
    }
    NSString *cmd = nil;
    if (strjiaoqi && strjiqi){
        cmd = [NSString stringWithFormat:@"%@#%@",strjiqi,strjiaoqi];
    }else if (strjiaoqi && !strjiqi)
        cmd = strjiaoqi;
    else
        cmd = strjiqi;
    if (cmd==nil) {
        bs_dispatch_sync_on_main_thread(^{
            [SVProgressHUD dismiss];
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"网络延迟，请稍后重新发送" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
            [alert show];
            [alert release];
            return ;
        });
    }
    _table=[[[info objectForKey:@"options"] objectForKey:@"table"] copy];
    [self uploadFood:cmd];
    [self uploadFoodToo:cmd];
    [pool release];
}


#pragma mark Handle Socket Return Message
- (void)handleSendtab:(NSNotification *)notification{
    CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    NSDictionary *userInfo = [notification userInfo];
    BOOL bSucceed = [[userInfo objectForKey:@"Result"] boolValue];
    NSString *msg = [userInfo objectForKey:@"Message"];
    NSString *tab = [userInfo objectForKey:@"tab"];
    
    NSMutableArray *aryDelete = [NSMutableArray array];
    NSString *title;
    if (bSucceed){
        title = [langSetting localizedString:@"Send Suceeded"];//@"传菜成功";
        NSMutableArray *ary = [dp orderedFood];
        for (int i=0;i<[ary count];i++){
            BSLogCell *cell = (BSLogCell *)[tvOrder cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            if (cell.bSelected)
                [aryDelete addObject:[NSNumber numberWithInt:i]];
        }
        
        if ([aryDelete count]>0){
            for (int i=[aryDelete count]-1;i>=0;i--){
                [ary removeObjectAtIndex:[[aryDelete objectAtIndex:i] intValue]];
            }
        }
        else
            [ary removeAllObjects];
        
        
        [dp saveOrders];
        [tvOrder reloadData];
        [self performSelector:@selector(updateTitle)];
        self.aryCommon = nil;
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"print"]){
            [dp pPrintQuery:[NSDictionary dictionaryWithObjectsAndKeys:self.strUser,@"user",tab,@"tab",@"ACCOUNT",@"type", nil]];
        }
    }
    else
        title = [langSetting localizedString:@"Send Failed"];//@"传菜失败";
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

#pragma mark Show Latest Price & Number
- (void)updateTitle{
    CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    NSArray *aryOrders = [dp orderedFood];
    int count = [aryOrders count];
    float fPrice = 0.0f;
    float fAdditionPrice = 0.0f;
    for (NSDictionary *dic in aryOrders){
        float fCount = [[dic objectForKey:@"total"] floatValue];
        NSDictionary *foodInfo = [dic objectForKey:@"food"];
        if (!foodInfo)
            foodInfo = dic;
        float price = [[foodInfo objectForKey:[dic objectForKey:@"priceKey"]] floatValue];
        float fTotal = price*fCount;
        
        fPrice += fTotal;
        
        NSArray *aryAdd = [dic objectForKey:@"addition"];
        for (NSDictionary *dicAdd in aryAdd){
            BOOL bAdd = YES;
            for (NSDictionary *dicCommonAdd in self.aryCommon){
                if ([[dicAdd objectForKey:@"DES"] isEqualToString:[dicCommonAdd objectForKey:@"DES"]])
                    bAdd = NO;
            }
            
            if (bAdd)
                fAdditionPrice += [[dicAdd objectForKey:@"PRICE1"] floatValue];
        }
        
        for (NSDictionary *dicCommonAdd in self.aryCommon){
            fAdditionPrice += [[dicCommonAdd objectForKey:@"PRICE1"] floatValue];
        }
        
    }
        
    lblTitle.text = [NSString stringWithFormat:[langSetting localizedString:@"QueryTitle"],count,fPrice,fAdditionPrice];
}


- (void)dismissViews{
    if (vSend && vSend.superview){
        [vSend removeFromSuperview];
        vSend = nil;
    }
    
    if (vCommon && vCommon.superview){
        [vCommon removeFromSuperview];
        vCommon = nil;
    }
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    
    BOOL bDismiss = YES;
    CGPoint pt;
    if (vSend && vSend.superview){
        pt = [touch locationInView:vSend];
        bDismiss = !(pt.x>=0 && pt.y<vSend.frame.size.width);
    }
    
    if (vCommon && vCommon.superview){
        pt = [touch locationInView:vCommon];
        bDismiss = !(pt.x>=0 && pt.y<vCommon.frame.size.width);
    }
    
    
    if (bDismiss)
        [self dismissViews];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self dismissViews];
}



#pragma mark SearchBar Delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if ([searchText length]>0){
        if (!popSearch.popoverVisible)
            [popSearch presentPopoverFromRect:barSearch.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        BSSearchViewController *vc = (BSSearchViewController *)popSearch.contentViewController;
        vc.strInput = searchText;
    }
    else{
        if (popSearch.popoverVisible)
            [popSearch dismissPopoverAnimated:YES];
    }
}

#pragma mark BSSearchDelegate
- (void)didSelectItem:(NSDictionary *)dic{
    [barSearch resignFirstResponder];
    barSearch.text = nil;
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:dic forKey:@"food"];
    [dict setObject:@"1.0" forKey:@"total"];
    
    
    
    [dp orderFood:dict];
    
    
    [SVProgressHUD showSuccessWithStatus:@"菜品已被添加"];
    [tvOrder reloadData];
    //    [tvOrder reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    [dp saveOrders];
    [self performSelector:@selector(updateTitle)];
}

- (void)tableClicked{
    BSTableViewController *vcTable = [[BSTableViewController alloc] init];
    [self.navigationController pushViewController:vcTable animated:YES];
}

-(void)quanClicked{
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    
    NSMutableArray *ary = [dp orderedFood];
    if ([ary count]==0) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"你还没有点菜" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    NSString *f = [[ary objectAtIndex:0] objectForKey:@"sendFlag"];
    for (int i=0; i<[ary count]; i++) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[ary objectAtIndex:i]];
        if ([f isEqualToString:@"1"]){
            [dic setObject:@"0" forKey:@"sendFlag"];
            [ary replaceObjectAtIndex:i withObject:dic];
        }else{
            [dic setObject:@"1" forKey:@"sendFlag"];
            [ary replaceObjectAtIndex:i withObject:dic];
            [tvOrder reloadData];
        }
    }
    [tvOrder reloadData];
    [dp saveOrders];
}

- (void)deleteAll{
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    NSMutableArray *ary = [dp orderedFood];
    
    
    [ary removeAllObjects];
    [tvOrder reloadData];
    //    [tvOrder reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    
    [dp saveOrders];
    
    [self performSelector:@selector(updateTitle)];
}


//#pragma mark Add Temp Food
//- (void)tempClicked{
//    if (!popTemp){
//        UIViewController *vcTemp = [[UIViewController alloc] init];
//        vcTemp.frame = CGRectMake(0, 0, 236, 237);
//
//        NSArray *ary = [[NSBundle mainBundle] loadNibNamed:@"BSTempFoodView" owner:nil options:nil];
//    }
//}
@end
