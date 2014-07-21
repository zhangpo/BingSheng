//
//  BSAdView.h
//  BookSystem
//
//  Created by Dream on 11-3-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    ADChangeTypeShuffle,
    ADChangeTypeCircle
}ADChangeType;

@interface BSAdView : UIView {
    int adIndex;
    UIImageView *imgvAD;
}
@property (nonatomic,retain) UIImageView *imgvAD;

- (void)changeAD:(ADChangeType)type;
@end
