//
//  BSHistoryViewController.m
//  BookSystem
//
//  Created by chensen on 14-5-13.
//
//

#import "BSHistoryViewController.h"
#import "BSDataProvider.h"
#import "SVProgressHUD.h"

@interface BSHistoryViewController ()

@end

@implementation BSHistoryViewController
{
    UITableView *_tvHistory;
    NSArray *_dataArray;
    NSString *_fileName;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)dealloc
{
    
    [_fileName release];
    [super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"历史账单";
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleBordered target:self action:@selector(releaseSelf)] autorelease];
//    NSDictionary *current = [BSDataProvider currentOrder];
//    if ([current objectForKey:@"name"])
//        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"保存修改" style:UIBarButtonItemStyleBordered target:self action:@selector(savecurrentClicked)] autorelease];
//    else
//        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"暂存当前菜品" style:UIBarButtonItemStyleBordered target:self action:@selector(saveClicked)] autorelease];
    
    _tvHistory = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 540, 620-44)];
    _tvHistory.delegate = self;
    _tvHistory.dataSource = self;
    [self.view addSubview:_tvHistory];
    [_tvHistory release];

}
- (void)releaseSelf{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[BSDataProvider historyFoodList] count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"CacheCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier] autorelease];
    }
    
    NSDictionary *info = [[BSDataProvider historyFoodList] objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[info objectForKey:@"table"]];
    
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

//    NSString *str=[formatter stringFromDate:[info objectForKey:@"date"]];
//    NSDate* date = [formatter dateFromString:[info objectForKey:@"date"]];
    cell.detailTextLabel.text =[formatter stringFromDate:[info objectForKey:@"date"]];
    NSLog(@"%@",[info objectForKey:@"date"]);
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIAlertView *as = [[UIAlertView alloc] initWithTitle:@"请选择操作" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"重新发送",@"删除" ,nil];
    as.tag = indexPath.row;
    [as show];
    [as release];
}
#pragma mark -  UIActionSheet Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSMutableArray *cacheDict = [NSMutableArray arrayWithContentsOfFile:[@"FoodHistory.plist" documentPath]];
    
    
    if (buttonIndex==2){
        [cacheDict removeObjectAtIndex:alertView.tag];
//        [cacheDict removeObjectForKey:[[[BSDataProvider historyFoodList] objectAtIndex:alertView.tag] objectForKey:@"tag"]];
        [cacheDict writeToFile:[@"FoodHistory.plist" documentPath] atomically:NO];
        [_tvHistory reloadData];
        
    }else if (buttonIndex==1){
        [BSDataProvider importHistoryOfName:[NSString stringWithFormat:@"%d",alertView.tag]];
        [_tvHistory reloadData];
        [BSDataProvider sharedInstance].userTable=[[[BSDataProvider historyFoodList] objectAtIndex:alertView.tag] objectForKey:@"table"];
    }
}

#pragma mark -  Upload Using FTP
-(void) requestCompleted:(WRRequest *) request{
    CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    //called if 'request' is completed successfully
    NSLog(@"%@ completed!", request);
    [request release];
    
    BOOL bSucceed = YES;
    
    NSString *title;
    if (bSucceed){
        title = [langSetting localizedString:@"Send Succeeded"];//@"传菜成功";
        
        
        NSMutableArray *ary = [dp orderedFood];
        
        NSMutableArray *aryMut = [NSMutableArray arrayWithArray:ary];
        int count = [ary count];
        for (int i=0; i<count; i++) {
            NSDictionary *dic = [aryMut objectAtIndex:i];
            NSString *flag = [dic objectForKey:@"sendFlag"];
            if (![flag isEqualToString:@"0"]) {
                [ary removeObject:dic];
            }
        }
        //        [ary removeAllObjects];
        [dp saveOrders];
        [self performSelector:@selector(updateTitle)];
    }
    else
        title = [langSetting localizedString:@"Send Failed"];//@"传菜失败";
    bs_dispatch_sync_on_main_thread(^{
        [SVProgressHUD showSuccessWithStatus:title];
    });
    
    
    //    [SVProgressHUD dismissWithSuccess:title afterDelay:2];
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
    //    [alert show];
    //    [alert release];
    
}

-(void) requestFailed:(WRRequest *) request{
    
    //called after 'request' ends in error
    //we can print the error message
    NSLog(@"%@", request.error.message);
    [request release];
    
    CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
    
    //called if 'request' is completed successfully
    NSLog(@"%@ completed!", request);
    [request release];
    
    NSString *title = [langSetting localizedString:@"Send Failed"];//@"传菜失败";
    
    //    [SVProgressHUD dismissWithError:title afterDelay:2];
    bs_dispatch_sync_on_main_thread(^{
        [SVProgressHUD showErrorWithStatus:title];
    });
    
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
    //    [alert show];
    //    [alert release];
    
}

-(BOOL) shouldOverwriteFileWithRequest:(WRRequest *)request {
    
    //if the file (ftp://xxx.xxx.xxx.xxx/space.jpg) is already on the FTP server,the delegate is asked if the file should be overwritten
    //'request' is the request that intended to create the file
    return YES;
    
}
- (void)uploadFood:(NSString *)str{
    bs_dispatch_sync_on_main_thread(^{
        NSString *settingPath = [@"setting.plist" documentPath];
        NSDictionary *didict= [NSDictionary dictionaryWithContentsOfFile:settingPath];
        NSString *ftpurl = nil;
        if (didict!=nil)
            ftpurl = [didict objectForKey:@"url"];
        
        if (!ftpurl)
            ftpurl = kPathHeader;
        WRRequestUpload *uploader = [[WRRequestUpload alloc] init];
        uploader.delegate = self;
        uploader.hostname = [ftpurl hostName];
        uploader.username = [[ftpurl account] objectForKey:@"username"];
        uploader.password = [[ftpurl account] objectForKey:@"password"];
        
        uploader.sentData = [str dataUsingEncoding:NSUTF8StringEncoding];
        NSString *filename = [NSString stringWithFormat:@"%@%lf",[NSString UUIDString],[[NSDate date] timeIntervalSince1970]];
        _fileName=filename;
        uploader.path = [NSString stringWithFormat:@"/orders/2/%@.order",[filename MD5]];
        [uploader start];
    });
}

- (void)uploadFoodToo:(NSString *)str{
    bs_dispatch_sync_on_main_thread(^{
        NSString *settingPath = [@"setting.plist" documentPath];
        NSDictionary *didict= [NSDictionary dictionaryWithContentsOfFile:settingPath];
        NSString *ftpurl = nil;
        if (didict!=nil)
            ftpurl = [didict objectForKey:@"url"];
        
        if (!ftpurl)
            ftpurl = kPathHeader;
        WRRequestUpload *uploader = [[WRRequestUpload alloc] init];
        uploader.delegate = self;
        uploader.hostname = [ftpurl hostName];
        uploader.username = [[ftpurl account] objectForKey:@"username"];
        uploader.password = [[ftpurl account] objectForKey:@"password"];
        
        uploader.sentData = [str dataUsingEncoding:NSUTF8StringEncoding];
        
        //        NSString *filename = [NSString stringWithFormat:@"%@%lf",[NSString UUIDString],[[NSDate date] timeIntervalSince1970]];
        
        uploader.path = [NSString stringWithFormat:@"/orders/1/%@.order",[_fileName MD5]];
        [uploader start];
    });
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
