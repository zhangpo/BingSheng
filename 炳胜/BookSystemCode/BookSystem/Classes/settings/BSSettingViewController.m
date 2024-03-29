//
//  BSSettingViewController.m
//  BookSystem
//
//  Created by Dream on 11-4-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BSSettingViewController.h"
#import "BSDataProvider.h"

@implementation BSSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/
- (id)initWithType:(BSSettingType)type{
    self = [super init];
    if (self){
        settingType = type;
    }
    
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

//    UILabel *lblCap = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 540, 30)];
//    lblCap.textAlignment = UITextAlignmentCenter;
//    lblCap.backgroundColor = [UIColor clearColor];
//    lblCap.font = [UIFont boldSystemFontOfSize:22];
//    lblCap.textColor = [UIColor darkGrayColor];
//    lblCap.text = @"cMenu 配置";
//    [self.view addSubview:lblCap];
//    [lblCap release];
    
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.center = CGPointMake(270, 340);
    [self.view addSubview:indicator];
    [indicator release];
    
    NSString *navTitle = nil;
    
    if (settingType==BSSettingTypeFtp){
        navTitle = @"设置FTP地址";
        btnConfirm = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnConfirm.frame = CGRectMake(0, 0, 100, 30);
        [btnConfirm setTitle:@"确认" forState:UIControlStateNormal];
        [btnConfirm addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
        
        btnCancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnCancel.frame = CGRectMake(0, 0, 100, 30);
        [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
        [btnCancel addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        tfUser = [[UITextField alloc] initWithFrame:CGRectMake(70, 150, 180, 30)];
        tfUser.autocorrectionType = UITextAutocorrectionTypeNo;
        tfUser.borderStyle = UITextBorderStyleRoundedRect;
        [self.view addSubview:tfUser];
        [tfUser release];
        
        tfPass = [[UITextField alloc] initWithFrame:CGRectMake(340, 150, 180, 30)];
        tfPass.autocorrectionType = UITextAutocorrectionTypeNo;
        tfPass.borderStyle = UITextBorderStyleRoundedRect;
        [self.view addSubview:tfPass];
        [tfPass release];
        
        tfSetting = [[UITextField alloc] initWithFrame:CGRectMake(70, 200, 450, 30)];
        tfSetting.autocorrectionType = UITextAutocorrectionTypeNo;
        tfSetting.borderStyle = UITextBorderStyleRoundedRect;
        [self.view addSubview:tfSetting];
        [tfSetting release];
        
        btnConfirm.center = CGPointMake(180, 536);
        btnCancel.center = CGPointMake(360, 536);
        
        
        [self.view addSubview:btnConfirm];
        [self.view addSubview:btnCancel];
        
        
        lblTips = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, 500, 40)];
        lblTips.numberOfLines = 3;
        lblTips.backgroundColor = [UIColor clearColor];
        lblTips.textColor = [UIColor grayColor];
        lblTips.text = @"请输入数据库文件所在文件夹的ftp地址及账号密码（匿名登陆时留空），注意，配置文件和其他资源必须在同一个目录";
        [self.view addSubview:lblTips];
        [lblTips release];
        
        lblUser = [[UILabel alloc] initWithFrame:CGRectMake(20, 150, 80, 30)];
        lblUser.backgroundColor = [UIColor clearColor];
        lblUser.textColor = [UIColor grayColor];
        lblUser.text = @"账号:";
        [self.view addSubview:lblUser];
        [lblUser release];
        
        lblPass = [[UILabel alloc] initWithFrame:CGRectMake(290, 150, 80, 30)];
        lblPass.backgroundColor = [UIColor clearColor];
        lblPass.textColor = [UIColor grayColor];
        lblPass.text = @"密码:";
        [self.view addSubview:lblPass];
        [lblPass release];
        
        lblSetting = [[UILabel alloc] initWithFrame:CGRectMake(20, 200, 80, 30)];
        lblSetting.backgroundColor = [UIColor clearColor];
        lblSetting.textColor = [UIColor grayColor];
        lblSetting.text = @"IP:";
        [self.view addSubview:lblSetting];
        [lblSetting release];
        

        

        NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docPath = [docPaths objectAtIndex:0];
        NSString *settingPath = [docPath stringByAppendingPathComponent:@"setting.plist"];
        
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:settingPath];
        NSString *str = [dict objectForKey:@"url"];
        if (!str)
            str = kPathHeader;
//        str = [str stringByAppendingPathComponent:@"BookSystem.sqlite"];
        
        lblPath = [[UILabel alloc] initWithFrame:CGRectMake(0, 240, 540, 30)];
        lblPath.textAlignment = UITextAlignmentCenter;
        lblPath.backgroundColor = [UIColor clearColor];
        lblPath.textColor = [UIColor grayColor];
        lblPath.text = [NSString stringWithFormat:@"当前地址:%@",str];
        [self.view addSubview:lblPath];
        [lblPath release];
        
        lblChecking = [[UILabel alloc] initWithFrame:CGRectZero];
        lblChecking.textColor = [UIColor darkGrayColor];
        lblChecking.backgroundColor = [UIColor clearColor];
        lblChecking.text = @"正在检查地址是否正确";
        [lblChecking sizeToFit];
        lblChecking.center = CGPointMake(270, 260);
        [self.view addSubview:lblChecking];
        [lblChecking release];
        lblChecking.hidden = YES;
        indicator.hidden = YES;
        
    }
    else if (settingType==BSSettingTypeUpdate){
        navTitle = @"更新资料";
        lblDownloading = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 20)];
        lblDownloading.backgroundColor = [UIColor clearColor];
        lblDownloading.textColor = [UIColor darkGrayColor];
        lblDownloading.text = @"正在下载最新数据";
        lblDownloading.textAlignment = UITextAlignmentCenter;
//        [lblDownloading sizeToFit];
        lblDownloading.center = CGPointMake(270, 260);
        [self.view addSubview:lblDownloading];
        [lblDownloading release];
        indicator.hidden = NO;
        [indicator startAnimating];
        
        [NSThread detachNewThreadSelector:@selector(download) toTarget:self withObject:nil];
    }
    else if (settingType==BSSettingTypeSocket){
        navTitle = @"设置IP地址";
        btnConfirm = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnConfirm.frame = CGRectMake(0, 0, 100, 30);
        [btnConfirm setTitle:@"确认" forState:UIControlStateNormal];
        [btnConfirm addTarget:self action:@selector(setIP) forControlEvents:UIControlEventTouchUpInside];
        
        btnCancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnCancel.frame = CGRectMake(0, 0, 100, 30);
        [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
        [btnCancel addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        
        

        
        btnConfirm.center = CGPointMake(180, 536);
        btnCancel.center = CGPointMake(360, 536);
        
        
        [self.view addSubview:btnConfirm];
        [self.view addSubview:btnCancel];
        
        
        lblTips = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, 500, 40)];
        lblTips.numberOfLines = 3;
        lblTips.backgroundColor = [UIColor clearColor];
        lblTips.textColor = [UIColor grayColor];
        lblTips.text = @"请输入Web Service的地址";
        [self.view addSubview:lblTips];
        [lblTips release];
        
        
        tfSetting = [[UITextField alloc] initWithFrame:CGRectMake(50, 200, 200, 30)];
        tfSetting.autocorrectionType = UITextAutocorrectionTypeNo;
        tfSetting.borderStyle = UITextBorderStyleRoundedRect;
        [self.view addSubview:tfSetting];
        [tfSetting release];
        
        tfUser = [[UITextField alloc] initWithFrame:CGRectMake(370, 200, 120, 30)];
        tfUser.autocorrectionType = UITextAutocorrectionTypeNo;
        tfUser.borderStyle = UITextBorderStyleRoundedRect;
        [self.view addSubview:tfUser];
        [tfUser release];
        
        
        lblSetting = [[UILabel alloc] initWithFrame:CGRectMake(20, 200, 80, 30)];
        lblSetting.backgroundColor = [UIColor clearColor];
        lblSetting.textColor = [UIColor grayColor];
        lblSetting.text = @"IP";
        [self.view addSubview:lblSetting];
        [lblSetting release];
        
        lblUser = [[UILabel alloc] initWithFrame:CGRectMake(320, 200, 80, 30)];
        lblUser.backgroundColor = [UIColor clearColor];
        lblUser.textColor = [UIColor grayColor];
        lblUser.text = @"端口";
        [self.view addSubview:lblUser];
        [lblUser release];
        

        
        
        NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docPath = [docPaths objectAtIndex:0];
        NSString *settingPath = [docPath stringByAppendingPathComponent:@"ip.plist"];
        
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:settingPath];
        NSString *str = [dict objectForKey:@"ip"];
        if (!str)
            str = kSocketServer;
        
        lblPath = [[UILabel alloc] initWithFrame:CGRectMake(0, 240, 540, 30)];
        lblPath.textAlignment = UITextAlignmentCenter;
        lblPath.backgroundColor = [UIColor clearColor];
        lblPath.textColor = [UIColor grayColor];
        lblPath.text = [NSString stringWithFormat:@"当前地址:http://%@/cmenu/CmenuServices.asmx",str];
        [self.view addSubview:lblPath];
        [lblPath release];
        

        lblChecking.hidden = YES;
        indicator.hidden = YES;
    }
    else if (settingType==BSSettingTypePDAID){
        navTitle = @"设置iPad编号";
        
        btnConfirm = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnConfirm.frame = CGRectMake(0, 0, 100, 30);
        [btnConfirm setTitle:@"确认" forState:UIControlStateNormal];
        [btnConfirm addTarget:self action:@selector(setPDAID) forControlEvents:UIControlEventTouchUpInside];
        
        btnCancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnCancel.frame = CGRectMake(0, 0, 100, 30);
        [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
        [btnCancel addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        
        
        tfSetting = [[UITextField alloc] initWithFrame:CGRectMake(70, 200, 450, 30)];
        tfSetting.autocorrectionType = UITextAutocorrectionTypeNo;
        tfSetting.borderStyle = UITextBorderStyleRoundedRect;
        [self.view addSubview:tfSetting];
        [tfSetting release];
        
        btnConfirm.center = CGPointMake(180, 536);
        btnCancel.center = CGPointMake(360, 536);
        
        
        [self.view addSubview:btnConfirm];
        [self.view addSubview:btnCancel];
        
        
        lblTips = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, 500, 40)];
        lblTips.numberOfLines = 3;
        lblTips.backgroundColor = [UIColor clearColor];
        lblTips.textColor = [UIColor grayColor];
        lblTips.text = @"请输入iPad编号";
        [self.view addSubview:lblTips];
        [lblTips release];
        
        
        lblSetting = [[UILabel alloc] initWithFrame:CGRectMake(20, 200, 80, 30)];
        lblSetting.backgroundColor = [UIColor clearColor];
        lblSetting.textColor = [UIColor grayColor];
        lblSetting.text = @"编号:";
        [self.view addSubview:lblSetting];
        [lblSetting release];
        
        
        

        NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"PDAID"];
        if (!str){
            str = kPDAID;
            [[NSUserDefaults standardUserDefaults] setObject:str forKey:@"PDAID"];
        }
        
        lblPath = [[UILabel alloc] initWithFrame:CGRectMake(0, 240, 540, 30)];
        lblPath.textAlignment = UITextAlignmentCenter;
        lblPath.backgroundColor = [UIColor clearColor];
        lblPath.textColor = [UIColor grayColor];
        lblPath.text = [NSString stringWithFormat:@"当前编号:%@",str];
        [self.view addSubview:lblPath];
        [lblPath release];
        
        
        lblChecking.hidden = YES;
        indicator.hidden = YES;
    }else {
        navTitle = @"员工登陆";
        
        btnConfirm = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnConfirm.frame = CGRectMake(0, 0, 100, 30);
        [btnConfirm setTitle:@"确认" forState:UIControlStateNormal];
        [btnConfirm addTarget:self action:@selector(loginUser) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *btnSignout = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnSignout.frame = CGRectMake(0, 0, 100, 30);
        [btnSignout setTitle:@"注销" forState:UIControlStateNormal];
        [btnSignout addTarget:self action:@selector(logoutUser) forControlEvents:UIControlEventTouchUpInside];
        
        btnCancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnCancel.frame = CGRectMake(0, 0, 100, 30);
        [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
        [btnCancel addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        tfUser = [[UITextField alloc] initWithFrame:CGRectMake(70, 150, 180, 30)];
        tfUser.autocorrectionType = UITextAutocorrectionTypeNo;
        tfUser.borderStyle = UITextBorderStyleRoundedRect;
        [self.view addSubview:tfUser];
        [tfUser release];
        
        tfPass = [[UITextField alloc] initWithFrame:CGRectMake(340, 150, 180, 30)];
        tfPass.autocorrectionType = UITextAutocorrectionTypeNo;
        tfPass.borderStyle = UITextBorderStyleRoundedRect;
        [self.view addSubview:tfPass];
        [tfPass release];
        
//        tfSetting = [[UITextField alloc] initWithFrame:CGRectMake(70, 200, 450, 30)];
//        tfSetting.autocorrectionType = UITextAutocorrectionTypeNo;
//        tfSetting.borderStyle = UITextBorderStyleRoundedRect;
//        [self.view addSubview:tfSetting];
//        [tfSetting release];
        
        btnConfirm.center = CGPointMake(160, 536);
        btnSignout.center = CGPointMake(270, 536);
        btnCancel.center = CGPointMake(380, 536);
        
        
        [self.view addSubview:btnConfirm];
        [self.view addSubview:btnCancel];
        [self.view addSubview:btnSignout];
        
        
        lblTips = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, 500, 40)];
        lblTips.numberOfLines = 3;
        lblTips.backgroundColor = [UIColor clearColor];
        lblTips.textColor = [UIColor grayColor];
        lblTips.text = @"请输入工号和对应密码";
        [self.view addSubview:lblTips];
        [lblTips release];
        
        lblUser = [[UILabel alloc] initWithFrame:CGRectMake(20, 150, 80, 30)];
        lblUser.backgroundColor = [UIColor clearColor];
        lblUser.textColor = [UIColor grayColor];
        lblUser.text = @"工号:";
        [self.view addSubview:lblUser];
        [lblUser release];
        
        lblPass = [[UILabel alloc] initWithFrame:CGRectMake(290, 150, 80, 30)];
        lblPass.backgroundColor = [UIColor clearColor];
        lblPass.textColor = [UIColor grayColor];
        lblPass.text = @"密码:";
        [self.view addSubview:lblPass];
        [lblPass release];
        
        NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"];
        NSString *str = [userInfo objectForKey:@"name"];
        
        lblPath = [[UILabel alloc] initWithFrame:CGRectMake(0, 240, 540, 30)];
        lblPath.textAlignment = UITextAlignmentCenter;
        lblPath.backgroundColor = [UIColor clearColor];
        lblPath.textColor = [UIColor grayColor];
        lblPath.text = str?[NSString stringWithFormat:@"当前员工:%@",str]:nil;
        [self.view addSubview:lblPath];
        [lblPath release];
        
        btnSignout.hidden = str?NO:YES;
        
        lblChecking = [[UILabel alloc] initWithFrame:CGRectZero];
        lblChecking.textColor = [UIColor darkGrayColor];
        lblChecking.backgroundColor = [UIColor clearColor];
        lblChecking.text = @"正在检查工号和密码是否正确";
        [lblChecking sizeToFit];
        lblChecking.center = CGPointMake(270, 260);
        [self.view addSubview:lblChecking];
        [lblChecking release];
        lblChecking.hidden = YES;
        indicator.hidden = YES;
    }
    
    self.navigationItem.title = navTitle;
    
    

}

- (void)loginUser{
    if (tfUser.text.length>0 && tfPass.text.length>0){
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:tfUser.text,@"username",tfPass.text,@"password", nil];
        
        
        NSDictionary *dict = [[BSDataProvider sharedInstance] pLoginUser:[NSDictionary dictionaryWithObjectsAndKeys:tfUser.text,@"user",tfPass.text,@"pwd", nil]];
        
//        NSLog(@"dict:%@",dict);
        
        
        
        
        if (![[dict objectForKey:@"Result"] boolValue]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登陆失败" message:[dict objectForKey:@"Message"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserInfo"];
        }else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"工号和密码已保存" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            [userInfo setObject:[dict objectForKey:@"Message"] forKey:@"name"];
            lblPath.text = [NSString stringWithFormat:@"当前员工:%@",[userInfo objectForKey:@"name"]];
            
            [[NSUserDefaults standardUserDefaults] setObject:userInfo forKey:@"UserInfo"];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"工号和密码不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (void)logoutUser{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserInfo"];
    tfUser.text = nil;
    tfPass.text = nil;
    lblPath.text = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return (UIInterfaceOrientationPortrait==interfaceOrientation || UIInterfaceOrientationPortraitUpsideDown==interfaceOrientation);
}

- (void)setIP{
    NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [docPaths objectAtIndex:0];
    NSString *settingPath = [docPath stringByAppendingPathComponent:@"ip.plist"];
    
    if ([tfSetting.text length]>0){
        NSString *portcode = [tfUser.text length]>0?[NSString stringWithFormat:@"%d",[tfUser.text intValue]]:nil;
        NSString *ipport = tfSetting.text;
        if (portcode)
            ipport = [NSString stringWithFormat:@"%@:%@",ipport,portcode];
        NSDictionary *dic = [NSDictionary dictionaryWithObject:ipport forKey:@"ip"];
        [dic writeToFile:settingPath atomically:NO];
        
        [self performSelector:@selector(cancel)];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请输入IP地址" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (void)setPDAID{
    if ([tfSetting.text length]>0){
        [[NSUserDefaults standardUserDefaults] setObject:tfSetting.text forKey:@"PDAID"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshID" object:nil];
        
        [self performSelector:@selector(cancel)];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请输入编号" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (void)download{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    BOOL valid = NO;
    NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [docPaths objectAtIndex:0];
    NSString *settingPath = [docPath stringByAppendingPathComponent:@"setting.plist"];
    
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:settingPath];
    
    NSString *str = [dict objectForKey:@"url"];
    if ([str length]==0)
        str = kPathHeader;
    str = [str stringByAppendingPathComponent:@"BookSystem.sqlite"];
    
    NSURLRequest *request;
    NSURL *url = [NSURL URLWithString:str];
    request = [[NSURLRequest alloc] initWithURL:url
                                    cachePolicy:NSURLRequestUseProtocolCachePolicy
                                timeoutInterval:5.0];
    
    
    // retreive the data using timeout
    NSURLResponse* response;
    NSError *error;
    
    
    error = nil;
    response = nil;
    NSData *serviceData = [NSURLConnection sendSynchronousRequest:request 
                                                returningResponse:&response
                                                            error:&error];
    
    NSLog(@"Error Info:%@",error);
    
    // 1001 is the error code for a connection timeout
    if (!serviceData) {
        valid = NO;
    }
    else{
        NSData *data = [[NSData alloc] initWithContentsOfURL:url];
        if (data==nil){
            valid = NO;
        }
        else{
            valid = YES;
        }
        [data release];
    }
    
    if (valid) {
        BSDataProvider *dp = [BSDataProvider sharedInstance];

        
        //Refresh Files
        

        NSArray *fileNames = nil;
        NSString *settingPath = [@"setting.plist" documentPath];
        NSDictionary *didict= [NSDictionary dictionaryWithContentsOfFile:settingPath];
        NSString *ftpurl = nil;
        if (didict!=nil)
            ftpurl = [didict objectForKey:@"url"];
        
        if (!ftpurl)
            ftpurl = kPathHeader;
        ftpurl = [ftpurl stringByAppendingPathComponent:@"BookSystem.sqlite"];
        
        
        NSData *imgData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:ftpurl]];
        [imgData writeToFile:[docPath stringByAppendingPathComponent:@"BookSystem.sqlite"] atomically:NO];
        [imgData release];
        NSDictionary *infoDict = [dp dictFromSQL];
        fileNames = [infoDict objectForKey:@"FileList"];
        int count = [fileNames count];
        for (int i=0;i<count;i++){
            @autoreleasepool {
                NSString *fileName = [fileNames objectAtIndex:i];
                NSString *path = [docPath stringByAppendingPathComponent:fileName];
                NSString *strURL = [[ftpurl stringByDeletingLastPathComponent] stringByAppendingPathComponent:fileName];
                imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]];
                [imgData writeToFile:path atomically:NO];
                
                bs_dispatch_sync_on_main_thread(^{
                    lblDownloading.text = [NSString stringWithFormat:@"正在更新              %d/%d",i+1,count]; 
                });
            }
        }
        
        
        
        //Refresh Files Ended
    }
    
    [self performSelectorOnMainThread:@selector(finishedDownloading:) withObject:[NSNumber numberWithBool:valid] waitUntilDone:NO];
    

    [request release];
    [pool release];
}

- (void)confirm{
    lblTips.hidden = YES;
    tfSetting.hidden = YES;
    tfUser.hidden = YES;
    tfPass.hidden = YES;
    lblUser.hidden = YES;
    lblPath.hidden = YES;
    lblPass.hidden = YES;
    lblSetting.hidden = YES;
    lblChecking.hidden = NO;
    indicator.hidden = NO;
    [indicator startAnimating];
    
    [NSThread detachNewThreadSelector:@selector(checkFTPSetting) toTarget:self withObject:nil];
}

- (void)cancel{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)checkFTPSetting{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    BOOL valid = NO;;
    NSString *str = [tfSetting.text stringByReplacingOccurrencesOfString:@"/" withString:@""];
    if ([tfUser.text length]==0 || [tfPass.text length]==0){
        if ([str length]==0)
            str = @"null";
        else
            str = [NSString stringWithFormat:@"ftp://%@/BookSystem/BookSystem.sqlite",str];
    }
    else{
        if ([str length]==0)
            str = @"null";
        else
            str = [NSString stringWithFormat:@"ftp://%@:%@@%@/BookSystem/BookSystem.sqlite",tfUser.text,tfPass.text,str];
    }
    
    NSURLRequest *request;
    NSURL *url = [NSURL URLWithString:str];
    request = [[NSURLRequest alloc] initWithURL:url
                                    cachePolicy:NSURLRequestUseProtocolCachePolicy
                                timeoutInterval:5.0];
    
    
    // retreive the data using timeout
    NSURLResponse* response;
    NSError *error;
    
    
    error = nil;
    response = nil;
    NSData *serviceData = [NSURLConnection sendSynchronousRequest:request 
                                                returningResponse:&response
                                                            error:&error];
    
    NSLog(@"Error Info:%@",error);
    
    // 1001 is the error code for a connection timeout
    if (!serviceData) {
        valid = NO;
    }
    else{
        NSData *data = [[NSData alloc] initWithContentsOfURL:url];
        if (data==nil){
            valid = NO;
        }
        
        else{
            valid = YES;
            NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *docPath = [docPaths objectAtIndex:0];
            NSString *settingPath = [docPath stringByAppendingPathComponent:@"setting.plist"];
            [[NSDictionary dictionaryWithObject:[str stringByReplacingOccurrencesOfString:@"BookSystem.sqlite" withString:@""] forKey:@"url"] writeToFile:settingPath atomically:NO];

        }
        [data release];
    }
    
    
    [self performSelectorOnMainThread:@selector(finishedChecking:) withObject:[NSNumber numberWithBool:valid] waitUntilDone:NO];
    
    
    [request release];
    [pool release];
}

- (void)finishedChecking:(NSNumber *)pass{
    BOOL valid = [pass boolValue];
    if (valid){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"FTP地址设置成功，请重新运行程序以使设置生效" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        [alert release];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"FTP地址设置失败，请检查地址或网络连接状况" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        lblTips.hidden = NO;
        tfSetting.hidden = NO;
        tfUser.hidden = NO;
        tfPass.hidden = NO;
        lblUser.hidden = NO;
        lblPath.hidden = NO;
        lblPass.hidden = NO;
        lblSetting.hidden = NO;
        lblChecking.hidden = YES;
        indicator.hidden = YES;
        [indicator stopAnimating];
    }
}

- (void)finishedDownloading:(NSNumber *)pass{
    BOOL valid = [pass boolValue];
    if (valid){
        NSFileManager *fileManager = [NSFileManager defaultManager];
        //获取路径
        //参数NSDocumentDirectory要获取那种路径
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];//去处需要的路径
        
        //更改到待操作的目录下
        [fileManager changeCurrentDirectoryPath:[documentsDirectory stringByExpandingTildeInPath]];
        
        //删除待删除的文件
        [fileManager removeItemAtPath:@"FoodHistory.plist" error:nil];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"下载完成，请重新运行程序以使设置生效" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        [alert release];
        [self.navigationController popViewControllerAnimated:YES];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CurrentPageConfig"];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"下载失败，请检查FTP配置或网络连接状况" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
    }
}

- (void)setType:(BSSettingType)type{
    settingType = type;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
