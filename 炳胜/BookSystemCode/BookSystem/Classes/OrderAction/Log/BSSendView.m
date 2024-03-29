//
//  BSSendView.m
//  BookSystem
//
//  Created by Dream on 11-5-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BSSendView.h"
#import "BSDataProvider.h"
#import "CVLocalizationSetting.h"

@implementation BSSendView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
        [self setTitle:[langSetting localizedString:@"Send Order"]];//@"发送菜品"];
        
        lblAcct = [[UILabel alloc] initWithFrame:CGRectMake(15, 80, 50, 30)];
        lblAcct.textAlignment = UITextAlignmentRight;
        lblAcct.backgroundColor = [UIColor clearColor];
        lblAcct.text = [langSetting localizedString:@"User:"];//@"工号:";
        [self addSubview:lblAcct];
        [lblAcct release];
        
        lblPwd = [[UILabel alloc] initWithFrame:CGRectMake(15, 130, 50, 30)];
        lblPwd.textAlignment = UITextAlignmentRight;
        lblPwd.backgroundColor = [UIColor clearColor];
        lblPwd.text = [langSetting localizedString:@"Password:"];//@"密码:";
        [self addSubview:lblPwd];
        [lblPwd release];
        
        lblTable = [[UILabel alloc] initWithFrame:CGRectMake(15, 180, 50, 30)];
        lblTable.textAlignment = UITextAlignmentRight;
        lblTable.backgroundColor = [UIColor clearColor];
        lblTable.text = [langSetting localizedString:@"Table:"];//@"台号:";
        [self addSubview:lblTable];
        [lblTable release];
        
        lblPeople = [[UILabel alloc] initWithFrame:CGRectMake(15, 230, 50, 30)];
        lblPeople.textAlignment = UITextAlignmentRight;
        lblPeople.backgroundColor = [UIColor clearColor];
        lblPeople.text = [langSetting localizedString:@"People:"];//@"人数:";
        [self addSubview:lblPeople];
        [lblPeople release];
        
        
        
        tfAcct = [[UITextField alloc] initWithFrame:CGRectMake(70, 80, 380, 30)];
        tfPwd = [[UITextField alloc] initWithFrame:CGRectMake(70, 130, 380, 30)];
        tfTable = [[UITextField alloc] initWithFrame:CGRectMake(70, 180, 380, 30)];
//        tfTable.delegate=self;
        if ([BSDataProvider sharedInstance].userTable) {
            tfTable.text=[BSDataProvider sharedInstance].userTable;
//            tfTable.enabled = NO;
        }
        tfPeople = [[UITextField alloc] initWithFrame:CGRectMake(70, 230, 380, 30)];
        tfAcct.borderStyle = UITextBorderStyleRoundedRect;
        tfPwd.borderStyle = UITextBorderStyleRoundedRect;
        tfTable.borderStyle = UITextBorderStyleRoundedRect;
        tfPeople.borderStyle = UITextBorderStyleRoundedRect;
        
        tfPeople.keyboardType = UIKeyboardTypeNumberPad;
        
        
        tfPwd.secureTextEntry = YES;
        
        [self addSubview:tfAcct];
        [self addSubview:tfPwd];
        [self addSubview:tfTable];
        [self addSubview:tfPeople];
        
        [tfAcct release];
        [tfPwd release];
        [tfTable release];
        [tfPeople release];
        
        btnSendNow = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnSendNow.frame = CGRectMake(40, 265, 100, 30);
        [btnSendNow setTitle:[langSetting localizedString:@"Send"]/*@"即起上传"*/ forState:UIControlStateNormal];
        [self addSubview:btnSendNow];
        btnSendNow.tag = 700;
        [btnSendNow addTarget:self action:@selector(sendOrder:) forControlEvents:UIControlEventTouchUpInside];
        
        //        btnSendWait = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        //        btnSendWait.frame = CGRectMake(180, 265, 100, 30);
        //        [btnSendWait setTitle:[langSetting localizedString:@"Send Hold"]/*@"叫起上传"*/ forState:UIControlStateNormal];
        //        [self addSubview:btnSendWait];
        //        btnSendWait.tag = 701;
        //        [btnSendWait addTarget:self action:@selector(sendOrder:) forControlEvents:UIControlEventTouchUpInside];
        
        
        btnCancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnCancel.frame = CGRectMake(320, 265, 100, 30);
        [btnCancel setTitle:[langSetting localizedString:@"Cancel"] forState:UIControlStateNormal];
        [self addSubview:btnCancel];
        [btnCancel addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        
        tfAcct.text = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"username"];
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
    [super dealloc];
}

- (void)sendOrder:(UIButton *)btn{
    int tag = btn.tag;
    
    BOOL bAuth = NO;
    tfTable.text=[tfTable.text lowercaseString];
    
    if ([tfAcct.text length]>0 && [tfPwd.text length]>0 && [tfTable.text length]>0)
        bAuth = YES;
    
    if (bAuth){
        NSDictionary *dict;
        if ([tfPeople.text length]<=0)
            tfPeople.text = @"0";
        if (700==tag){
            dict = [NSDictionary dictionaryWithObjectsAndKeys:tfAcct.text,@"user",tfPwd.text,@"pwd",tfTable.text,@"table",tfPeople.text,@"pn",@"N",@"type", nil];
        }
        else{
            dict = [NSDictionary dictionaryWithObjectsAndKeys:tfAcct.text,@"user",tfPwd.text,@"pwd",tfTable.text,@"table",tfPeople.text,@"pn",@"Y",@"type", nil];
        }
        [delegate sendOrderWithOptions:dict];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"工号密码和台位不能为空" message:@"请重新输入再尝试发送" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    
}

- (void)cancel{
    [delegate sendOrderWithOptions:nil];
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    //  判断输入的是否为数字 (只能输入数字)输入其他字符是不被允许的
    textField.text=[textField.text uppercaseString];
    return YES;
    
}
-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    textField.text=[textField.text uppercaseString];
    return YES;
}

@end
