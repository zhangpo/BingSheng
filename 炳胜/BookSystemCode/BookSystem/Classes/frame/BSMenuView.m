//
//  BSMenuView.m
//  BookSystem
//
//  Created by Wu Stan on 12-4-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BSMenuView.h"

@implementation BSMenuView
@synthesize menuStyle,delegate,aryClass,aryItems;

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.delegate = nil;
    self.aryClass = nil;
    self.aryItems = nil;
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.aryItems = [NSMutableArray array];
        BSDataProvider *dp = [BSDataProvider sharedInstance];
        
        int index = 0;

        self.aryClass = [dp menuItemList];
        
        NSArray *aryOrdered = [dp orderedFood];
        
        scvMenu = [[UIScrollView alloc] initWithFrame:self.bounds];
        [self addSubview:scvMenu];
        [scvMenu release];
        scvMenu.showsHorizontalScrollIndicator = NO;
        scvMenu.showsVerticalScrollIndicator = NO;
        
        int count = [aryClass count];
        [scvMenu setContentSize:CGSizeMake(MAX(frame.size.width, count*(kMenuCellWidth+4-4)), frame.size.height)];
        
        index = [[NSUserDefaults standardUserDefaults] integerForKey:@"GlobalMenuIndex"];
        [scvMenu setContentOffset:CGPointMake((index>count-8?(count-8>0?count-8:0):index)*kMenuCellWidth,0)];
        
        for (int i=0;i<count;i++){
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            btn.frame = CGRectMake((kMenuCellWidth+4-4)*i, 0, kMenuCellWidth, frame.size.height);
            [btn setBackgroundImage:[UIImage imageNamed:@"BSMenuButtonNormal.png"] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"BSMenuButtonSelected.png"] forState:UIControlStateSelected];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            
            NSDictionary *infoclass = [dp getClassByID:[[aryClass objectAtIndex:i] objectForKey:@"classid"]];
            
            NSString *title = [infoclass objectForKey:@"DES"];
            
            [btn setTitle:title forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont fontWithName:@"HYg2gj" size:14];
            [scvMenu addSubview:btn];
            btn.tag = 700+i;
            
            UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, kMenuCellWidth-10, 12)];
            lbl.font = [UIFont systemFontOfSize:12];
            lbl.textColor = [UIColor colorWithRed:.95 green:.9 blue:.4 alpha:1];
            lbl.backgroundColor = [UIColor clearColor];
            lbl.textAlignment = UITextAlignmentRight;
            lbl.tag = 800;
            [btn addSubview:lbl];
            [lbl release];
            
            int j = 0;
            for (NSDictionary *food in aryOrdered){
                if ([[[food objectForKey:@"food"] objectForKey:@"GRPTYP"] intValue]==[[infoclass objectForKey:@"GRP"] intValue])
                    j++;
            }
            lbl.text = j!=0?[NSString stringWithFormat:@"%d",j]:nil;

            
            [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
            
//            if (0!=i){
//                UIImageView *imgvLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1, frame.size.height)];
//                imgvLine.backgroundColor = [UIColor darkGrayColor];
//                [btn addSubview:imgvLine];
//                [imgvLine release];
//            }
            
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateOrdered) name:@"UpdateOrderedNumber" object:nil];
    }
    return self;
}

- (void)updateOrdered{
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    
    NSArray *aryOrdered = [dp orderedFood];
    
    int count = [aryClass count];
    
    for (int i=0;i<count;i++){
        UIButton *btn = (UIButton *)[scvMenu viewWithTag:700+i];
        UILabel *lbl = (UILabel *)[btn viewWithTag:800];
        NSDictionary *infoclass = [dp getClassByID:[[aryClass objectAtIndex:i] objectForKey:@"classid"]];
        
        int j = 0;
        for (NSDictionary *food in aryOrdered){
            if ([[[food objectForKey:@"food"] objectForKey:@"GRPTYP"] intValue]==[[infoclass objectForKey:@"GRP"] intValue])
                j++;
        }
        lbl.text = j!=0?[NSString stringWithFormat:@"%d",j]:nil;
        
        
        [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)setSelectedIndex:(NSInteger)index{
    NSDictionary *dict = [aryClass objectAtIndex:index];
    if ([(NSObject *)delegate respondsToSelector:@selector(showPage:)])
        [delegate showPage:[[dict objectForKey:@"index"] intValue]];
    
    
    for (int i=0;i<[aryClass count];i++){
        UIButton *btn = (UIButton *)[scvMenu viewWithTag:700+i];
        
        btn.selected = i==index;
    }
        
}

- (void)deselectMenu{
    for (int i=0;i<[aryClass count];i++){
        UIButton *btn = (UIButton *)[scvMenu viewWithTag:700+i];
        
        btn.selected = NO;
    }
}

- (void)changeButtonIndex:(NSInteger)index{
    for (int i=0;i<[aryClass count];i++){
        UIButton *btn = (UIButton *)[scvMenu viewWithTag:700+i];
        
        btn.selected = i==index;
    }
    
}

- (UITableView *)currentTableView{
    UINavigationController *nav = (UINavigationController *)pop.contentViewController;
    UIViewController *vc = [nav.viewControllers lastObject];
    return (UITableView *)[vc.view viewWithTag:100+nav.viewControllers.count-1];
}

- (void)btnClicked:(UIButton *)btn{
    int index = btn.tag-700;
    
    NSDictionary *dict = [aryClass objectAtIndex:index];
    
    if ([dict objectForKey:@"items"]){
        if (!pop){
            UIViewController *vc = [[UIViewController alloc] init];
            vc.view.frame = CGRectMake(0, 0, 320, 460);
            UINavigationController *vcNav = [[UINavigationController alloc] initWithRootViewController:vc];
            [vc release];
            vcNav.view.frame = CGRectMake(0, 0, 320, 460);
            vcNav.delegate = self;
            pop = [[UIPopoverController alloc] initWithContentViewController:vcNav];
            pop.popoverContentSize = CGSizeMake(320, 460);
            [vcNav release];
            
            [aryItems addObject:[dict objectForKey:@"items"]];
            
            
            UITableView *tv = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 416)];
            tv.delegate = self;
            tv.dataSource = self;
            tv.tag = 100;
            [vc.view addSubview:tv];
            [tv release];
            [tv reloadData];
        }
        
        [aryItems removeAllObjects];
        [aryItems addObject:[dict objectForKey:@"items"]];
        [(UINavigationController *)pop.contentViewController popToRootViewControllerAnimated:YES];
        UIViewController *vcroot = [[(UINavigationController *)pop.contentViewController viewControllers] lastObject];
        vcroot.navigationItem.title = [dict objectForKey:@"DES"];
        [[self currentTableView] reloadData];
        
        [pop presentPopoverFromRect:btn.frame inView:scvMenu permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }else{
        NSDictionary *dict = [aryClass objectAtIndex:index];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowCategoryDetail" object:nil userInfo:dict];
        
    }
    
    return;
    //  之前的代码
    
    
//    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:@"GlobalMenuIndex"];
//    [[NSNotificationCenter defaultCenter] postNotificationName:BSMenuStyleSub==menuStyle?@"JumpToSubMenu":@"JumpToContent" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:index],@"index", nil]];
  
    
}

#pragma mark - UITableView Data Source & Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    int index = tableView.tag-100;
    NSArray *ary = [aryItems objectAtIndex:index];
    
    static NSString *identifier = @"MenuIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
    }
    
    NSDictionary *dict = [ary objectAtIndex:indexPath.row];
    if ([dict objectForKey:@"items"])
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.text = [dict objectForKey:@"name"];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    int index = tableView.tag-100;
    NSArray *ary = [aryItems objectAtIndex:index];
    
    return [ary count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    int index = tableView.tag-100;
    NSArray *ary = [aryItems objectAtIndex:index];
    
    NSDictionary *dict = [ary objectAtIndex:indexPath.row];
    
    if ([dict objectForKey:@"items"]){
        [aryItems addObject:[dict objectForKey:@"items"]];
        
        UINavigationController *nav = (UINavigationController *)pop.contentViewController;
        UIViewController *vc = [[UIViewController alloc] init];
        vc.contentSizeForViewInPopover = CGSizeMake(320, 460);
        vc.navigationItem.title = [dict objectForKey:@"name"];
        UITableView *tv = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 416)];
        tv.delegate = self;
        tv.dataSource = self;
        tv.tag = 100+aryItems.count-1;
        [vc.view addSubview:tv];
        [tv release];
        [tv reloadData];
        
        [nav pushViewController:vc animated:YES];
        [vc release];
    }else{
        [pop dismissPopoverAnimated:YES];
        if ([dict objectForKey:@"page"])
            [[NSNotificationCenter defaultCenter] postNotificationName:@"JumpToPage" object:nil userInfo:dict];
        else
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowFoodDetail" object:nil userInfo:dict];
    }
    
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    viewController.contentSizeForViewInPopover = CGSizeMake(320, 460);
    [pop setPopoverContentSize:CGSizeMake(320, 460)];
}
@end
