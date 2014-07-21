//
//  BSCategoryViewController.h
//  BookSystem
//
//  Created by Stan Wu on 12-9-3.
//
//

#import <UIKit/UIKit.h>
#import "ABScrollPageView.h"

@interface BSCategoryViewController : UIViewController<ABScrollPageViewDeleage>{
    UIButton *btnLog,*btnQuery;
    NSDictionary *dicInfo;
    BOOL bShowBig;
    
    ABScrollPageView *scvFoods;
}
@property (nonatomic,retain) NSDictionary *dicInfo;

@end
