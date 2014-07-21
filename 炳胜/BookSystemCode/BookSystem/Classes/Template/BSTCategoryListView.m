//
//  BSTCategoryListView.m
//  BookSystem
//
//  Created by Stan Wu on 12-9-3.
//
//

#import "BSTCategoryListView.h"
#import "BSCategoryViewController.h"
#import "BSDataProvider.h"

@implementation BSTCategoryListView

- (id)initWithFrame:(CGRect)frame info:(NSDictionary *)info
{
    self = [super initWithFrame:frame info:info];
    if (self) {
        NSArray *aryDict = [info objectForKey:@"categories"];

        // Initialization code
        for (int i=0;i<[aryDict count];i++){

            NSDictionary *dataDict = [aryDict objectAtIndex:i];
            
            MainMenuCell *cell = [[MainMenuCell alloc] initWithInfo:dataDict pageColor:pageColor];
            
            cell.opaque = YES;
            cell.tag = i;
            cell.delegate = self;
            [self addSubview:cell];
            [cell release];
        }
    }
    return self;
}


- (void)cellSelected:(id)sender{
    int index = [(UIButton *)sender tag];
    
    NSDictionary *dict = [[dicInfo objectForKey:@"categories"] objectAtIndex:index];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowCategoryDetail" object:nil userInfo:dict];    
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
