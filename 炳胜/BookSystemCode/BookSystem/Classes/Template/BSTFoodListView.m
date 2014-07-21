//
//  BSTFoodListView.m
//  BookSystem
//
//  Created by Wu Stan on 12-6-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BSTFoodListView.h"
#import "BSDataProvider.h"
#import <QuartzCore/QuartzCore.h>
#import "BSTFoodCell.h"

@implementation BSTFoodListView

- (id)initWithFrame:(CGRect)frame info:(NSDictionary *)info
{
    self = [super initWithFrame:frame info:info];
    if (self) {
        // Initialization code
        NSArray *foods = [info objectForKey:@"foods"];
        
        NSMutableArray *itcodes = [NSMutableArray array];
        for (NSDictionary *food in foods){
            NSString *stritcode = [food objectForKey:@"ITCODE"];
            [itcodes addObjectsFromArray:[stritcode componentsSeparatedByString:@","]];
        }
        
        NSMutableString *mutstr = [NSMutableString string];
        [mutstr appendString:@"select * from food where "];
        for (int i=0;i<itcodes.count;i++){
            if (0!=i)
                [mutstr appendFormat:@"or ITCODE = '%@' ",[itcodes objectAtIndex:i]];
            else
                [mutstr appendFormat:@"ITCODE = '%@' ",[itcodes objectAtIndex:i]];
        }
        NSArray *ary = [BSDataProvider getDataFromSQLByCommand:mutstr];
        if ([ary isKindOfClass:[NSDictionary class]])
            ary = [NSArray arrayWithObject:ary];
        
        for (int i=0;i<[foods count];i++){
            NSMutableDictionary *foodInfo = [NSMutableDictionary dictionaryWithDictionary:[foods objectAtIndex:i]];
            if (ary.count>0)
                [foodInfo setObject:ary forKey:@"infos"];
            BSTFoodCell *food = [[BSTFoodCell alloc] initWithInfo:foodInfo pageColor:pageColor];
            [self addSubview:food];
            [food release];
        }
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)refreshCount{
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    NSMutableArray *ary = [dp orderedFood];
    
    NSMutableDictionary *diccount = [NSMutableDictionary dictionary];
    
    for (NSDictionary *food in ary){
        if (![food objectForKey:@"addition"] && ![[food objectForKey:@"isPack"] boolValue]){
            NSString *itcode = [[food objectForKey:@"food"] objectForKey:@"ITCODE"];
            
            float count = [[diccount objectForKey:itcode] floatValue];
            count += [[food objectForKey:@"total"] intValue];
            
            [diccount setObject:[NSNumber numberWithInt:count] forKey:itcode];
        }
    }
    
    NSArray *foods = [dicInfo objectForKey:@"foods"];
    for (int i=0;i<[foods count];i++){
        UILabel *lblcount = (UILabel *)[self viewWithTag:100+i];
        NSString *itcode = [[foods objectAtIndex:i] objectForKey:@"ITCODE"];
        lblcount.text = [NSString stringWithFormat:@"%.1f",[[diccount objectForKey:itcode] floatValue]];
    }
}

- (void)photoClicked:(UIButton *)btn{
    NSArray *foods = [dicInfo objectForKey:@"foods"];
    NSDictionary *food = [foods objectAtIndex:btn.tag];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowFoodDetail" object:nil userInfo:food];
}



- (void)plusClicked:(UIButton *)btn{
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    NSArray *foods = [dicInfo objectForKey:@"foods"];
    NSDictionary *foodInfo = (NSDictionary *)[BSDataProvider getDataFromSQLByCommand:[NSString stringWithFormat:@"select * from food where ITCODE = %@",[[foods objectAtIndex:btn.tag] objectForKey:@"ITCODE"]]];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:foodInfo forKey:@"food"];
    [dict setObject:@"1.00" forKey:@"total"];
    
    BOOL bFinded = NO;
    NSMutableArray *ary = [dp orderedFood];
    NSString *itcode = [[foods objectAtIndex:btn.tag] objectForKey:@"ITCODE"];
    for (NSDictionary *food in ary){
        if (![food objectForKey:@"addition"]
            && ![[food objectForKey:@"isPack"] boolValue]
            && [[[food objectForKey:@"food"] objectForKey:@"ITCODE"] isEqualToString:itcode]){
            bFinded = YES;
            float total = [[food objectForKey:@"total"] floatValue];
            total += 1.0f;
            
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
    if (!bFinded)
        [dp orderFood:dict];
    
    
    [self refreshCount];
    
    CGRect rect = CGRectZero;
    
    if ([foods count]>1)
        rect = CGRectFromString([[[foods objectAtIndex:btn.tag] objectForKey:@"frame"] objectForKey:@"Photo"]);
    else
        rect = CGRectMake(0, 0, 768, 1004);
    
    UIImageView *imgv = [[UIImageView alloc] initWithFrame:rect];
    [self addSubview:imgv];
    [imgv release];
    NSString *imgname = [foodInfo objectForKey:@"picBig"];
    [imgv setImage:[UIImage imageWithContentsOfFile:[imgname documentPath]]];
    
    
    [UIView animateWithDuration:0.3f animations:^{
        imgv.frame = CGRectMake(344, 40, 80, 80);
    }completion:^(BOOL finished) {
        //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[langSetting localizedString:@"Food Ordered"] delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
        //        [alert show];
        //        [alert release];
        
        [imgv removeFromSuperview];
    }];
    
    //  点此菜的用户还点过
    if ([[foods objectAtIndex:btn.tag] objectForKey:@"recommends"]){
        NSArray *recommends = [[foods objectAtIndex:btn.tag] objectForKey:@"recommends"];
        NSMutableArray *mut = [NSMutableArray array];
        for (int i=0;i<[recommends count];i++){
            NSDictionary *foodInfo = (NSDictionary *)[BSDataProvider getDataFromSQLByCommand:[NSString stringWithFormat:@"select * from food where ITCODE = %@",[recommends objectAtIndex:i]]];
            if (foodInfo)
                [mut addObject:foodInfo];
        }
        
        if ([mut count]>0){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowRecommendGrid" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:mut,@"foods", nil]];
        }
        
    }
    
}

- (void)minusClicked:(UIButton *)btn{
    NSLog(@"Minus Clicked");
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    UILabel *lbl = (UILabel *)[self viewWithTag:100+btn.tag];
    float count = [lbl.text floatValue];
    NSArray *foods = [dicInfo objectForKey:@"foods"];
    NSString *itcode = [[foods objectAtIndex:btn.tag] objectForKey:@"ITCODE"];
    
    if (count>0){
        BOOL bFinded = NO;
        NSMutableArray *ary = [dp orderedFood];
        for (NSDictionary *food in ary){
            if (![food objectForKey:@"addition"]
                && ![[food objectForKey:@"isPack"] boolValue]
                && [[[food objectForKey:@"food"] objectForKey:@"ITCODE"] isEqualToString:itcode]){
                bFinded = YES;
                float total = [[food objectForKey:@"total"] floatValue];
                total -= 1;
                
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
        [self refreshCount];
    }
}

@end
