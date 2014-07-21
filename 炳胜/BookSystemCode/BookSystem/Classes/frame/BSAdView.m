//
//  BSAdView.m
//  BookSystem
//
//  Created by Dream on 11-3-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BSAdView.h"
#import "BSDataProvider.h"
#import <stdlib.h>
#import <time.h>

@implementation BSAdView
@synthesize imgvAD;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        adIndex = 0;
        imgvAD= [[UIImageView alloc] initWithFrame:self.bounds];
        
        [self addSubview:imgvAD];
        [imgvAD release];
        
        [self changeAD:ADChangeTypeShuffle];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAD:) name:@"kNotificationUpdateAD" object:nil];
        // Initialization code
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}


- (void)changeAD:(ADChangeType)type{
    int selectedIndex;
    
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    NSArray *aryADs = [dp getADNames];
    int total = [aryADs count];
    if (ADChangeTypeCircle==type){
        adIndex++;
        if (adIndex>=total)
            adIndex = 0;
        selectedIndex = adIndex;
    }
    else{
        srandom(time(NULL));
       selectedIndex = random()%total;
    }
    NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docPath = [docPaths objectAtIndex:0];
    
    NSString *path = [docPath stringByAppendingPathComponent:[aryADs objectAtIndex:selectedIndex]];
    
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:path];
    
    [imgvAD setImage:img];
    
    [img release];
    
}


- (void)updateAD:(NSNotification *)notification{
    BOOL bNeedUpdate = NO;
    
    if (self.superview!=nil && self.superview.superview!=nil)
        bNeedUpdate = YES;
    
    if (bNeedUpdate)
        [self changeAD:ADChangeTypeCircle];
}
@end
