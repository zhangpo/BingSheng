//
//  BSRecommendGridView.m
//  BookSystem
//
//  Created by Stan Wu on 12-9-9.
//
//

#import "BSRecommendGridView.h"

@implementation BSRecommendGridView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.6];
        
        scvContent = [[UIScrollView alloc] initWithFrame:self.bounds];
        [self addSubview:scvContent];
        [scvContent release];
        
        UILabel *lbl = [UILabel createLabelWithFrame:CGRectMake(10, 10, 500, 20) font:[UIFont systemFontOfSize:18]];
        lbl.text = @"点过这道菜的客户还点过:";
        [self addSubview:lbl];
        
        
    }
    return self;
}

- (void)setAryFoods:(NSArray *)ary{
    if (aryFoods!=ary){
        [aryFoods release];
        aryFoods = [ary retain];
        
        [self showFoods];
    }
}

- (NSArray *)aryFoods{
    return aryFoods;
}

- (void)showFoods{
    for (UIView *v in scvContent.subviews)
        [v removeFromSuperview];
    
    [scvContent setContentSize:CGSizeMake(MAX(scvContent.frame.size.width, 5+60*aryFoods.count), scvContent.frame.size.height)];
    
    for (int i=0;i<[aryFoods count];i++){
        NSDictionary *dic = [aryFoods objectAtIndex:i];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(5+60*i, 25, 50, 50);
        UIImage *img = [UIImage imageWithContentsOfFile:[[dic objectForKey:@"picSmall"] documentPath]];
        [btn setBackgroundImage:img forState:UIControlStateNormal];
        [scvContent addSubview:btn];
        btn.tag = i;
        [btn addTarget:self action:@selector(foodClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *lbl = [UILabel createLabelWithFrame:CGRectMake(5+60*i, 80, 50, 15) font:[UIFont systemFontOfSize:15]];
        lbl.textAlignment = UITextAlignmentCenter;
        [scvContent addSubview:lbl];
        lbl.text = [dic objectForKey:@"DES"];
        lbl.userInteractionEnabled = NO;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    if (self.hidden){
        self.alpha = 0;
        self.hidden = NO;
        [UIView animateWithDuration:1.0f animations:^{
            self.alpha = 1;
        }completion:^(BOOL finished) {
            [self performSelector:@selector(hideSelf) withObject:nil afterDelay:5];
            
        }];
    }else{
        [self performSelector:@selector(hideSelf) withObject:nil afterDelay:5];
    }
    
}

- (void)foodClicked:(UIButton *)btn{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self hideSelf];
    NSDictionary *dic = [aryFoods objectAtIndex:btn.tag];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowFoodDetail" object:nil userInfo:dic];
}

- (void)hideSelf{
    [UIView animateWithDuration:.5f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
