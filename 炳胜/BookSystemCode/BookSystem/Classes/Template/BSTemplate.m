//
//  BSTemplate.m
//  BookSystem
//
//  Created by Wu Stan on 12-5-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BSTemplate.h"

@implementation BSTemplate
@synthesize dicInfo,vcParent,bActivated,pageColor;

- (void)dealloc{
    self.dicInfo = nil;
    self.vcParent = nil;
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame info:(NSDictionary *)info
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.dicInfo = info;
        self.backgroundColor = [UIColor whiteColor];
        if ([info objectForKey:@"background"]){
            
            
            NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *docPath = [docPaths objectAtIndex:0];
            NSString *path = [docPath stringByAppendingPathComponent:[info objectForKey:@"background"]];
            
            NSData *data = [[NSData alloc] initWithContentsOfFile:path];
            UIImage *img = [[UIImage alloc] initWithData:data];
            [data release];
            if (img){
                imgvBG = [[UIImageView alloc] initWithFrame:self.bounds];
                [self addSubview:imgvBG];
                [imgvBG release];
                [imgvBG setImage:img];
            }
            [img release];
        }
        
        if ([info objectForKey:@"color"]){
            NSString *strcolor = [info objectForKey:@"color"];
            NSArray *ary = [strcolor componentsSeparatedByString:@","];
            if (ary.count==4){
                self.pageColor = [UIColor colorWithRed:[[ary objectAtIndex:0] floatValue] green:[[ary objectAtIndex:1] floatValue] blue:[[ary objectAtIndex:2] floatValue] alpha:[[ary objectAtIndex:3] floatValue]];
            }else if (ary.count==3){
                self.pageColor = [UIColor colorWithRed:[[ary objectAtIndex:0] floatValue] green:[[ary objectAtIndex:1] floatValue] blue:[[ary objectAtIndex:2] floatValue] alpha:1];
            }else
                self.pageColor = [UIColor blackColor];
        }
            
        else
            self.pageColor = [UIColor blackColor];
    }
    return self;
}


@end
