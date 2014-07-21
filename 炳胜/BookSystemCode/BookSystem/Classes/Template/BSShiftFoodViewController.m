//
//  BSShiftFoodViewController.m
//  BookSystem
//
//  Created by Wu Stan on 12-6-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BSShiftFoodViewController.h"
#import "BSDataProvider.h"

@interface BSShiftFoodViewController ()

@end

@implementation BSShiftFoodViewController
@synthesize dicPackageInfo,dicBookInfo,dicFood,aryShiftFood,dicInfo,delegate;

- (void)dealloc{
    self.dicPackageInfo = nil;
    self.dicBookInfo = nil;
    self.dicFood = nil;
    self.aryShiftFood = nil;
    self.dicInfo = nil;
    self.delegate = nil;
    
    [super dealloc];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    bBlockAction = [[dicInfo objectForKey:@"blockAction"] boolValue];
	// Do any additional setup after loading the view.
    NSString *suitid = [dicInfo objectForKey:@"suitid"];
    self.dicPackageInfo = [[BSDataProvider sharedInstance] getPackageDetail:suitid];
    self.dicBookInfo = [NSMutableDictionary dictionaryWithDictionary:dicPackageInfo];
    
    self.title = @"套餐菜品列表";
    tvFoodList = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 540, 580)];
    tvFoodList.delegate = self;
    tvFoodList.dataSource = self;
    [self.view addSubview:tvFoodList];
    [tvFoodList release];
    tvFoodList.tag = 100;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:self action:@selector(removeSelf)];
    self.navigationItem.leftBarButtonItem = item;
    [item release];
}

- (void)removeSelf{
    if (delegate && [(NSObject *)delegate respondsToSelector:@selector(packageChanged:)])
        [delegate packageChanged:self.dicBookInfo];
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark UITableView Delegate & Data Source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier0 = @"PackageDetailCell";
    static NSString *identifier1 = @"FoodShiftDetail";
    if (100==tableView.tag){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier0];
        if (!cell){
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier0] autorelease];
        }
        NSString *suitid = [dicInfo objectForKey:@"suitid"];
        NSDictionary *packageInfo = [[BSDataProvider sharedInstance] getPackageDetail:suitid];
        
        NSArray *foods = [packageInfo objectForKey:@"foods"];
        
        cell.textLabel.text = [[[dicBookInfo objectForKey:@"foods"] objectAtIndex:indexPath.row] objectForKey:@"DES"];
        
        if ([[[foods objectAtIndex:indexPath.row] objectForKey:@"TAG"] boolValue])
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        else
            cell.accessoryType = UITableViewCellAccessoryNone;
        
        return cell;
    }else if (200==tableView.tag){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
        if (!cell){
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier1] autorelease];
        }
        cell.textLabel.text = [[aryShiftFood objectAtIndex:indexPath.row] objectForKey:@"DES"];
        
        //        if ([[[foods objectAtIndex:indexPath.row] objectForKey:@"TAG"] boolValue])
        //            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        //        else
        //            cell.accessoryType = UITableViewCellAccessoryNone;
        
        return cell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (100==tableView.tag){
        NSString *suitid = [dicInfo objectForKey:@"suitid"];
        NSDictionary *packageInfo = [[BSDataProvider sharedInstance] getPackageDetail:suitid];
        
        NSArray *foods = [packageInfo objectForKey:@"foods"];
        
        return [foods count];
    }else if (200==tableView.tag){
        return [aryShiftFood count];
    }
    
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (bBlockAction)
        return;
    if (100==tableView.tag){
        self.dicFood = [[dicPackageInfo objectForKey:@"foods"] objectAtIndex:indexPath.row];
        NSString *suitid = [dicInfo objectForKey:@"suitid"];
        
        NSMutableArray *ary = [NSMutableArray arrayWithArray:[[BSDataProvider sharedInstance] getShiftFood:[dicFood objectForKey:@"ITEM"] ofPackage:suitid]];
        if (dicBookInfo && ![[[[dicBookInfo objectForKey:@"foods"] objectAtIndex:indexPath.row] objectForKey:@"ITEM"] isEqualToString:[dicFood objectForKey:@"ITEM"]])
            [ary insertObject:dicFood atIndex:0];
        
        self.aryShiftFood = [NSArray arrayWithArray:ary];
        
        UIViewController *vc = [[UIViewController alloc] init];
        vc.view.frame = CGRectMake(0, 0, 540, 580);
        vc.title = @"可换菜列表";
        UITableView *tv = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 540, 580)];
        tv.delegate = self;
        tv.dataSource = self;
        [vc.view addSubview:tv];
        [tv release];
        tv.tag = 200;
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    }else if (200==tableView.tag){
        NSMutableArray *foods = [NSMutableArray arrayWithArray:[dicPackageInfo objectForKey:@"foods"]];
        
        for (int i=0;i<[foods count];i++){
            if ([[[foods objectAtIndex:i] objectForKey:@"ITEM"] isEqualToString:[dicFood objectForKey:@"ITEM"]]){
                NSMutableDictionary *mut = [NSMutableDictionary dictionaryWithDictionary:[aryShiftFood objectAtIndex:indexPath.row]];
                if ([mut objectForKey:@"SUBITEM"])
                    [mut setObject:[mut objectForKey:@"SUBITEM"] forKey:@"ITEM"];
                [foods replaceObjectAtIndex:i withObject:mut];
                break;
            }
        }
        
        [dicBookInfo setObject:foods forKey:@"foods"];
        [self.navigationController popViewControllerAnimated:YES];
        [tvFoodList reloadData];
        
    }
}

@end
