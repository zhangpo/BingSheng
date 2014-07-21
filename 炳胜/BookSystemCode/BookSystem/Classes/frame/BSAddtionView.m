//
//  BSAddtionViewController.m
//  BookSystem
//
//  Created by Dream on 11-5-23.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BSAddtionView.h"
#import "BSAdditionCell.h"
#import "BSDataProvider.h"
#import "CVLocalizationSetting.h"

@implementation BSAddtionView
@synthesize dicInfo;
@synthesize delegate;
@synthesize arySelectedAddtions,aryAdditions,aryResult;


- (id)initWithFrame:(CGRect)frame info:(NSDictionary *)info{
    self = [super initWithFrame:frame];
    if (self){
        BSDataProvider *dp = [BSDataProvider sharedInstance];
        self.aryAdditions = [NSMutableArray arrayWithArray:[dp getAdditions]];
        self.aryResult = [NSMutableArray arrayWithArray:aryAdditions];
        
        self.arySelectedAddtions = [NSMutableArray array];
        CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
        self.dicInfo = info;
        
        [self setTitle:[langSetting localizedString:@"AdditionsConfiguration"]];
        
        vAddition = [[UIView alloc] initWithFrame:CGRectMake(15, 55, 320, 50)];
        barAddition = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        barAddition.barStyle = UIBarStyleBlack;
        //       barAddition.showsBookmarkButton = YES;
        //       barAddition.tintColor = [UIColor whiteColor];
        barAddition.delegate = self;
        [vAddition addSubview:barAddition];
        [barAddition release];
        [self addSubview:vAddition];
        
        tv = [[UITableView alloc] initWithFrame:CGRectMake(15, 105, 320, 205) style:UITableViewStylePlain];
        tv.backgroundColor = [UIColor whiteColor];
        tv.opaque = NO;
        tv.delegate = self;
        tv.dataSource = self;
        [self addSubview:tv];
        [tv release];
        
        btnConfirm = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnConfirm.frame = CGRectMake(350, 90, 100, 44);
        [btnConfirm setTitle:[langSetting localizedString:@"OK"] forState:UIControlStateNormal];
        [btnConfirm addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
        
        btnCancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnCancel.frame = CGRectMake(350, 150, 100, 44);
        [btnCancel setTitle:[langSetting localizedString:@"Cancel"] forState:UIControlStateNormal];
        [btnCancel addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        
        tfAddition = [[UITextField alloc] initWithFrame:CGRectMake(350, 210, 100, 44)];
        tfAddition.borderStyle = UITextBorderStyleRoundedRect;
        tfAddition.font = [UIFont systemFontOfSize:12];
        [self addSubview:tfAddition];
        [tfAddition release];
        
        [self addSubview:btnConfirm];
        [self addSubview:btnCancel];
    }
    
    return self;
}

- (void)dealloc
{
    self.aryAdditions = nil;
    self.arySelectedAddtions = nil;
    self.aryResult = nil;
    
    [super dealloc];
}



#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.






- (void)confirm{
    NSMutableArray *aryMut = [NSMutableArray arrayWithArray:arySelectedAddtions];

    
    if ([tfAddition.text length]>0){
        NSDictionary *dicCustom = [NSDictionary dictionaryWithObjectsAndKeys:tfAddition.text,@"DES",@"0.0",@"PRICE1",nil];
        [aryMut addObject:dicCustom];
    }
    
    [delegate additionSelected:aryMut];
}

- (void)cancel{
    [delegate additionSelected:nil];
}

#pragma mark TableView Delegate & DataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"CellIdentifier";
    BSAdditionCell *cell = (BSAdditionCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell){
        cell = [[[BSAdditionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setHeight:[self tableView:tableView heightForRowAtIndexPath:indexPath]];
        

    }
    
    

    NSArray *ary = aryResult;
    
    [cell setContent:[ary objectAtIndex:indexPath.row]];
    BOOL selected = NO;
    for (NSDictionary *dic in arySelectedAddtions){
        if ([[[ary objectAtIndex:indexPath.row] objectForKey:@"DES"] isEqualToString:[dic objectForKey:@"DES"]]){
            selected = YES;
            break;
        }
    }
    cell.bSelected = selected;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [aryResult count];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    BSAdditionCell *cell = (BSAdditionCell *)[tableView cellForRowAtIndexPath:indexPath];

    cell.bSelected = !cell.bSelected;
    
    BOOL needAdd = YES;
    int index = -1;
    for (NSDictionary *dicAdd in arySelectedAddtions){
        if ([[dicAdd objectForKey:@"DES"] isEqualToString:[[aryAdditions objectAtIndex:indexPath.row] objectForKey:@"DES"]]){
            needAdd = NO;
            index = [arySelectedAddtions indexOfObject:dicAdd];
            break;
        }
    }
    
    if (cell.bSelected && needAdd)
        [arySelectedAddtions addObject:[aryResult objectAtIndex:indexPath.row]];
    else if (!cell.bSelected && !needAdd){
        [arySelectedAddtions removeObjectAtIndex:index];
    }
        

    [tv reloadData];
}


NSInteger intSort(id num1,id num2,void *context){
    int v1 = [[(NSDictionary *)num1 objectForKey:@"ITCODE"] intValue];
    int v2 = [[(NSDictionary *)num2 objectForKey:@"ITCODE"] intValue];
    
    if (v1 < v2)
    return NSOrderedAscending;
    else if (v1 > v2)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}


#pragma mark SearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if ([searchText length]>0){
        searchText = [searchText uppercaseString];

        NSArray *ary = aryAdditions;
        int count = [ary count];
        [aryResult removeAllObjects];
        for (int i=0;i<count;i++){
            NSDictionary *dic = [ary objectAtIndex:i];
            
            NSString *strITCODE = [[dic objectForKey:@"ITCODE"] uppercaseString];
            NSString *strINIT = [[dic objectForKey:@"INIT"] uppercaseString];
            NSString *strDES = [dic objectForKey:@"DES"];
            if ([strITCODE rangeOfString:searchText].location!=NSNotFound ||
                [strINIT rangeOfString:searchText].location!=NSNotFound ||
                [strDES rangeOfString:searchText].location!=NSNotFound){
                [aryResult addObject:dic];
            }
        }
        
        self.aryResult = [NSMutableArray arrayWithArray:[aryResult sortedArrayUsingFunction:intSort context:NULL]];

        
        [tv reloadData];
    }
    else{
//        [searchBar resignFirstResponder];
        self.aryResult = [NSMutableArray arrayWithArray:aryAdditions];
        self.aryResult = [NSMutableArray arrayWithArray:[aryResult sortedArrayUsingFunction:intSort context:NULL]];
        [tv reloadData];
    }
}

- (void)sortArray:(NSDictionary *)dict{
    
}

@end
