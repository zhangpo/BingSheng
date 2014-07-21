//
//  BSDataProvider.m
//  BookSystem
//
//  Created by Dream on 11-3-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BSDataProvider.h"
#import "UIKitUtil.h"


@implementation BSDataProvider
@synthesize userTable=_userTable;

static BSDataProvider *sharedInstance = nil;
static NSDictionary *infoDict = nil;
static NSDictionary *dicCurrentPageConfig = nil;
static NSDictionary *dicCurrentPageConfigDetail = nil;
static NSArray *aryPageConfigList = nil;
static NSLock *_loadingMutex = nil;
static NSMutableArray *aryOrders = nil;
static NSArray *aryAllDetailPages = nil;
static NSArray *aryAllPages = nil;
static int dSendCount = 0;

+ (NSDictionary *)currentOrder{
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentOrder"];
    
    if (!dict){
        if (aryOrders.count>0){
            dict = [NSDictionary dictionaryWithObjectsAndKeys:aryOrders,@"foods",[NSDate date],@"date", nil];
            
            [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"CurrentOrder"];
        }
    }
    
    return dict;
}

+ (NSDictionary *)allCachedOrder{
    return [NSDictionary dictionaryWithContentsOfFile:[@"FoodCache.plist" documentPath]];
}

+ (void)removeOrderOfName:(NSString *)name{
    NSMutableDictionary *cacheDict = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfFile:[@"FoodCache.plist" documentPath]]];
    [cacheDict removeObjectForKey:name];
    [cacheDict writeToFile:[@"FoodCache.plist" documentPath] atomically:NO];
    
    NSDictionary *current = [BSDataProvider currentOrder];
    if ([name isEqualToString:[current objectForKey:@"name"]]){
        [aryOrders removeAllObjects];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateOrderedNumber" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshOrderStatus" object:nil];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CurrentOrder"];
    }
}
+ (void)importHistoryOfName:(NSString *)name{
    NSDictionary *order = [[NSArray arrayWithContentsOfFile:[@"FoodHistory.plist" documentPath]] objectAtIndex:[name intValue]];
    [aryOrders release];
    aryOrders = [[order objectForKey:@"foods"] retain];
    if (!aryOrders)
        aryOrders = [[NSMutableArray array] retain];
    [[BSDataProvider sharedInstance] saveOrders];
    
    NSMutableDictionary *mut = [NSMutableDictionary dictionaryWithDictionary:order];
    [mut setObject:name forKey:@"name"];
    
    [[NSUserDefaults standardUserDefaults] setObject:mut forKey:@"CurrentOrder"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateOrderedNumber" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshOrderStatus" object:nil];
}
+ (void)importOrderOfName:(NSString *)name{
    NSDictionary *order = [[BSDataProvider allCachedOrder] objectForKey:name];
    [aryOrders release];
    aryOrders = [[order objectForKey:@"foods"] retain];
    if (!aryOrders)
        aryOrders = [[NSMutableArray array] retain];
    [[BSDataProvider sharedInstance] saveOrders];
    
    NSMutableDictionary *mut = [NSMutableDictionary dictionaryWithDictionary:order];
    [mut setObject:name forKey:@"name"];
    
    [[NSUserDefaults standardUserDefaults] setObject:mut forKey:@"CurrentOrder"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateOrderedNumber" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshOrderStatus" object:nil];
}

- (void)saveOrders{
    NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docPath = [docPaths objectAtIndex:0];
    NSString *path = [docPath stringByAppendingPathComponent:kOrdersFileName];
    NSArray *aryOrd = [NSArray arrayWithArray:aryOrders];
    if ([aryOrd count]>0){
        NSMutableArray *ary = [NSMutableArray array];
        for (NSDictionary *dic in aryOrd){
            if ([[dic objectForKey:@"total"] intValue]!=0)
                [ary addObject:dic];
        }
        if ([ary count]>0){
            NSDictionary *dict = [NSDictionary dictionaryWithObject:ary forKey:@"orders"];
            [dict writeToFile:path atomically:NO];
        }
    }
    else{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:path error:nil];
    }
    
    NSMutableDictionary *mut = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentOrder"]];
    [mut setObject:aryOrders forKey:@"foods"];
    [mut setObject:[NSDate date] forKey:@"date"];
    
    [[NSUserDefaults standardUserDefaults] setObject:mut forKey:@"CurrentOrder"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateOrderedNumber" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshOrderStatus" object:nil];
}

+ (NSArray *)cachedFoodList{
    NSDictionary *dict = [BSDataProvider allCachedOrder];
    
    NSMutableArray *mut = [NSMutableArray array];
    
    for (NSString *key in dict.allKeys){
        NSMutableDictionary *mutdict = [NSMutableDictionary dictionaryWithDictionary:[dict objectForKey:key]];
        [mutdict setObject:key forKey:@"name"];
        [mut addObject:mutdict];
    }

    [mut sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDictionary *dict1 = (NSDictionary *)obj1;
        NSDictionary *dict2 = (NSDictionary *)obj2;
        
        double interval = [[dict1 objectForKey:@"date"] timeIntervalSinceDate:[dict2 objectForKey:@"date"]];
        
        
        return interval>0?NSOrderedAscending:(interval<0?NSOrderedDescending:NSOrderedSame);
    }];
    
    return mut;
}

+ (BOOL)isCacheNameExist:(NSString *)name{
    BOOL bExist = NO;
    NSArray *ary = [BSDataProvider cachedFoodList];
    for (NSDictionary *cache in ary){
        if ([[cache objectForKey:@"name"] isEqualToString:name]){
            bExist = YES;
            break;
        }
    }
    
    return bExist;
}
+(NSArray *)historyFoodList{
    NSArray *dict = [NSArray arrayWithContentsOfFile:[@"FoodHistory.plist" documentPath]];
    return dict;
}
-(void)historyFoods:(NSArray *)foods withName:(NSString *)name{
    NSMutableArray *array = [NSMutableArray arrayWithArray:[NSArray arrayWithContentsOfFile:[@"FoodHistory.plist" documentPath]]];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:foods,@"foods",name,@"table",[NSDate date],@"date", nil];
    [array insertObject:dict atIndex:0];
    [array writeToFile:[@"FoodHistory.plist" documentPath] atomically:NO];
//    
//    [aryOrders removeAllObjects];
//    [[BSDataProvider sharedInstance] saveOrders];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshOrderStatus" object:nil userInfo:nil];
}

+ (void)saveFoods:(NSArray *)foods withName:(NSString *)name{
    NSMutableDictionary *cacheDict = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfFile:[@"FoodCache.plist" documentPath]]];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:foods,@"foods",[NSDate date],@"date", nil];
    [cacheDict setObject:dict forKey:name];
    
    [cacheDict writeToFile:[@"FoodCache.plist" documentPath] atomically:NO];
    [[[BSDataProvider sharedInstance] orderedFood] removeAllObjects];
    [[BSDataProvider sharedInstance] saveOrders];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshOrderStatus" object:nil userInfo:nil];
}

+ (void)loadConfig{
    //  配置文件列表
    NSArray *ary = [NSArray arrayWithContentsOfFile:[@"PageConfigList.plist" documentPath]];
    if (!ary)
        ary = [NSArray arrayWithContentsOfFile:[@"PageConfigListDemo.plist" bundlePath]];
    NSMutableArray *mut = [NSMutableArray array];
    for (int i=0;i<ary.count;i++){
        NSDictionary *dict = [ary objectAtIndex:i];
        NSString *pathLayout = [dict objectForKey:@"layout"];
        NSString *pathSQLite = [dict objectForKey:@"sqlite"];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        BOOL layoutExist = ([fileManager fileExistsAtPath:[pathLayout documentPath]] || [fileManager fileExistsAtPath:[pathLayout bundlePath]]);
        BOOL sqliteExist = ([fileManager fileExistsAtPath:[pathSQLite documentPath]] || [fileManager fileExistsAtPath:[pathSQLite bundlePath]]);
        if (layoutExist && sqliteExist)
            [mut addObject:dict];
    }
    aryPageConfigList = mut>0?[[NSArray arrayWithArray:mut] retain]:nil;
    
    //  当前选择的配置
    NSDictionary *pageConfig = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentPageConfig"];
    if (!pageConfig){
        NSArray *ary = aryPageConfigList;
        if (ary.count>0)
            pageConfig = [ary objectAtIndex:0];
        if (!pageConfig){
            pageConfig = [NSDictionary dictionaryWithObjectsAndKeys:@"PageConfigDemo.plist",@"layout",@"BookSystem.sqlite",@"sqlite",@"Demo",@"name",@"1",@"number", nil];
            [[NSUserDefaults standardUserDefaults] setObject:pageConfig
                                                      forKey:@"CurrentPageConfig"];
        }
    }
    dicCurrentPageConfig = [pageConfig retain];
    
    
    //  当前选择的配置的详细
    NSDictionary *dict = dicCurrentPageConfig;
    NSString *layout = [dict objectForKey:@"layout"];
    
    NSString *path = [layout documentPath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
        path = [layout bundlePath];
    
    dict = [NSDictionary dictionaryWithContentsOfFile:path];
    
    
    //  当前选择的页面配置的所有主页面列表
    ary = [dict objectForKey:@"PageList"];

    NSMutableDictionary *mutdict = [NSMutableDictionary dictionaryWithDictionary:dict];
    NSMutableArray *mutary = [NSMutableArray arrayWithArray:ary];
    NSArray *recommends = [[NSUserDefaults standardUserDefaults] objectForKey:@"RecommendList"];
    if (recommends.count>0){
        int index = -1;
        for (int i=0;i<mutary.count;i++){
            if ([[[mutary objectAtIndex:i] objectForKey:@"type"] isEqualToString:@"推荐菜"]){
                index = i;
                break;
            }
        }
        
        if (index>=0){
            for (int i=mutary.count-1;i>=0 && i<mutary.count;i--){
                NSDictionary *dict = [mutary objectAtIndex:i];
                if ([[dict objectForKey:@"type"] isEqualToString:@"推荐菜"])
                    [mutary removeObject:dict];
            }
            
            for (int i=recommends.count;i>=0 && i<recommends.count;i--){
                [mutary insertObject:[recommends objectAtIndex:i] atIndex:index];
            }
        }
    }
    
    [mutdict setObject:mutary forKey:@"PageList"];
    aryAllPages = [[NSArray arrayWithArray:mutary] retain];
    dicCurrentPageConfigDetail = [[NSDictionary dictionaryWithDictionary:mutdict] retain];
    
    //  当前选择的页面配置的详情页面列表
    ary = [dicCurrentPageConfigDetail objectForKey:@"PageList"];
    mut = [NSMutableArray array];
    
    for (int i=0;i<[ary count];i++){
        NSDictionary *dict = [ary objectAtIndex:i];
        
        if ([[dict objectForKey:@"type"] isEqualToString:@"菜品列表"]){
            NSArray *foods = [dict objectForKey:@"foods"];
            for (int j=0;j<[foods count];j++){
                NSArray *itcodes = [[[foods objectAtIndex:j] objectForKey:@"ITCODE"] componentsSeparatedByString:@","];
                NSString *itcode = [itcodes objectAtIndex:0];
                
                NSMutableDictionary *mutdict = [NSMutableDictionary dictionaryWithDictionary:[BSDataProvider getDataFromSQLByCommand:[NSString stringWithFormat:@"select * from food where ITCODE = '%@'",itcode]]];
                [mutdict setObject:@"菜品详情" forKey:@"type"];
                [mutdict setObject:[dict objectForKey:@"classid"] forKey:@"classid"];
                NSDictionary *video = [[foods objectAtIndex:j] objectForKey:@"video"];
                if (video)
                    [mutdict setObject:video forKey:@"video"];
                NSString *bg = [[foods objectAtIndex:j] objectForKey:@"background"];
                if (!bg)
                    bg = [dict objectForKey:@"background"];
                
                if (bg)
                    [mutdict setObject:bg forKey:@"background"];
                
                [mut addObject:mutdict];//添加一页
            }
        }
        
    }
    aryAllDetailPages = [mut count]>0?[[NSArray arrayWithArray:mut] retain]:nil;
}

+ (void)reloadConfig{
    [dicCurrentPageConfigDetail release];
    dicCurrentPageConfigDetail = nil;
    
    [dicCurrentPageConfig release];
    dicCurrentPageConfig = nil;
    
    [aryPageConfigList release];
    aryPageConfigList = nil;
    
    [aryAllPages release];
    aryAllPages = nil;
    
    [aryAllDetailPages release];
    aryAllDetailPages = nil;
}

+ (void)reloadCurrentPageConfig{
    [dicCurrentPageConfigDetail release];
    dicCurrentPageConfigDetail = nil;
    
    [dicCurrentPageConfig release];
    dicCurrentPageConfig = nil;
    
    [aryAllPages release];
    aryAllPages = nil;
    
    [aryAllDetailPages release];
    aryAllDetailPages = nil;
    
    NSDictionary *pageConfig = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentPageConfig"];
    if (!pageConfig){
        NSArray *ary = aryPageConfigList;
        if (ary.count>0)
            pageConfig = [ary objectAtIndex:0];
        if (!pageConfig){
            pageConfig = [NSDictionary dictionaryWithObjectsAndKeys:@"PageConfigDemo.plist",@"layout",@"BookSystem.sqlite",@"sqlite",@"Demo",@"name",@"1",@"number", nil];
            [[NSUserDefaults standardUserDefaults] setObject:pageConfig
                                                      forKey:@"CurrentPageConfig"];
        }
    }
    dicCurrentPageConfig = [pageConfig retain];
    
    NSDictionary *dict = dicCurrentPageConfig;
    NSString *layout = [dict objectForKey:@"layout"];
    
    NSString *path = [layout documentPath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
        path = [layout bundlePath];
    
    dict = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSMutableDictionary *mutdict = [NSMutableDictionary dictionaryWithDictionary:dict];
    NSMutableArray *mutary = [NSMutableArray arrayWithArray:[mutdict objectForKey:@"PageList"]];
    NSArray *ary = [[NSUserDefaults standardUserDefaults] objectForKey:@"RecommendList"];
    if (ary.count>0){
        int index = -1;
        for (int i=0;i<mutary.count;i++){
            if ([[[mutary objectAtIndex:i] objectForKey:@"type"] isEqualToString:@"推荐菜"]){
                index = i;
                break;
            }
        }
        
        if (index>=0){
            for (int i=mutary.count-1;i>=0 && i<mutary.count;i--){
                NSDictionary *dict = [mutary objectAtIndex:i];
                if ([[dict objectForKey:@"type"] isEqualToString:@"推荐菜"])
                    [mutary removeObject:dict];
            }
            
            for (int i=ary.count-1;i>=0 && i<ary.count;i--){
                [mutary insertObject:[ary objectAtIndex:i] atIndex:index];
            }
        }
    }
    
    [mutdict setObject:mutary forKey:@"PageList"];
    
    dicCurrentPageConfigDetail = [mutdict retain];
    
    aryAllPages = [mutary retain];
    
    //  当前选择的页面配置的详情页面列表
    ary = aryAllPages;
    NSMutableArray *mut = [NSMutableArray array];
    
    for (int i=0;i<[ary count];i++){
        NSDictionary *dict = [ary objectAtIndex:i];
        
        if ([[dict objectForKey:@"type"] isEqualToString:@"菜品列表"]){
            NSArray *foods = [dict objectForKey:@"foods"];
            for (int j=0;j<[foods count];j++){
                NSArray *itcodes = [[[foods objectAtIndex:j] objectForKey:@"ITCODE"] componentsSeparatedByString:@","];
                NSString *itcode = [itcodes objectAtIndex:0];
                
                NSMutableDictionary *mutdict = [NSMutableDictionary dictionaryWithDictionary:[BSDataProvider getDataFromSQLByCommand:[NSString stringWithFormat:@"select * from food where ITCODE = '%@'",itcode]]];
                [mutdict setObject:@"菜品详情" forKey:@"type"];
                [mutdict setObject:[dict objectForKey:@"classid"] forKey:@"classid"];
                NSDictionary *video = [[foods objectAtIndex:j] objectForKey:@"video"];
                if (video)
                    [mutdict setObject:video forKey:@"video"];
                NSString *bg = [[foods objectAtIndex:j] objectForKey:@"background"];
                if (!bg)
                    bg = [dict objectForKey:@"background"];
                
                if (bg)
                    [mutdict setObject:bg forKey:@"background"];
                
                [mut addObject:mutdict];//添加一页
            }
        }
        
    }
    aryAllDetailPages = [mut count]>0?[[NSArray arrayWithArray:mut] retain]:nil;
}

+ (BSDataProvider *)sharedInstance {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[super allocWithZone:NULL] init];
			
            [BSDataProvider loadConfig];
            //		CVDataProviderSetting *s = [CVDataProviderSetting sharedInstance];
			_loadingMutex = [[NSLock alloc] init];
            aryOrders = [[NSMutableArray alloc] init];
            NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *docPath = [docPaths objectAtIndex:0];
            NSString *path = [docPath stringByAppendingPathComponent:kOrdersFileName];
            NSDictionary *dicOrders = [NSDictionary dictionaryWithContentsOfFile:path];
            NSArray *ary = [dicOrders objectForKey:@"orders"];
            
            NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:[docPath stringByAppendingPathComponent:kOrdersCountFileName]];
            if (!dic){
                dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:@"count"];
                [dic writeToFile:[docPath stringByAppendingPathComponent:kOrdersCountFileName] atomically:NO];
            }
            
            
            dSendCount = [[dic objectForKey:@"count"] intValue];
            [aryOrders addObjectsFromArray:ary];
            
            
            dic = [NSDictionary dictionaryWithContentsOfFile:[docPath stringByAppendingPathComponent:@"pdaid.plist"]];
            if (!dic){
                dic = [NSDictionary dictionaryWithObject:@"8" forKey:@"pdaid"];
                [dic writeToFile:[docPath stringByAppendingPathComponent:@"pdaid.plist"] atomically:NO];
            }
        }
    }
    return sharedInstance;
}

- (NSString *)padID{
    NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"PDAID"];
    if (!str){
        str = kPDAID;
        [[NSUserDefaults standardUserDefaults] setObject:str forKey:@"PDAID"];
    }
    
    return str;
}


+ (id)allocWithZone:(NSZone *)zone {
    return [[self sharedInstance] retain];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}




- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  //denotes an object that cannot be released
}

- (oneway void)release {
	//[_cache release];
}

- (id)autorelease {
    return self;
}


#pragma mark -  Upload Using FTP
-(void) requestCompleted:(WRRequest *) request{
    
    //called if 'request' is completed successfully
    NSLog(@"%@ completed!", request);
    [request release];
    
}

-(void) requestFailed:(WRRequest *) request{
    
    //called after 'request' ends in error
    //we can print the error message
    NSLog(@"%@", request.error.message);
    [request release];
    
}

-(BOOL) shouldOverwriteFileWithRequest:(WRRequest *)request {
    
    //if the file (ftp://xxx.xxx.xxx.xxx/space.jpg) is already on the FTP server,the delegate is asked if the file should be overwritten
    //'request' is the request that intended to create the file
    return YES;
    
}

- (NSDictionary *)checkFoodAvailable:(NSArray *)ary info:(NSDictionary *)info{
    NSString *pdanum = [NSString stringWithFormat:@"%@-%d",[self padID],[[[self currentPageConfig] objectForKey:@"number"] intValue]];
    
    NSMutableString *mutfood = [NSMutableString string];
    
    for (int i=0;i<ary.count;i++){
        NSArray *foods = [[ary objectAtIndex:i] objectForKey:@"foods"];
        for (int j=0;j<foods.count;j++){
            NSDictionary *food = [foods objectAtIndex:j];
            NSString *foodid = [[food objectForKey:@"food"] objectForKey:@"ITCODE"];
            NSString *count = [food objectForKey:@"total"];
            
            [mutfood appendFormat:@"%@^%@",foodid,count];
            [mutfood appendString:@";"];
        }
    }
    
    
    NSString *strParam = [NSString stringWithFormat:@"?PdaId=%@&oSerial=%@&User=%@-%@&GrantEmp=%@&GrantPass=&Rsn=",pdanum,mutfood,[info objectForKey:@"user"],[info objectForKey:@"pwd"],[info objectForKey:@"table"]];
    NSDictionary *dict = [self bsService:@"checkFoodAvailable" arg:strParam];
    NSString *str = [[[dict objectForKey:@"Root"] objectForKey:@"OStr"] objectForKey:@"text"];
    
    NSMutableDictionary *mutret = [NSMutableDictionary dictionary];
    BOOL isOK = NO;
    NSString *msg = nil;
    if (str){
        if ([str rangeOfString:@"ok"].location!=NSNotFound){
            isOK = YES;
        }else{
            NSRange start = [str rangeOfString:@":"];
            NSRange end = [str rangeOfString:@">"];
            
            if (start.location!=NSNotFound && end.location!=NSNotFound){
                NSRange sub = NSMakeRange(start.location+1, ((int)end.location-(int)start.location-1)>=0?(end.location-start.location-1):0);
                if (sub.length>0)
                    msg = [str substringWithRange:sub];

            }
        }
    }
    
    [mutret setObject:[NSNumber numberWithBool:isOK] forKey:@"Result"];
    if (!isOK){
        [mutret setObject:msg?msg:@"查询沽清失败" forKey:@"Message"];
    }
    
    return mutret;
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
        uploader.path = [NSString stringWithFormat:@"/orders/%@.order",[filename MD5]];
        
        [uploader start];
    });
}

#pragma mark -
#pragma mark Data Get & Refresh


- (NSArray *)getAdditions{
    NSMutableArray *ary = [NSMutableArray array];
    NSString *path = [BSDataProvider sqlitePath];
    sqlite3 *db;
    sqlite3_stmt *stat;
    NSString *sqlcmd;
    //   char *errorMsg;
    
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
        sqlcmd = @"select * from attach";
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                int count = sqlite3_column_count(stat);
                NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
                for (int i=0;i<count;i++){
                    char *attachKey = (char *)sqlite3_column_name(stat, i);
                    char *attachValue = (char *)sqlite3_column_text(stat, i);
                    NSString *strKey = nil,*strValue = nil;
                    if (attachKey)
                    strKey = [NSString stringWithUTF8String:attachKey];
                    if (attachValue)
                    strValue = [NSString stringWithUTF8String:attachValue];
                    if (strKey && strValue)
                        [mutDC setObject:strValue forKey:strKey];
                }
                [ary addObject:mutDC];
            }
        }
        sqlite3_finalize(stat);
    }
    sqlite3_close(db);
    
    return [NSArray arrayWithArray:ary]; 

}


- (void)updateData{
    
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docPath = [docPaths objectAtIndex:0];
//    NSDictionary *attribute;
    NSString *settingPath = [docPath stringByAppendingPathComponent:@"setting.plist"];
    NSDictionary *didict= [[NSDictionary alloc] initWithContentsOfFile:settingPath];
    NSString *ftpurl = nil;
    if (didict!=nil)
        ftpurl = [didict objectForKey:@"url"];
    
    if (!ftpurl)
        ftpurl = kPathHeader;
    ftpurl = [ftpurl stringByAppendingPathComponent:@"BookSystem.sqlite"];
    
    NSURL *url = nil;
	NSURLRequest *request;
	url = [NSURL URLWithString:ftpurl];
	request = [[NSURLRequest alloc] initWithURL:url
									cachePolicy:NSURLRequestUseProtocolCachePolicy
								timeoutInterval:2.0];
	
	
	// retreive the data using timeout
	NSURLResponse* response;
	NSError *error;

	
	error = nil;
	response = nil;
	NSData *serviceData = [NSURLConnection sendSynchronousRequest:request 
                                        returningResponse:&response
                                                    error:&error];
	[request release];
	// 1001 is the error code for a connection timeout
	if (!serviceData) {
		NSLog( @"Server timeout!" );
        [didict release];
        return;
	}
    

    NSData *sqldata = [[NSData alloc] initWithContentsOfURL:url];
    

 //   NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfURL:url];
    
    if (sqldata){
        [sqldata writeToFile:[docPath stringByAppendingPathComponent:@"BookSystem.sqlite"] atomically:NO];
        [sqldata release];
        infoDict = [[NSDictionary alloc] initWithDictionary:[self dictFromSQL]];
    }
    else{
        [sqldata release];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Download Data Failed,Please check your ftp setting and re-lanuch the app" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        [didict release];
        return;
    }
    
    
    NSArray *fileNames = [BSDataProvider getDataFromSQLByCommand:@"select * from FileList" sqlName:@"BookSystem.sqlite"];
    int count = [fileNames count];
    
    
    
    for (int i=0;i<count;i++){
        NSString *fileName = [[fileNames objectAtIndex:i] objectForKey:@"name"];
        NSString *path = [docPath stringByAppendingPathComponent:fileName];
        
        BOOL bFileExist = [fileManager fileExistsAtPath:path];
        
        if (!bFileExist){
            NSString *strURL = [[ftpurl stringByDeletingLastPathComponent] stringByAppendingPathComponent:fileName];
            NSData *sqldata = [NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]];
            [sqldata writeToFile:path atomically:NO];
        }
    }
    
    [didict release];
}

- (NSArray *)getADNames{
    return [infoDict objectForKey:@"Ads"];
}

- (void)refreshFiles{
    NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docPath = [docPaths objectAtIndex:0];
    NSArray *fileNames = nil;
    NSString *settingPath = [docPath stringByAppendingPathComponent:@"setting.plist"];
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
    infoDict = [self dictFromSQL];
    fileNames = [BSDataProvider getDataFromSQLByCommand:@"select * from FileList" sqlName:@"BookSystem.sqlite"];
    int count = [fileNames count];
    for (int i=0;i<count;i++){
        NSString *fileName = [[fileNames objectAtIndex:i] objectForKey:@"name"];
        NSString *path = [docPath stringByAppendingPathComponent:fileName];
        NSString *strURL = [[ftpurl stringByDeletingLastPathComponent] stringByAppendingPathComponent:fileName];
        imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]];
        [imgData writeToFile:path atomically:NO];
    }
}

- (NSArray *)getAllFoods{
    NSMutableArray *ary = [NSMutableArray array];
    NSString *path = [BSDataProvider sqlitePath];
    sqlite3 *db;
    sqlite3_stmt *stat;
    NSString *sqlcmd;
    
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
        sqlcmd = @"select * from food";
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                int count = sqlite3_column_count(stat);
                NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
                for (int i=0;i<count;i++){
                    char *foodKey = (char *)sqlite3_column_name(stat, i);
                    char *foodValue = (char *)sqlite3_column_text(stat, i);
                    NSString *strKey = nil,*strValue = nil;
                    strKey = nil;
                    strValue = nil;
                    if (foodKey)
                        strKey = [NSString stringWithUTF8String:foodKey];
                    if (foodValue)
                        strValue = [NSString stringWithUTF8String:foodValue];
                    if (strKey && strValue)
                        [mutDC setObject:strValue forKey:strKey];
                }
                [ary addObject:mutDC];
            }
        }
        sqlite3_finalize(stat);
    }
    sqlite3_close(db);
    
    return ary;
}

NSInteger intSort2(id num1,id num2,void *context){
    int v1 = [[(NSDictionary *)num1 objectForKey:@"ITCODE"] intValue];
    int v2 = [[(NSDictionary *)num2 objectForKey:@"ITCODE"] intValue];
    
    if (v1 < v2)
        return NSOrderedAscending;
    else if (v1 > v2)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}

- (NSMutableArray *)getFoodList:(NSString *)cmd{
    NSMutableArray *ary = [NSMutableArray array];
    NSString *path = [BSDataProvider sqlitePath];
    sqlite3 *db;
    sqlite3_stmt *stat;
    NSString *sqlcmd;
    
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
        sqlcmd = [NSString stringWithFormat:@"select * from food where %@",cmd];
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                int count = sqlite3_column_count(stat);
                NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
                for (int i=0;i<count;i++){
                    char *foodKey = (char *)sqlite3_column_name(stat, i);
                    char *foodValue = (char *)sqlite3_column_text(stat, i);
                    NSString *strKey = nil,*strValue = nil;
                    strKey = nil;
                    strValue = nil;
                    
                    if (foodKey)
                        strKey = [NSString stringWithUTF8String:foodKey];
                    if (foodValue)
                        strValue = [NSString stringWithUTF8String:foodValue];
                    if (strKey && strValue)
                        [mutDC setObject:strValue forKey:strKey];
                }
                [ary addObject:mutDC];
            }
        }
        sqlite3_finalize(stat);
    }
    sqlite3_close(db);
    
    return [NSArray arrayWithArray:[ary sortedArrayUsingFunction:intSort2 context:NULL]];
}

- (NSMutableArray *)getCodeDesc{
    NSMutableArray *ary = [NSMutableArray array];
    NSString *path = [BSDataProvider sqlitePath];
    sqlite3 *db;
    sqlite3_stmt *stat;
    NSString *sqlcmd;
    
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
        sqlcmd = @"select * from codedesc";
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                int count = sqlite3_column_count(stat);
                NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
                for (int i=0;i<count;i++){
                    char *foodKey = (char *)sqlite3_column_name(stat, i);
                    char *foodValue = (char *)sqlite3_column_text(stat, i);
                    NSString *strKey = nil,*strValue = nil;
                    
                    if (foodKey)
                        strKey = [NSString stringWithUTF8String:foodKey];
                    if (foodValue)
                        strValue = [NSString stringWithUTF8String:foodValue];
                    if (strKey && strValue)
                        [mutDC setObject:strValue forKey:strKey];
                }
                [ary addObject:mutDC];
            }
        }
        sqlite3_finalize(stat);
    }
    sqlite3_close(db);
    
    return ary;
}

- (NSMutableArray *)getClassList{
    NSMutableArray *ary = [NSMutableArray array];
    
    NSString *path = [BSDataProvider sqlitePath];
    sqlite3 *db;
    sqlite3_stmt *stat;
    NSString *sqlcmd;
    
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
        sqlcmd = @"select * from class";
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                int count = sqlite3_column_count(stat);
                NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
                for (int i=0;i<count;i++){
                    char *foodKey = (char *)sqlite3_column_name(stat, i);
                    char *foodValue = (char *)sqlite3_column_text(stat, i);
                    NSString *strKey = nil,*strValue = nil;
                    
                    if (foodKey)
                        strKey = [NSString stringWithUTF8String:foodKey];
                    if (foodValue)
                        strValue = [NSString stringWithUTF8String:foodValue];
                    if (strKey && strValue)
                        [mutDC setObject:strValue forKey:strKey];
                }
                [ary addObject:mutDC];
            }
        }
        sqlite3_finalize(stat);
    }
    sqlite3_close(db);
    
    return ary;
}

- (NSDictionary *)getClassByID:(NSString *)classid{
    NSMutableArray *ary = [NSMutableArray array];
    
    NSString *path = [BSDataProvider sqlitePath];
    sqlite3 *db;
    sqlite3_stmt *stat;
    NSString *sqlcmd;
    
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
        sqlcmd = [NSString stringWithFormat:@"select * from class where GRP = %@",classid];
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                int count = sqlite3_column_count(stat);
                NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
                for (int i=0;i<count;i++){
                    char *foodKey = (char *)sqlite3_column_name(stat, i);
                    char *foodValue = (char *)sqlite3_column_text(stat, i);
                    NSString *strKey = nil,*strValue = nil;
                    
                    if (foodKey)
                        strKey = [NSString stringWithUTF8String:foodKey];
                    if (foodValue)
                        strValue = [NSString stringWithUTF8String:foodValue];
                    if (strKey && strValue)
                        [mutDC setObject:strValue forKey:strKey];
                }
                [ary addObject:mutDC];
            }
        }
        sqlite3_finalize(stat);
    }
    sqlite3_close(db);
    
    return [ary count]>0?[ary objectAtIndex:0]:nil;
}

- (NSArray *)getCovers{
    NSMutableArray *ary = [NSMutableArray array];
    
    NSString *path = [BSDataProvider sqlitePath];
    sqlite3 *db;
    sqlite3_stmt *stat;
    NSString *sqlcmd;
    
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
        sqlcmd = @"select * from cover";
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                int count = sqlite3_column_count(stat);
                NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
                for (int i=0;i<count;i++){
                    char *foodKey = (char *)sqlite3_column_name(stat, i);
                    char *foodValue = (char *)sqlite3_column_text(stat, i);
                    NSString *strKey=nil,*strValue=nil;
                    
                    if (foodKey)
                        strKey = [NSString stringWithUTF8String:foodKey];
                    if (foodValue)
                        strValue = [NSString stringWithUTF8String:foodValue];
                    if (strKey && strValue)
                        [mutDC setObject:strValue forKey:strKey];
                }
                [ary addObject:mutDC];
            }
        }
        sqlite3_finalize(stat);
    }
    sqlite3_close(db);
    
    return ary;
}

- (NSArray *)getCaptions{
    NSMutableArray *ary = [NSMutableArray array];
    
   NSString *path = [BSDataProvider sqlitePath];
    sqlite3 *db;
    sqlite3_stmt *stat;
    NSString *sqlcmd;
    
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
        sqlcmd = @"select * from caption";
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                int count = sqlite3_column_count(stat);
                NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
                for (int i=0;i<count;i++){
                    char *foodKey = (char *)sqlite3_column_name(stat, i);
                    char *foodValue = (char *)sqlite3_column_text(stat, i);
                    NSString *strKey=nil,*strValue=nil;
                    
                    if (foodKey)
                        strKey = [NSString stringWithUTF8String:foodKey];
                    if (foodValue)
                        strValue = [NSString stringWithUTF8String:foodValue];
                    if (strKey && strValue)
                        [mutDC setObject:strValue forKey:strKey];
                }
                [ary addObject:mutDC];
            }
        }
        sqlite3_finalize(stat);
    }
    sqlite3_close(db);
    
    return ary;
}

- (NSArray *)getAccounts{
    NSMutableArray *ary = [NSMutableArray array];
    
   NSString *path = [BSDataProvider sqlitePath];
    sqlite3 *db;
    sqlite3_stmt *stat;
    NSString *sqlcmd;
    
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
        sqlcmd = @"select * from user";
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                int count = sqlite3_column_count(stat);
                NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
                for (int i=0;i<count;i++){
                    char *foodKey = (char *)sqlite3_column_name(stat, i);
                    char *foodValue = (char *)sqlite3_column_text(stat, i);
                    NSString *strKey = nil,*strValue = nil;
                    
                    if (foodKey)
                        strKey = [NSString stringWithUTF8String:foodKey];
                    if (foodValue)
                        strValue = [NSString stringWithUTF8String:foodValue];
                    if (strKey && strValue)
                        [mutDC setObject:strValue forKey:strKey];
                }
                [ary addObject:mutDC];
            }
        }
        sqlite3_finalize(stat);
    }
    sqlite3_close(db);
    
    return ary;
}

- (NSDictionary *)dictFromSQL{
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    NSMutableArray *mutAds = [NSMutableArray array];
    NSMutableArray *mutFileList = [NSMutableArray array];

    NSMutableArray *mutClass = [NSMutableArray array];
    
    NSString *path = [BSDataProvider sqlitePath];
    sqlite3 *db;
    sqlite3_stmt *stat;
    NSString *sqlcmd;
 //   char *errorMsg;
    
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
        //Generate Ads & FileList
        //1 Ads
        sqlcmd = @"select * from ads";
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                char *name = (char *)sqlite3_column_text(stat, 0);
                [mutAds addObject:[NSString stringWithUTF8String:name]];
            }
        }
        sqlite3_finalize(stat);
        [ret setObject:mutAds forKey:@"Ads"];
        //2 FileList
        sqlcmd = @"select * from FileList";
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                char *name = (char *)sqlite3_column_text(stat, 0);
                [mutFileList addObject:[NSString stringWithUTF8String:name]];
            }
        }
        sqlite3_finalize(stat);
        [ret setObject:mutFileList forKey:@"FileList"];
        
        
        //Generate Main Menu
        //1. Get image,name of MainMenu
        sqlcmd = @"select * from class";
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                char *background = (char *)sqlite3_column_text(stat,0);
                int type = sqlite3_column_int(stat, 1);
                char *image = (char *)sqlite3_column_text(stat,2);
                char *name = (char *)sqlite3_column_text(stat, 3);
                char *recommend = (char *)sqlite3_column_text(stat, 4);
 
                NSMutableDictionary *mut = [NSMutableDictionary dictionary];
                [mut setObject:[NSNumber numberWithInt:type] forKey:@"type"];
                if (background)
                    [mut setObject:[NSString stringWithUTF8String:background] forKey:@"background"];
                if (image)
                     [mut setObject:[NSString stringWithUTF8String:image] forKey:@"image"];
                if (name)
                     [mut setObject:[NSString stringWithUTF8String:name] forKey:@"name"];
                if (recommend)
                     [mut setObject:[NSString stringWithUTF8String:recommend] forKey:@"recommend"];
                
                [mutClass addObject:mut];
            }
        }
        sqlite3_finalize(stat);
        
        //2. Genereate by Food
        for (int i=0;i<[mutClass count];i++){
            NSMutableDictionary *mutC = [mutClass objectAtIndex:i];
            NSString *strOrder;
            NSString *strPrice = [[NSUserDefaults standardUserDefaults] stringForKey:@"price"];
            if ([strPrice isEqualToString:@"PRICE"])
                strOrder = @"ITEMNO";
            else if ([strPrice isEqualToString:@"PRICE"])
                strOrder = @"ITEMNO2";
            else
                strOrder = @"ITEMNO3";
            sqlcmd = [NSString stringWithFormat:@"select * from food where GRPTYP = %d and HSTA = 'Y' order by %@",[[[mutClass objectAtIndex:i] objectForKey:@"type"] intValue],strOrder];
            NSMutableArray *foods = [NSMutableArray array];
            if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
                while (sqlite3_step(stat)==SQLITE_ROW) {
                    int count = sqlite3_column_count(stat);
                    NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
                    for (int i=0;i<count;i++){
                        char *foodKey = (char *)sqlite3_column_name(stat, i);
                        char *foodValue = (char *)sqlite3_column_text(stat, i);
                        NSString *strKey = nil,*strValue = nil;
                        strKey = nil;
                        strValue = nil;
                        if (foodKey)
                            strKey = [NSString stringWithUTF8String:foodKey];
                        if (foodValue)
                            strValue = [NSString stringWithUTF8String:foodValue];
                        if (strKey && strValue)
                            [mutDC setObject:strValue forKey:strKey];
                    }
                    [foods addObject:mutDC];
                }
            }
            sqlite3_finalize(stat);
            
            if (foods && [foods count]>0)
                [mutC setObject:foods forKey:@"SubMenu"];
        }
        
        if (mutClass && [mutClass count]>0)
            [ret setObject:mutClass forKey:@"MainMenu"];
    }
    sqlite3_close(db);

    return ret;
}
- (NSDictionary *)dataDict{
    return infoDict;
}

- (void)getCachedFile{
    NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docPath = [docPaths objectAtIndex:0];
    NSArray *fileNames = nil;
    NSString *ftpurl = nil;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:[docPath stringByAppendingPathComponent:@"BookSystem.sqlite"]])
    {
        NSString *settingPath = [docPath stringByAppendingPathComponent:@"setting.plist"];
        NSDictionary *didict= [[NSDictionary alloc] initWithContentsOfFile:settingPath];
        
        if (didict!=nil)
            ftpurl = [didict objectForKey:@"url"];
        
        if (!ftpurl)
            ftpurl = kPathHeader;
        ftpurl = [ftpurl stringByAppendingPathComponent:@"BookSystem.sqlite"];

        NSData *sqldata = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:ftpurl]];
        [sqldata writeToFile:[docPath stringByAppendingPathComponent:@"BookSystem.sqlite"] atomically:NO];
        [didict release];
        [sqldata release];
    }
    
    fileNames = [BSDataProvider getDataFromSQLByCommand:@"select * from FileList" sqlName:@"BookSystem.sqlite"];
    if (![fileNames isKindOfClass:[NSArray class]]){
        NSString *fileName = (NSString *)fileNames;
        NSString *path = [docPath stringByAppendingPathComponent:fileName];
        if (![fileManager fileExistsAtPath:path]){
            NSString *strURL = [[ftpurl stringByDeletingLastPathComponent] stringByAppendingPathComponent:fileName];
            NSData *sqldata = [NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]];
            [sqldata writeToFile:path atomically:NO];
        }
    }else{
        int count = [fileNames count];
        for (int i=0;i<count;i++){
            NSString *fileName = [[fileNames objectAtIndex:i] objectForKey:@"name"];
            NSString *path = [docPath stringByAppendingPathComponent:fileName];
            if (![fileManager fileExistsAtPath:path]){
                NSString *strURL = [[ftpurl stringByDeletingLastPathComponent] stringByAppendingPathComponent:fileName];
                NSData *sqldata = [NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]];
                [sqldata writeToFile:path atomically:NO];
            }
            
        }
    }
    
}

- (void)writeToServer:(const uint8_t *)buf{
    [oStream write:buf maxLength:strlen((char*)buf)];
}
    


#pragma mark -
#pragma mark 上传菜品，催菜，退菜，查询订单
- (void)orderFood:(NSDictionary *)info{
    //info包括菜品信息＋数量＋附加项
    //增加价格和单位信息
    if ([info objectForKey:@"food"]){
        int i = [[NSUserDefaults standardUserDefaults] integerForKey:@"OrderTimeCount"];
        i++;
        NSMutableDictionary *mut = [NSMutableDictionary dictionaryWithDictionary:info];
        if (![mut objectForKey:@"unitKey"]){
            [mut setObject:@"UNIT" forKey:@"unitKey"];
            [mut setObject:@"PRICE" forKey:@"priceKey"];
        }
        
        
        [mut setObject:[NSNumber numberWithInt:i] forKey:@"OrderTimeCount"];
        [mut setObject:[NSNumber numberWithBool:NO] forKey:@"isPack"];
        [[NSUserDefaults standardUserDefaults] setInteger:i forKey:@"OrderTimeCount"];
        
        info = [NSDictionary dictionaryWithDictionary:mut];
        
        [aryOrders addObject:info]; 
    }else if ([info objectForKey:@"foods"]){
        NSArray *ary = [info objectForKey:@"foods"];
        int j = [[NSUserDefaults standardUserDefaults] integerForKey:@"OrderTimeCount"];
        j++;
        NSMutableArray *foods = [NSMutableArray array];
        for (int i=0;i<[ary count];i++){
            NSDictionary *dict = [BSDataProvider getDataFromSQLByCommand:[NSString stringWithFormat:@"select * from food where ITEM = %@",[[ary objectAtIndex:i] objectForKey:@"ITEM"]]];
            
            if (dict){
                NSMutableDictionary *mut = [NSMutableDictionary dictionaryWithDictionary:dict];
                [mut setObject:[info objectForKey:@"PACKID"] forKey:@"PACKID"];
                [mut setObject:@"1" forKey:@"PACKCNT"];
                [mut setObject:@"1" forKey:@"total"];

                
//                info = [NSDictionary dictionaryWithDictionary:mut];
                
                [foods addObject:mut]; 
            }

        }
        NSMutableDictionary *mutdict = [NSMutableDictionary dictionaryWithDictionary:info];
        [mutdict setObject:[NSNumber numberWithInt:j] forKey:@"OrderTimeCount"];
        [mutdict setObject:foods forKey:@"foods"];
        [mutdict setObject:[NSNumber numberWithBool:YES] forKey:@"isPack"];
        if (![mutdict objectForKey:@"unitKey"]){
            [mutdict setObject:@"UNIT" forKey:@"unitKey"];
            [mutdict setObject:@"PRICE" forKey:@"priceKey"];
        }
        [aryOrders addObject:mutdict];
        
        [[NSUserDefaults standardUserDefaults] setInteger:j forKey:@"OrderTimeCount"];
    }
    
    
    [self saveOrders];
    
}



- (NSMutableArray *)orderedFood{
    return aryOrders;
    //
    NSMutableArray *ary = [NSMutableArray array];
    
    NSMutableSet *mutset = [NSMutableSet set];
    
    for (int i=0;i<[aryOrders count];i++){
        if (![mutset containsObject:[[aryOrders objectAtIndex:i] objectForKey:@"OrderTimeCount"]])
            [mutset addObject:[[aryOrders objectAtIndex:i] objectForKey:@"OrderTimeCount"]];
    }

    NSArray *aryset = [mutset allObjects];
    for (int i=0;i<[aryset count];i++){
        NSArray *resultary = [[[NSSet setWithArray:aryOrders] filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.OrderTimeCount == %d",[[aryset objectAtIndex:i] intValue]]] allObjects];
        
        if ([resultary count]>1){
            NSString *suitid = [[resultary lastObject] objectForKey:@"PACKID"];
            NSDictionary *suitdetail = [self getPackageDetail:suitid];
            NSMutableDictionary *mutdict = [NSMutableDictionary dictionaryWithDictionary:suitdetail];
            [mutdict setObject:resultary forKey:@"foods"];
            [mutdict setObject:[NSNumber numberWithBool:YES] forKey:@"isPack"];
            
            [ary addObject:mutdict];
            
        }else{
            NSMutableDictionary *mutdict = [NSMutableDictionary dictionaryWithDictionary:[resultary lastObject]];
            [mutdict setObject:[NSNumber numberWithBool:NO] forKey:@"isPack"];
            
            [ary addObject:mutdict];
        }
    }
    
    return ary;
}


- (NSDictionary *)pGogo:(NSDictionary *)info{
    NSString *user,*pwd;
    NSString *pdaid = [NSString stringWithFormat:@"%@-%d",[self padID],[[[self currentPageConfig] objectForKey:@"number"] intValue]];
    user = [info objectForKey:@"user"];
    pwd = [info objectForKey:@"pwd"];
    if (pwd)
        user = [NSString stringWithFormat:@"%@-%@",user,pwd];
    int tab = [[info objectForKey:@"tab"] intValue];
    NSString *foodnum = [info objectForKey:@"num"];

    NSString *strParam = [NSString stringWithFormat:@"?PdaID=%@&User=%@&Acct=%d&oSerial=%@",pdaid,user,tab,foodnum];

    NSDictionary *dict = [self bsService:@"pGogo" arg:strParam];
    if (dict) {
//        NSString *strValue = [[dict objectForKey:@"string"] objectForKey:@"text"];
        NSString *result = [[[dict objectForKey:@"Root"] objectForKey:@"OStr"] objectForKey:@"text"];//[[[[strValue componentsSeparatedByString:@"<oStr>"] objectAtIndex:1] componentsSeparatedByString:@"</oStr>"] objectAtIndex:0];
        NSArray *ary = [result componentsSeparatedByString:@"<"];
        NSRange range = [[ary objectAtIndex:1] rangeOfString:@"ok"];
        if (range.location!=NSNotFound){
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result", nil];
        }
        else{
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",
                    [[[[[ary objectAtIndex:1] componentsSeparatedByString:@":"] objectAtIndex:1] componentsSeparatedByString:@">"] objectAtIndex:0],@"Message",nil];
        }
    }else{
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",@"催菜失败",@"Message",nil];
    }
    return nil;
}
-(NSDictionary *)pChangMan:(NSDictionary *)info
{
    NSString *user,*pwd;
    NSString *pdaid = [NSString stringWithFormat:@"%@-%d",[self padID],[[[self currentPageConfig] objectForKey:@"number"] intValue]];
    user = [info objectForKey:@"user"];
    pwd = [info objectForKey:@"pwd"];
    if (pwd)
        user = [NSString stringWithFormat:@"%@,%@",user,pwd];
    NSString *tab = [info objectForKey:@"tab"];
    NSString *strParam = [NSString stringWithFormat:@"?User=modipeoplenum&Pass=%@,%@,%@,%@",pdaid,user,tab,[info objectForKey:@"man"]];
    
    NSDictionary *dict = [self bsService:@"pLoginUser" arg:strParam];
    NSMutableDictionary *dict1=[NSMutableDictionary dictionary];
    if (dict) {
        NSString *result = [[[dict objectForKey:@"Root"] objectForKey:@"OStr"] objectForKey:@"text"];
        [dict1 setValue:result forKey:@"message"];
//        NSArray *ary = [result componentsSeparatedByString:@"<"];
//        NSString *content = [[[ary objectAtIndex:1] componentsSeparatedByString:@">"] objectAtIndex:0];
//        NSRange range = [content rangeOfString:@"ok"];
//        result = [[content componentsSeparatedByString:@":"] objectAtIndex:1];
//        if (range.location!=NSNotFound){
//            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",result,@"Message", nil];
//        }
//        else
//            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",result,@"Message", nil];
    }else
    {
        [dict1 setValue:@"网络连接失败" forKey:@"message"];
    }
    
    return dict1;

}


- (NSDictionary *)pQuery:(NSDictionary *)info{
    NSMutableDictionary *dicMut = [NSMutableDictionary dictionary];
    
    NSString *user,*pwd;
    NSString *pdaid = [NSString stringWithFormat:@"%@-%d",[self padID],[[[self currentPageConfig] objectForKey:@"number"] intValue]];
    user = [info objectForKey:@"user"];
    pwd = [info objectForKey:@"pwd"];
    if (pwd)
        user = [NSString stringWithFormat:@"%@-%@",user,pwd];
    NSString *table = [info objectForKey:@"table"];
    
    NSString *strParam = [NSString stringWithFormat:@"?PdaID=%@&User=%@&TblInit=%@&iRecNo=0",pdaid,user,table];
    NSDictionary *dict = [self bsService:@"pQuery" arg:strParam];
    NSString *result = [[[dict objectForKey:@"Root"] objectForKey:@"Buffer"] objectForKey:@"text"];//[[[[[[dict objectForKey:@"string"] objectForKey:@"text"]  componentsSeparatedByString:@"<Buffer>"] objectAtIndex:1] componentsSeparatedByString:@"</Buffer>"] objectAtIndex:0];
    NSArray *ary = [result componentsSeparatedByString:@"<"];
    
    if ([result rangeOfString:@"error"].location!=NSNotFound){
        [dicMut setObject:[NSNumber numberWithBool:NO] forKey:@"Result"];
        if (result==nil) {
            [dicMut setObject:@"网络连接失败" forKey:@"Message"];
        }else
        {
        
        [dicMut setObject:[[[[[ary objectAtIndex:1] componentsSeparatedByString:@">"] objectAtIndex:0] componentsSeparatedByString:@":"] objectAtIndex:1] forKey:@"Message"];
        }
    }else{
        if (![result isEqualToString:@"+query<end>"]){
            
            NSString *content = [[[ary objectAtIndex:1] componentsSeparatedByString:@">"] objectAtIndex:0];
            
            NSArray *aryFenhao = [content componentsSeparatedByString:@";"];
            if ([aryFenhao count]>3){
                NSString *tab = [[[aryFenhao objectAtIndex:0] componentsSeparatedByString:@":"] objectAtIndex:1];
                NSString *total = [[[aryFenhao objectAtIndex:1] componentsSeparatedByString:@":"] objectAtIndex:1];
                NSString *people = [[[aryFenhao objectAtIndex:2] componentsSeparatedByString:@":"] objectAtIndex:1];
                
                [dicMut setObject:tab forKey:@"tab"];
                [dicMut setObject:total forKey:@"total"];
                [dicMut setObject:people forKey:@"people"];
                
                NSString *account = [[[aryFenhao objectAtIndex:3] componentsSeparatedByString:@":"] objectAtIndex:1];
                NSArray *aryAcc = [account componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"&"]];
                int countAcc = [aryAcc count];
                
                NSMutableArray *aryMut = [NSMutableArray array];
                for (int i=0;i<countAcc;i++){
                    NSMutableDictionary *mutFood = [NSMutableDictionary dictionary];
                    NSString *strAcc = [aryAcc objectAtIndex:i];
                    NSArray *aryStr = [strAcc componentsSeparatedByString:@"^"];
                    
                    if ([aryStr count]>8){
                        [mutFood setObject:[aryStr objectAtIndex:0] forKey:@"num"];
                        [mutFood setObject:[aryStr objectAtIndex:1] forKey:@"name"];
                        [mutFood setObject:[aryStr objectAtIndex:2] forKey:@"total"];
                        [mutFood setObject:[aryStr objectAtIndex:3] forKey:@"price"];
                        [mutFood setObject:[aryStr objectAtIndex:4] forKey:@"unit"];
                        [mutFood setObject:[aryStr objectAtIndex:5] forKey:@"add1"];
                        [mutFood setObject:[aryStr objectAtIndex:6] forKey:@"add2"];
                        [mutFood setObject:[[[aryStr objectAtIndex:7] componentsSeparatedByString:@"#"] objectAtIndex:1] forKey:@"waiter"];
                        [mutFood setObject:[aryStr objectAtIndex:8] forKey:@"PACKID"];
                        [aryMut addObject:mutFood];
                    }
                    
                }
                
                [dicMut setObject:aryMut forKey:@"account"];
                
            }
        
        }
    }
    
    
    return dicMut;
    

}

- (NSDictionary *)pChuck:(NSDictionary *)info{
    NSString *user,*userid,*pwd,*tab,*reason,*foodnum;
    /*
     function pChuck(PdaID,User,GrantEmp,GrantPass,oSerial,Rsn,Cnt,oStr:PChar):PChar; stdcall; //退菜
     
     参数说明：
     PdaID       :PDA号 //格式'1-1'第一个1为PDA编码，第二个为餐厅号 ，默认为1
     USER        :工号
     GrantEmp    :授权人工号
     GrantPass   :授权人密码
     oSerial     :菜品流水号
     Rsn         :退菜原因码
     Cnt         :退菜数量
     oStr        :返回值
     */
    NSString *pdaid = [NSString stringWithFormat:@"%@-%d",[self padID],[[[self currentPageConfig] objectForKey:@"number"] intValue]];
    userid = [info objectForKey:@"user"];
    pwd = [info objectForKey:@"pwd"];
    user = [info objectForKey:@"user"];
    if (pwd)
        user = [NSString stringWithFormat:@"%@-%@",user,pwd];

    tab = [[[info objectForKey:@"account"] objectAtIndex:0] objectForKey:@"num"];
    reason = [info objectForKey:@"rsn"];
    foodnum = [info objectForKey:@"total"];
    
    NSString *strParam = [NSString stringWithFormat:@"?PdaID=%@&User=%@&GrantEmp=%@&GrantPass=%@&oSerial=%@&Rsn=%@&Cnt=%@",pdaid,user,userid,pwd,tab,reason,foodnum];
    
    
    NSDictionary *dict = [self bsService:@"pChuck" arg:strParam];
//    NSString *strValue = [[dict objectForKey:@"string"] objectForKey:@"text"];
    if (dict){
        NSString *result = [[[dict objectForKey:@"Root"] objectForKey:@"OStr"] objectForKey:@"text"];//[[[[strValue componentsSeparatedByString:@"<oStr>"] objectAtIndex:1] componentsSeparatedByString:@"</oStr>"] objectAtIndex:0];
        NSArray *ary = [result componentsSeparatedByString:@"<"];
        NSRange range = [[ary objectAtIndex:1] rangeOfString:@"ok"];
        if (range.location!=NSNotFound){
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result", nil];
        }
        else{
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",
                    [[[[[ary objectAtIndex:1] componentsSeparatedByString:@":"] objectAtIndex:1] componentsSeparatedByString:@">"] objectAtIndex:0],@"Message",nil];
        }
    }
    return nil;    
}

- (NSArray *)expendList:(NSArray *)ary{
    NSMutableArray *mut = [NSMutableArray array];
    for (int i=0;i<[ary count];i++){
        NSDictionary *dict = [ary objectAtIndex:i];
        BOOL isPack = [[dict objectForKey:@"isPack"] boolValue];
        if (isPack){
            NSArray *foods = [dict objectForKey:@"foods"];
            for (int j=0;j<[foods count];j++){
                NSDictionary *food = [foods objectAtIndex:j];
                NSMutableDictionary *mutfood = [NSMutableDictionary dictionaryWithObject:food forKey:@"food"];
                [mutfood setObject:@"PRICE" forKey:@"priceKey"];
                [mutfood setObject:@"1.00" forKey:@"total"];
                [mutfood setObject:@"UNIT" forKey:@"unitKey"];
                [mut addObject:mutfood];
                
            }
        }else 
            [mut addObject:dict];
    }
    
    return [NSArray arrayWithArray:mut];
}

- (NSArray *)foldList:(NSArray *)ary{
    NSMutableArray *mut = [NSMutableArray array];
    NSMutableArray *mutpack = [NSMutableArray array];
    for (int i=0;i<[ary count];i++){
        NSDictionary *food = [ary objectAtIndex:i];
        if ([[food objectForKey:@"PACKID"] intValue]>0)
            [mutpack addObject:food];
        else
            [mut addObject:food];
    }
    
    NSMutableSet *mutset = [NSMutableSet set];
    
    for (int i=0;i<[mutpack count];i++){
        if (![mutset containsObject:[[mutpack objectAtIndex:i] objectForKey:@"PACKID"]])
            [mutset addObject:[[mutpack objectAtIndex:i] objectForKey:@"PACKID"]];
    }
}

- (NSString *)pSendTab:(NSArray *)ary options:(NSDictionary *)info{
    if (ary && [ary count]>0){
        ary = [self expendList:ary];

        NSString *user,*acct,*tb,*usr,*pn,*type,*cmd,*pwd;
        NSMutableString *addition = [NSMutableString string];
        NSMutableString *tablist = [NSMutableString string];
        int tabid,foodnum;
        
        NSString *pdaid = [NSString stringWithFormat:@"%@-%d",[self padID],[[[self currentPageConfig] objectForKey:@"number"] intValue]];
        user = [info objectForKey:@"user"];
        pwd = [info objectForKey:@"pwd"];
        if (pwd)
            user = [NSString stringWithFormat:@"%@-%@",user,pwd];
        tabid = dSendCount++;
        acct = @"0";
        tb = [info objectForKey:@"table"];
        usr = [info objectForKey:@"usr"];
        usr = usr?usr:user;
        pn = [info objectForKey:@"pn"];//@"4";
        if (0==[pn intValue])
            pn = @"4";
        foodnum = [ary count];
        type = [info objectForKey:@"type"];

        
        [addition appendString:@"|"];
        
        
        
        for (int i=0;i<foodnum;i++){
            NSDictionary *dic = [ary objectAtIndex:i];
            NSMutableArray *aryMut = [NSMutableArray array];
            
            if ([info objectForKey:@"common"])
                [aryMut addObjectsFromArray:[info objectForKey:@"common"]];
            if ([dic objectForKey:@"addition"])
                [aryMut addObjectsFromArray:[dic objectForKey:@"addition"]];
            
            int additionCount = [aryMut count];
            for (int i=0;i<10;i++){
                if (i%2==0){
                    int index = i/2;
                    if (index<additionCount)
                        [addition appendString:[[aryMut objectAtIndex:index] objectForKey:@"DES"]];
                    [addition appendString:@"|"];
                }
                else{
                    int index = (i-1)/2;
                    if (index<additionCount){
                        NSString *additionprice = [[aryMut objectAtIndex:index] objectForKey:@"PRICE1"];
                        if (!additionprice)
                            additionprice = @"0.0";
                        [addition appendString:additionprice];
                    }
                        
                    [addition appendString:@"|"];
                }
                
            }
            
            int packid = [[[dic objectForKey:@"food"] objectForKey:@"PACKID"] intValue];
            int packcnt = [[[dic objectForKey:@"food"] objectForKey:@"PACKCNT"] intValue];
            packid = 0==packid?-1:packid;
//            packcnt = 0==packcnt?-1:packcnt;
            
            float fTotal = [[[dic objectForKey:@"food"] objectForKey:[dic objectForKey:@"priceKey"]?[dic objectForKey:@"priceKey"]:[[NSUserDefaults standardUserDefaults] stringForKey:@"price"]] floatValue];
//            [tablist appendFormat:@"-1|0|%@|%@|%@|%@|0.00%@0|\n",[[dic objectForKey:@"food"] objectForKey:@"ITCODE"],[dic objectForKey:@"total"],[[dic objectForKey:@"food"] objectForKey:@"UNIT"],[NSString stringWithFormat:@"%.2f",fTotal],addition];
            [tablist appendFormat:@"%d|%d|%@|%@|%@|%@|0.00%@0|^",packid,packcnt,[[dic objectForKey:@"food"] objectForKey:@"ITCODE"],[dic objectForKey:@"total"],[[dic objectForKey:@"food"] objectForKey:[dic objectForKey:@"unitKey"]],[NSString stringWithFormat:@"%.2f",fTotal],addition];
            
            addition = [NSMutableString string];
            [addition appendFormat:@"|"];
        }

        
        cmd = [NSString stringWithFormat:@"+sendtab<pdaid:%@;user:%@;tabid:%d;acct:%@;tb:%@;usr:%@;pn:%@;foodnum:%d;type:%@;tablist:%@;>^",pdaid,user,tabid,acct,tb,usr,pn,foodnum,type,tablist];
        
        return cmd;
    }else
    {
        return nil;
    }
//        [self uploadFood:cmd];
//        
//
//        
//        NSString *strParam = [NSString stringWithFormat:@"?PdaID=%@&User=%@&PdaSerial=%d&Acct=%@&TblInit=%@&Waiter=%@&Pax=%@&zCnt=%d&Typ=%@&sbBuffer=%@",pdaid,user,tabid,acct,tb,usr,pn,foodnum,type,tablist];
//        
//        
//        
//        
//        NSDictionary *dict;
//        dict = [self bsService:@"pSendTab" arg:strParam];
//        if (dict) {
//
//            NSString *result = [[[dict objectForKey:@"Root"] objectForKey:@"OStr"] objectForKey:@"text"];
//            NSArray *ary = [result componentsSeparatedByString:@"<"];
//            NSRange range = [[ary objectAtIndex:1] rangeOfString:@"ok"];
//            if (range.location != NSNotFound) {
//                return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",
//                        [[[[[ary objectAtIndex:1] componentsSeparatedByString:@"msg:"] objectAtIndex:1] componentsSeparatedByString:@">"] objectAtIndex:0],@"Message",[[[[[ary objectAtIndex:1] componentsSeparatedByString:@"msg"] objectAtIndex:0] componentsSeparatedByString:@":"] objectAtIndex:1],@"tab", nil];
//            } else {
//                return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",
//                        [[[[[ary objectAtIndex:1] componentsSeparatedByString:@":"] objectAtIndex:1] componentsSeparatedByString:@">"] objectAtIndex:0],@"Message",nil];
//            }
//        }
//    }
//    
//    return nil;
}

- (NSString *)cachedOrder:(NSDictionary *)order{
    NSArray *ary = [order objectForKey:@"foods"];
    NSString *name = [order objectForKey:@"name"];
    
    if (ary && [ary count]>0){
        ary = [self expendList:ary];
        

        NSMutableString *addition = [NSMutableString string];
        NSMutableString *tablist = [NSMutableString string];
        int foodnum;
        
        NSString *pdaid = [NSString stringWithFormat:@"%@-%d",[self padID],[[[self currentPageConfig] objectForKey:@"number"] intValue]];
        foodnum = [ary count];        
        
        [addition appendString:@"|"];
        
        
        
        for (int i=0;i<foodnum;i++){
            NSDictionary *dic = [ary objectAtIndex:i];
            NSMutableArray *aryMut = [NSMutableArray array];

            if ([dic objectForKey:@"addition"])
                [aryMut addObjectsFromArray:[dic objectForKey:@"addition"]];
            
            int additionCount = [aryMut count];
            for (int i=0;i<10;i++){
                if (i%2==0){
                    int index = i/2;
                    if (index<additionCount)
                        [addition appendString:[[aryMut objectAtIndex:index] objectForKey:@"DES"]];
                    [addition appendString:@"|"];
                }
                else{
                    int index = (i-1)/2;
                    if (index<additionCount){
                        NSString *additionprice = [[aryMut objectAtIndex:index] objectForKey:@"PRICE1"];
                        if (!additionprice)
                            additionprice = @"0.0";
                        [addition appendString:additionprice];
                    }
                    
                    [addition appendString:@"|"];
                }
                
            }
            
            int packid = [[[dic objectForKey:@"food"] objectForKey:@"PACKID"] intValue];
            int packcnt = [[[dic objectForKey:@"food"] objectForKey:@"PACKCNT"] intValue];
            packid = 0==packid?-1:packid;
            //            packcnt = 0==packcnt?-1:packcnt;
            
            float fTotal = [[[dic objectForKey:@"food"] objectForKey:[dic objectForKey:@"priceKey"]?[dic objectForKey:@"priceKey"]:[[NSUserDefaults standardUserDefaults] stringForKey:@"price"]] floatValue];
            //            [tablist appendFormat:@"-1|0|%@|%@|%@|%@|0.00%@0|\n",[[dic objectForKey:@"food"] objectForKey:@"ITCODE"],[dic objectForKey:@"total"],[[dic objectForKey:@"food"] objectForKey:@"UNIT"],[NSString stringWithFormat:@"%.2f",fTotal],addition];
            [tablist appendFormat:@"%d|%d|%@|%@|%@|%@|0.00%@0|^",packid,packcnt,[[dic objectForKey:@"food"] objectForKey:@"ITCODE"],[dic objectForKey:@"total"],[[dic objectForKey:@"food"] objectForKey:[dic objectForKey:@"unitKey"]],[NSString stringWithFormat:@"%.2f",fTotal],addition];
            
            addition = [NSMutableString string];
            [addition appendFormat:@"|"];
        }
        
        
        return [NSString stringWithFormat:@"+gettempfolio<pdaid:%@;name:%@;foodnum:%d;tablist:%@;>^",pdaid,name,foodnum,tablist];
    }else
        return nil;
}
- (NSDictionary *)pListTable:(NSDictionary *)info{
    
    //+listtable<user:%s;pdanum:%s;floor:%s;area:%s;status:%s;>\r\n
    //'全部状态' '空闲' '开台点菜' '开台未点' '预订' '预结'全部楼层=ALLFLOOR全部区域=ALLAREA全部状态=ALLSTA
    /*
     '空闲'=A  
     '开台点菜'=B
     '开台未点'=C
     '预订'=D
     '预结'=E
     */
    NSMutableDictionary *mut = [NSMutableDictionary dictionary];
    
    NSString *user,*pdanum,*floor,*area,*status;
    NSString *cmd;
    
 //   user = [NSString stringWithFormat:@"%@-%@",[info objectForKey:@"user"],[info objectForKey:@"pwd"]];
    user = @"-";
    pdanum = [NSString stringWithFormat:@"%@-%d",[self padID],[[[self currentPageConfig] objectForKey:@"number"] intValue]];
    floor = [info objectForKey:@"floor"];
    if (!floor)
        floor = @"";
    area = [info objectForKey:@"area"];
    if (!area)
        area = @"";
    status = [info objectForKey:@"status"];
    if (!status)
        status = @"";
    
    
    cmd = [NSString stringWithFormat:@"+listtable<user:%@;pdanum:%@;floor:%@;area:%@;status:%@;>\r\n",user,pdanum,floor,area,status];
   
    NSString *strParam = [NSString stringWithFormat:@"?User=%@&Floor=%@&Area=%@&Status=%@&PdaId=%@&iRecNo=",user,floor,area,status,pdanum];
    NSDictionary *dict = [self bsService:@"pListTable" arg:strParam];
   
    if (dict){
        
        NSString *result = [[[dict objectForKey:@"Root"] objectForKey:@"Buffer"] objectForKey:@"text"];
        
        NSArray *ary = [result componentsSeparatedByString:@"<"];
        
        if (ary.count>1){
            NSString *content = [[[ary objectAtIndex:1] componentsSeparatedByString:@">"] objectAtIndex:0];
            if ([[content componentsSeparatedByString:@":"] count]<2){
                
                //            NSRange range = [content rangeOfString:@"ok"];
                //             if (range.location!=NSNotFound){
                [mut setObject:[NSNumber numberWithBool:YES] forKey:@"Result"];
                
                NSArray *aryTables = [content componentsSeparatedByString:@"|"];
                
                NSMutableArray *mutTables = [NSMutableArray array];
                
                for (NSString *strTable in aryTables){
                    
                    NSArray *aryTableInfo = [strTable componentsSeparatedByString:@"^"];
                    NSMutableDictionary *mutTable = [NSMutableDictionary dictionary];
                    
                    if ([aryTableInfo count]>=4){
                        [mutTable setObject:[aryTableInfo objectAtIndex:0] forKey:@"code"];
                        [mutTable setObject:[aryTableInfo objectAtIndex:1] forKey:@"short"];
                        [mutTable setObject:[aryTableInfo objectAtIndex:2] forKey:@"name"];
                        [mutTable setObject:[aryTableInfo objectAtIndex:3] forKey:@"status"];
                        
                        [mutTables addObject:mutTable];
                    }
                    
                }

                [mut setObject:mutTables forKey:@"Message"];
                
                
                if ([mutTables count]>0)
                    [[NSNotificationCenter defaultCenter] postNotificationName:msgListTable object:nil userInfo:mut];
            }
            else{
                NSRange range = [content rangeOfString:@"error"];
                if (range.location!=NSNotFound){
                    [[NSNotificationCenter defaultCenter] postNotificationName:msgListTable object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",@"查询失败",@"Message", nil]];
                }
            }
        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:msgListTable object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",@"查询失败",@"Message", nil]];
        }
        
    }
    
    
    return mut;
}

- (NSDictionary *)pStart:(NSDictionary *)info{
    //"+start<pdaid:%s;user:%s;table:%s;peoplenum:%s;waiter:%s;acct:%s;>\r\n")},//3.开台start
    NSString *pdaid,*user,*table,*peoplenum,*waiter,*acct,*pwd;
//    NSString *cmd;

    pdaid = [NSString stringWithFormat:@"%@-%d",[self padID],[[[self currentPageConfig] objectForKey:@"number"] intValue]];
    user = [info objectForKey:@"user"];
    pwd = [info objectForKey:@"pwd"];
    if (pwd)
        user = [NSString stringWithFormat:@"%@-%@",user,pwd];
    table = [info objectForKey:@"table"];
    peoplenum = [info objectForKey:@"people"];
    waiter = [info objectForKey:@"waiter"];
    if (!waiter)
        waiter = user;
    if (!peoplenum)
        peoplenum = @"0";
    acct = @"1";
    

    
    NSString *strParam = [NSString stringWithFormat:@"?PdaID=%@&User=%@&Acct=%@&TblInit=%@&Pax=%@&Waiter=%@",pdaid,user,acct,table,peoplenum,waiter];
    NSDictionary *dict = [self bsService:@"pStart" arg:strParam];
    if (dict) {
        NSString *result = [[[dict objectForKey:@"Root"] objectForKey:@"OStr"] objectForKey:@"text"];
        NSArray *ary = [result componentsSeparatedByString:@"<"];
        NSString *content = [[[ary objectAtIndex:1] componentsSeparatedByString:@">"] objectAtIndex:0];
        NSArray *aryContent = [content componentsSeparatedByString:@":"];
        NSRange range = [content rangeOfString:@"error"];
        if (range.location!=NSNotFound){
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[aryContent objectAtIndex:1],@"Message", nil];
        }
        else
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",[aryContent objectAtIndex:1],@"Message", nil];
    }
    return nil;
  //   点击确定后后跳出一个窗口，输入人数和服务员号，以及工号密码，服务员号和人数可不输，人数不输为0，服务员好为空。
     
}

- (NSDictionary *)pOver:(NSDictionary *)info{
    //+over<pdaid:%s;user:%s;table:%s;>\r\n")},4.取消开台
    NSString *pdaid,*user,*table,*pwd;
    
    pdaid = [NSString stringWithFormat:@"%@-%d",[self padID],[[[self currentPageConfig] objectForKey:@"number"] intValue]];
    user = [info objectForKey:@"user"];
    pwd = [info objectForKey:@"pwd"];
    if (pwd)
        user = [NSString stringWithFormat:@"%@-%@",user,pwd];
    
    table = [info objectForKey:@"table"];
    
    NSString *strParam = [NSString stringWithFormat:@"?PdaID=%@&User=%@&TblInit=%@",pdaid,user,table];
    NSDictionary *dict = [self bsService:@"pOver" arg:strParam];
    if (dict) {
        NSString *result = [[[dict objectForKey:@"Root"] objectForKey:@"OStr"] objectForKey:@"text"];
        NSArray *ary = [result componentsSeparatedByString:@"<"];
        NSString *content = [[[ary objectAtIndex:1] componentsSeparatedByString:@">"] objectAtIndex:0];
        NSArray *aryContent = [content componentsSeparatedByString:@":"];
        NSRange range = [content rangeOfString:@"error"];
        if (range.location!=NSNotFound){
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[aryContent lastObject],@"Message", nil];
        }
        else
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",[aryContent lastObject],@"Message", nil];
    }
    return nil;
}

- (NSDictionary *)pChangeTable:(NSDictionary *)info{
    //+changetable<pdaid:%s;user:%s;oldtable:%s;newtable:%s;>\r\n")},//6.换台changetable
    //+changetable<pdaid:%s;user:%s;oldtable:%s;newtable:%s;>\r\n
    NSString *pdaid,*user,*oldtable,*newtable,*pwd;

    
    pdaid = [NSString stringWithFormat:@"%@-%d",[self padID],[[[self currentPageConfig] objectForKey:@"number"] intValue]];
    user = [info objectForKey:@"user"];
    pwd = [info objectForKey:@"pwd"];
    if (pwd)
        user = [NSString stringWithFormat:@"%@-%@",user,pwd];
    oldtable = [info objectForKey:@"oldtable"];
    newtable = [info objectForKey:@"newtable"];

    NSString *strParam = [NSString stringWithFormat:@"?PdaID=%@&User=%@&TblInit=%@-%@&dTblInit=&Typ=",pdaid,user,oldtable,newtable];
    NSDictionary *dict = [self bsService:@"pSignTeb" arg:strParam];
    if (dict) {
        NSString *result = [[[dict objectForKey:@"Root"] objectForKey:@"OStr"] objectForKey:@"text"];
        if ([result rangeOfString:@"ok"].location==NSNotFound){
            NSString *msg = [[[[result componentsSeparatedByString:@"error:"] objectAtIndex:1] componentsSeparatedByString:@">"] objectAtIndex:0];
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",msg,@"Message",nil];
        }
        else
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",nil];
    }
    return nil;
}

- (NSDictionary *)pPrintQuery:(NSDictionary *)info{
    //+printquery<pdaid:%s;user:%s;tab:%s;type:%s;>\r\n"
    NSString *pdaid,*user,*tab,*type,*pwd;

    
    pdaid = [NSString stringWithFormat:@"%@-%d",[self padID],[[[self currentPageConfig] objectForKey:@"number"] intValue]];
    user = [info objectForKey:@"user"];
    pwd = [info objectForKey:@"pwd"];
    if (pwd)
        user = [NSString stringWithFormat:@"%@-%@",user,pwd];
    tab = [info objectForKey:@"tab"];
    type = [info objectForKey:@"type"];

    
    NSString *strParam = [NSString stringWithFormat:@"?PdaID=%@&User=%@&Acct=%@&Typ=%@",pdaid,user,tab,type];
    
    NSDictionary *dict = [self bsService:@"pPrintQuery" arg:strParam];
    if (dict) {
       NSString *result = [[[dict objectForKey:@"Root"] objectForKey:@"OStr"] objectForKey:@"text"];
        NSArray *ary = [result componentsSeparatedByString:@"<"];
        NSString *content = [[[ary objectAtIndex:1] componentsSeparatedByString:@">"] objectAtIndex:0];
        NSArray *aryContent = [content componentsSeparatedByString:@":"];
        NSRange range = [content rangeOfString:@"error"];
        if (range.location!=NSNotFound){
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[aryContent objectAtIndex:2],@"Message", nil];
        }
        else
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",[aryContent objectAtIndex:2],@"Message", nil];
    }    
    return nil;
}

- (NSDictionary *)pListSubscribeOfTable:(NSDictionary *)info{
    NSString *pdaid,*user,*table;
    
    pdaid = [NSString stringWithFormat:@"%@-%d",[self padID],[[[self currentPageConfig] objectForKey:@"number"] intValue]];
    user = [info objectForKey:@"user"];
    table = [info objectForKey:@"table"];
    
    NSString *strParam = [NSString stringWithFormat:@"?PdaID=%@&User=%@&TblInit=%@",pdaid,user,table];
    
    NSDictionary *dict = [self bsService:@"pListSubscribeOfTable" arg:strParam];
    
    if (dict) {
        NSString *result = [[[dict objectForKey:@"Root"] objectForKey:@"OStr"] objectForKey:@"text"];
        result = [result stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSArray *ary = [result componentsSeparatedByString:@"<"];
        NSString *content = [[[ary objectAtIndex:1] componentsSeparatedByString:@">"] objectAtIndex:0];
        NSArray *aryContent = [content componentsSeparatedByString:@"^"];
        
        
        NSMutableDictionary *mut = [NSMutableDictionary dictionary];
        for (NSString *subcontent in aryContent){
            NSArray *arysub = [subcontent componentsSeparatedByString:@":"];
            NSString *key = [arysub objectAtIndex:0];
            
            NSMutableString *strsub = [NSMutableString string];
            for (int i=1;i<[arysub count];i++){
                [strsub appendString:[arysub objectAtIndex:i]];
                if (i!=[arysub count]-1)
                    [strsub appendString:@":"];
            }
            NSString *value = [strsub length]>0?strsub:nil;
            
            if (value)
                [mut setObject:value forKey:key];
        }
        
        NSArray *arary = [result componentsSeparatedByString:@"account:"];
        NSMutableString *mutstr = [NSMutableString string];
        if ([arary count]>1){
            NSString *account = [arary objectAtIndex:1];
            NSArray *foodsary = [account componentsSeparatedByString:@"^"];
            int foodcount = [foodsary count]/8;
            for (int j=0;j<foodcount;j++){
                [mutstr appendString:@"\n"];
                for (int k=0;k<8;k++){
                    [mutstr appendFormat:@"%@ ",[foodsary objectAtIndex:8*j+k]];
                }
            }
        }
        if ([mutstr length]>0){
            [mut setObject:mutstr forKey:@"account"];
        }
        
        dict = [NSDictionary dictionaryWithDictionary:mut];
    } 

    
    return dict;
}

- (NSArray *)pListResv:(NSDictionary *)info{
    NSString *pdaid,*user;
    
    pdaid = [NSString stringWithFormat:@"%@-%d",[self padID],[[[self currentPageConfig] objectForKey:@"number"] intValue]];
    user = [info objectForKey:@"user"];
    
    NSString *strParam = [NSString stringWithFormat:@"?PdaID=%@&User=%@",pdaid,user];
    
    NSDictionary *dict = [self bsService:@"pListResv" arg:strParam];
    
    NSMutableArray *mut = [NSMutableArray array];
    
    if (dict) {
        NSString *result = [[[dict objectForKey:@"Root"] objectForKey:@"OStr"] objectForKey:@"text"];
        NSArray *ary = [result componentsSeparatedByString:@"<"];
        NSString *content = [[[ary objectAtIndex:1] componentsSeparatedByString:@">"] objectAtIndex:0];
        content = [content stringByReplacingOccurrencesOfString:@"acct:" withString:@""];
        NSArray *aryContent = [content componentsSeparatedByString:@"|"];
        
        
        
        for (NSString *subcontent in aryContent){
            NSArray *arysub = [subcontent componentsSeparatedByString:@"^"];
            
            
            if ([arysub count]>7){
                
                NSMutableDictionary *mutdict = [NSMutableDictionary dictionary];
                [mutdict setObject:[arysub objectAtIndex:0] forKey:@"acct"];
                for (int i=1;i<8;i++){
                    NSArray *kv = [[arysub objectAtIndex:i] componentsSeparatedByString:@":"];
                    NSString *key = [kv objectAtIndex:0];
                    NSMutableString *strsub = [NSMutableString string];
                    for (int i=1;i<[kv count];i++){
                        [strsub appendString:[kv objectAtIndex:i]];
                        if (i!=[kv count]-1)
                            [strsub appendString:@":"];
                    }
                    NSString *value = [strsub length]>0?strsub:nil;
                    
                    if (value)
                        [mutdict setObject:value forKey:key];
                }
                
                [mut addObject:mutdict];
            }
        }
        
        dict = [NSDictionary dictionaryWithObjectsAndKeys:mut,@"Result", nil];
    } 
    
    return [mut count]>0?mut:nil;
}

- (NSDictionary *)pLoginUser:(NSDictionary *)info{
    NSString *user,*pwd;
    
    user = [info objectForKey:@"user"];
    pwd = [info objectForKey:@"pwd"];
    
    
    NSString *strParam = [NSString stringWithFormat:@"?User=%@&Pass=%@",user,pwd];
    
    NSDictionary *dict = [self bsService:@"pLoginUser" arg:strParam];
    
    if (dict) {
        NSString *result = [[[dict objectForKey:@"Root"] objectForKey:@"OStr"] objectForKey:@"text"];
        NSArray *ary = [result componentsSeparatedByString:@"<"];
        NSString *content = [[[ary objectAtIndex:1] componentsSeparatedByString:@">"] objectAtIndex:0];
        NSRange range = [content rangeOfString:@"ok"];
        result = [[content componentsSeparatedByString:@":"] objectAtIndex:1];
        if (range.location!=NSNotFound){
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",result,@"Message", nil];
        }
        else
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",result,@"Message", nil];
    }
    
    return dict;
}




#pragma mark -
#pragma mark Process Received Data
- (void)getQueryResult:(NSString *)result{
    if ([result length]>0){
        NSArray *ary = [result componentsSeparatedByString:@"<"];
        if ([ary count]>1){
            //+sendtab
            NSString *cmd = [ary objectAtIndex:0];
            if ([cmd isEqualToString:@"+sendtab"]){
                NSString *content = [[[ary objectAtIndex:1] componentsSeparatedByString:@">"] objectAtIndex:0];
                
                NSMutableDictionary *mut = [NSMutableDictionary dictionary];
                NSRange range = [content rangeOfString:@"ok"];
                if (range.location!=NSNotFound){
                    [mut setObject:[NSNumber numberWithBool:YES] forKey:@"Result"];
                    [mut setObject:[[content componentsSeparatedByString:@"msg:"] objectAtIndex:1] forKey:@"Message"];
                    [mut setObject:[[[[content componentsSeparatedByString:@"msg:"] objectAtIndex:0] componentsSeparatedByString:@":"] objectAtIndex:1] forKey:@"tab"];
                    
                    NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *docPath = [docPaths objectAtIndex:0];
                    [[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:dSendCount] forKey:@"count"] 
                     writeToFile:[docPath stringByAppendingPathComponent:kOrdersCountFileName] atomically:NO];
                }
                else{
                    [mut setObject:[NSNumber numberWithBool:NO] forKey:@"Result"];
                    [mut setObject:[[content componentsSeparatedByString:@"error:"] objectAtIndex:1] forKey:@"Message"];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:msgSendTab object:nil userInfo:mut];
            }
            else if ([cmd isEqualToString:@"+printquery"]){
                //Recived Data:+printquery<error:台号错误或已结帐或未定义查询单打印机!>
                NSString *content = [[[ary objectAtIndex:1] componentsSeparatedByString:@">"] objectAtIndex:0];
                NSArray *aryContent = [content componentsSeparatedByString:@":"];
                NSRange range = [content rangeOfString:@"error"];
                if (range.location!=NSNotFound){
                    [[NSNotificationCenter defaultCenter] postNotificationName:msgPrint 
                                                                        object:nil 
                                                                      userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[aryContent objectAtIndex:1],@"Message", nil]];
                }
                else{
                    int dCocount = [aryContent count];
                    if (dCocount>1)
                        [[NSNotificationCenter defaultCenter] postNotificationName:msgPrint object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",[aryContent objectAtIndex:1],@"Message", nil]];
                    else
                        [[NSNotificationCenter defaultCenter] postNotificationName:msgPrint object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",nil]];
                }
            }
            
        }
    }
}





- (UIImage *)backgroundImage{
    if (!imgBG){
        NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docPath = [docPaths objectAtIndex:0];
        NSString *path = [docPath stringByAppendingPathComponent:kBGFileName];
        NSString *imgpath = nil;
        
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
    
        if (!dic){
            NSArray *ary = [self getAllBG];
            if (ary>0)
                dic = [ary objectAtIndex:0];
            else
                dic = [NSDictionary dictionaryWithObject:@"defaultbg.jpg" forKey:@"name"];
            [dic writeToFile:path atomically:NO];
        }
        
        imgpath = [docPath stringByAppendingPathComponent:[dic objectForKey:@"name"]];
        
        imgBG = [[UIImage alloc] initWithContentsOfFile:imgpath];
    }
    
    
    return imgBG;
    
}

- (void)setBackgroundImage:(NSDictionary *)info{
    NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [docPaths objectAtIndex:0];
    NSString *path = [docPath stringByAppendingPathComponent:kBGFileName];
    [info writeToFile:path atomically:NO];
    
    [imgBG release];
    imgBG = nil;
}

- (NSArray *)getAllBG{
    NSMutableArray *ary = [NSMutableArray array];
    
    NSString *path = [BSDataProvider sqlitePath];
    sqlite3 *db;
    sqlite3_stmt *stat;
    NSString *sqlcmd;
    
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
        sqlcmd = @"select * from background";
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                int count = sqlite3_column_count(stat);
                NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
                for (int i=0;i<count;i++){
                    char *foodKey = (char *)sqlite3_column_name(stat, i);
                    char *foodValue = (char *)sqlite3_column_text(stat, i);
                    NSString *strKey = nil,*strValue = nil;
                    
                    if (foodKey)
                        strKey = [NSString stringWithUTF8String:foodKey];
                    if (foodValue)
                        strValue = [NSString stringWithUTF8String:foodValue];
                    if (strKey && strValue)
                        [mutDC setObject:strValue forKey:strKey];
                }
                [ary addObject:mutDC];
            }
        }
        sqlite3_finalize(stat);
    }
    sqlite3_close(db);
    
    return ary;
}

- (NSDictionary *)bsService:(NSString *)api arg:(NSString *)arg{
    BSWebServiceAgent *agent = [[BSWebServiceAgent alloc] init];
    NSDictionary *dict = [agent GetData:api arg:arg];
    [agent release];
    return dict;
}

- (NSString *)bsService_string:(NSString *)api arg:(NSString *)arg{
    BSWebServiceAgent *agent = [[BSWebServiceAgent alloc] init];
    [agent GetData:api arg:arg];
    NSString *str = agent.strData;

    [agent release];
    
    str = [str stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    str = [str stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    
    return str;
}
//List Table
- (NSArray *)getArea{
    NSMutableArray *ary = [NSMutableArray array];
    
    NSString *path = [BSDataProvider sqlitePath];
    sqlite3 *db;
    sqlite3_stmt *stat;
    NSString *sqlcmd;
    
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
        sqlcmd = @"select * from codedesc where code = 'AR'";
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                int count = sqlite3_column_count(stat);
                NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
                for (int i=0;i<count;i++){
                    char *foodKey = (char *)sqlite3_column_name(stat, i);
                    char *foodValue = (char *)sqlite3_column_text(stat, i);
                    NSString *strKey = nil,*strValue = nil;
                    
                    if (foodKey)
                        strKey = [NSString stringWithUTF8String:foodKey];
                    if (foodValue)
                        strValue = [NSString stringWithUTF8String:foodValue];
                    if (strKey && strValue)
                        [mutDC setObject:strValue forKey:strKey];
                }
                [ary addObject:mutDC];
            }
        }
        sqlite3_finalize(stat);
    }
    sqlite3_close(db);
    
    return ary;
}

- (NSArray *)getFloor{
    NSMutableArray *ary = [NSMutableArray array];
    
    NSString *path = [BSDataProvider sqlitePath];
    sqlite3 *db;
    sqlite3_stmt *stat;
    NSString *sqlcmd;
    
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
        sqlcmd = @"select * from codedesc where code = 'LC'";
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                int count = sqlite3_column_count(stat);
                NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
                for (int i=0;i<count;i++){
                    char *foodKey = (char *)sqlite3_column_name(stat, i);
                    char *foodValue = (char *)sqlite3_column_text(stat, i);
                    NSString *strKey = nil,*strValue = nil;
                    
                    if (foodKey)
                        strKey = [NSString stringWithUTF8String:foodKey];
                    if (foodValue)
                        strValue = [NSString stringWithUTF8String:foodValue];
                    if (strKey && strValue)
                        [mutDC setObject:strValue forKey:strKey];
                }
                [ary addObject:mutDC];
            }
        }
        sqlite3_finalize(stat);
    }
    sqlite3_close(db);
    
    return ary;
}

- (NSArray *)getStatus{
CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
    
    NSString *langCode = [langSetting localizedString:@"LangCode"];
    
    if ([langCode isEqualToString:@"en"])
        return [NSArray arrayWithObjects:@"Idle",@"Ordered",@"No order",nil];
    else if ([langCode isEqualToString:@"cn"])
        return [NSArray arrayWithObjects:@"空闲",@"开台点菜",@"开台未点",nil];
    else
        return [NSArray arrayWithObjects:@"空閒",@"開台點菜",@"開台未點",nil];

}

- (BOOL)pCommentFood:(NSDictionary *)info{
    NSString *itcode = [info objectForKey:@"itcode"];
    NSString *level = [info objectForKey:@"level"];
    NSString *comment = [info objectForKey:@"comment"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"comments.plist"];
    
    NSMutableDictionary *mut = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    if (!mut)
        mut = [NSMutableDictionary dictionary];
    
    NSArray *ary = [mut objectForKey:itcode];
    NSMutableArray *mutary = [NSMutableArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:itcode,@"itcode",level,@"level",comment,@"comment", nil]];
    [mutary addObjectsFromArray:ary];
    
    [mut setObject:mutary forKey:itcode];
    
    [mut writeToFile:path atomically:NO];
    
    return YES;
    

    /*
    NSString *param = [NSString stringWithFormat:@"?itcode=%@&level=%@&comment=%@",itcode,level,comment];
    
    NSDictionary *dict = [self bsService:@"pCommentFood" arg:param];
    
    NSString *OStr = [[[dict objectForKey:@"Root"] objectForKey:@"OStr"] objectForKey:@"text"];
    
    NSRange range = [OStr rangeOfString:@"提交成功"];
    
    return (range.location!=NSNotFound);
     */
}

- (NSArray *)pGetFoodComment:(NSDictionary *)info{
    NSString *itcode = [info objectForKey:@"itcode"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"comments.plist"];
    
    NSMutableDictionary *mut = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    
    
    return [mut objectForKey:itcode];
    
    /*
    NSString *itcode = [info objectForKey:@"itcode"];;
    
    
    NSString *param = [NSString stringWithFormat:@"?itcode=%@",itcode];
    
    NSDictionary *dict = [self bsService:@"pGetFoodComment" arg:param];
    
    NSArray *ary = [[[[dict objectForKey:@"DataTable"] objectForKey:@"diffgr:diffgram"] objectForKey:@"NewDataSet"] objectForKey:@"ds"];
    if ([ary isKindOfClass:[NSDictionary class]])
        ary = [NSArray arrayWithObject:ary];
    
    NSMutableArray *mut = [NSMutableArray array];
    
    for (int i=0;i<[ary count];i++){
        NSMutableDictionary *mutdict = [NSMutableDictionary dictionary];
        
        NSDictionary *dictcomment = [ary objectAtIndex:i];
        NSString *strcomment = [[dictcomment objectForKey:@"comment"] objectForKey:@"text"];
        const char *cstr = [strcomment cStringUsingEncoding:NSUTF8StringEncoding];
        
        BOOL bchar = NO;
        
        NSMutableString *mutstr = [NSMutableString string];
        for (int j=0;j<strlen(cstr);j++){
            if (cstr[j]!='\n' && cstr[j]!=' ')
                bchar = YES;
            
            if (bchar)
                [mutstr appendFormat:@"%c",cstr[j]];
            
        }
        
        if ([mutstr length]>0)
            [mutdict setObject:mutstr forKey:@"comment"];
        
        NSString *level = [[dictcomment objectForKey:@"lv"] objectForKey:@"text"];
        for (int k=1;k<=5;k++){
            if ([level rangeOfString:[NSString stringWithFormat:@"%d",k]].location!=NSNotFound){
                level = [NSString stringWithFormat:@"%d",k];
                break;
            }
        }
        if ([level intValue]!=0)
            [mutdict setObject:level forKey:@"level"];
        
        if ([mutdict count]>0)
            [mut addObject:mutdict];
    }
    
    return [mut count]>0?[NSArray arrayWithArray:mut]:nil;
     
     */
}

- (NSString *)pGetFoodVideo:(NSDictionary *)info{
    NSString *itcode = [info objectForKey:@"itcode"];;
    return @"http://www.5stan.com/test.mov";
    NSString *param = [NSString stringWithFormat:@"?itcode=%@",itcode];
    
    NSDictionary *dict = [self bsService:@"pGetFoodVideo" arg:param];
    
    NSString *path = [[[dict objectForKey:@"video"] objectForKey:@"Videopath"] objectForKey:@"text"];
    [path stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    [path stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    
    return [path length]>0?path:nil;
}


#pragma mark - Template Functions
- (NSArray *)pageConfigList{
    return aryPageConfigList;
}

- (NSDictionary *)currentPageConfig{
    return dicCurrentPageConfig;
}

- (NSDictionary *)currentPageConfigDetail{
    return dicCurrentPageConfigDetail;
}

- (NSArray *)pageList{
    NSArray *ary = [[self currentPageConfigDetail] objectForKey:@"PageList"];
    
    return ary;
}

- (NSDictionary *)resourceConfig{
    NSDictionary *dict = [[self currentPageConfigDetail] objectForKey:@"ResourceConfig"];
    
    return dict;
}

- (NSDictionary *)foodDetailConfig{
    return [[self currentPageConfigDetail] objectForKey:@"FoodDetail"];
}

- (NSDictionary *)buttonConfig{
    NSDictionary *dict = [[self currentPageConfigDetail] objectForKey:@"ButtonConfig"];
    
    return dict;
}

- (NSArray *)menuItemList{
    NSArray *ary = [[self currentPageConfigDetail] objectForKey:@"MenuItemList"];
    
    return ary;
}

- (NSUInteger)totalPages{
    NSArray *ary = [self pageList];
    
    int total = 0;
    for (NSDictionary *info in ary){
        if ([[info objectForKey:@"type"] isEqualToString:@"类别"]){
            NSArray *foods = [self foodListForClass:[info objectForKey:@"classid"]];
            int page = (int)([foods count]/9)+[foods count]%9==0?0:1;
            total += page;
        }   
        else
            total++;
    }
    
    return total;
}

- (NSArray *)foodListForClass:(NSString *)classid{
    return  [self getFoodList:[NSString stringWithFormat:@"GRPTYP = %@",classid]];
}

- (void)updateRecommendList{
    @autoreleasepool {        
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[@"setting.plist" documentPath]];
        
        NSString *str = [dict objectForKey:@"url"];
        if ([str length]==0)
            str = kPathHeader;
        str = [str stringByAppendingPathComponent:@"RecommendFoods.txt"];
        
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
        
        NSMutableArray *mut = [NSMutableArray array];
        
        
        
        if (serviceData){
            NSString *recommend = [NSString stringWithCString:[serviceData bytes] encoding:NSUTF8StringEncoding];
            
           
            NSString *current = [[NSUserDefaults standardUserDefaults] objectForKey:@"RecommendTxt"];
            
            if (![current isEqualToString:recommend]){
                if (recommend)
                    [[NSUserDefaults standardUserDefaults] setObject:recommend forKey:@"RecommendTxt"];
                else
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"RecommendTxt"];
                NSArray *ary = [recommend componentsSeparatedByString:@","];
                
                for (int i=0;i<ary.count;i++){
                    NSString *foodid = nil;
                    NSString *background = nil;
                    
                    NSArray *items = [[ary objectAtIndex:i] componentsSeparatedByString:@"#"];
                    
                    
                    if (1==items.count)
                        foodid = [items objectAtIndex:0];
                    else if (2==items.count){
                        foodid = [items objectAtIndex:0];
                        background = [items objectAtIndex:1];
                    }
                    
                    if (foodid){
                        NSDictionary *recommendDetail = [[self currentPageConfigDetail] objectForKey:@"RecommendDetail"];
                        
                        if (!recommendDetail){
                            for (NSDictionary *page in [[self currentPageConfigDetail] objectForKey:@"PageList"]){
                                if ([[page objectForKey:@"type"] isEqualToString:@"推荐菜"]){
                                    recommendDetail = [page objectForKey:@"frame"];
                                    break;
                                }
                            }
                        }
                        
                        if (!background)
                            background = [NSString stringWithFormat:@"%@R.png",foodid];
                        
                        if (recommendDetail){
                            NSMutableDictionary *mutdict = [NSMutableDictionary dictionary];
                            [mutdict setObject:recommendDetail forKey:@"frame"];
                            [mutdict setObject:foodid forKey:@"foodid"];
                            [mutdict setObject:background forKey:@"background"];
                            [mutdict setObject:@"推荐菜" forKey:@"type"];
                            [mutdict setObject:[NSNumber numberWithBool:NO] forKey:@"hideButton"];
                            [mut addObject:mutdict];
                        }
                        
                    }
                }
                
                if (mut.count>0)
                    [[NSUserDefaults standardUserDefaults] setObject:mut forKey:@"RecommendList"];
                else
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"RecommendList"];
                
                
                NSLog(@"Update Recommend List Finished:%d",mut.count);
                [[NSNotificationCenter defaultCenter] postNotificationName:@"PageConfigChanged" object:nil];
            }
        }
    }
}


- (NSArray *)topPages{
    //封面 广告 推荐菜 类别列表
//    NSArray *allpages = [self pageConfigList];
//    NSMutableArray *mut = [NSMutableArray array];
//    
//    for (int i=0;i<allpages.count;i++){
//        NSDictionary *dict = [allpages objectAtIndex:i];
//        if ([[dict objectForKey:@"type"] isEqualToString:@"类别"]){
//            
//        }
//    }
    NSMutableArray *mut = [NSMutableArray array];
    
    NSMutableDictionary *mutdict = [NSMutableDictionary dictionary];
    if ([self getCovers].count>0){
        [mutdict setObject:[NSMutableArray array] forKey:@"images"];
        for (NSDictionary *didi in [self getCovers])
            [[mutdict objectForKey:@"images"] addObject:[didi objectForKey:@"cover"]];
    }
        
    [mutdict setObject:@"封面" forKey:@"type"];
    [mut addObject:mutdict];
    
    NSArray *ary = [self getClassList];
    

    for (int i=0;i<[ary count];i++){
        if (i%9==0){
            mutdict = [NSMutableDictionary dictionaryWithObject:@"类别列表" forKey:@"type"];
            [mutdict setObject:[NSMutableArray array] forKey:@"categories"];
            [mut addObject:mutdict];
        }
            
        [[mutdict objectForKey:@"categories"] addObject:[ary objectAtIndex:i]];
    }
    
    return [NSArray arrayWithArray:mut];
    
}

- (NSArray *)allPages{
    return aryAllPages;
}

- (NSArray *)allDetailPages{
    return aryAllDetailPages;
}

- (NSDictionary *)pageInfoAtIndex:(NSUInteger)index{
    NSArray *ary = [self allPages];
    
    return index<[ary count]?[ary objectAtIndex:index]:nil; 
}
//  套餐相关
- (NSArray *)getFoodListOfPackage:(NSString *)packageid{
    NSString *cmd = [NSString stringWithFormat:@"select * from PACKDTL where PACKID = %@",packageid];
    
    return [BSDataProvider getDataFromSQLByCommand:cmd];
}

- (NSDictionary *)getFoodByCode:(NSString *)itcode{
    NSString *cmd = [NSString stringWithFormat:@"select * from food where ITCODE = %@",itcode];
    
    return [BSDataProvider getDataFromSQLByCommand:cmd];
}

- (NSDictionary *)getPackageDetail:(NSString *)packageid{
    NSArray *foods = [self getFoodListOfPackage:packageid];
    NSMutableDictionary *mut = [NSMutableDictionary dictionary];
    if (foods)
        [mut setObject:foods forKey:@"foods"];
    NSString *cmd = [NSString stringWithFormat:@"select * from PACKAGE where PACKID = %@",packageid];
    
    NSDictionary *dict = [BSDataProvider getDataFromSQLByCommand:cmd];
    
    if (dict)
        [mut setValuesForKeysWithDictionary:dict];
    
    return [mut count]>0?[NSDictionary dictionaryWithDictionary:mut]:nil;
    
}

- (NSArray *)getShiftFood:(NSString *)foodid ofPackage:(NSString *)packageid{
    NSString *cmd = [NSString stringWithFormat:@"select * from ITEMPKG where PACKID = %@ and ITEM = %@",packageid,foodid];
    NSArray *ary = [BSDataProvider getDataFromSQLByCommand:cmd];
    if (![ary isKindOfClass:[NSArray class]])
        return [NSArray arrayWithObject:ary];
    else
        return ary;
}

// SQLite相关
+ (NSString *)sqlitePath{
    NSDictionary *dict = dicCurrentPageConfig;
    NSString *sqlite = [dict objectForKey:@"sqlite"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[sqlite documentPath]])
        return [sqlite documentPath];
    else if ([[NSFileManager defaultManager] fileExistsAtPath:[sqlite bundlePath]])
        return [sqlite bundlePath];
    else
        return [@"BookSystem.sqlite" bundlePath];
}

+ (id)getDataFromSQLByCommand:(NSString *)cmd sqlName:(NSString *)sqlname{
    id ret = nil;
    NSMutableArray *ary = [NSMutableArray array];
    NSString *path = [@"BookSystem.sqlite" bundlePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[sqlname documentPath]])
        path = [sqlname documentPath];
    sqlite3 *db;
    sqlite3_stmt *stat;
    NSString *sqlcmd = cmd;
    
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                int count = sqlite3_column_count(stat);
                NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
                for (int i=0;i<count;i++){
                    char *foodKey = (char *)sqlite3_column_name(stat, i);
                    char *foodValue = (char *)sqlite3_column_text(stat, i);
                    NSString *strKey = nil,*strValue = nil;
                    
                    if (foodKey)
                        strKey = [NSString stringWithUTF8String:foodKey];
                    if (foodValue)
                        strValue = [NSString stringWithUTF8String:foodValue];
                    if (strKey && strValue)
                        [mutDC setObject:strValue forKey:strKey];
                }
                [ary addObject:mutDC];
            }
        }
        sqlite3_finalize(stat);
    }
    sqlite3_close(db);
    
    if ([ary count]==1){
        NSDictionary *dict = [ary objectAtIndex:0];
        if (1==[dict count])
            ret = [dict objectForKey:[[dict allKeys] objectAtIndex:0]];
        else if ([dict count]>1)
            ret = dict;
    }else if ([ary count]>1)
        ret = ary;
    
    
    return ret;
}

+ (id)getDataFromSQLByCommand:(NSString *)cmd{
    id ret = nil;
    NSMutableArray *ary = [NSMutableArray array];
    NSString *path = [self sqlitePath];
    sqlite3 *db;
    sqlite3_stmt *stat;
    NSString *sqlcmd = cmd;
    
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                int count = sqlite3_column_count(stat);
                NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
                for (int i=0;i<count;i++){
                    char *foodKey = (char *)sqlite3_column_name(stat, i);
                    char *foodValue = (char *)sqlite3_column_text(stat, i);
                    NSString *strKey = nil,*strValue = nil;
                    
                    if (foodKey)
                        strKey = [NSString stringWithUTF8String:foodKey];
                    if (foodValue)
                        strValue = [NSString stringWithUTF8String:foodValue];
                    if (strKey && strValue)
                        [mutDC setObject:strValue forKey:strKey];
                }
                [ary addObject:mutDC];
            }
        }
        sqlite3_finalize(stat);
    }
    sqlite3_close(db);
    
    if ([ary count]==1){
        NSDictionary *dict = [ary objectAtIndex:0];
        if (1==[dict count])
            ret = [dict objectForKey:[[dict allKeys] objectAtIndex:0]];
        else if ([dict count]>1)
            ret = dict;
    }else if ([ary count]>1)
        ret = ary;
    
    
    return ret;
}

#pragma mark -  激活
- (BOOL)checkActivated{
    BOOL bActivated = [[NSUserDefaults standardUserDefaults] boolForKey:@"Activated"];

    if (bActivated)
        return YES;
    BOOL bSuceed = NO;

    NSString *strRegNo = [NSString UUIDString];


    NSArray *urls = [NSArray arrayWithObjects:@"61.174.28.122",@"60.12.218.91",nil];
    for (int i=0;i<2;i++){
        NSString *strUrl = [NSString stringWithFormat:@"http://%@:9100/choicereg.asmx/choicereg?uuid=%@",[urls objectAtIndex:i],strRegNo];
        
        NSURL *url = [NSURL URLWithString:strUrl];
        
        NSMutableURLRequest *request = nil;
        NSHTTPURLResponse *response = nil;
        NSError *error = nil;
        NSData *serviceData = nil;
        
        request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:3];
        [request setHTTPMethod:@"GET"];
        
        serviceData = [NSURLConnection sendSynchronousRequest:request
                                            returningResponse:&response
                                                        error:&error];
        
        
        
        if (!error){
            NSString *str = [[NSString stringWithCString:[serviceData bytes]
                                                encoding:NSUTF8StringEncoding] lowercaseString];
            NSRange range = [str rangeOfString:@"true"];
            if (range.location!=NSNotFound && str){
                bSuceed = YES;
                break;
            }
        }
    }
    
    
    
    [[NSUserDefaults standardUserDefaults] setBool:bSuceed forKey:@"Activated"];
    
    return bSuceed;
    
    
    
    
}

- (BOOL)activated{
    return [self checkActivated];
}
@end
