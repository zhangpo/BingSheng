//
//  BSMovingCover.m
//  BookSystem
//
//  Created by Wu Stan on 12-4-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BSMovingCover.h"

@implementation BSMovingCover
@synthesize aryCovers;


- (void)dealloc{
    self.aryCovers = nil;
    
    [super dealloc];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.clipsToBounds = YES;
        
        imgvBG = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:imgvBG];
        [imgvBG release];
        
        imgvFirst = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:imgvFirst];
        [imgvFirst release];
        
        imgvSecond = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:imgvSecond];
        [imgvSecond release];
    }
    return self;
}

- (void)startAnimation{
    
}

- (void)stopAnimation{
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)setImage:(UIImage *)img{
    [imgvBG setImage:img];
}

@end
