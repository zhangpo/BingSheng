//
//  BSCommonView.m
//  BookSystem
//
//  Created by Dream on 11-5-28.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BSCommonView.h"
#import "BSAdditionCell.h"
#import "BSDataProvider.h"

@implementation BSCommonView
@synthesize arySelectedAdditions,aryAdditions,arySearchMatched,aryCustomAdditions;
@synthesize delegate;



- (id)initWithFrame:(CGRect)frame info:(NSArray *)ary{
    self = [super initWithFrame:frame];
    if (self){
        CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
        self.aryCustomAdditions = [NSMutableArray array];
        self.arySelectedAdditions = [NSMutableArray array];
        
        [self setTitle:[langSetting localizedString:@"Common Additions"]];
        
        BSDataProvider *dp = [BSDataProvider sharedInstance];
        self.aryAdditions = [NSMutableArray arrayWithArray:[dp getAdditions]];
        
        if ([ary count]>0){
            for (int i=0;i<[ary count];i++){
                if (![[ary objectAtIndex:i] objectForKey:@"ITCODE"])
                    [aryCustomAdditions addObject:[ary objectAtIndex:i]];
                else
                    [arySelectedAdditions addObject:[ary objectAtIndex:i]];
            }
        }
        
        self.arySearchMatched = [NSMutableArray arrayWithArray:[dp getAdditions]];
        for (int i=aryCustomAdditions.count-1;i>=0;i--)
            [arySearchMatched insertObject:[aryCustomAdditions objectAtIndex:i] atIndex:0];
        
        
        vAddition = [[UIView alloc] initWithFrame:CGRectMake(15, 55, 320, 50)];
        barAddition = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        barAddition.barStyle = UIBarStyleBlack;
        //       barAddition.showsBookmarkButton = YES;
        //       barAddition.tintColor = [UIColor whiteColor];
        barAddition.delegate = self;
        [vAddition addSubview:barAddition];
        [barAddition release];
        [self addSubview:vAddition];
        [vAddition release];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeContactAdd];
        //      [btn setTitle:@"+" forState:UIControlStateNormal];
        btn.frame = CGRectMake(270, 0, 50, 50);
        [vAddition addSubview:btn];
        [btn addTarget:self action:@selector(addCustiomAddition) forControlEvents:UIControlEventTouchUpInside];
        
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
        
        [self addSubview:btnConfirm];
        [self addSubview:btnCancel];
    }
    
    return self;
}

- (void)dealloc
{
    self.arySelectedAdditions = nil;
    self.aryCustomAdditions = nil;
    self.aryAdditions = nil;
    self.arySearchMatched = nil;
    
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
    NSMutableArray *aryAll = [NSMutableArray arrayWithArray:arySelectedAdditions];
    [aryAll addObjectsFromArray:aryCustomAdditions];
    
    [delegate setCommon:aryAll];
}

- (void)cancel{
    [delegate setCommon:nil];
}

#pragma mark TableView Delegate & DataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"CellIdentifier";
    BSAdditionCell *cell = (BSAdditionCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell){
        cell = [[[BSAdditionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSDictionary *dicContent;
    [cell setHeight:[self tableView:tableView heightForRowAtIndexPath:indexPath]];
//    BSDataProvider *dp = [BSDataProvider sharedInstance];
    dicContent = [arySearchMatched objectAtIndex:indexPath.row];
    [cell setContent:dicContent];
    
    BOOL bSelected = NO;
    
    for (NSDictionary *dic in self.arySelectedAdditions){
        if ([[dic objectForKey:@"ITCODE"] intValue]==[[dicContent objectForKey:@"ITCODE"] intValue]){
            bSelected = YES;
            break;
        }
    }
    
    for (NSDictionary *dic in aryCustomAdditions){
        if ([[dicContent objectForKey:@"DES"] isEqualToString:[dic objectForKey:@"DES"]])
            bSelected = YES;
    }
    
    cell.bSelected = bSelected;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    BSDataProvider *dp = [BSDataProvider sharedInstance];
    return [arySearchMatched count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dictSelected = [arySearchMatched objectAtIndex:indexPath.row];
    if ([aryCustomAdditions containsObject:dictSelected]) {
        [aryCustomAdditions removeObjectAtIndex:indexPath.row];
        [arySearchMatched removeObjectAtIndex:indexPath.row];
    }
    else{
        BSAdditionCell *cell = (BSAdditionCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.bSelected = !cell.bSelected;
        BOOL needAdd = YES;
        int index = -1;
        
        for (NSDictionary *dicAdd in arySelectedAdditions){
            if ([[dicAdd objectForKey:@"DES"] isEqualToString:[dictSelected objectForKey:@"DES"]]){
                needAdd = NO;
                index = [arySelectedAdditions indexOfObject:dicAdd];
                break;
            }
        }
        
        if (cell.bSelected && needAdd)
            [arySelectedAdditions addObject:[arySearchMatched objectAtIndex:indexPath.row]];
        else if (!cell.bSelected && !needAdd){
            [arySelectedAdditions removeObjectAtIndex:index];
        }
        
    }
    
    NSMutableArray *aryAll = [NSMutableArray arrayWithArray:arySelectedAdditions];
    [aryAll addObjectsFromArray:aryCustomAdditions];
    
    
    [tv reloadData];
    
    [barAddition resignFirstResponder];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}



NSInteger intSort3(id num1,id num2,void *context){
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

        NSArray *ary = [NSArray arrayWithArray:aryAdditions];
        
        // clean buffer after
        [arySearchMatched removeAllObjects];
        
        int count = [ary count];
        for (int i=0;i<count;i++){
            NSDictionary *dic = [ary objectAtIndex:i];
            
            NSString *strITCODE = [[dic objectForKey:@"ITCODE"] uppercaseString];
            NSString *strINIT = [[dic objectForKey:@"INIT"] uppercaseString];
            NSString *strDES = [dic objectForKey:@"DES"];
            if ([strITCODE rangeOfString:searchText].location!=NSNotFound ||
                [strINIT rangeOfString:searchText].location!=NSNotFound ||
                [strDES rangeOfString:searchText].location!=NSNotFound){
                [arySearchMatched addObject:dic];
            }
        }
         self.arySearchMatched = [NSMutableArray arrayWithArray:[arySearchMatched sortedArrayUsingFunction:intSort3 context:NULL]];
        for (int i=aryCustomAdditions.count-1;i>=0;i--)
            [arySearchMatched insertObject:[aryCustomAdditions objectAtIndex:i] atIndex:0];
//        if (bJump)
//            [tv scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:dJump inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    else{
//        [searchBar resignFirstResponder];
//        [tv scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
        // clean buffer first
        self.arySearchMatched = [NSMutableArray arrayWithArray:aryAdditions];

        self.arySearchMatched = [NSMutableArray arrayWithArray:[arySearchMatched sortedArrayUsingFunction:intSort3 context:NULL]];
        
        for (int i=aryCustomAdditions.count-1;i>=0;i--)
            [arySearchMatched insertObject:[aryCustomAdditions objectAtIndex:i] atIndex:0];
    }
    [tv reloadData];
//    [barAddition becomeFirstResponder];
}

- (void)addCustiomAddition{
    if ([barAddition.text length]>0){
        for (NSDictionary *dic in aryCustomAdditions){
            if ([[dic objectForKey:@"DES"] isEqualToString:barAddition.text])
                return;
        }
        NSDictionary *dicToAdd = [NSDictionary dictionaryWithObjectsAndKeys:barAddition.text,@"DES",@"0.0",@"PRICE1", nil];
        [aryCustomAdditions addObject:dicToAdd];
        
        [arySearchMatched removeAllObjects];
        [arySearchMatched addObjectsFromArray:aryCustomAdditions];
        [arySearchMatched addObjectsFromArray:aryAdditions];
        barAddition.text = nil;
        
        [tv reloadData];
    }
}


@end
