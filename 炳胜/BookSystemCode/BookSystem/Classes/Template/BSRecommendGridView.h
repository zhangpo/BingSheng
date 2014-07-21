//
//  BSRecommendGridView.h
//  BookSystem
//
//  Created by Stan Wu on 12-9-9.
//
//

#import <UIKit/UIKit.h>

@interface BSRecommendGridView : UIView{
    UIScrollView *scvContent;

    NSArray *aryFoods;
}
@property (nonatomic,retain) NSArray *aryFoods;

@end
