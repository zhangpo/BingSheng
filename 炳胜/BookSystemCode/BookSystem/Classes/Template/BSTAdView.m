//
//  BSTAdView.m
//  BookSystem
//
//  Created by Wu Stan on 12-6-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BSTAdView.h"

@implementation BSTAdView

- (id)initWithFrame:(CGRect)frame info:(NSDictionary *)info
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:[info objectForKey:@"image"]];
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:path]];
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
