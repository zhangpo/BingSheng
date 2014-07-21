//
//  BSSwitchTableView.m
//  BookSystem
//
//  Created by Dream on 11-7-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BSSwitchTableView.h"
#import "CVLocalizationSetting.h"

@implementation BSSwitchTableView
@synthesize delegate,tfOldTable,tfNewTable;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
        // Initialization code
        [self setTitle:[langSetting localizedString:@"Change Table"]];
        
        lblUser = [[UILabel alloc] initWithFrame:CGRectMake(15, 80, 80, 30)];
        lblUser.textAlignment = UITextAlignmentRight;
        lblUser.backgroundColor = [UIColor clearColor];
        lblUser.text = [langSetting localizedString:@"User:"];
        [self addSubview:lblUser];
        [lblUser release];
        
        lblPwd = [[UILabel alloc] initWithFrame:CGRectMake(15, 130, 80, 30)];
        lblPwd.textAlignment = UITextAlignmentRight;
        lblPwd.backgroundColor = [UIColor clearColor];
        lblPwd.text = [langSetting localizedString:@"Password:"];
        [self addSubview:lblPwd];
        [lblPwd release];
        
        lblOldTable = [[UILabel alloc] initWithFrame:CGRectMake(15, 180, 80, 30)];
        lblOldTable.textAlignment = UITextAlignmentRight;
        lblOldTable.backgroundColor = [UIColor clearColor];
        lblOldTable.text = [langSetting localizedString:@"From Table:"];//@"当前台位:";
        [self addSubview:lblOldTable];
        [lblOldTable release];
        
        lblNewTable = [[UILabel alloc] initWithFrame:CGRectMake(15, 230, 80, 30)];
        lblNewTable.textAlignment = UITextAlignmentRight;
        lblNewTable.backgroundColor = [UIColor clearColor];
        lblNewTable.text = [langSetting localizedString:@"To Table:"];//@"目标台位:";
        [self addSubview:lblNewTable];
        [lblNewTable release];
        
        
        
        tfUser = [[UITextField alloc] initWithFrame:CGRectMake(100, 80, 350, 30)];
        tfPwd = [[UITextField alloc] initWithFrame:CGRectMake(100, 130, 350, 30)];
        tfOldTable = [[UITextField alloc] initWithFrame:CGRectMake(100, 180, 350, 30)];
        tfNewTable = [[UITextField alloc] initWithFrame:CGRectMake(100, 230, 350, 30)];
        tfUser.borderStyle = UITextBorderStyleRoundedRect;
        tfPwd.borderStyle = UITextBorderStyleRoundedRect;
        tfOldTable.borderStyle = UITextBorderStyleRoundedRect;
        tfNewTable.borderStyle = UITextBorderStyleRoundedRect;
        
        tfPwd.secureTextEntry = YES;
        
        
        [self addSubview:tfUser];
        [self addSubview:tfPwd];
        [self addSubview:tfOldTable];
        [self addSubview:tfNewTable];
        
        [tfUser release];
        [tfPwd release];
        [tfOldTable release];
        [tfNewTable release];
        
        btnConfirm = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnConfirm.frame = CGRectMake(105, 265, 100, 30);
        [btnConfirm setTitle:[langSetting localizedString:@"OK"] forState:UIControlStateNormal];
        [self addSubview:btnConfirm];
        btnConfirm.tag = 700;
        [btnConfirm addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
        
        btnCancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnCancel.frame = CGRectMake(245, 265, 100, 30);
        [btnCancel setTitle:[langSetting localizedString:@"Cancel"] forState:UIControlStateNormal];
        [self addSubview:btnCancel];
        btnCancel.tag = 701;
        [btnCancel addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        
        tfUser.text = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"username"];
        tfPwd.text = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"password"];
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
    self.tfOldTable = nil;
    self.tfNewTable = nil;
    self.delegate = nil;
    [super dealloc];
}

- (void)confirm{
    CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
    if ([tfUser.text length]<=0 || [tfOldTable.text length]<=0 || [tfNewTable.text length]<=0 || tfPwd.text.length<=0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Error"] message:[langSetting localizedString:@"User or Password or Table could not be empty"] delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    else{
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:tfUser.text forKey:@"user"];
        [dic setObject:tfPwd.text forKey:@"pwd"];
        if ([tfOldTable.text length]>0)
            [dic setObject:tfOldTable.text forKey:@"oldtable"];
        if ([tfNewTable.text length]>0)
            [dic setObject:tfNewTable.text forKey:@"newtable"];
        
        [delegate switchTableWithOptions:dic];
    }
}

- (void)cancel{
    [delegate switchTableWithOptions:nil];
}

@end
