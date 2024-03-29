//
//  BSTableViewController.m
//  BookSystem
//
//  Created by Dream on 11-7-11.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BSTableViewController.h"
#import "CVLocalizationSetting.h"
#import "BSDataProvider.h"
#import "SVProgressHUD.h"

@implementation BSTableViewController
@synthesize  aryTables,dicListTable,aryResvResult;
@synthesize checkTableInfo;



- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.aryTables = nil;
    self.dicListTable = nil;
    self.checkTableInfo = nil;
    self.aryResvResult = nil;
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
    dSelectedIndex = 0;
    CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleListTable:) name:msgListTable object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOpenTable:) name:msgOpenTable object:nil];
    
    
    UIImageView *imgvBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 768, 1004)];
    UIImage *imgBG = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"logbg" ofType:@"png"]];
    [imgvBG setImage:imgBG];
    [imgBG release];
    [self.view addSubview:imgvBG];
    [imgvBG release];
    
    
    scvTables = [[UIScrollView alloc] initWithFrame:CGRectMake(25, 75, 718, 890)];
    [self.view addSubview:scvTables];
    [scvTables release];
    
    
    NSString *pathNormal = [[NSBundle mainBundle] pathForResource:@"cv_rotation_normal_button" ofType:@"png"];
    NSString *pathSelected = [[NSBundle mainBundle] pathForResource:@"cv_rotation_highlight_button" ofType:@"png"];
    UIImage *imgNormal = [[UIImage alloc] initWithContentsOfFile:pathNormal];
    UIImage *imgSelected = [[UIImage alloc] initWithContentsOfFile:pathSelected];
    
    btnCheck = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnCheck setBackgroundImage:imgNormal forState:UIControlStateNormal];
    [btnCheck setBackgroundImage:imgSelected forState:UIControlStateHighlighted];
    [btnCheck sizeToFit];
    [btnCheck addTarget:self action:@selector(checkTable) forControlEvents:UIControlEventTouchUpInside];
    
    btnSwitch = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSwitch setBackgroundImage:imgNormal forState:UIControlStateNormal];
    [btnSwitch setBackgroundImage:imgSelected forState:UIControlStateHighlighted];
    [btnSwitch sizeToFit];
    [btnSwitch addTarget:self action:@selector(switchTable) forControlEvents:UIControlEventTouchUpInside];
    
//    btnChuck = [UIButton buttonWithType:UIButtonTypeCustom];
//    [btnChuck setBackgroundImage:imgNormal forState:UIControlStateNormal];
//    [btnChuck setBackgroundImage:imgSelected forState:UIControlStateHighlighted];
//    [btnChuck sizeToFit];
//    [btnChuck addTarget:self action:@selector(chuckOrder) forControlEvents:UIControlEventTouchUpInside];
    
    btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack setBackgroundImage:imgNormal forState:UIControlStateNormal];
    [btnBack setBackgroundImage:imgSelected forState:UIControlStateHighlighted];
    [btnBack sizeToFit];
    [btnBack addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    [imgNormal release];
    [imgSelected release];
    
    btnCheck.center = CGPointMake(384-105, 1004-27);
    btnSwitch.center = CGPointMake(384, 1004-27);
    btnBack.center = CGPointMake(384+105, 1004-27);
    
    [self.view addSubview:btnCheck];
    [self.view addSubview:btnSwitch];
    [self.view addSubview:btnBack];
    
    UILabel *lblCheck = [[UILabel alloc] initWithFrame:CGRectMake(43, 23, 100, 20)];
	lblCheck.backgroundColor = [UIColor clearColor];
	lblCheck.font = [UIFont boldSystemFontOfSize:13];
	lblCheck.textColor = [UIColor whiteColor];
	lblCheck.text = [langSetting localizedString:@"List Table"];
	lblCheck.userInteractionEnabled = NO;
	[btnCheck addSubview:lblCheck];
	[lblCheck release];
	
	UILabel *lblSwitch = [[UILabel alloc] initWithFrame:CGRectMake(33, 23, 100, 20)];
	lblSwitch.backgroundColor = [UIColor clearColor];
	lblSwitch.font = [UIFont boldSystemFontOfSize:13];
    //	labelBalanceSheet.textAlignment = UITextAlignmentCenter;
	lblSwitch.numberOfLines = 1;
	lblSwitch.textColor = [UIColor whiteColor];
	lblSwitch.text = [langSetting localizedString:@"Change Table"];
	lblSwitch.userInteractionEnabled = NO;
	[btnSwitch addSubview:lblSwitch];
	[lblSwitch release];
	
	UILabel *lblBack = [[UILabel alloc] initWithFrame:CGRectMake(50, 23, 100, 20)];
	lblBack.backgroundColor = [UIColor clearColor];
	lblBack.font = [UIFont boldSystemFontOfSize:13];
    //	labelIncomeStatement.textAlignment = UITextAlignmentCenter;
	lblBack.textColor = [UIColor whiteColor];
	lblBack.text = [langSetting localizedString:@"Back"];
	lblBack.userInteractionEnabled = NO;
	[btnBack addSubview:lblBack];
	[lblBack release];
    
    
    
    
    lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 14, 728, 50)];
    lblTitle.textAlignment = UITextAlignmentCenter;
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.textColor = [UIColor whiteColor];
    lblTitle.font = [UIFont boldSystemFontOfSize:17];
    lblTitle.text = [langSetting localizedString:@"Table Operation"];//@"台位操作";
    [self.view addSubview:lblTitle];
    [lblTitle release];
    
    barSearch = [[UISearchBar alloc] initWithFrame:CGRectMake(545, 20, 190, 40)];
    barSearch.backgroundColor = [UIColor clearColor];
    barSearch.tintColor = [UIColor clearColor];
    //   barSearch.barStyle = UIBarStyleBlackTranslucent;
    barSearch.delegate = self;
    [self.view addSubview:barSearch];
    [barSearch release];
    
    BSResvSearchViewController *vcSearch = [[BSResvSearchViewController alloc] init];
    vcSearch.delegate = self;
    popSearch = [[UIPopoverController alloc] initWithContentViewController:vcSearch];
    [vcSearch release];
    [popSearch setPopoverContentSize:CGSizeMake(375, 360)];
    
 //   [self performSelector:@selector(updateTitle)];
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



- (void)handleListTable:(NSNotification *)notification{
    NSDictionary *info = [notification userInfo];
    
    BOOL bSucceed = [[info objectForKey:@"Result"] boolValue];
    
    if (bSucceed){
        self.aryTables = [info objectForKey:@"Message"];
        [self performSelectorOnMainThread:@selector(showTables:) withObject:aryTables waitUntilDone:NO];
//        [self showTables:aryTables];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"查询台位失败" message:[info objectForKey:@"Message"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (void)handleOpenTable:(NSNotification *)notification{
    NSDictionary *info = [notification userInfo];
    BOOL bSucceed = [[info objectForKey:@"Result"] boolValue];
    
    NSString *title;
    
    if (bSucceed)
        title = [NSString stringWithFormat:@"开台成功，账单流水号为:%@",[info objectForKey:@"Message"]];
    else 
        title = [info objectForKey:@"Message"];
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)showTables:(NSArray *)ary{
    int count = [ary count];
    
    for (UIView *v in scvTables.subviews){
        if ([v isKindOfClass:[BSTableButton class]])
            [v removeFromSuperview];
    }
    
    for (int i=0;i<count;i++){
        int row = i/5;
        int column = i%5;
        NSDictionary *dic = [ary objectAtIndex:i];
        
        BSTableButton *btnTable = [BSTableButton buttonWithType:UIButtonTypeCustom];
        btnTable.delegate = self;
        btnTable.tag = i;
        btnTable.frame = CGRectMake(15+141*column, 5+83*row, 126, 71);
        [btnTable addTarget:self action:@selector(tableClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        btnTable.tableTitle = [dic objectForKey:@"name"];
        btnTable.tableType = [[dic objectForKey:@"status"] intValue];
        
        [scvTables addSubview:btnTable];
        
        [scvTables setContentSize:CGSizeMake(141*column+15*(column-1), 83*row+70)];
        
    }
}


- (void)checkTable{
    if (!vCheck){
        [self dismissViews];
        vCheck = [[BSCheckTableView alloc] initWithFrame:CGRectMake(0, 0, 492, 354)];
        vCheck.delegate = self;
        vCheck.center = btnCheck.center;
        [self.view addSubview:vCheck];
        [vCheck release];
        [vCheck firstAnimation];
    }
    else{
        [vCheck removeFromSuperview];
        vCheck = nil;
    }
    
}

- (void)switchTable{
    vSwitch.tfOldTable.userInteractionEnabled = YES;
    vSwitch.tfNewTable.userInteractionEnabled = YES;
    
    if (!vSwitch){
        [self dismissViews];
        vSwitch = [[BSSwitchTableView alloc] initWithFrame:CGRectMake(0, 0, 492, 354)];
        vSwitch.delegate = self;
        vSwitch.center = btnSwitch.center;
        [self.view addSubview:vSwitch];
        [vSwitch release];
        [vSwitch firstAnimation];
    }
    else{
        [vSwitch removeFromSuperview];
        vSwitch = nil;
    }
}


- (void)dismissViews{
    if (vCheck && vCheck.superview){
        [vCheck removeFromSuperview];
        vCheck = nil;
    }
    if (vOpen && vOpen.superview){
        [vOpen removeFromSuperview];
        vOpen = nil;
    }
    if (vSwitch && vSwitch.superview){
        [vSwitch removeFromSuperview];
        vSwitch = nil;
    }
    if (vCancel && vCancel.superview){
        [vCancel removeFromSuperview];
        vCancel = nil;
    }
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
    
    [self performSelector:@selector(releaseSelf) withObject:nil afterDelay:1.0];
}

#pragma mark View's Delegate
- (void)checkTableWithOptions:(NSDictionary *)info{
    self.checkTableInfo = info;
    if (self.checkTableInfo){
        [NSThread detachNewThreadSelector:@selector(getTableList:) toTarget:self withObject:info];
        self.dicListTable = info;
    }
    [self dismissViews];
}

- (void)getTableList:(NSDictionary *)info{

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    NSDictionary *dict = [dp pListTable:info];
    
    BOOL bSucceed = [[dict objectForKey:@"Result"] boolValue];
    
    if (bSucceed){
        self.aryTables = [dict objectForKey:@"Message"];
        [self performSelectorOnMainThread:@selector(showTables:) withObject:aryTables waitUntilDone:YES];
    }
    else{
        bs_dispatch_sync_on_main_thread(^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"查询台位失败" message:[dict objectForKey:@"Message"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            [alert release];
        });
    }
    
    [pool release];
}

- (void)openTableWithOptions:(NSDictionary *)info{
    if (info){
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:info];
        [dic setObject:[[aryTables objectAtIndex:dSelectedIndex] objectForKey:@"short"] forKey:@"table"];
        
        [NSThread detachNewThreadSelector:@selector(openTable:) toTarget:self withObject:dic];
    }
    [self dismissViews];
}

- (void)openTable:(NSDictionary *)info{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    
    NSDictionary *dict = [dp pStart:info];
    
    
    BOOL bSucceed = [[dict objectForKey:@"Result"] boolValue];
    
    NSString *title;
    
    if (bSucceed) {
        title = [NSString stringWithFormat:@"开台成功，账单流水号为:%@", [dict objectForKey:@"Message"]];
        
        [self checkTableWithOptions:self.checkTableInfo];
    }
    else 
        title = [dict objectForKey:@"Message"];
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
    [alert release];
    
    [pool release];
}

- (void)switchTableWithOptions:(NSDictionary *)info{
    if (info){
        [NSThread detachNewThreadSelector:@selector(switchTable:) toTarget:self withObject:info];
    }
    
    [self dismissViews];
}

- (void)switchTable:(NSDictionary *)info{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    NSDictionary *dict = [dp pChangeTable:info];
    
    NSString *msg,*title;
    if ([[dict objectForKey:@"Result"] boolValue]) {
        title = [langSetting localizedString:@"Change Table Succeed"];
        msg = [dict objectForKey:@"Message"];
        [self checkTableWithOptions:self.checkTableInfo];
   }
    else{
        title = [langSetting localizedString:@"Change Table Failed"];
        msg = [dict objectForKey:@"Message"];
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
    [alert show];
    [alert release];
    
    [pool release];
}

- (void)cancelTableWithOptions:(NSDictionary *)info{
    if (info){
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:info];
        [dic setObject:[[aryTables objectAtIndex:dSelectedIndex] objectForKey:@"short"] forKey:@"table"];
        
        [NSThread detachNewThreadSelector:@selector(cancelTable:) toTarget:self withObject:dic];
    }
    [self dismissViews];
}

- (void)cancelTable:(NSDictionary *)info{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    BSDataProvider *dp = [BSDataProvider sharedInstance];        
    NSDictionary *dict = [dp pOver:info];
    
    BOOL bSucceed = [[dict objectForKey:@"Result"] boolValue];
    
    NSString *title,*msg;
    CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
    if (bSucceed) {
        title = [langSetting localizedString:@"Cancel Table Succeed"];
        msg = [dict objectForKey:@"Message"];
        
        [self checkTableWithOptions:self.checkTableInfo];
    }
    else{
        title = [langSetting localizedString:@"Cancel Table Failed"];
        msg = [dict objectForKey:@"Message"];
        
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
    [alert show];
    [alert release];
    
    [pool release];
    
    [pool release];
}



- (void)releaseSelf{
    [self release];
}

#pragma mark Handle TableButton Click Event
- (void)tableClicked:(BSTableButton *)btn{
    [self dismissViews];
    NSLog(@"%u",btn.tableType);
    dSelectedIndex = btn.tag;
    NSDictionary *info = [self.aryTables objectAtIndex:dSelectedIndex];
    
    BSTableType type = [[info objectForKey:@"status"] intValue];
    UIAlertView *alert;
    switch (type) {
        case BSTableTypeEmpty:
            alert = [[UIAlertView alloc] initWithTitle:@"空台" message:@"此台位是空台，是否开台？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
            alert.tag = kOpenTag;
            [alert show];
            [alert release];
            break;
        case BSTableTypeOrdered:{
            UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"请选择" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"查询预订信息",@"开台", nil];
            [as showInView:self.view];
            [as release];
        }
            break;
        case BSTableTypeNotPaid:
        case BSTableTypeNoOrder:
            alert = [[UIAlertView alloc] initWithTitle:nil message:@"是否要取消开台？" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
            alert.tag = kCancelTag;
            [alert show];
            [alert release];
            break;
        default:
            break;
    }
}


#pragma mark AlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (kOpenTag==alertView.tag){
        if (1==buttonIndex){
            if (vOpen){
                [vOpen removeFromSuperview];
                vOpen = nil;
            }
            vOpen = [[BSOpenTableView alloc] initWithFrame:CGRectMake(0, 0, 492, 354)];
            vOpen.delegate = self;
            vOpen.center = CGPointMake(384, 512);
            vOpen.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
            [self.view addSubview:vOpen];
            [vOpen release];
            [UIView animateWithDuration:0.5f animations:^(void) {
                vOpen.transform = CGAffineTransformIdentity;
            }];
        }
    }
    else if (kCancelTag==alertView.tag){
        if (1==buttonIndex){
            if (vCancel){
                [vCancel removeFromSuperview];
                vCancel = nil;
            }
            vCancel = [[BSCancelTableView alloc] initWithFrame:CGRectMake(0, 0, 492, 354)];
            vCancel.delegate = self;
            vCancel.center = CGPointMake(384, 512);
            vCancel.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
            [self.view addSubview:vCancel];
            [vCancel release];
            [UIView animateWithDuration:0.5f animations:^(void) {
                vCancel.transform = CGAffineTransformIdentity;
            }]; 
        }
    }
}

- (int)indexOfButtonCoveredPoint:(CGPoint)pt{
    int i = -1;
    
    
    for (BSTableButton *btn in scvTables.subviews){
        if ([btn isKindOfClass:[BSTableButton class]]){
      //      CGPoint ptCenter = btn.center;//[btn convertPoint:pt fromView:self.view];
            CGPoint ptCenter = CGPointMake(pt.x, pt.y);//[btn convertPoint:pt fromView:scvTables];
            if ((ptCenter.x-btn.frame.origin.x>=0 && ptCenter.x-btn.frame.origin.x<=btn.frame.size.width) && (ptCenter.y-btn.frame.origin.y>=0 && ptCenter.y-btn.frame.origin.y<=btn.frame.size.height)){
                i = btn.tag;
                break;
            }
        }
    }
    
    return i;
}

- (void)replaceOldTable:(int)oldIndex withNewTable:(int)newIndex{
    [self switchTable];
    NSDictionary *oldDic = [self.aryTables objectAtIndex:oldIndex];
    NSDictionary *newDic = [self.aryTables objectAtIndex:newIndex];
    
    vSwitch.tfOldTable.text = [oldDic objectForKey:@"short"];
    vSwitch.tfNewTable.text = [newDic objectForKey:@"short"];
    
    vSwitch.tfOldTable.userInteractionEnabled = NO;
    vSwitch.tfNewTable.userInteractionEnabled = NO;
}



#pragma mark -  UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (1==buttonIndex){
        NSDictionary *info = [self.aryTables objectAtIndex:dSelectedIndex];
        
//        NSLog(@"Table Info:%@",info);
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"8",@"user",[info objectForKey:@"short"],@"table", nil];
        
        dict = [[BSDataProvider sharedInstance] pListSubscribeOfTable:dict];
        
//        NSLog(@"Reserve Information:%@",dict);
        
        NSMutableString *likefood = [NSMutableString string];
        for (int i=0;i<10;i++){
            NSString *likekey = [NSString stringWithFormat:@"f%d",i+1];
            if ([dict objectForKey:likekey]){
                if (9!=i)
                    [likefood appendFormat:@"%@,",[dict objectForKey:likekey]];
                else
                    [likefood appendFormat:@"%@",[dict objectForKey:likekey]];
            }
        }
        if ([likefood length]>0){
            NSMutableDictionary *mutmut = [NSMutableDictionary dictionaryWithDictionary:dict];
            [mutmut setObject:likefood forKey:@"likefood"];
            dict = [NSDictionary dictionaryWithDictionary:mutmut];
        }
        
        
        NSMutableArray *aryKeysValues = [NSMutableArray arrayWithObjects:@"acct",@"账单号码",@"name",@"客户姓名",@"address",@"客户单位",@"mobile",@"手机号码",@"number",@"预定人数",@"time",@"客到时间",@"business",@"客户维护",
                                         @"remark",@"备注信息",@"likefood",@"喜好菜品",@"interest",@"客户禁忌",@"money",@"累计",@"account",@"预定菜品",nil];
        
        
        
        [aryKeysValues addObjectsFromArray:[NSArray arrayWithObjects:@"num",@"菜品数量",@"price",@"菜品总价",nil]];
        NSMutableString *str = [NSMutableString string];
        for (int i=0;i<[aryKeysValues count]/2;i++){
            if ([dict objectForKey:[aryKeysValues objectAtIndex:i*2]])
                [str appendFormat:@"%@:%@\n",[aryKeysValues objectAtIndex:i*2+1],[dict objectForKey:[aryKeysValues objectAtIndex:i*2]]];
        }

        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"预订信息" message:str delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectZero];
        lbl.numberOfLines = 0;
        lbl.lineBreakMode = UILineBreakModeWordWrap;
        lbl.backgroundColor = [UIColor clearColor];
        lbl.text = str;
        [lbl sizeToFit];
        for (UILabel *lbl in alert.subviews){
            if ([lbl isKindOfClass:[UILabel class]] && ![lbl.text isEqualToString:@"预订信息"]){
                lbl.textAlignment = UITextAlignmentLeft;
                lbl.backgroundColor = [UIColor whiteColor];
                lbl.textColor = [UIColor blackColor];
                lbl.font = [UIFont systemFontOfSize:16];
                lbl.shadowColor = nil;
            }
        }
//        [alert addSubview:lbl];
        [lbl release];
        [alert show];
        [alert release];
        
    }else if (2==buttonIndex){
        if (vOpen){
            [vOpen removeFromSuperview];
            vOpen = nil;
        }
        vOpen = [[BSOpenTableView alloc] initWithFrame:CGRectMake(0, 0, 492, 354)];
        vOpen.delegate = self;
        vOpen.center = CGPointMake(384, 512);
        vOpen.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
        [self.view addSubview:vOpen];
        [vOpen release];
        [UIView animateWithDuration:0.5f animations:^(void) {
            vOpen.transform = CGAffineTransformIdentity;
        }];
    }
}

#pragma mark SearchBar Delegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    NSString *user = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"username"];
    
    self.aryResvResult = [[BSDataProvider sharedInstance] pListResv:[NSDictionary dictionaryWithObjectsAndKeys:user,@"user", nil]];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if ([searchText length]>0){
        if (!popSearch.popoverVisible)
            [popSearch presentPopoverFromRect:barSearch.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        BSResvSearchViewController *vc = (BSResvSearchViewController *)popSearch.contentViewController;
        vc.aryFoods = [NSMutableArray arrayWithArray:self.aryResvResult];
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

    
    
    [SVProgressHUD showSuccessWithStatus:@"菜品已被添加"];
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"菜品已经被添加" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
//    [alert show];
//    [alert release];

}
@end
