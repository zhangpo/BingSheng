//
//  BSConfigurationViewController.m
//  BookSystem
//
//  Created by Wu Stan on 12-4-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BSConfigurationViewController.h"
#import "BSSettingViewController.h"
#import "BSBGSettingViewController.h"

#import "BSPageConfigViewController.h"

@interface BSConfigurationViewController ()

@end

@implementation BSConfigurationViewController
@synthesize colorText;

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.colorText = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationItem.title = @"软件设置";
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleBordered target:self action:@selector(releaseSelf)] autorelease];//[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(releaseSelf)] autorelease];
    
//    [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleBordered target:self action:@selector(releaseSelf)];
    
    tvConfig = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 540, 620-44) style:UITableViewStyleGrouped];
    [self.view addSubview:tvConfig];
    [tvConfig release];
    tvConfig.delegate = self;
    tvConfig.dataSource = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshID) name:@"RefreshID" object:nil];
}

- (void)refreshID{
    [tvConfig reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)releaseSelf{
    [self.navigationController dismissModalViewControllerAnimated:YES];
//    [self performSelector:@selector(release) withObject:nil afterDelay:0.5f];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark UITableView Delegate & Data Source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"ConfigruationCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier] autorelease];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    int section = indexPath.section;
    int row = indexPath.row;
    switch (section) {
        case 0:{
            switch (row) {
                case 0:{
                    cell.textLabel.text = @"字体颜色";
                    
                    NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"textColor"];
                    UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
                    
                    UIImageView *imgv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 95, 30)];
                    imgv.backgroundColor = color;
                    cell.accessoryView = [imgv autorelease];
                }
                    break;
                case 1:{
                    cell.textLabel.text = @"显示所有按钮";
                    UISwitch *swShowButton = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
                    swShowButton.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"ShowButton"];
                    swShowButton.tag = 100;
                    [swShowButton addTarget:self action:@selector(swChanged:) forControlEvents:UIControlEventValueChanged];
                    cell.accessoryView = [swShowButton autorelease];
                }
                    break;
                case 2:{
                    NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"PDAID"];
                    if (!str){
                        str = kPDAID;
                        [[NSUserDefaults standardUserDefaults] setObject:str forKey:@"PDAID"];
                    }
                    
                    cell.textLabel.text = @"iPad编号";
                    cell.detailTextLabel.text = str;
                    cell.accessoryView = nil;
                }
                    break;
                case 3:{
                    cell.textLabel.text = @"设置背景图片";
                    cell.accessoryView = nil;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                    break;
                case 4:{
                    cell.textLabel.text = @"员工登陆";
                    cell.accessoryView = nil;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                    break;
                case 5:{
                    cell.textLabel.text = @"菜品暂存至服务器";
                    UISwitch *swShowButton = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
                    swShowButton.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"CacheOnServer"];
                    swShowButton.tag = 200;
                    [swShowButton addTarget:self action:@selector(swChanged:) forControlEvents:UIControlEventValueChanged];
                    cell.accessoryView = [swShowButton autorelease];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 1:{
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.accessoryView = nil;
            switch (row) {
                case 0:
                    cell.textLabel.text = @"设置FTP地址";
                    break;
                case 1:
                    cell.textLabel.text = @"设置IP地址";
                    break;
                case 2:
                    cell.textLabel.text = @"更新资料";
                    break;
                default:
                    break;
            }
        }
            break;
        case 2:{
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = nil;
            switch (row) {
                case 0:
                    cell.textLabel.text = @"选择页面配置文件";
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)swChanged:(UISwitch *)sw{
    if (100==sw.tag){
        [[NSUserDefaults standardUserDefaults] setBool:sw.isOn forKey:@"ShowButton"];
    }else if (200==sw.tag)
        [[NSUserDefaults standardUserDefaults] setBool:sw.isOn forKey:@"CacheOnServer"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0==section?5:(1==section?3:1);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    int section = indexPath.section;
    int row = indexPath.row;
    if (0==section){
        if (0==row){
            if (!popColor){
                UIViewController *vc = [[UIViewController alloc] init];
                popColor = [[UIPopoverController alloc] initWithContentViewController:vc];
                [vc release];
                
                ColorPickerView *vColorPicker = [[ColorPickerView alloc] initWithFrame:CGRectMake(0, 0, 350, 360) delegate:self];
                [vc.view addSubview:vColorPicker];
                [vColorPicker release];
                
                [popColor setPopoverContentSize:CGSizeMake(350, 360)];
            }
            
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            
            [popColor presentPopoverFromRect:cell.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }else if (2==row){
            //iPad编号
            BSSettingViewController *vcSetting = [[BSSettingViewController alloc] initWithType:BSSettingTypePDAID];
            [self.navigationController pushViewController:vcSetting animated:YES];
            [vcSetting release];
        }else if (3==row){
            //设置背景图片
            BSBGSettingViewController *vcBG = [[BSBGSettingViewController alloc] init];
            [self.navigationController pushViewController:vcBG animated:YES];
            [vcBG release];
        }else if (4==row){
            //员工登陆
            BSSettingViewController *vcSetting = [[BSSettingViewController alloc] initWithType:BSSettingTypeLogin];
            [self.navigationController pushViewController:vcSetting animated:YES];
            [vcSetting release];
        }
    }else if (1==section){
        if (0==row){
            //设置FTP地址
            BSSettingViewController *vcSetting = [[BSSettingViewController alloc] initWithType:BSSettingTypeFtp];
            [self.navigationController pushViewController:vcSetting animated:YES];
            [vcSetting release];
        }else if (1==row){
            //设置IP地址
            BSSettingViewController *vcSetting = [[BSSettingViewController alloc] initWithType:BSSettingTypeSocket];
            [self.navigationController pushViewController:vcSetting animated:YES];
            [vcSetting release];
        }else if (2==row){
            //更新资料
            BSSettingViewController *vcSetting = [[BSSettingViewController alloc] initWithType:BSSettingTypeUpdate];
            [self.navigationController pushViewController:vcSetting animated:YES];
            [vcSetting release];
        }
    }else if (2==section){
        BSPageConfigViewController *vcPageConfig = [[BSPageConfigViewController alloc] init];
        [self.navigationController pushViewController:vcPageConfig animated:YES];
        [vcPageConfig release];
    }
    
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return @"本机配置";
            break;
        case 1:
            return @"服务器配置";
        case 2:
            return @"页面配置";
        default:
            return nil;
            break;
    }
}

#pragma mark -
#pragma mark Color Picker delegate
- (void)colorSelected:(UIColor *)color{
    self.colorText = color;
    
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color];
    [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:@"textColor"];
    
    [popColor dismissPopoverAnimated:YES];
    [popColor release];
    popColor = nil;
    
    [tvConfig reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)circleColorSelected:(UIColor *)color{
    self.colorText = color;
}

- (UIColor *)lastSelectedColor{
    NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"textColor"];
    
    if (!colorData){
        colorData = [NSKeyedArchiver archivedDataWithRootObject:[UIColor blackColor]];
        [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:@"textColor"];
    }
    
    UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    return color;
}

#pragma mark - New Demos
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"确定"]){
        NSString *username = [[alertView textFieldAtIndex:0] text];
        NSString *password = [[alertView textFieldAtIndex:1] text];
        
        NSArray *users = [[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Demo" ofType:@"plist"]] objectForKey:@"EmpList"];
        
        BOOL bExist,bCorrect;
        for (NSDictionary *user in users){
            if ([username isEqualToString:[user objectForKey:@"Emp"]]){
                bExist = YES;
                bCorrect = [password isEqualToString:[user objectForKey:@"Psd"]];
                break;
            }
        }
        
        if (bExist){
            if (bCorrect)
            {

            }
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登录失败" message:@"密码错误" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
                [alert release];
            }
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登录失败" message:@"用户名不存在" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            [alert release];
        }
    }
}

@end
