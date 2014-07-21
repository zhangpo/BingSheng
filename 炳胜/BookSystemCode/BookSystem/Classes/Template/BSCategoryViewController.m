//
//  BSCategoryViewController.m
//  BookSystem
//
//  Created by Stan Wu on 12-9-3.
//
//

#import "BSCategoryViewController.h"
#import "BSDataProvider.h"
#import "BSTemplate.h"
#import "BSTFoodListView.h"
#import "BSTFoodDetailView.h"
#import "BSLogViewController.h"
#import "BSQueryViewController.h"

@interface BSCategoryViewController ()

@end

@implementation BSCategoryViewController
@synthesize dicInfo;

- (void)dealloc{
    self.dicInfo = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
//    NSLog(@"Category Info:%@",dicInfo);
    bShowBig = [[dicInfo objectForKey:@"isbig"] intValue]>0;
//    self.view.backgroundColor = [UIColor whiteColor];
    
    NSArray *foods = [[BSDataProvider sharedInstance] getFoodList:[NSString stringWithFormat:@"GRPTYP = %@",[dicInfo objectForKey:@"GRP"]]];

    
    NSMutableArray *mut = [NSMutableArray array];
    NSMutableDictionary *mutdict = nil;
    for (int i=0;i<foods.count;i++){
        if (i%6==0){
            mutdict = [NSMutableDictionary dictionaryWithDictionary:dicInfo];
            [mut addObject:mutdict];
            [mutdict setObject:@"菜品列表" forKey:@"type"];
            [mutdict setObject:[NSMutableArray array] forKey:@"foods"];
        }
        [[mutdict objectForKey:@"foods"] addObject:[foods objectAtIndex:i]];
    }
    
    scvFoods = [[ABScrollPageView alloc] initWithFrame:CGRectMake(0, 0, 768, 1004)];
    [scvFoods setDelegate:self];
    scvFoods.pageCount = bShowBig?[foods count]:[mut count];
    [scvFoods reloadData];
    [self.view addSubview:scvFoods];
    [scvFoods release];
    
    NSDictionary *buttonConfig = [[BSDataProvider sharedInstance] buttonConfig];
    NSDictionary *resourceConfig = [[BSDataProvider sharedInstance] resourceConfig];
    btnLog = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnLog setBackgroundImage:[UIImage imageWithContentsOfFile:[[resourceConfig objectForKey:@"button"] objectForKey:@"log"]] forState:UIControlStateNormal];
    [btnLog addTarget:self action:@selector(showLog) forControlEvents:UIControlEventTouchUpInside];
    btnLog.frame = CGRectFromString([buttonConfig objectForKey:@"log"]);
    [self.view addSubview:btnLog];
//    btnLog.hidden = YES;
    btnLog.titleLabel.font = [UIFont systemFontOfSize:15];
    //    btnLog.layer.shadowColor = [UIColor redColor].CGColor;
    //    btnLog.layer.shadowOpacity = 0.5f;
    //    btnLog.layer.shadowOffset = CGSizeMake(0, 0);
    
    btnQuery = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnQuery setBackgroundImage:[UIImage imageWithContentsOfFile:[[resourceConfig objectForKey:@"button"] objectForKey:@"query"]] forState:UIControlStateNormal];
    [btnQuery addTarget:self action:@selector(showQuery) forControlEvents:UIControlEventTouchUpInside];
    btnQuery.frame = CGRectFromString([buttonConfig objectForKey:@"query"]);
    [self.view addSubview:btnQuery];
//    btnQuery.hidden = YES;
    btnQuery.titleLabel.font = [UIFont systemFontOfSize:15];
    
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    btnBack.frame = CGRectMake(13, 56, 102, 49);;
    [btnBack setBackgroundImage:[UIImage imageWithContentsOfFile:[@"xbback.png" documentPath]] forState:UIControlStateNormal];
    [btnBack setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnBack addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnBack];
}

- (void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showLog{
    BSLogViewController *vcMyMenu = [[BSLogViewController alloc] init];
    vcMyMenu.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:vcMyMenu animated:YES];
    [vcMyMenu release];
}

- (void)showQuery{
    BSQueryViewController *vcQuery = [[BSQueryViewController alloc] init];
    vcQuery.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:vcQuery animated:YES];
    [vcQuery release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -  ABScrollPageView Delegate
- (UIView *)scrollPageView:(id)scrollPageView viewForPageAtIndex:(NSUInteger)index{
    
    BSTemplate *vTemplate = (BSTemplate *)[(ABScrollPageView *)scrollPageView dequeueReusablePage:index];
    if (!vTemplate){
        NSArray *foods = [[BSDataProvider sharedInstance] getFoodList:[NSString stringWithFormat:@"GRPTYP = %@",[dicInfo objectForKey:@"GRP"]]];
        NSMutableArray *mut = [NSMutableArray array];
        NSMutableDictionary *mutdict = nil;
        for (int i=0;i<foods.count;i++){
            if (i%6==0){
                mutdict = [NSMutableDictionary dictionaryWithDictionary:dicInfo];
                [mut addObject:mutdict];
                [mutdict setObject:@"菜品列表" forKey:@"type"];
                [mutdict setObject:[NSMutableArray array] forKey:@"foods"];
            }
            [[mutdict objectForKey:@"foods"] addObject:[foods objectAtIndex:i]];
        }
        NSDictionary *dict = [bShowBig?foods:mut objectAtIndex:index];
        if (bShowBig)
            vTemplate = (BSTemplate *)[[[BSTFoodDetailView alloc] initWithFrame:CGRectMake(0, 0, 768, 1004) info:dict] autorelease];
        else
            vTemplate = (BSTemplate *)[[[BSTFoodListView alloc] initWithFrame:CGRectMake(0, 0, 768, 1004) info:dict] autorelease];
        vTemplate.vcParent = self;
    }
    
    return vTemplate;
}

- (void)didScrollToPageAtIndex:(NSUInteger)index{
    
}

@end
