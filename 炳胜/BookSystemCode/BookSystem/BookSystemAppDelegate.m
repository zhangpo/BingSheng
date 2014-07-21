//
//  BookSystemAppDelegate.m
//  BookSystem
//
//  Created by Dream on 11-3-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BookSystemAppDelegate.h"
#import "BSDataProvider.h"
#import "BookSystemViewController.h"
#import "CVLocalizationSetting.h"
#import <mach/mach.h>
#import "WhiteRaccoon.h"

@implementation BookSystemAppDelegate

void report_memory(void) {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    if( kerr == KERN_SUCCESS ) {
        NSLog(@"Memory used: %u", info.resident_size/1024); //in bytes
    } else {
        NSLog(@"Error: %s", mach_error_string(kerr));
    }
}

- (void)reportMemory{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    report_memory();
    [pool release];
}

- (UIWindow *)window{
    return window;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Name:HYg2gj
    
    [self copyFiles];
    
    NSLog(@"%@",NSHomeDirectory());
    
    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    NSString *language = [[NSUserDefaults standardUserDefaults] 
						  stringForKey:@"language"];
    NSString *price = [[NSUserDefaults standardUserDefaults] stringForKey:@"price"];
    if(!language || !price) {
        [self performSelector:@selector(registerDefaultsFromSettingsBundle)];        
    }
	strLanguage = [[[NSUserDefaults standardUserDefaults] stringForKey:@"language"] copy];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.window.frame =  CGRectMake(0,20,self.window.frame.size.width,self.window.frame.size.height-20);
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    }
    
    vcBookSystem = [[BookSystemViewController alloc] init];
    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:vcBookSystem];
    
    window.rootViewController = nav;
    [nav release];
//    [window addSubview:vcBookSystem.view];
//    vcBookSystem.view.frame = CGRectMake(0, 20, 768, 1004);
    [window makeKeyAndVisible];
    
//    [[BSDataProvider sharedInstance] topPages];
    
//    NSLog(@"%@",NSHomeDirectory());
    
//    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"8",@"user",@"8",@"pwd",@"23",@"tb", nil];
//    
//    BSDataProvider *dp = [BSDataProvider sharedInstance];
//    
//    NSDictionary *di1 = [dp pListSubscribeOfTable:dict];
//    NSDictionary *di2 = [dp pListResv:dict];
//    NSDictionary *di3 = [dp pLoginUser:dict];
    [self generateFrameStrings];

//     [[NSUserDefaults standardUserDefaults] setObject:[[[BSDataProvider sharedInstance] pageConfigList] objectAtIndex:0] forKey:@"CurrentPageConfig"];
    
    [[NSUserDefaults standardUserDefaults] setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentPageConfig"] forKey:@"CurrentPageConfig"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PageConfigChanged" object:nil];
    
    return YES;
}

- (void)generateFrameStrings{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PageConfigDemo" ofType:@"plist"]];
    
    NSMutableArray *ary = [NSMutableArray arrayWithArray:[dict objectForKey:@"PageList"]];

    for (int i=0;i<ary.count;i++){
        NSDictionary *dicpage = [ary objectAtIndex:i];
        NSMutableDictionary *mutpage = [NSMutableDictionary dictionaryWithDictionary:dicpage];
//        NSLog(@"%@",mutpage);
        
        if ([[dicpage objectForKey:@"type"] isEqualToString:@"菜品列表"]){
            NSMutableArray *foods = [NSMutableArray arrayWithArray:[dicpage objectForKey:@"foods"]];
            
            for (int j=0;j<foods.count;j++){
                NSDictionary *dicfood = [foods objectAtIndex:j];
                NSMutableDictionary *mutfood = [NSMutableDictionary dictionaryWithDictionary:dicfood];
                
                NSMutableDictionary *dicframe = [NSMutableDictionary dictionaryWithDictionary:[mutfood objectForKey:@"frame"]];
                [dicframe setObject:@"{{15,5},{42,48}}" forKey:@"Ordered"];
                [mutfood setObject:dicframe forKey:@"frame"];
                
                [foods replaceObjectAtIndex:j withObject:mutfood];
            }
            
            [mutpage setObject:foods forKey:@"foods"];
        }
        
        [ary replaceObjectAtIndex:i withObject:mutpage];
    }
    
    [dict setObject:ary forKey:@"PageList"];
    
    [dict writeToFile:[@"PageConfigDemo.plist" documentPath] atomically:NO];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    [self performSelector:@selector(checkLanguage) withObject:nil afterDelay:1.0];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    NSLog(@"Source URL:%@",url);
    
    
    return YES;
}

- (void)registerDefaultsFromSettingsBundle {
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(!settingsBundle) {
        NSLog(@"Could not find Settings.bundle");
        return;
    }
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if(key) {
//			NSLog(@"Default %@ value:%@",key,[prefSpecification objectForKey:@"DefaultValue"]);
            [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
        }
    }
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
    [defaultsToRegister release];
}


-(void)checkLanguage{
	CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
	NSString *currentLanguage = [[NSUserDefaults standardUserDefaults] stringForKey:@"language"];
	if (![strLanguage isEqualToString:currentLanguage])
	{
		//	[check invalidate];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"LanguageChangedTitle"] 
														message:[langSetting localizedString:@"LanguageChangedMessage"]
													   delegate:nil
											  cancelButtonTitle:[langSetting localizedString:@"OK"] 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		[alert release];
	}
	//	else
	//		[check invalidate];
}

- (void)dealloc
{
    [strLanguage release];
    [window release];
    [vcBookSystem release];
    [super dealloc];
}


- (void)copyFiles{
    NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docPath = [docPaths objectAtIndex:0];
    
    NSString *sqlpath = [docPath stringByAppendingPathComponent:@"BookSystem.plist"];

    

    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:sqlpath]){
        NSArray *ary = [NSBundle pathsForResourcesOfType:@"jpg" inDirectory:[[NSBundle mainBundle] bundlePath]];
        for (NSString *path in ary){
            [fileManager copyItemAtPath:path toPath:[docPath stringByAppendingPathComponent:[path lastPathComponent]] error:nil];
        }
        
        ary = [NSBundle pathsForResourcesOfType:@"JPG" inDirectory:[[NSBundle mainBundle] bundlePath]];
        for (NSString *path in ary){
            [fileManager copyItemAtPath:path toPath:[docPath stringByAppendingPathComponent:[path lastPathComponent]] error:nil];
        }
        
        ary = [NSBundle pathsForResourcesOfType:@"png" inDirectory:[[NSBundle mainBundle] bundlePath]];
        for (NSString *path in ary){
            [fileManager copyItemAtPath:path toPath:[docPath stringByAppendingPathComponent:[path lastPathComponent]] error:nil];
        }
        
        ary = [NSBundle pathsForResourcesOfType:@"PNG" inDirectory:[[NSBundle mainBundle] bundlePath]];
        for (NSString *path in ary){
            [fileManager copyItemAtPath:path toPath:[docPath stringByAppendingPathComponent:[path lastPathComponent]] error:nil];
        }
        
        ary = [NSBundle pathsForResourcesOfType:@"plist" inDirectory:[[NSBundle mainBundle] bundlePath]];
        for (NSString *path in ary){
            [fileManager copyItemAtPath:path toPath:[docPath stringByAppendingPathComponent:[path lastPathComponent]] error:nil];
        }
        
        ary = [NSBundle pathsForResourcesOfType:@"sqlite" inDirectory:[[NSBundle mainBundle] bundlePath]];
        for (NSString *path in ary){
            [fileManager copyItemAtPath:path toPath:[docPath stringByAppendingPathComponent:[path lastPathComponent]] error:nil];
        }
    }
}



@end
