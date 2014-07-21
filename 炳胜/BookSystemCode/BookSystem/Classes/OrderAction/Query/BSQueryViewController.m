//
//  BSQueryViewController.m
//  BookSystem
//
//  Created by Dream on 11-5-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BSQueryViewController.h"
#import "CVLocalizationSetting.h"


@implementation BSQueryViewController
@synthesize dicOrder,dicQuery,strTable,strUser,strPwd,arySelectedFood;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    self.arySelectedFood = nil;
    self.strUser = nil;
    self.strPwd = nil;
    self.dicOrder = nil;
    self.dicQuery = nil;
    self.strTable = nil;
    [vHeader release];
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
    self.arySelectedFood = [NSMutableArray array];
    dTable = 1;
    CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
    
    UIImageView *imgvBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 768, 1004)];
    UIImage *imgBG = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"logbg" ofType:@"png"]];
    [imgvBG setImage:imgBG];
    [imgBG release];
    [self.view addSubview:imgvBG];
    [imgvBG release];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleQuery:) name:msgQuery object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGogo:) name:msgGogo object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleChuck:) name:msgChuck object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePrint:) name:msgPrint object:nil];
    self.view.backgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0];
    
    NSString *pathNormal = [[NSBundle mainBundle] pathForResource:@"cv_rotation_normal_button" ofType:@"png"];
    NSString *pathSelected = [[NSBundle mainBundle] pathForResource:@"cv_rotation_highlight_button" ofType:@"png"];
    UIImage *imgNormal = [[UIImage alloc] initWithContentsOfFile:pathNormal];
    UIImage *imgSelected = [[UIImage alloc] initWithContentsOfFile:pathSelected];
    
    btnPrint = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnPrint setBackgroundImage:imgNormal forState:UIControlStateNormal];
    [btnPrint setBackgroundImage:imgSelected forState:UIControlStateHighlighted];
    [btnPrint sizeToFit];
    [btnPrint addTarget:self action:@selector(printQuery) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btnChangMan = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnChangMan setBackgroundImage:imgNormal forState:UIControlStateNormal];
    [btnChangMan setBackgroundImage:imgSelected forState:UIControlStateHighlighted];
    [btnChangMan sizeToFit];
    [btnChangMan addTarget:self action:@selector(changeManCount) forControlEvents:UIControlEventTouchUpInside];
    
    btnQuery = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnQuery setBackgroundImage:imgNormal forState:UIControlStateNormal];
    [btnQuery setBackgroundImage:imgSelected forState:UIControlStateHighlighted];
    [btnQuery sizeToFit];
    [btnQuery addTarget:self action:@selector(queryOrder) forControlEvents:UIControlEventTouchUpInside];
    
    btnGogo = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnGogo setBackgroundImage:imgNormal forState:UIControlStateNormal];
    [btnGogo setBackgroundImage:imgSelected forState:UIControlStateHighlighted];
    [btnGogo sizeToFit];
    [btnGogo addTarget:self action:@selector(gogoOrder) forControlEvents:UIControlEventTouchUpInside];
    
    btnChuck = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnChuck setBackgroundImage:imgNormal forState:UIControlStateNormal];
    [btnChuck setBackgroundImage:imgSelected forState:UIControlStateHighlighted];
    [btnChuck sizeToFit];
    [btnChuck addTarget:self action:@selector(chuckOrder) forControlEvents:UIControlEventTouchUpInside];
    
    btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack setBackgroundImage:imgNormal forState:UIControlStateNormal];
    [btnBack setBackgroundImage:imgSelected forState:UIControlStateHighlighted];
    [btnBack sizeToFit];
    [btnBack addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    [imgNormal release];
    [imgSelected release];
    
    //139 54
    btnPrint.center = CGPointMake(384-115-72+20-115+8, 1004-27);
    btnQuery.center = CGPointMake(384-115-72+20, 1004-27);
    btnChangMan.center=CGPointMake(384-72+16, 1004-27);
    btnGogo.center = CGPointMake(384+72-16, 1004-27);
    btnChuck.center = CGPointMake(384+115+72-20, 1004-27);
    btnBack.center = CGPointMake(384+115+115+72-20-8, 1004-27);
    
    [self.view addSubview:btnPrint];
    [self.view addSubview:btnQuery];
    [self.view addSubview:btnChangMan];
    [self.view addSubview:btnGogo];
    [self.view addSubview:btnChuck];
    [self.view addSubview:btnBack];
    
    
    UILabel *labelPrint = [[UILabel alloc] initWithFrame:CGRectMake(50, 23, 100, 20)];
	labelPrint.backgroundColor = [UIColor clearColor];
	labelPrint.font = [UIFont boldSystemFontOfSize:13];
	labelPrint.textColor = [UIColor whiteColor];
	labelPrint.text = [langSetting localizedString:@"PrintQuery"];
	labelPrint.userInteractionEnabled = NO;
	[btnPrint addSubview:labelPrint];
	[labelPrint release];
    
    UILabel *labelMan = [[UILabel alloc] initWithFrame:CGRectMake(50, 23, 100, 20)];
	labelMan.backgroundColor = [UIColor clearColor];
	labelMan.font = [UIFont boldSystemFontOfSize:13];
	labelMan.textColor = [UIColor whiteColor];
	labelMan.text = @"修改人数";
	labelMan.userInteractionEnabled = NO;
	[btnChangMan addSubview:labelMan];
	[labelMan release];
    
    UILabel *labelNews = [[UILabel alloc] initWithFrame:CGRectMake(50, 23, 100, 20)];
	labelNews.backgroundColor = [UIColor clearColor];
	labelNews.font = [UIFont boldSystemFontOfSize:13];
	labelNews.textColor = [UIColor whiteColor];
	labelNews.text = [langSetting localizedString:@"Gogo"];
	labelNews.userInteractionEnabled = NO;
	[btnGogo addSubview:labelNews];
	[labelNews release];
	
	UILabel *labelBalanceSheet = [[UILabel alloc] initWithFrame:CGRectMake(50, 23, 100, 20)];
	labelBalanceSheet.backgroundColor = [UIColor clearColor];
	labelBalanceSheet.font = [UIFont boldSystemFontOfSize:13];
    //	labelBalanceSheet.textAlignment = UITextAlignmentCenter;
	labelBalanceSheet.numberOfLines = 1;
	labelBalanceSheet.textColor = [UIColor whiteColor];
	labelBalanceSheet.text = [langSetting localizedString:@"QueryBill"];
	labelBalanceSheet.userInteractionEnabled = NO;
	[btnQuery addSubview:labelBalanceSheet];
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
    
    UILabel *lblChuck = [[UILabel alloc] initWithFrame:CGRectMake(50, 23, 100, 20)];
	lblChuck.backgroundColor = [UIColor clearColor];
	lblChuck.font = [UIFont boldSystemFontOfSize:13];
    //	labelIncomeStatement.textAlignment = UITextAlignmentCenter;
	lblChuck.textColor = [UIColor whiteColor];
	lblChuck.text = [langSetting localizedString:@"Chuck"];
	lblChuck.userInteractionEnabled = NO;
	[btnChuck addSubview:lblChuck];
	[lblChuck release];
    
    tvOrder = [[UITableView alloc] initWithFrame:CGRectMake(40, 75, 688, 890)];
    tvOrder.delegate = self;
    tvOrder.dataSource = self;
    [self.view insertSubview:tvOrder belowSubview:btnQuery];
    [tvOrder release];
    tvOrder.backgroundColor = [UIColor clearColor];
    tvOrder.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if (!vHeader){
        vHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 688, 20)];
        
        UILabel *lblName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 220, 20)];
        lblName.textAlignment = UITextAlignmentCenter;
        lblName.backgroundColor = [UIColor clearColor];
        lblName.font = [UIFont boldSystemFontOfSize:16];
        lblName.text = [langSetting localizedString:@"FoodName"];
        [vHeader addSubview:lblName];
        [lblName release];
        UILabel *lblline = [[UILabel alloc] initWithFrame:CGRectMake(220, 2, 2, 16)];
        lblline.backgroundColor = [UIColor blackColor];
        [vHeader addSubview:lblline];
        [lblline release];
        
        UILabel *lblUnit = [[UILabel alloc] initWithFrame:CGRectMake(222, 0, 67, 20)];
        lblUnit.textAlignment = UITextAlignmentCenter;
        lblUnit.backgroundColor = [UIColor clearColor];
        lblUnit.font = [UIFont boldSystemFontOfSize:16];
        lblUnit.text = [langSetting localizedString:@"Count"];
        [vHeader addSubview:lblUnit];
        [lblUnit release];
        lblline = [[UILabel alloc] initWithFrame:CGRectMake(289, 2, 2, 16)];
        lblline.backgroundColor = [UIColor blackColor];
        [vHeader addSubview:lblline];
        [lblline release];
        
        UILabel *lblCount = [[UILabel alloc] initWithFrame:CGRectMake(291, 0, 67, 20)];
        lblCount.textAlignment = UITextAlignmentCenter;
        lblCount.backgroundColor = [UIColor clearColor];
        lblCount.font = [UIFont boldSystemFontOfSize:16];
        lblCount.text = [langSetting localizedString:@"Unit"];
        [vHeader addSubview:lblCount];
        [lblCount release];
        lblline = [[UILabel alloc] initWithFrame:CGRectMake(358, 2, 2, 16)];
        lblline.backgroundColor = [UIColor blackColor];
        [vHeader addSubview:lblline];
        [lblline release];
        
        UILabel *lblPrice = [[UILabel alloc] initWithFrame:CGRectMake(360, 0, 67, 20)];
        lblPrice.textAlignment = UITextAlignmentCenter;
        lblPrice.backgroundColor = [UIColor clearColor];
        lblPrice.font = [UIFont boldSystemFontOfSize:16];
        lblPrice.text = [langSetting localizedString:@"Price"];
        [vHeader addSubview:lblPrice];
        [lblPrice release];
        lblline = [[UILabel alloc] initWithFrame:CGRectMake(427, 2, 2, 16)];
        lblline.backgroundColor = [UIColor blackColor];
        [vHeader addSubview:lblline];
        [lblline release];
        
        UILabel *lblTotal = [[UILabel alloc] initWithFrame:CGRectMake(429, 0, 67, 20)];
        lblTotal.textAlignment = UITextAlignmentCenter;
        lblTotal.backgroundColor = [UIColor clearColor];
        lblTotal.font = [UIFont boldSystemFontOfSize:16];
        lblTotal.text = [langSetting localizedString:@"Subtotal"];;
        [vHeader addSubview:lblTotal];
        [lblTotal release];
        lblline = [[UILabel alloc] initWithFrame:CGRectMake(514, 2, 2, 16)];
        lblline.backgroundColor = [UIColor blackColor];
        [vHeader addSubview:lblline];
        [lblline release];
        
        UILabel *lblAddition = [[UILabel alloc] initWithFrame:CGRectMake(516, 0, 180, 20)];
        lblAddition.textAlignment = UITextAlignmentCenter;
        lblAddition.backgroundColor = [UIColor clearColor];
        lblAddition.font = [UIFont boldSystemFontOfSize:16];
        lblAddition.text = [langSetting localizedString:@"Additions"];
        [vHeader addSubview:lblAddition];
        [lblAddition release];
    }
    
    tvOrder.tableHeaderView = vHeader;
    
    lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, 14, 900, 50)];
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.textColor = [UIColor whiteColor];
    lblTitle.font = [UIFont boldSystemFontOfSize:22];
    [self.view addSubview:lblTitle];
    [lblTitle release];
    [self performSelector:@selector(updateTitle)];
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
    return [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:foods,@"foods",@"1",@"classid", nil]];
    
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
    return [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:foods,@"foods",@"1",@"classid", nil]];
}

#pragma mark -
#pragma mark TableView Delegate & DataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"CellIdentifier";
    BSQueryCell *cell = (BSQueryCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell){
        cell = [[[BSQueryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
    }
    

    
    NSDictionary *dic = [[[[self seperatedByType:[self.dicOrder objectForKey:@"account"]] objectAtIndex:indexPath.section] objectForKey:@"foods"] objectAtIndex:indexPath.row];
    
    [cell setInfo:dic];
    
    cell.tag = indexPath.section*100+indexPath.row;

    
    BOOL bInArray = NO;
    for (NSDictionary *food in arySelectedFood){
        if ([[food objectForKey:@"FoodIndex"] intValue]==[[cell.dicInfo objectForKey:@"FoodIndex"] intValue]){
            bInArray = YES;
            break;
        }
    }
    
    cell.bSelected = bInArray;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *ary = [[[self seperatedByType:[self.dicOrder objectForKey:@"account"]] objectAtIndex:section] objectForKey:@"foods"];
    
    
    return [ary count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [[self seperatedByType:[self.dicOrder objectForKey:@"account"]] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSArray *ary = [self seperatedByType:[self.dicOrder objectForKey:@"account"]];
    NSString *classid = [[ary objectAtIndex:section] objectForKey:@"classid"];
    NSDictionary *dic = [[BSDataProvider sharedInstance] getClassByID:classid];
    
    return [dic objectForKey:@"DES"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 72;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    for (int i=0;i<[[self.dicOrder objectForKey:@"account"] count];i++){
//        BSQueryCell *cell1 = (BSQueryCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
//        cell1.selected = NO;
//        cell1.bSelected = NO;
//    }
    BSQueryCell *cell = (BSQueryCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    
    BOOL bInArray = NO;
    NSDictionary *foodIn = nil;
    for (NSDictionary *food in arySelectedFood){
        if ([[food objectForKey:@"FoodIndex"] intValue]==[[cell.dicInfo objectForKey:@"FoodIndex"] intValue]){
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
        
        UILabel *lblName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 220, 20)];
        lblName.textAlignment = UITextAlignmentCenter;
        lblName.backgroundColor = [UIColor clearColor];
        lblName.font = [UIFont boldSystemFontOfSize:16];
        lblName.text = [langSetting localizedString:@"FoodName"];
        [vHeader addSubview:lblName];
        [lblName release];
        UILabel *lblline = [[UILabel alloc] initWithFrame:CGRectMake(220, 2, 2, 16)];
        lblline.backgroundColor = [UIColor blackColor];
        [vHeader addSubview:lblline];
        [lblline release];
        
        UILabel *lblUnit = [[UILabel alloc] initWithFrame:CGRectMake(222, 0, 67, 20)];
        lblUnit.textAlignment = UITextAlignmentCenter;
        lblUnit.backgroundColor = [UIColor clearColor];
        lblUnit.font = [UIFont boldSystemFontOfSize:16];
        lblUnit.text = [langSetting localizedString:@"Count"];
        [vHeader addSubview:lblUnit];
        [lblUnit release];
        lblline = [[UILabel alloc] initWithFrame:CGRectMake(289, 2, 2, 16)];
        lblline.backgroundColor = [UIColor blackColor];
        [vHeader addSubview:lblline];
        [lblline release];
        
        UILabel *lblCount = [[UILabel alloc] initWithFrame:CGRectMake(291, 0, 67, 20)];
        lblCount.textAlignment = UITextAlignmentCenter;
        lblCount.backgroundColor = [UIColor clearColor];
        lblCount.font = [UIFont boldSystemFontOfSize:16];
        lblCount.text = [langSetting localizedString:@"Unit"];
        [vHeader addSubview:lblCount];
        [lblCount release];
        lblline = [[UILabel alloc] initWithFrame:CGRectMake(358, 2, 2, 16)];
        lblline.backgroundColor = [UIColor blackColor];
        [vHeader addSubview:lblline];
        [lblline release];
        
        UILabel *lblPrice = [[UILabel alloc] initWithFrame:CGRectMake(360, 0, 67, 20)];
        lblPrice.textAlignment = UITextAlignmentCenter;
        lblPrice.backgroundColor = [UIColor clearColor];
        lblPrice.font = [UIFont boldSystemFontOfSize:16];
        lblPrice.text = [langSetting localizedString:@"Price"];
        [vHeader addSubview:lblPrice];
        [lblPrice release];
        lblline = [[UILabel alloc] initWithFrame:CGRectMake(427, 2, 2, 16)];
        lblline.backgroundColor = [UIColor blackColor];
        [vHeader addSubview:lblline];
        [lblline release];
        
        UILabel *lblTotal = [[UILabel alloc] initWithFrame:CGRectMake(429, 0, 67, 20)];
        lblTotal.textAlignment = UITextAlignmentCenter;
        lblTotal.backgroundColor = [UIColor clearColor];
        lblTotal.font = [UIFont boldSystemFontOfSize:16];
        lblTotal.text = [langSetting localizedString:@"Subtotal"];;
        [vHeader addSubview:lblTotal];
        [lblTotal release];
        lblline = [[UILabel alloc] initWithFrame:CGRectMake(514, 2, 2, 16)];
        lblline.backgroundColor = [UIColor blackColor];
        [vHeader addSubview:lblline];
        [lblline release];
        
        UILabel *lblAddition = [[UILabel alloc] initWithFrame:CGRectMake(516, 0, 180, 20)];
        lblAddition.textAlignment = UITextAlignmentCenter;
        lblAddition.backgroundColor = [UIColor clearColor];
        lblAddition.font = [UIFont boldSystemFontOfSize:16];
        lblAddition.text = [langSetting localizedString:@"Additions"];
        [vHeader addSubview:lblAddition];
        [lblAddition release];
    }
    
    return vHeader;
}
 */

#pragma mark Bottom Buttons Events
- (void)printQuery{
    bs_dispatch_sync_on_main_thread(^{
        if (!vPrint){
            [self dismissViews];
            if (!self.dicOrder){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"请先查询账单!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
                [alert release];
            }
            else{
                vPrint = [[BSPrintQueryView alloc] initWithFrame:CGRectMake(0, 0, 492, 354)];
                vPrint.delegate = self;
                vPrint.center = btnPrint.center;
                [self.view addSubview:vPrint];
                [vPrint release];
                [vPrint firstAnimation];
            }
        }
        else{
            [vPrint removeFromSuperview];
            vPrint = nil;
        }
    });
}

- (void)queryOrder{
    bs_dispatch_sync_on_main_thread(^{
        if (!vQuery){
            [self dismissViews];
            vQuery = [[BSQueryView alloc] initWithFrame:CGRectMake(0, 0, 492, 354) withTag:1];
            vQuery.delegate = self;
            vQuery.center = btnQuery.center;
            [self.view addSubview:vQuery];
            [vQuery release];
            [vQuery firstAnimation];
        }
        else{
            [vQuery removeFromSuperview];
            vQuery = nil;
        }
    });
}
-(void)changeManCount{
    if (!self.dicOrder){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"请先查询账单!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }else
    {
    bs_dispatch_sync_on_main_thread(^{
        if (!vQuery){
            [self dismissViews];
            vQuery = [[BSQueryView alloc] initWithFrame:CGRectMake(0, 0, 492, 354) withTag:2];
            vQuery.delegate = self;
            vQuery.center = btnQuery.center;
            [self.view addSubview:vQuery];
            [vQuery release];
            [vQuery firstAnimation];
        }
        else{
            [vQuery removeFromSuperview];
            vQuery = nil;
        }
    });
    }
    
}
- (void)gogoOrder{
    bs_dispatch_sync_on_main_thread(^{
        if (!vGogo){
            [self dismissViews];
            NSMutableArray *aryOrderToChuck = [NSMutableArray array];
            NSArray *ary = [self seperatedByType:[self.dicOrder objectForKey:@"account"]];
            
            for (int i=0;i<[ary count];i++){
                NSArray *foods = [[ary objectAtIndex:i] objectForKey:@"foods"];
                for (int j=0;j<foods.count;j++){
                    BSQueryCell *cell = (BSQueryCell *)[tvOrder cellForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
                    if (cell.bSelected)
                        [aryOrderToChuck addObject:[foods objectAtIndex:j]];
                }
                
            }
            
            if ([aryOrderToChuck count]==0){
                //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"请选择要催的菜!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                //            [alert show];
                //            [alert release];
                [aryOrderToChuck addObjectsFromArray:[self.dicOrder objectForKey:@"account"]];
            }
            //        else{
            vGogo = [[BSGogoView alloc] initWithFrame:CGRectMake(0, 0, 492, 354)];
            vGogo.delegate = self;
            vGogo.center = btnGogo.center;
            [self.view addSubview:vGogo];
            [vGogo release];
            [vGogo firstAnimation];
            //        }
        }
        else{
            [vGogo removeFromSuperview];
            vGogo = nil;
        }
    });
}

- (void)chuckOrder{
    CVLocalizationSetting *langSetting  = [CVLocalizationSetting sharedInstance];
    if (!vChuck){
        [self dismissViews];
        NSMutableArray *aryOrderToChuck = [NSMutableArray array];
        NSArray *ary = [self seperatedByType:[self.dicOrder objectForKey:@"account"]];
        
        for (int i=0;i<[ary count];i++){
            NSArray *foods = [[ary objectAtIndex:i] objectForKey:@"foods"];
            for (int j=0;j<foods.count;j++){
                BSQueryCell *cell = (BSQueryCell *)[tvOrder cellForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
                if (cell.bSelected)
                    [aryOrderToChuck addObject:[foods objectAtIndex:j]];
            }
            
        }
        
        bs_dispatch_sync_on_main_thread(^{
            if ([aryOrderToChuck count]==0){
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Error"] message:[langSetting localizedString:@"NoFoodToChuckAlert"] delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
                [alert show];
                [alert release];
            }
            else{
                vChuck = [[BSChuckView alloc] initWithFrame:CGRectMake(0, 0, 492, 354)];
                vChuck.delegate = self;
                vChuck.center = btnChuck.center;
                [self.view addSubview:vChuck];
                [vChuck release];
                [vChuck firstAnimation];
            }
        });
        
    }
    else{
        bs_dispatch_sync_on_main_thread(^{
            [vChuck removeFromSuperview];
            vChuck = nil;
        });
        
    }
    
}

- (void)back{
//    [self dismissModalViewControllerAnimated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)printQueryWithOptions:(NSDictionary *)info{
    [vPrint removeFromSuperview];
    vPrint = nil;
    
    if (!info)
        return;
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:info];
    [dic setObject:[dicOrder objectForKey:@"tab"] forKey:@"tab"];
    
    [NSThread detachNewThreadSelector:@selector(printQuery:) toTarget:self withObject:dic];
}

- (void)printQuery:(NSDictionary *)info{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    NSDictionary *dict = [dp pPrintQuery:info];
    
    NSString *msg;
    if ([[dict objectForKey:@"Result"] boolValue])
        msg = [langSetting localizedString:@"PrintSucceed"];
    else
        msg = [langSetting localizedString:@"PrintFailed"];
    
    bs_dispatch_sync_on_main_thread(^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
        [alert show];
        [alert release];
    });
    
    
    
    [pool release];
}

#pragma mark QueryView Delegate
- (void)queryOrderWithOptions:(NSDictionary *)info{
    [vQuery removeFromSuperview];
    vQuery = nil;
    
    if (!info)
        return;
    dTable = [[info objectForKey:@"table"] intValue];

    self.dicQuery = info;
    
    [NSThread detachNewThreadSelector:@selector(getQueryResult:) toTarget:self withObject:info];

}
-(void)changeMan:(NSDictionary *)info
{
    [vQuery removeFromSuperview];
    vQuery = nil;
    
    if (!info)
        return;
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:info];
    [dic setObject:[dicOrder objectForKey:@"tab"] forKey:@"tab"];
    [NSThread detachNewThreadSelector:@selector(getChangManResult:) toTarget:self withObject:dic];

}
-(void)getChangManResult:(NSDictionary *)info
{
    @autoreleasepool {
        BSDataProvider *dp = [BSDataProvider sharedInstance];
        NSDictionary *dic = [dp pChangMan:info];
        bs_dispatch_sync_on_main_thread(^{
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:[dic objectForKey:@"message"] delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
            [alert show];
            [alert release];
        });
        
    }

}
- (void)getQueryResult:(NSDictionary *)info{
    @autoreleasepool {
        BSDataProvider *dp = [BSDataProvider sharedInstance];
        NSDictionary *dic = [dp pQuery:info];
        
        if ([dic objectForKey:@"Result"]){
            NSString *title,*msg;
            title = @"查询账单失败";
            msg = [dic objectForKey:@"Message"];
            CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
            
            bs_dispatch_sync_on_main_thread(^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
                [alert show];
                [alert release];
            });
            
        }else{
            self.dicOrder = [dp pQuery:info];
            
            
            
            NSArray *ary = [self.dicOrder objectForKey:@"account"];
            NSMutableArray *mut = [NSMutableArray array];
            
            for (int i=0;i<[ary count];i++){
                NSMutableDictionary *mutdict = [NSMutableDictionary dictionaryWithDictionary:[ary objectAtIndex:i]];
                [mutdict setObject:[NSNumber numberWithInt:100+i] forKey:@"FoodIndex"];
                
                [mut addObject:mutdict];
            }
            
            NSMutableDictionary *mutdict = [NSMutableDictionary dictionaryWithDictionary:self.dicOrder];
            [mutdict setObject:mut forKey:@"account"];
            
            self.dicOrder = [NSDictionary dictionaryWithDictionary:mutdict];
            [arySelectedFood removeAllObjects];
            
            
            [tvOrder performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            [self performSelectorOnMainThread:@selector(updateTitle) withObject:nil waitUntilDone:NO];
        }
    }
}

#pragma mark GogoView Delegate
- (void)gogoOrderWithOptions:(NSDictionary *)info{
//    CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
    [vGogo removeFromSuperview];
    vGogo = nil;
    
    if (!info)
        return;
    
    dGogoCount = 1;
//    BSDataProvider *dp = [BSDataProvider sharedInstance];
    
    
    NSString *tab = [self.dicOrder objectForKey:@"tab"];

    NSMutableArray *aryOrderToGogo = [NSMutableArray array];
    NSArray *ary = [self seperatedByType:[self.dicOrder objectForKey:@"account"]];
    
    for (int i=0;i<[ary count];i++){
        NSArray *foods = [[ary objectAtIndex:i] objectForKey:@"foods"];
        for (int j=0;j<foods.count;j++){
            BSQueryCell *cell = (BSQueryCell *)[tvOrder cellForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
            if (cell.bSelected)
                [aryOrderToGogo addObject:[foods objectAtIndex:j]];
        }
        
    }
    
    if ([aryOrderToGogo count]==0){
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Error"] message:[langSetting localizedString:@"GogoAlert"] delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
//        [alert show];
//        [alert release];
        [aryOrderToGogo addObjectsFromArray:[self.dicOrder objectForKey:@"account"]];
    }
//    else{
//        for (int i=0;i<[aryOrderToGogo count];i++){
    if ([aryOrderToGogo count]) {
        NSString *num = [[aryOrderToGogo lastObject] objectForKey:@"num"];
        [aryOrderToGogo removeLastObject];
        [NSThread detachNewThreadSelector:@selector(gogoOrder:) toTarget:self withObject:[NSDictionary dictionaryWithObjectsAndKeys:[info objectForKey:@"user"],@"user",[info objectForKey:@"pwd"],@"pwd",tab,@"tab",aryOrderToGogo,@"account",num,@"num", nil]];
        //          NSDictionary *dict = [dp pGogo:[NSDictionary dictionaryWithObjectsAndKeys:[info objectForKey:@"user"],@"user",[info objectForKey:@"pwd"],@"pwd",tab,@"tab",aryOrderToChuck,@"account",num,@"num", nil]];
        self.strUser = [info objectForKey:@"user"];
        self.strPwd = [info objectForKey:@"pwd"];
    }
//        }
        
//    }
}

- (void)gogoOrder:(NSDictionary *)info{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
    
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    NSDictionary *dict = [dp pGogo:info];
    
    BOOL bSuceed = [[dict objectForKey:@"Result"] boolValue];
    NSString *title,*msg;
    title = nil;
    msg = nil;
    if (bSuceed) {
        [arySelectedFood removeAllObjects];
        
        NSMutableArray *aryOrderToGogo = [info objectForKey:@"account"];
        if (![aryOrderToGogo count]) {
            
            title = @"催菜成功完成";
            bs_dispatch_sync_on_main_thread(^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
                [alert show];
                [alert release];
            });
            
            
//            [aryOrderToGogo release];
            
            [NSThread detachNewThreadSelector:@selector(getQueryResult:) toTarget:self withObject:self.dicQuery];
        } else {
            NSString *num = [[aryOrderToGogo lastObject] objectForKey:@"num"];
            [aryOrderToGogo removeLastObject];
            NSString *tab = [self.dicOrder objectForKey:@"tab"];
            [NSThread detachNewThreadSelector:@selector(gogoOrder:) toTarget:self withObject:[NSDictionary dictionaryWithObjectsAndKeys:[info objectForKey:@"user"],@"user",[info objectForKey:@"pwd"],@"pwd",tab,@"tab",aryOrderToGogo,@"account",num,@"num", nil]];
        }
    } else {
        title = @"催菜失败";
        bs_dispatch_sync_on_main_thread(^{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
            [alert show];
            [alert release];
        });
        
        
        [NSThread detachNewThreadSelector:@selector(getQueryResult:) toTarget:self withObject:self.dicQuery];
    }
    
    [pool release];
}

#pragma mark ChuckView Delegate
- (void)chuckOrderWithOptions:(NSDictionary *)info{
    CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
    [vChuck removeFromSuperview];
    vChuck = nil;
    
    if (!info)
        return;
    
    dChuckCount = 1;


    NSString *tab = [self.dicOrder objectForKey:@"tab"];
    
    NSMutableArray *aryOrderToChuck = [NSMutableArray array];
    NSArray *ary = [self seperatedByType:[self.dicOrder objectForKey:@"account"]];
    
    for (int i=0;i<[ary count];i++){
        NSArray *foods = [[ary objectAtIndex:i] objectForKey:@"foods"];
        for (int j=0;j<foods.count;j++){
            BSQueryCell *cell = (BSQueryCell *)[tvOrder cellForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
            if (cell.bSelected)
                [aryOrderToChuck addObject:[foods objectAtIndex:j]];
        }
        
    }
    
    if ([aryOrderToChuck count]==0){
        bs_dispatch_sync_on_main_thread(^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Error"] message:[langSetting localizedString:@"NoFoodToChuckAlert"] delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
            [alert show];
            [alert release];
        });
        
    }
    else{
        NSMutableDictionary *dicToChuck = [NSMutableDictionary dictionaryWithDictionary:info];
        [dicToChuck setObject:tab forKey:@"tab"];
        [dicToChuck setObject:aryOrderToChuck forKey:@"account"];
        
        [NSThread detachNewThreadSelector:@selector(chuckFood:) toTarget:self withObject:dicToChuck];
        

    }
    
}

- (void)chuckFood:(NSDictionary *)info{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    NSDictionary *dict = [dp pChuck:info];
    CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];

    BOOL bSucceed = [[dict objectForKey:@"Result"] boolValue];

    
    NSString *title,*msg;
    if (bSucceed){
        title = [langSetting localizedString:@"ChuckSucceed"];//@"退菜成功";
        msg = nil;
        [arySelectedFood removeAllObjects];
    }
    else{
        title = [langSetting localizedString:@"ChuckFailed"];//@"退菜失败";
        msg = [dict objectForKey:@"Message"];
    }
    bs_dispatch_sync_on_main_thread(^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
        [alert show];
        [alert release];
    });
    
    
    
    if (bSucceed){
        [NSThread detachNewThreadSelector:@selector(getQueryResult:) toTarget:self withObject:dicQuery];        
    }
    
    [pool release];
}


#pragma mark Handle Socket Return Message
- (void)handleQuery:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];

    self.dicOrder = userInfo;
    
    [tvOrder reloadData];
    
    [self performSelector:@selector(updateTitle)];

}

- (void)handleGogo:(NSNotification *)notification{
    CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
    NSDictionary *userInfo = [notification userInfo];
    BOOL bSucceed = [[userInfo objectForKey:@"Result"] boolValue];
    dGogoCount--;
    
    NSString *title;
    if (bSucceed)
        title = [langSetting localizedString:@"GogoSucceed"];//@"催菜成功";
    else
        title = [langSetting localizedString:@"GogoFailed"];//@"催菜失败";
    
    if (0==dGogoCount){
        bs_dispatch_sync_on_main_thread(^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:title delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
            [alert show];
            [alert release];
        });
        
    }
}

- (void)handleChuck:(NSNotification *)notification{
    CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
    NSDictionary *userInfo = [notification userInfo];
    BOOL bSucceed = [[userInfo objectForKey:@"Result"] boolValue];
    dChuckCount--;
    
    NSString *title;
    if (bSucceed)
        title = [langSetting localizedString:@"ChuckSucceed"];//@"退菜成功";
    else
        title = [langSetting localizedString:@"ChuckFailed"];//@"退菜失败";
    
    if (0==dChuckCount){
        bs_dispatch_sync_on_main_thread(^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:title delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
            [alert show];
            [alert release];
        });
        
    }
    
    if (bSucceed){
        self.dicOrder = nil;
        [arySelectedFood removeAllObjects];
        
        bs_dispatch_sync_on_main_thread(^{
            [tvOrder reloadData];
        });
        
        
        
        BSDataProvider *dp = [BSDataProvider sharedInstance];

        NSDictionary *dicInfo = [NSDictionary dictionaryWithObjectsAndKeys:self.strUser,@"user",self.strPwd,@"pwd",self.strTable,@"table", nil];
        [dp pQuery:dicInfo];
        
        bs_dispatch_sync_on_main_thread(^{
            [self performSelector:@selector(updateTitle)];
        });
        

    }
}

- (void)handlePrint:(NSNotification *)notification{
    CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
    NSDictionary *userInfo = [notification userInfo];
    BOOL bSucceed = [[userInfo objectForKey:@"Result"] boolValue];

    
    NSString *title,*msg;
    if (bSucceed)
        title = [langSetting localizedString:@"PrintSucceed"];
    else
        title = [langSetting localizedString:@"PrintFailed"];
    msg = [userInfo objectForKey:@"Message"];
    
    bs_dispatch_sync_on_main_thread(^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
        [alert show];
        [alert release];
    });
    
    

}

#pragma mark Show Latest Price & Number
- (void)updateTitle{
    bs_dispatch_sync_on_main_thread(^{
        CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
        NSArray *aryOrders = [self.dicOrder objectForKey:@"account"];
        int count = 0;
        float fPrice = 0.0f;
        for (NSDictionary *dic in aryOrders){
            float fCount = [[dic objectForKey:@"total"] floatValue];
            float price = [[dic objectForKey:@"price"] floatValue];
            float fTotal = price*fCount;
            
            if ([[dic objectForKey:@"total"] floatValue]>0)
                count++;
            
            fPrice += fTotal;
        }
        
        fPrice = [[self.dicOrder objectForKey:@"total"] floatValue];
//        NSLog(@"%@",self.dicOrder);
        
        lblTitle.text = [NSString stringWithFormat:[langSetting localizedString:@"QueryTitle2"],count,fPrice,[self.dicOrder objectForKey:@"tab"]];
    });
    
}

- (void)dismissViews{
    bs_dispatch_sync_on_main_thread(^{
        if (vPrint && vPrint.superview){
            [vPrint removeFromSuperview];
            vPrint = nil;
        }
        
        if (vQuery && vQuery.superview){
            [vQuery removeFromSuperview];
            vQuery = nil;
        }
        
        if (vGogo && vGogo.superview){
            [vGogo removeFromSuperview];
            vGogo = nil;
        }
        
        if (vChuck && vChuck.superview){
            [vChuck removeFromSuperview];
            vChuck = nil;
        }
    });
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    
    BOOL bDismiss = YES;
    CGPoint pt;
    if (vQuery && vQuery.superview){
        pt = [touch locationInView:vQuery];
        bDismiss = !(pt.x>=0 && pt.y<vQuery.frame.size.width);
    }
    else if (vGogo && vGogo.superview){
        pt = [touch locationInView:vGogo];
        bDismiss = !(pt.x>=0 && pt.y<vGogo.frame.size.width);
    }
    else if (vChuck && vChuck.superview){
        pt = [touch locationInView:vChuck];
        bDismiss = !(pt.x>=0 && pt.y<vChuck.frame.size.width);
    }
    
    if (bDismiss)
        [self dismissViews];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self dismissViews];
}



@end
