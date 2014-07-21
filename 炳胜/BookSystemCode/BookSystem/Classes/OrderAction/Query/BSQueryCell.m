//
//  BSQueryCell.m
//  BookSystem
//
//  Created by Dream on 11-5-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BSQueryCell.h"


@implementation BSQueryCell
@synthesize dicInfo;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        // Initialization code
        bSelected = NO;
        
        lblName = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 200, 72)];
        lblName.numberOfLines = 3;
        lblName.backgroundColor = [UIColor clearColor];
        lblName.font = [UIFont boldSystemFontOfSize:20];
        [self.contentView addSubview:lblName];
        [lblName release];
        
        lblCount = [[UILabel alloc] initWithFrame:CGRectMake(254, 0, 67, 72)];
        lblCount.backgroundColor = [UIColor clearColor];
        lblCount.font = [UIFont boldSystemFontOfSize:20];
        [self.contentView addSubview:lblCount];
        [lblCount release];
        
        lblUnit = [[UILabel alloc] initWithFrame:CGRectMake(303, 0, 67, 72)];
        lblUnit.backgroundColor = [UIColor clearColor];
        lblUnit.font = [UIFont boldSystemFontOfSize:20];
        [self.contentView addSubview:lblUnit];
        [lblUnit release];
        
        lblPrice = [[UILabel alloc] initWithFrame:CGRectMake(372-25, 0, 67, 72)];
        lblPrice.textAlignment = UITextAlignmentRight;
        lblPrice.backgroundColor = [UIColor clearColor];
        lblPrice.font = [UIFont boldSystemFontOfSize:20];
        [self.contentView addSubview:lblPrice];
        [lblPrice release];
        
        lblTotalPrice = [[UILabel alloc] initWithFrame:CGRectMake(441-35, 0, 100, 72)];
        lblTotalPrice.textAlignment = UITextAlignmentRight;
        lblTotalPrice.backgroundColor = [UIColor clearColor];
        lblTotalPrice.font = [UIFont boldSystemFontOfSize:20];
        [self.contentView addSubview:lblTotalPrice];
        [lblTotalPrice release];
        
        lblAddition = [[UILabel alloc] initWithFrame:CGRectMake(543, 0, 150, 72)];
        lblAddition.numberOfLines = 3;
        lblAddition.backgroundColor = [UIColor clearColor];
        lblAddition.font = [UIFont boldSystemFontOfSize:16];
        [self.contentView addSubview:lblAddition];
        [lblAddition release];
        
        UILabel *lblline = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, 688, 2)];
        lblline.backgroundColor = [UIColor colorWithRed:29.0f/255.0f green:55.0f/255.0f blue:82.0f/255.0f alpha:1.0];
        [self.contentView addSubview:lblline];
        [lblline release];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    self.dicInfo = nil;
    
    [super dealloc];
}


- (void)setInfo:(NSDictionary *)dic{
    self.dicInfo = dic;
    
    lblName.text = [dic objectForKey:@"name"];
    lblCount.text = [dic objectForKey:@"total"];
    lblPrice.text =  [NSString stringWithFormat:@"%.2f",[[dic objectForKey:@"price"] floatValue]/[lblCount.text floatValue]];
    lblTotalPrice.text = [NSString stringWithFormat:@"%.2f",[lblCount.text floatValue]*[lblPrice.text floatValue]];
    lblUnit.text = [dic objectForKey:@"unit"];
    lblAddition.text = [NSString stringWithFormat:@"%@,%@",[dic objectForKey:@"add1"],[dic objectForKey:@"add2"]];
}

#pragma mark bSelected's Getter & Setter
- (BOOL)bSelected{
    return bSelected;
}

- (void)setBSelected:(BOOL)bSelected_{
    bSelected = bSelected_;
    
    if (bSelected){
        self.contentView.backgroundColor = [UIColor colorWithRed:0.0f green:155.0f/255.0f blue:52.0f/255.0f alpha:1.0f];
        for (UILabel *lbl in self.contentView.subviews){
            if ([lbl isKindOfClass:[UILabel class]])
                lbl.textColor = [UIColor whiteColor];
        }
    }
    else{
        self.contentView.backgroundColor = [UIColor clearColor];
        for (UILabel *lbl in self.contentView.subviews){
            if ([lbl isKindOfClass:[UILabel class]])
                lbl.textColor = [UIColor blackColor];
        }
    }    
}
@end
