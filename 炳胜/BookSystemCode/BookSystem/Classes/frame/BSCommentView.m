//
//  BSCommentView.m
//  BookSystem
//
//  Created by Wu Stan on 12-3-6.
//  Copyright (c) 2012年 CheersDigi. All rights reserved.
//

#import "BSCommentView.h"

@implementation BSCommentView
- (void)setLevel:(NSUInteger)d{
    level = d;
    
    for (int i=0;i<5;i++){
        UIButton *btn = (UIButton *)[self viewWithTag:777+i];
        btn.selected = i<d?YES:NO;
    }
}

- (NSUInteger)level{
    return level;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.frame = CGRectMake(frame.origin.x, frame.origin.y, 435-2*4*2, 31);
        
        for (int i=0;i<5;i++){
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(i*(32+2), 0, 32, 31);
            btn.tag = 777+i;
            [btn setImage:[UIImage imageNamed:@"emptystar.png"] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"fullstar.png"] forState:UIControlStateSelected];
            [btn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:btn];
        }
    }
    return self;
}

- (void)buttonClicked:(UIButton *)btn{
    self.level = btn.tag-777+1;
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
