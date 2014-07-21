//
//  BSDataProvider.h
//  BookSystem
//
//  Created by Dream on 11-3-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "BSWebServiceAgent.h"
#import "CVLocalizationSetting.h"
#import "WhiteRaccoon.h"

#define kPlistPath      @"ftp://shipader:shipader123@61.174.28.122/BookSystem/BookSystem.sqlite"
#define kPathHeader      @"ftp://ipad:ipad@10.211.55.4/BookSystem/"
#define kSocketServer   @"61.174.28.122:8010"
#define kPDAID          @"8"
#define  TCHAR unsigned char

#define msgSendTab      @"NotificationSendTab"
#define msgQuery        @"NotificationQuery"
#define msgGogo         @"NotifcationGogo"
#define msgChuck        @"NotificationChuck"
#define msgListTable    @"NotificationListTable"
#define msgOpenTable    @"NotificationOpenTable"
#define msgCancelTable  @"NotificationCancelTable"
#define msgPrint        @"NotificationPrint"


#define kBGFileName         @"BackgroundImage.plist"
#define kOrdersFileName     @"Orders.plist"
#define kOrdersCountFileName    @"OrdersCount.plist"
#define kFunctionControlFileName @"FunctionControl.plist"
@interface BSDataProvider : NSObject<NSStreamDelegate,WRRequestDelegate>{
    NSMutableData *data;
    
    NSInputStream *iStream;
    NSOutputStream *oStream;
    
    UIImage *imgBG;
}
@property(nonatomic,copy)NSString *userTable;
+ (void)loadConfig;
+ (void)reloadConfig;
+ (void)reloadCurrentPageConfig;

+ (BSDataProvider *)sharedInstance;

+ (NSDictionary *)currentOrder;
+ (void)removeOrderOfName:(NSString *)name;
+ (void)importOrderOfName:(NSString *)name;
+ (NSArray *)cachedFoodList;
+ (BOOL)isCacheNameExist:(NSString *)name;
+ (void)saveFoods:(NSArray *)foods withName:(NSString *)name;
- (NSString *)cachedOrder:(NSDictionary *)order;

+ (id)getDataFromSQLByCommand:(NSString *)cmd;
- (NSArray *)getADNames;
- (NSArray *)getAdditions;
- (void)refreshFiles;
- (NSString *)padID;
- (NSDictionary *)dictFromSQL;
- (void)updateData;
- (NSDictionary *)dataDict;
- (void)getCachedFile;
- (NSMutableArray *)getAllFoods;
- (NSMutableArray *)getFoodList:(NSString *)cmd;
- (NSArray *)getAccounts;
- (NSArray *)getAllBG;
- (NSMutableArray *)getCodeDesc;
- (NSArray *)getCovers;
- (NSArray *)getCaptions;


- (UIImage *)backgroundImage;
- (void)setBackgroundImage:(NSDictionary *)info;


- (void)orderFood:(NSDictionary *)info;
- (NSMutableArray *)orderedFood;
- (void)saveOrders;


- (void)writeToServer:(const uint8_t *)buf;
+ (void)importHistoryOfName:(NSString *)name;
+(NSArray *)historyFoodList;//查询历史账单
- (void)historyFoods:(NSArray *)foods withName:(NSString *)name;
- (void)getQueryResult:(NSString *)result;

- (NSString *)pSendTab:(NSArray *)ary options:(NSDictionary *)info;
- (NSDictionary *)pListTable:(NSDictionary *)info;
- (NSDictionary *)pQuery:(NSDictionary *)info;
- (NSDictionary *)pGogo:(NSDictionary *)info;
-(NSDictionary *)pChangMan:(NSDictionary *)info;
- (NSDictionary *)pChuck:(NSDictionary *)info;
- (NSDictionary *)pStart:(NSDictionary *)info;
- (NSDictionary *)pChangeTable:(NSDictionary *)info;
- (NSDictionary *)pOver:(NSDictionary *)info;
- (NSDictionary *)pPrintQuery:(NSDictionary *)info;
- (BOOL)pCommentFood:(NSDictionary *)info;
- (NSArray *)pGetFoodComment:(NSDictionary *)info;
- (NSString *)pGetFoodVideo:(NSDictionary *)info;
- (NSDictionary *)pListSubscribeOfTable:(NSDictionary *)info;
- (NSArray *)pListResv:(NSDictionary *)info;
- (NSDictionary *)pLoginUser:(NSDictionary *)info;
- (NSDictionary *)checkFoodAvailable:(NSArray *)ary info:(NSDictionary *)info;


//List Table
- (NSArray *)getArea;
- (NSArray *)getFloor;
- (NSArray *)getStatus;

- (NSDictionary *)bsService:(NSString *)api arg:(NSString *)arg;
- (NSString *)bsService_string:(NSString *)api arg:(NSString *)arg;


#pragma mark -  Template Functions
- (NSArray *)pageList;
- (NSDictionary *)resourceConfig;
- (NSDictionary *)buttonConfig;
- (NSDictionary *)foodDetailConfig;
- (NSArray *)menuItemList;
- (NSUInteger)totalPages;
- (NSArray *)foodListForClass:(NSString *)classid;
- (NSDictionary *)pageInfoAtIndex:(NSUInteger)index;
- (NSArray *)allPages;
- (NSArray *)allDetailPages;
- (NSMutableArray *)getClassList;
- (NSDictionary *)getClassByID:(NSString *)classid;
- (NSDictionary *)getFoodByCode:(NSString *)itcode;
- (NSArray *)pageConfigList;
- (NSDictionary *)currentPageConfig;
- (void)updateRecommendList;
//  套餐相关
//- (NSDictionary *)getPackageByID:(NSString *)packageid;
- (NSDictionary *)getPackageDetail:(NSString *)packageid;
- (NSArray *)getShiftFood:(NSString *)foodid ofPackage:(NSString *)packageid;

#pragma mark - New Demo
- (NSArray *)topPages;
#pragma mark - 激活
- (BOOL)activated;
@end


/*
 
 char* scCommandWord[22]=
 { 
 {("+login<user:%s;password:%s;>\r\n")}, //0.登陆login
 {("+logout<user:%s;>\r\n")},//1.退出登陆logout
 {("+listtable<user:%s;pdanum:%s;floor:%s;area:%s;status:%s;>\r\n")},// 2.查询桌位list table  
 {("+start<pdaid:%s;user:%s;table:%s;peoplenum:%s;waiter:%s;acct:%s;>\r\n")},//3.开台start
 {("+over<pdaid:%s;user:%s;table:%s;>\r\n")},//4.取消开台
 {("+sendtab<pdaid:%s;user:%s;tabid:%d;acct:%s;tb:%s;usr:%s;pn:%s;foodnum:%d;type:%s;tablist:%s;>\r\n")},//5.发送菜单
 {("+changetable<pdaid:%s;user:%s;oldtable:%s;newtable:%s;>\r\n")},//6.换台changetable
 {("+signteb<pdaid:%s;user:%s;tabto:%s;intotab:%s;type:%s;>\r\n")},//7.标记并单
 {("+query<pdaid:%s;user:%s;table:%s;>\r\n")},//8.查询
 {("+gogo<pdaid:%s;user:%s;tab:%s;foodnum:%s;>\r\n")},//9.催菜
 {("+rebate<pdaid:%s;user:%s;id:%s;pwd:%s;tab:%s;rebatetype:%s;foodnum:%s;pic:%s;ispic:%d;>\r\n")},//10.打折//fwang modif
 {("+printquery<pdaid:%s;user:%s;tab:%s;type:%s;>\r\n")},//11.打印
 {("+printtab<pdaid:%s;user:%s;tab:%s;>\r\n")},//12.打印
 {("+chuck<pdaid:%s;user:%s;id:%s;pwd:%s;tab:%s;result:%s;foodnum:%s;>\r\n")}, //13.退菜
 {("+listsubscribetab<pdaid:%s;user:%s;table:%s;>\r\n")}, //14.显示预订单
 {("+entersubscribetab<pdaid:%s;user:%s;tab:%s;num:%s;>\r\n")},  //15.预定单转成正式单
 {("+updata<pdaid:%s;user:%s;updatatype:%s;cls:%s;>\r\n") },//16.更新//fwang modif
 {("+modifyfoodnum<pdaid:%s;user:%s;foodid:%s;newnum:%.2f;oldnum:%.2f;>\r\n") },//17.更改数量
 {("+gototab<pdaid:%s;user:%s;tab:%s;foodnum:%s;>\r\n") },//18.转单  
 {("+set_branch<pdaid:%s;branch:%s;>\r\n") },//19.set branch  
 {("+customer<pdaid:%s;user:%s;tab:%s;data:%s;>\r\n") },//20.customer
 {("+card<pdaid:%s;user:%s;id:%s;pwd:%s;tab:%s;do:%s;vip:%s;vpwd:%s;money:%s;type:%s;>\r\n") }//21.card
 };
 
 */
