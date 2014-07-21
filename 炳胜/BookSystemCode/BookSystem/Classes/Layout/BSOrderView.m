//
//  BSOrderView.m
//  BookSystem
//
//  Created by Dream on 11-5-12.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BSOrderView.h"
#import "BSDataProvider.h"

@implementation BSOrderView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setTitle:@"附加项"];
        

        
        btnConfirm = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnConfirm.frame = CGRectMake(105, 265, 100, 30);
        [btnConfirm setTitle:@"退菜" forState:UIControlStateNormal];
        [self addSubview:btnConfirm];
        btnConfirm.tag = 700;
        [btnConfirm addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
        
        btnCancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnCancel.frame = CGRectMake(245, 265, 100, 30);
        [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
        [self addSubview:btnCancel];
        btnCancel.tag = 701;
        [btnCancel addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        
        
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

- (void)dealloc
{
    [super dealloc];
}

- (void)confirm{

    
    
}

- (void)cancel{
    [self removeFromSuperview];
}

@end
