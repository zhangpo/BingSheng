//
//  BSTFoodCell.m
//  BookSystem
//
//  Created by Wu Stan on 12-6-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BSTFoodCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIKitUtil.h"
#import "BSDataProvider.h"
#import "BookSystemAppDelegate.h"
#import "BSTFoodDetailView.h"
#import "SVProgressHUD.h"

@interface NSString(FrameExtensions)

- (CGRect)frameAtIndex:(NSInteger)index seperatedBy:(NSString *)seperator;
- (CGRect)frameAtIndex:(NSInteger)index;

@end

@implementation NSString(FrameExtensions)

- (CGRect)frameAtIndex:(NSInteger)index{
    return [self frameAtIndex:index seperatedBy:@";"];
}

- (CGRect)frameAtIndex:(NSInteger)index seperatedBy:(NSString *)seperator{
    NSArray *ary = [self componentsSeparatedByString:seperator];
    if (index<ary.count)
        return CGRectFromString([ary objectAtIndex:index]);
    else
        return CGRectZero;
}

@end

@implementation BSTFoodCell
@synthesize dicInfo,strPriceKey,strUnitKey,aryAddition,aryFood,aryCount,aryRecommends,pageColor;

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [vFront release];
    [vBack release];
    [vRecommends release];
    
    self.pageColor = nil;
    self.dicInfo = nil;
    self.strPriceKey = nil;
    self.strUnitKey = nil;
    self.aryAddition = nil;
    self.aryFood = nil;
    self.aryCount = nil;
    self.aryRecommends = nil;
    
    [super dealloc];
}

- (id)initWithInfo:(NSDictionary *)info pageColor:(UIColor *)color{
    self = [super init];
    if (self){
        self.dicInfo = info;
        self.pageColor = color;
        fCount = 0;
        
        self.aryFood = [NSMutableArray array];
        self.aryCount = [NSMutableArray array];
        self.aryRecommends = [NSMutableArray array];
        NSArray *itcodes = [[info objectForKey:@"ITCODE"] componentsSeparatedByString:@","];
        
        NSArray *infos = [info objectForKey:@"infos"];
        for (int i=0;i<itcodes.count;i++){
            NSDictionary *foodInfo = nil;
            NSString *itcode = [itcodes objectAtIndex:i];
            for (NSDictionary *dictinfo in infos){
                if ([[dictinfo objectForKey:@"ITCODE"] isEqualToString:itcode]){
                    foodInfo = dictinfo;
                    break;
                }
            }
            if (foodInfo){
                [aryCount addObject:[NSNumber numberWithFloat:0]];
                [aryFood addObject:[NSMutableDictionary dictionaryWithDictionary:foodInfo]];
            }
        }
        
        itcodes = [[dicInfo objectForKey:@"recommends"] objectForKey:@"foods"];
        for (int i=0;i<itcodes.count;i++){
            NSDictionary *foodInfo = (NSDictionary *)[BSDataProvider getDataFromSQLByCommand:[NSString stringWithFormat:@"select * from food where ITCODE = '%@'",[itcodes objectAtIndex:i]]];
            [aryRecommends addObject:[NSMutableDictionary dictionaryWithDictionary:foodInfo]];
        }

        NSDictionary *totalframe = [info objectForKey:@"frame"];
        CGRect frame = CGRectFromString([totalframe objectForKey:@"MainFrame"]);
        self.frame = frame;
        

        self.strUnitKey = @"UNIT";
        self.strPriceKey = @"PRICE";

        [self addFrontView];
//        [self addBackView];
//        [self addRecommendsView];
//
        [self refreshOrderStatus];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(otherFoodClicked:) name:@"OtherFoodClicked" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshOrderStatus) name:@"RefreshOrderStatus" object:nil];        
    }
    
    return self;
}

- (void)otherFoodClicked:(NSNotification *)notification{
    NSArray *itcodes = [[dicInfo objectForKey:@"ITCODE"] componentsSeparatedByString:@","];
    
    BOOL isself = NO;
    for (NSString *itcode in itcodes){
        if ([itcode intValue]==[[[notification userInfo] objectForKey:@"ITCODE"] intValue]){
            isself = YES;
            break;
        }
    }
    
    if (!isself)
        [self backToFront];
    
}


- (void)refreshOrderStatus{
    NSArray *itcodes = [[dicInfo objectForKey:@"ITCODE"] componentsSeparatedByString:@","];
    
    
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    NSMutableArray *ary = [dp orderedFood];
    
    BOOL bFinded = NO;
    for (NSString *itcode in itcodes){
        for (NSDictionary *food in ary){
            if (![[food objectForKey:@"isPack"] boolValue]
                && [[[food objectForKey:@"food"] objectForKey:@"ITCODE"] isEqualToString:itcode]){
                bFinded = YES;
                break;
            }
        }
        if (bFinded)
            break;
    }
    
    
    imgvOrdered.hidden = !bFinded;
    
    [self refreshCount];
}

- (void)addFood:(NSDictionary *)foodInfo byCount:(NSString *)count{
    
    NSString *itcode = [foodInfo objectForKey:@"ITCODE"];
    
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    NSMutableArray *ary = [dp orderedFood];
    
        
    BOOL bFinded = NO;
    for (NSDictionary *food in ary){
        if (![food objectForKey:@"addition"]
            && ![[food objectForKey:@"isPack"] boolValue]
            && [[[food objectForKey:@"food"] objectForKey:@"ITCODE"] isEqualToString:itcode]){
            bFinded = YES;
            float total = [[food objectForKey:@"total"] floatValue];
            total += [count floatValue];
            
            if (total>0){
                NSMutableDictionary *mut = [NSMutableDictionary dictionaryWithDictionary:food];
                [mut setObject:[NSString stringWithFormat:@"%.1f",total] forKey:@"total"];
                [ary replaceObjectAtIndex:[ary indexOfObject:food] withObject:mut];
            }else
                [ary removeObject:food];
            
            [dp saveOrders];
            break;
        }
    }
    
    
    if (!bFinded && [count floatValue]>0){
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:foodInfo forKey:@"food"];
        [dict setObject:count forKey:@"total"];
        
        
        
        
        if (self.aryAddition)
            [dict setObject:aryAddition forKey:@"addition"];
        
        if (self.strUnitKey){
            [dict setObject:strUnitKey forKey:@"unitKey"];
            [dict setObject:strPriceKey forKey:@"priceKey"];
        }
        
        [dp orderFood:dict];
        
//        self.aryAddition = nil;
        self.strUnitKey = @"UNIT";
        self.strPriceKey = @"PRICE";
    }
    
    [self refreshCount];
}


- (void)picClicked{
//    NSLog(@"Current Selector:%@",NSStringFromSelector(_cmd));
    BOOL bShowBack = [[dicInfo objectForKey:@"showBack"] boolValue];
    BOOL bShowDetail = ![[dicInfo objectForKey:@"disableDetail"] boolValue];
    if (bShowBack){
        if (!vBack)
            [self addBackView];
        [UIView transitionWithView:self
                          duration:1
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        animations:^{
                            [vFront removeFromSuperview];
                            [vRecommends removeFromSuperview];
                            [self addSubview:vBack];
                        }
                        completion:NULL];
        
        
    }else if (bShowDetail){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowFoodDetail" object:nil userInfo:[aryFood objectAtIndex:0]];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OtherFoodClicked" object:nil userInfo:self.dicInfo];
    
}

- (void)dismissPopDetail{
    [UIView animateWithDuration:.3 animations:^{
        vDetail.alpha = 0;
    }completion:^(BOOL finished) {
        [vDetail removeFromSuperview];
        vDetail = nil;
    }];
}

- (void)showPopDetail{
    if (!vDetail){
        float padding = 20;
        vDetail = [[UIView alloc] initWithFrame:CGRectMake(padding, 20+padding, 768-padding*2, 1004-padding*2)];
        
        vDetail.backgroundColor = [UIColor clearColor];
        [vDetail.layer setCornerRadius:10.0];
        [vDetail.layer setMasksToBounds:YES];
        vDetail.clipsToBounds = YES;
        
        UIView *skinView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, vDetail.frame.size.width, vDetail.frame.size.height)];
        skinView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        skinView.backgroundColor = [UIColor blackColor];
        skinView.alpha = 0.4f;
        [vDetail addSubview:skinView];
        [skinView release];
        
        UIButton *btncancel = [UIButton buttonWithType:UIButtonTypeCustom];
        btncancel.frame = CGRectMake(vDetail.frame.size.width - (kPadding+25), 0,35, 35);
        [btncancel setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
        [btncancel setImage:[UIImage imageNamed:@"close_selected.png"] forState:UIControlStateHighlighted];
        [btncancel addTarget:self action:@selector(dismissPopDetail) forControlEvents:UIControlEventTouchUpInside];
        [vDetail addSubview:btncancel];
        
        NSDictionary *food = [aryFood objectAtIndex:0];
        int index = 0;
        NSArray *ary = [[BSDataProvider sharedInstance] allDetailPages];
        for (int i=0;i<[ary count];i++){
            if ([[[ary objectAtIndex:i] objectForKey:@"ITCODE"] isEqualToString:[food objectForKey:@"ITCODE"]]){
                index = i;
            }
        }
        
        NSMutableDictionary *mut = [NSMutableDictionary dictionaryWithDictionary:[ary objectAtIndex:index]];
        [mut setObject:[NSNumber numberWithBool:YES] forKey:@"isPop"];
        BSTFoodDetailView *vtDetail = [[BSTFoodDetailView alloc] initWithFrame:CGRectMake(kPadding, kPadding+20, vDetail.frame.size.width-2*kPadding, vDetail.frame.size.height-2*kPadding-20) info:mut];
        [vDetail addSubview:vtDetail];
        [vtDetail release];
        
    }
    
    vDetail.alpha = 0;
    UIWindow *w = (UIWindow *)[(BookSystemAppDelegate *)[UIApplication sharedApplication].delegate window];
    [w addSubview:vDetail];
    [vDetail release];
    
    [UIView animateWithDuration:.3 animations:^{
        vDetail.alpha = 1;
    }];
}

- (void)backToFront{
    if (!vFront.superview){
        [UIView transitionWithView:self
                          duration:1
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        animations:^{
                            [self addSubview:vFront];
                            [vBack removeFromSuperview];
                            [vRecommends removeFromSuperview];
                        }
                        completion:NULL];
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
- (void)showFoodDetail{
    
}


//  UI Elements Layout
- (void)addFrontView{
    vFront = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:vFront];
    
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    NSDictionary *frameInfo = [dicInfo objectForKey:@"frame"];
    NSDictionary *resourceInfo = [dp resourceConfig];

    for (int i=0;i<aryFood.count;i++){
        NSDictionary *foodInfo = [aryFood objectAtIndex:i];
        
        NSData *imgdata = [[NSData alloc] initWithContentsOfFile:[[foodInfo objectForKey:@"picSmall"] documentPath]];
        UIImage *img = [[UIImage alloc] initWithData:imgdata];
        [imgdata release];
        //  菜品图片
        UIButton *btn = nil;
        CGRect rect = [[frameInfo objectForKey:@"Photo"] frameAtIndex:i];
        if (rect.size.width!=0){
            btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = rect;
            [btn setBackgroundImage:img forState:UIControlStateNormal];
            btn.tag = i;
            [vFront addSubview:btn];
            [btn addTarget:self action:@selector(picClicked) forControlEvents:UIControlEventTouchUpInside];
            
        }
        [img release];
        
        //  弹出按钮
        rect = [[frameInfo objectForKey:@"Detail"] frameAtIndex:i];
        if (rect.size.width!=0){
            btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = rect;
            btn.tag = i;
            [vFront addSubview:btn];
            [btn addTarget:self action:@selector(showPopDetail) forControlEvents:UIControlEventTouchUpInside];
        }
        
        //  加减号按钮
        //  加号
        rect = [[frameInfo objectForKey:@"Plus"] frameAtIndex:i];
        if (rect.size.width!=0){
            imgdata = [[NSData alloc] initWithContentsOfFile:[[[resourceInfo objectForKey:@"button"] objectForKey:@"plus"] documentPath]];
            img = [[UIImage alloc] initWithData:imgdata];
            [imgdata release];
            btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = rect;
            [btn setBackgroundImage:img forState:UIControlStateNormal];
            [img release];
            btn.tag = i;
            [vFront addSubview:btn];
            [btn addTarget:self action:@selector(addFood:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        //  减号
        rect = [[frameInfo objectForKey:@"Minus"] frameAtIndex:i];
        if (rect.size.width!=0){
            imgdata = [[NSData alloc] initWithContentsOfFile:[[[resourceInfo objectForKey:@"button"] objectForKey:@"minus"] documentPath]];
            img = [[UIImage alloc] initWithData:imgdata];
            [imgdata release];
            btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = rect;
            [btn setBackgroundImage:img forState:UIControlStateNormal];
            [img release];
            btn.tag = i;
            [vFront addSubview:btn];
            [btn addTarget:self action:@selector(subtractFood:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        //  菜名、价格单位、描述、分隔线
        //  中文名
        rect = [[frameInfo objectForKey:@"ChineseName"] frameAtIndex:i];
        UILabel *lbl = [UILabel createLabelWithFrame:rect font:[UIFont boldSystemFontOfSize:rect.size.height-4] textColor:pageColor];
        [vFront addSubview:lbl];
        //(CGRect) rect = origin=(x=0, y=358) size=(width=122, height=22)
        lbl.text = [[foodInfo objectForKey:@"DES"] stringByReplacingOccurrencesOfString:@"^" withString:@"\n"];
//        lbl.numberOfLines = 1 ;
        lbl.frame = CGRectMake(0, 335, 130, 70);
        //  英文名
        rect = [[frameInfo objectForKey:@"EnglishName"] frameAtIndex:i];
        lbl = [UILabel createLabelWithFrame:rect font:[UIFont systemFontOfSize:rect.size.height-2] textColor:pageColor];
        [vFront addSubview:lbl];
        lbl.text = [[foodInfo objectForKey:@"DESCE"] stringByReplacingOccurrencesOfString:@"^" withString:@"\n"];
        //  价格
        rect = [[frameInfo objectForKey:@"Price"] frameAtIndex:i];
        lbl = [UILabel createLabelWithFrame:rect font:[UIFont boldSystemFontOfSize:rect.size.height-2] textColor:[UIColor redColor]];
        lbl.textAlignment = UITextAlignmentRight;
        [vFront addSubview:lbl];
        lbl.text = [[foodInfo objectForKey:@"PRICE"] stringByReplacingOccurrencesOfString:@"^" withString:@"\n"];
//        lbl.frame = CGRectMake(130, 350, 55, 70);
        //  单位
        rect = [[frameInfo objectForKey:@"Unit"] frameAtIndex:i];
        lbl = [UILabel createLabelWithFrame:rect font:[UIFont boldSystemFontOfSize:rect.size.height-2] textColor:pageColor];
        [vFront addSubview:lbl];
        lbl.text = [NSString stringWithFormat:@"元/%@",[foodInfo objectForKey:@"UNIT"]];
//        lbl.frame = CGRectMake(185, 350, 60, 70);
        //  描述
        rect = [[frameInfo objectForKey:@"Description"] frameAtIndex:i];
        if (rect.size.width!=0){
            UITextView *tv = [[UITextView alloc] initWithFrame:rect];
            tv.backgroundColor = [UIColor clearColor];
            tv.textColor = pageColor;
            tv.font = [UIFont boldSystemFontOfSize:14];
            tv.userInteractionEnabled = NO;
            [vFront addSubview:tv];
            [tv release];
            tv.text = [foodInfo objectForKey:@"REMEMO"];
        }
        
        //  分隔线
        rect = [[frameInfo objectForKey:@"Line"] frameAtIndex:i];
        if (rect.size.width!=0){
            img = [UIImage imgWithContentsOfFile:[[resourceInfo objectForKey:@"line"] documentPath]];
            UIImageView *imgv = [[UIImageView alloc] initWithFrame:rect];
            imgv.clipsToBounds = YES;
            [imgv setImage:img];
            [vFront addSubview:imgv];
            [imgv release];
        }
        
        
        
        //  菜品数量
        rect = [[frameInfo objectForKey:@"Count"] frameAtIndex:i];
        lbl = [UILabel createLabelWithFrame:rect font:[UIFont boldSystemFontOfSize:rect.size.height-2]];
        lbl.textAlignment = UITextAlignmentRight;
        [vFront addSubview:lbl];
        lbl.text = @"0";
        lbl.textColor = [UIColor redColor];
        lbl.tag = 100+i;
    }
    
    CGRect rect = CGRectFromString([frameInfo objectForKey:@"Ordered"]);
    imgvOrdered = [[UIImageView alloc] initWithImage:[UIImage imgWithContentsOfFile:[[[resourceInfo objectForKey:@"button"] objectForKey:@"ordered"] documentPath]]];
    imgvOrdered.frame = rect;
    [vFront addSubview:imgvOrdered];
    [imgvOrdered release];
    imgvOrdered.hidden = YES;
    
}

- (void)addBackView{
    vBack = [[UIView alloc] initWithFrame:self.bounds];
    
    NSDictionary *backInfo = [dicInfo objectForKey:@"back"];
    NSDictionary *frameInfo = [backInfo objectForKey:@"frame"];
    
    UIImageView *imgv = [[UIImageView alloc] initWithFrame:vBack.bounds];
    
    NSData *imgdata = [[NSData alloc] initWithContentsOfFile:[[backInfo objectForKey:@"background"] documentPath]];
    UIImage *img = [[UIImage alloc] initWithData:imgdata];
    [imgdata release];
    
    [imgv setImage:img];
    [img release];
    if (!imgv.image){
        vBack.backgroundColor = [UIColor whiteColor];
    }else
        [vBack addSubview:imgv];
    [imgv release];
    
    for (int i=0;i<aryFood.count;i++){
        NSDictionary *foodInfo = [aryFood objectAtIndex:i];
        //  名称
        CGRect frame = [[frameInfo objectForKey:@"Name"] frameAtIndex:i];
        UILabel *lbl = [UILabel createLabelWithFrame:frame font:[UIFont systemFontOfSize:frame.size.height-2] textColor:[UIColor blackColor]];
        [vBack addSubview:lbl];
        lbl.text = [[foodInfo objectForKey:@"DES"] stringByReplacingOccurrencesOfString:@"^" withString:@"\n"];
        //  价格
        frame = [[frameInfo objectForKey:@"Price"] frameAtIndex:i];
        lbl = [UILabel createLabelWithFrame:frame font:[UIFont boldSystemFontOfSize:frame.size.height-2] textColor:[UIColor redColor]];
        lbl.textAlignment = UITextAlignmentRight;
        [vBack addSubview:lbl];
        lbl.text = [foodInfo objectForKey:@"PRICE"];
        //  单位
        frame = [[frameInfo objectForKey:@"Unit"] frameAtIndex:i];
        lbl = [UILabel createLabelWithFrame:frame font:[UIFont systemFontOfSize:frame.size.height-2] textColor:[UIColor blackColor]];
        lbl.textAlignment = UITextAlignmentRight;
        [vBack addSubview:lbl];
        lbl.text = [NSString stringWithFormat:@"元/%@",[foodInfo objectForKey:strUnitKey]];
        //  数量
        frame = [[frameInfo objectForKey:@"Count"] frameAtIndex:i];
        lbl = [UILabel createLabelWithFrame:frame font:[UIFont systemFontOfSize:frame.size.height-2] textColor:[UIColor blackColor]];
        [vBack addSubview:lbl];
        lbl.textAlignment = UITextAlignmentRight;
        lbl.tag = 100+i;

        //  添加
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = [[frameInfo objectForKey:@"Add"] frameAtIndex:i];
        [btn setImage:[UIImage imgWithContentsOfFile:[[backInfo objectForKey:@"add"] documentPath]] forState:UIControlStateNormal];
        [vBack addSubview:btn];
        [btn addTarget:self action:@selector(addFood:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i;
        //  减少
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = [[frameInfo objectForKey:@"Subtract"] frameAtIndex:i];
        [btn setImage:[UIImage imgWithContentsOfFile:[[backInfo objectForKey:@"subtract"] documentPath]] forState:UIControlStateNormal];
        [vBack addSubview:btn];
        [btn addTarget:self action:@selector(subtractFood:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i;
        //  取消
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = [[frameInfo objectForKey:@"Cancel"] frameAtIndex:i];
        [btn setImage:[UIImage imgWithContentsOfFile:[[backInfo objectForKey:@"cancel"] documentPath]] forState:UIControlStateNormal];
        [vBack addSubview:btn];
        [btn addTarget:self action:@selector(backToFront) forControlEvents:UIControlEventTouchUpInside];

    }
    
    //  附加项
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = [[frameInfo objectForKey:@"Additions"] frameAtIndex:0];
    [btn setImage:[UIImage imgWithContentsOfFile:[[backInfo objectForKey:@"additions"] documentPath]] forState:UIControlStateNormal];
    [vBack addSubview:btn];
    [btn addTarget:self action:@selector(additionsClicked:) forControlEvents:UIControlEventTouchUpInside];
    //  详情
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = [[frameInfo objectForKey:@"Detail"] frameAtIndex:0];
    [btn setImage:[UIImage imgWithContentsOfFile:[[backInfo objectForKey:@"detail"] documentPath]] forState:UIControlStateNormal];
    [vBack addSubview:btn];
    [btn addTarget:self action:@selector(detailClicked) forControlEvents:UIControlEventTouchUpInside];
    //  确定
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = [[frameInfo objectForKey:@"Confirm"] frameAtIndex:0];
    [btn setImage:[UIImage imgWithContentsOfFile:[[backInfo objectForKey:@"confirm"] documentPath]] forState:UIControlStateNormal];
    [vBack addSubview:btn];
    [btn addTarget:self action:@selector(confirmBack) forControlEvents:UIControlEventTouchUpInside];
    
    [self refreshOrderStatus];
    [self refreshCount];
}

- (void)addRecommendsView{
    vRecommends = [[UIView alloc] initWithFrame:self.bounds];
    
    NSDictionary *recommendInfo = [dicInfo objectForKey:@"recommends"];
    NSDictionary *frameInfo = [recommendInfo objectForKey:@"frame"];
    
    UIImageView *imgv = [[UIImageView alloc] initWithFrame:vBack.bounds];
    [imgv setImage:[UIImage imgWithContentsOfFile:[[recommendInfo objectForKey:@"background"] documentPath]]];
    if (!imgv.image){
        vRecommends.backgroundColor = [UIColor whiteColor];
    }else
        [vRecommends addSubview:imgv];
    [imgv release];
    
    //  推荐菜品列表
    CGRect rect = [[frameInfo objectForKey:@"List"] frameAtIndex:0];
    UITableView *tv = [[UITableView alloc] initWithFrame:rect];
    tv.delegate = self;
    tv.dataSource = self;
    [vRecommends addSubview:tv];
    [tv release];
    [tv reloadData];
    tv.backgroundColor = [UIColor clearColor];
    tv.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // 标题
    rect = [[frameInfo objectForKey:@"Title"] frameAtIndex:0];
    UILabel *lbl = [UILabel createLabelWithFrame:rect font:[UIFont systemFontOfSize:rect.size.height-2]];
    [vRecommends addSubview:lbl];
    lbl.text = [recommendInfo objectForKey:@"title"];
    
    //  确定
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = [[frameInfo objectForKey:@"Confirm"] frameAtIndex:0];
    [btn setImage:[UIImage imgWithContentsOfFile:[[recommendInfo objectForKey:@"confirm"] documentPath]] forState:UIControlStateNormal];
    [vRecommends addSubview:btn];
    [btn addTarget:self action:@selector(confirmRecommends) forControlEvents:UIControlEventTouchUpInside];
    //  取消
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = [[frameInfo objectForKey:@"Cancel"] frameAtIndex:0];
    [btn setImage:[UIImage imgWithContentsOfFile:[[recommendInfo objectForKey:@"cancel"] documentPath]] forState:UIControlStateNormal];
    [vRecommends addSubview:btn];
    [btn addTarget:self action:@selector(cancelRecommends) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark -  Actions
- (void)refreshCount{
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    NSMutableArray *ary = [dp orderedFood];
    
    NSMutableDictionary *diccount = [NSMutableDictionary dictionary];
    
    for (NSDictionary *food in ary){
        if (![[food objectForKey:@"isPack"] boolValue]){
            NSString *itcode = [[food objectForKey:@"food"] objectForKey:@"ITCODE"];
            
            float count = [[diccount objectForKey:itcode] floatValue];
            count += [[food objectForKey:@"total"] floatValue];
            
            [diccount setObject:[NSNumber numberWithInt:count] forKey:itcode];
        }
    }
    
    float ftotal = 0;
    for (int i=0;i<[aryFood count];i++){
        UILabel *lblcount = nil;
        NSString *itcode = [[aryFood objectAtIndex:i] objectForKey:@"ITCODE"];
        ftotal += [[diccount objectForKey:itcode] floatValue];
        
        lblcount = (UILabel *)[vBack viewWithTag:100+i];
        lblcount.text = [NSString stringWithFormat:@"%.1f",[[aryCount objectAtIndex:i] floatValue]];
    }
    
    UILabel *lblcount = (UILabel *)[vFront viewWithTag:100];
    lblcount.text = [NSString stringWithFormat:@"%.1f",ftotal];
}

- (void)addFood:(UIButton *)btn{
    float fcurrent = [[aryCount objectAtIndex:btn.tag] floatValue];
    fcurrent += 1.0f;
    [aryCount replaceObjectAtIndex:btn.tag withObject:[NSNumber numberWithFloat:fcurrent]];
    
    for (int i=0;i<[aryFood count];i++){
        UILabel *lblcount = (UILabel *)[vFront viewWithTag:100+i];

        lblcount = (UILabel *)[vBack viewWithTag:100+i];
        lblcount.text = [NSString stringWithFormat:@"%.1f",[[aryCount objectAtIndex:i] floatValue]];
    }
//    [self addFood:[aryFood objectAtIndex:btn.tag] byCount:@"1.0f"];
}

- (void)subtractFood:(UIButton *)btn{
    float fcurrent = [[aryCount objectAtIndex:btn.tag] floatValue];
    fcurrent -= 1.0f;
    if (fcurrent<0)
        fcurrent = 0;
    [aryCount replaceObjectAtIndex:btn.tag withObject:[NSNumber numberWithFloat:fcurrent]];
    
    for (int i=0;i<[aryFood count];i++){
        UILabel *lblcount = (UILabel *)[vFront viewWithTag:100+i];
        
        lblcount = (UILabel *)[vBack viewWithTag:100+i];
        lblcount.text = [NSString stringWithFormat:@"%.1f",[[aryCount objectAtIndex:i] floatValue]];
    }
//    [self addFood:[aryFood objectAtIndex:btn.tag] byCount:@"-1.0f"];
}

- (void)additionsClicked:(UIButton *)btn{
    UIViewController *vc = [[UIViewController alloc] init];
    pop = [[UIPopoverController alloc] initWithContentViewController:vc];
    [vc release];
    BSAddtionView *vaadition = [[BSAddtionView alloc] initWithFrame:CGRectMake(0, 0, 492, 354) info:nil];
    vaadition.delegate = self;
    [vc.view addSubview:vaadition];
    vaadition.transform = CGAffineTransformIdentity;
    [vaadition release];
    
    [pop setPopoverContentSize:CGSizeMake(492, 354)];
    pop.delegate = self;
    [pop presentPopoverFromRect:btn.frame inView:vBack permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    [popoverController release];
}

- (void)additionSelected:(NSArray *)ary{
    self.aryAddition = [NSMutableArray arrayWithArray:ary];
    
    [pop dismissPopoverAnimated:YES];
    
}

- (void)detailClicked{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowFoodDetail" object:nil userInfo:[aryFood objectAtIndex:0]];
}

- (void)confirmBack{
    BOOL bOrderedFood = NO;
    for (int i=0;i<aryCount.count;i++){
        NSDictionary *foodInfo = [aryFood objectAtIndex:i];
        float ffoodcount = [[aryCount objectAtIndex:i] floatValue];
        if (ffoodcount>0){
            bOrderedFood = YES;
            [self addFood:foodInfo byCount:[NSString stringWithFormat:@"%.1f",ffoodcount]];
        }
    }
    
    if (!bOrderedFood){
        [self addFood:[aryFood objectAtIndex:0] byCount:@"1.0"];
    }
    
    self.aryAddition = nil;
    for (int i=0;i<aryCount.count;i++){
        [aryCount replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:0]];
    }
    
    if (aryRecommends.count>0){
        if (!vRecommends)
            [self addRecommendsView];
        
        if (!vRecommends.superview){
            
            [UIView transitionWithView:self
                              duration:1
                               options:UIViewAnimationOptionTransitionFlipFromRight
                            animations:^{
                                [vFront removeFromSuperview];
                                [vBack removeFromSuperview];
                                [self addSubview:vRecommends];
                            }
                            completion:NULL];
        }
    }else
        [self backToFront];
    
    [self refreshOrderStatus];
    [self refreshCount];
    
}

- (void)confirmRecommends{
    for (NSDictionary *food in aryRecommends){
        if ([[food objectForKey:@"selected"] boolValue])
            [self addFood:food byCount:@"1.0f"];
    }
    
    
    [self backToFront];
}

- (void)cancelRecommends{
    [self backToFront];
}

#pragma mark -  UITableView Delegate & Data Source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"FoodRecommendsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        
        float h = [self tableView:tableView heightForRowAtIndexPath:indexPath];
        UIImageView *imgv = [[UIImageView alloc] initWithFrame:CGRectMake(5, h-1, tableView.frame.size.width-10, 1)];
        imgv.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3f];
        [cell.contentView addSubview:imgv];
        [imgv release];
    }
    
    NSDictionary *foodInfo = [aryRecommends objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [foodInfo objectForKey:@"DES"];
    [cell.imageView setImage:[UIImage imgWithContentsOfFile:[[foodInfo objectForKey:@"picBig"] documentPath]]];
    
    BOOL bchosed = [[foodInfo objectForKey:@"selected"] boolValue];
    
    cell.accessoryType = bchosed?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return aryRecommends.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    float fdefault = 40;
    float fheight = [[[dicInfo objectForKey:@"recommends"] objectForKey:@"height"] floatValue];
    
    return fheight>0?fheight:fdefault;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableDictionary *foodInfo = [NSMutableDictionary dictionaryWithDictionary:[aryRecommends objectAtIndex:indexPath.row]];
    
    [foodInfo setObject:[NSNumber numberWithBool:![[foodInfo objectForKey:@"selected"] boolValue]] forKey:@"selected"];
    [aryRecommends replaceObjectAtIndex:indexPath.row withObject:foodInfo];
    
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

@end
