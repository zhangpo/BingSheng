//
//  BSTSuitView.m
//  BookSystem
//
//  Created by Wu Stan on 12-6-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BSTSuitView.h"
#import "BSDataProvider.h"


@implementation BSTSuitView
@synthesize dicBookInfo;

- (void)dealloc{
    self.dicBookInfo = nil;

    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame info:(NSDictionary *)info
{
    self = [super initWithFrame:frame info:info];
    if (self) {
        // Initialization code
        NSString *suitid = [info objectForKey:@"suitid"];
        self.dicBookInfo = [[BSDataProvider sharedInstance] getPackageDetail:suitid];

        
        btnSuit = [UIButton buttonWithType:UIButtonTypeCustom];
        btnSuit.frame = CGRectFromString([info objectForKey:@"frame"]);
        [btnSuit setImage:[UIImage imageWithContentsOfFile:[[info objectForKey:@"image"] documentPath]] forState:UIControlStateNormal];
        [btnSuit addTarget:self action:@selector(showPackageDetail) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnSuit];
        
        lblName = [[UILabel alloc] initWithFrame:CGRectMake(0, btnSuit.frame.origin.y+btnSuit.frame.size.height+10, frame.size.width, 30)];
        lblName.textAlignment = UITextAlignmentCenter;
        lblName.backgroundColor = [UIColor clearColor];
        lblName.font = [UIFont systemFontOfSize:18];
        [self addSubview:lblName];
        [lblName release];
        lblName.text = [NSString stringWithFormat:@"%@  %@元/份",[dicBookInfo objectForKey:@"DES"],[dicBookInfo objectForKey:@"PRICE"]];
        lblName.textColor = self.pageColor;
        
        btnConfirm = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnConfirm.frame = CGRectMake(0, 0, 60, 30);
        btnConfirm.center = CGPointMake(btnSuit.center.x, btnSuit.center.y+btnSuit.frame.size.height/2+60);
        [btnConfirm setTitle:@"确定" forState:UIControlStateNormal];
        [self addSubview:btnConfirm];
        [btnConfirm addTarget:self action:@selector(bookSuit) forControlEvents:UIControlEventTouchUpInside];
        
        
        
    }
    return self;
}


- (void)bookSuit{
    NSMutableDictionary *mut = [NSMutableDictionary dictionaryWithDictionary:dicBookInfo];
    [mut setObject:@"1.00" forKey:@"total"];
    [[BSDataProvider sharedInstance] orderFood:mut];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)packageChanged:(NSDictionary *)info{
    self.dicBookInfo = info;
}

- (void)showPackageDetail{
    BSShiftFoodViewController *vc = [[BSShiftFoodViewController alloc] init];
    vc.dicInfo = self.dicInfo;
    vc.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.vcParent presentModalViewController:nav animated:YES];
    [nav release];
    
//    if (!popList){
//        UIViewController *vc = [[UIViewController alloc] init];
//        vc.title = @"套餐菜品列表";
//        UITableView *tv = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 300, 400)];
//        tvFoodList = tv;
//        tv.delegate = self;
//        tv.dataSource = self;
//        [vc.view addSubview:tv];
//        [tv release];
//        tv.tag = 100;
//        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
//        nav.view.frame = CGRectMake(0, 0, 300, 400);
//        popList = [[UIPopoverController alloc] initWithContentViewController:nav];
//        [nav release];
//        [popList setPopoverContentSize:CGSizeMake(300, 400)];
//        
//    }
//    
//    [popList presentPopoverFromRect:btnSuit.frame inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}



@end
