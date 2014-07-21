//
//  BSTCategoryDetailView.m
//  BookSystem
//
//  Created by Wu Stan on 12-5-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BSTCategoryDetailView.h"
#import "BSTFoodCell.h"

@implementation BSTCategoryDetailView

- (id)initWithFrame:(CGRect)frame info:(NSDictionary *)info
{
    self = [super initWithFrame:frame info:info];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        // Initialization code
        NSArray *foods = [info objectForKey:@"foods"];
        
        for (int i=0;i<[foods count];i++){
            BSTFoodCell *cell = [[BSTFoodCell alloc] initWithInfo:[foods objectAtIndex:i] pageColor:pageColor];
            [self addSubview:cell];
            [cell release];
            
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

@end
