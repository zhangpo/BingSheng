//
//  BookSystemAppDelegate.h
//  BookSystem
//
//  Created by Dream on 11-3-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class BookSystemViewController;

@interface BookSystemAppDelegate : NSObject <UIApplicationDelegate> {
    NSString *strLanguage;
    BookSystemViewController *vcBookSystem;
    UIWindow *window;
}


- (UIWindow *)window;

- (void)copyFiles;
@end
