//
//  MainMenuCell.m
//  BookSystem
//
//  Created by Dream on 11-3-16.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "MainMenuCell.h"
#import <QuartzCore/QuartzCore.h>
#import "BSDataProvider.h"

@implementation MainMenuCell
@synthesize delegate;
@synthesize imgvPic,imgvName;
@synthesize lblName;

- (id)initWithInfo:(NSDictionary *)info pageColor:(UIColor *)color{
    self = [super init];
    if (self){
        NSDictionary *classdict = [[BSDataProvider sharedInstance] getClassByID:[info objectForKey:@"classid"]];
        CGRect frame = CGRectFromString([info objectForKey:@"frame"]);
        self.frame = frame;
        
        float h = [[info objectForKey:@"height"] floatValue];
        UIFont *font = [UIFont systemFontOfSize:[[info objectForKey:@"font"] floatValue]];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = self.bounds;
        [btn setBackgroundImage:[UIImage imageWithContentsOfFile:[[classdict objectForKey:@"image"] documentPath]]
                       forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        
        
        lblName = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height-h, frame.size.width, h)];
        [btn addSubview:lblName];
        [lblName release];
        lblName.font = font;
        lblName.textColor = color;
        lblName.backgroundColor = [UIColor colorWithWhite:1 alpha:.5f];
        lblName.textAlignment = UITextAlignmentCenter;
        lblName.text = [classdict objectForKey:@"DES"];

        self.opaque = YES;

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

- (void)btnClicked{
    [self.delegate cellSelected:self];
}

- (void)showData:(NSDictionary *)dict{
    
    NSString *name = [dict objectForKey:@"DES"];
    lblName.text = name;
    [lblName sizeToFit];
    lblName.center = imgvName.center;
    NSString *image = [dict objectForKey:@"image"];
    [NSThread detachNewThreadSelector:@selector(showImage:) toTarget:self withObject:image];
}

- (void)showImage:(NSString *)str{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
//    
//    NSURL *url = [NSURL URLWithString:str];
//    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
//    UIImage *img = [[UIImage alloc] initWithData:data];
//    [imgvPic setImage:img];
//    [img release];
//    [data release];
    NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docPath = [docPaths objectAtIndex:0];
    NSString *path = [docPath stringByAppendingPathComponent:str];
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:path];
    [imgvPic setImage:img];
    [img release];
    

    
    [pool release];
}

- (void)removeOtherViews:(UIImage *)img{
    [imgvPic removeFromSuperview];

    
    [btnCover setImage:img forState:UIControlStateNormal];
    [btnCover setImage:img forState:UIControlStateHighlighted];
    [btnCover setImage:img forState:UIControlStateSelected];
}


@end
