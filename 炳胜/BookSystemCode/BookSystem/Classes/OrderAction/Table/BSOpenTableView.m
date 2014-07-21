//
//  BSOpenTableView.m
//  BookSystem
//
//  Created by Dream on 11-7-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BSOpenTableView.h"
#import "CVLocalizationSetting.h"

@implementation BSOpenTableView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
        self.transform = CGAffineTransformIdentity;
        
        [self setTitle:@"开台"];
        
        lblUser = [[UILabel alloc] initWithFrame:CGRectMake(15, 80, 80, 30)];
        lblUser.textAlignment = UITextAlignmentRight;
        lblUser.backgroundColor = [UIColor clearColor];
        lblUser.text = @"工号:";
        [self addSubview:lblUser];
        [lblUser release];
        
        lblPeople = [[UILabel alloc] initWithFrame:CGRectMake(15, 130, 80, 30)];
        lblPeople.textAlignment = UITextAlignmentRight;
        lblPeople.backgroundColor = [UIColor clearColor];
        lblPeople.text = @"人数:";
        [self addSubview:lblPeople];
        [lblPeople release];
        
        lblWaiter = [[UILabel alloc] initWithFrame:CGRectMake(15, 180, 80, 30)];
        lblWaiter.textAlignment = UITextAlignmentRight;
        lblWaiter.backgroundColor = [UIColor clearColor];
        lblWaiter.text = @"服务员号:";
        [self addSubview:lblWaiter];
        [lblWaiter release];
        
        
        
        tfUser = [[UITextField alloc] initWithFrame:CGRectMake(100, 80, 350, 30)];
        tfPeople = [[UITextField alloc] initWithFrame:CGRectMake(100, 130, 350, 30)];
        tfWaiter = [[UITextField alloc] initWithFrame:CGRectMake(100, 180, 350, 30)];
        tfUser.borderStyle = UITextBorderStyleRoundedRect;
        tfPeople.borderStyle = UITextBorderStyleRoundedRect;
        tfWaiter.borderStyle = UITextBorderStyleRoundedRect;
        
        
        
        [self addSubview:tfUser];
        [self addSubview:tfPeople];
        [self addSubview:tfWaiter];
        
        [tfUser release];
        [tfPeople release];
        [tfWaiter release];
        
        btnConfirm = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnConfirm.frame = CGRectMake(105, 265, 100, 30);
        [btnConfirm setTitle:@"确定" forState:UIControlStateNormal];
        [self addSubview:btnConfirm];
        btnConfirm.tag = 700;
        [btnConfirm addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
        
        btnCancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnCancel.frame = CGRectMake(245, 265, 100, 30);
        [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
        [self addSubview:btnCancel];
        btnCancel.tag = 701;
        [btnCancel addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        
        tfUser.text = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"username"];
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


- (void)confirm{
    CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
    if ([tfUser.text length]<=0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Error"] message:[langSetting localizedString:@"User could not be empty"] delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    else{
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:tfUser.text forKey:@"user"];
        
        if ([tfPeople.text length]>0)
            [dic setObject:tfPeople.text forKey:@"people"];
        if ([tfWaiter.text length]>0)
            [dic setObject:tfWaiter.text forKey:@"waiter"];
        
        [delegate openTableWithOptions:dic];
    }
}

- (void)cancel{
    [delegate openTableWithOptions:nil];
}
@end
