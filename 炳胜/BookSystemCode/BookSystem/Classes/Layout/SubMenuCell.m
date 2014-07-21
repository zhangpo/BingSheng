//
//  SubMenuCell.m
//  BookSystem
//
//  Created by Dream on 11-3-23.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "SubMenuCell.h"


@implementation SubMenuCell
@synthesize delegate;
@synthesize imgvPic,imgvPap;
@synthesize lblNameCN,lblNameEn,lblPrice,lblWeight;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        imgvPic = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 180, 160)];
        imgvPap = [[UIImageView alloc] initWithFrame:CGRectMake(195, 91, 95, 23)];
        imgvPic.opaque = YES;
        imgvPap.opaque = YES;
    
        
        lblNameCN = [[UILabel alloc] initWithFrame:CGRectMake(195, 0, 140, 40)];
        lblNameEn = [[UILabel alloc] initWithFrame:CGRectMake(195, 40, 140, 40)];
        lblNameCN.numberOfLines = 2;
        lblNameEn.numberOfLines = 2;
        lblWeight = [[UILabel alloc] initWithFrame:CGRectMake(195, 116, 75, 20)];
        lblPrice = [[UILabel alloc] initWithFrame:CGRectMake(195, 138, 75, 20)];
        lblNameCN.textColor = [UIColor blackColor];
        lblNameEn.textColor = [UIColor darkGrayColor];
        lblWeight.textColor = [UIColor blackColor];
        lblPrice.textColor = [UIColor blackColor];
        lblNameCN.backgroundColor = [UIColor clearColor];
        lblNameEn.backgroundColor = [UIColor clearColor];
        lblWeight.backgroundColor = [UIColor clearColor];
        lblPrice.backgroundColor = [UIColor clearColor];
        
//        [self addSubview:imgvPic];
//        [self addSubview:imgvPap];
//        [self addSubview:lblNameCN];
//        [self addSubview:lblNameEn];
//        [self addSubview:lblWeight];
//        [self addSubview:lblPrice];
        
        UIButtonEx *btn = [UIButtonEx buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor = [UIColor clearColor];
//        btn.opaque = YES;
        [btn addTarget:self action:@selector(btnClicked) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = self.bounds;
        
        [btn addSubview:lblNameCN];
        [btn addSubview:lblNameEn];
        [btn addSubview:lblWeight];
        [btn addSubview:lblPrice];
        [btn addSubview:imgvPic];
        [btn addSubview:imgvPap];
        
        [self addSubview:btn];
        
        [lblNameCN release];
        [lblNameEn release];
        [lblWeight release];
        [lblPrice release];
        [imgvPic release];
        [imgvPap release];
        
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
    self.delegate = nil;
    [super dealloc];
}

- (void)showData:(NSDictionary *)dict{
    NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docPath = [docPaths objectAtIndex:0];
    
    NSString *pathPic = [docPath stringByAppendingPathComponent:[dict objectForKey:@"picSmall"]];
    NSString *pathPap = [docPath stringByAppendingPathComponent:[dict objectForKey:@"pap"]];
    UIImage *imgPic = [[UIImage alloc] initWithContentsOfFile:pathPic];
    UIImage *imgPap = [[UIImage alloc] initWithContentsOfFile:pathPap];
    [imgvPic setImage:imgPic];
    [imgvPap setImage:imgPap];
    [imgvPap sizeToFit];
    CGRect rect = imgvPap.frame;
    imgvPap.frame = CGRectMake(195,91
                               
                               , rect.size.width, rect.size.height);
    lblNameCN.text = [dict objectForKey:@"DES"];
    lblNameEn.text = [dict objectForKey:@"DESCE"];
    lblWeight.text = [dict objectForKey:@"UNIT"];
    lblPrice.text = [dict objectForKey:[[NSUserDefaults standardUserDefaults] stringForKey:@"price"]];
    
//    [lblNameCN sizeToFit];
//    [lblNameEn sizeToFit];
//    [lblWeight sizeToFit];
//    [lblPrice sizeToFit];
    [imgPic release];
    [imgPap release];
    
}

- (void)btnClicked{
    [self.delegate cellSelected:self];
}
@end
