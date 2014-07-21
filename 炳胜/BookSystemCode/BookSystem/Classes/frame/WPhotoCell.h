//
//  WPhotoCell.h
//  Wabo
//
//  Created by Stan Wu on 11-9-20.
//  Copyright 2011年 CheersDigi. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kClickDistance      6.0f

typedef enum{
    WImageViewAnimationStyleFlip,
    WImageViewAnimationStyleCrossOver
}WImageViewAnimationStyle;

@interface WPhotoCell : UIView<UIScrollViewDelegate>{
    UIImageView *imgvBG;
    UIImageView *imgvPhoto;
    UILabel *lblStatus;
    UIScrollView *scvPhoto;
    UIButton *btnCancel;
    UIActivityIndicatorView *indicator;
    
    CGPoint ptPrev;
    NSDictionary *dicInfo;
    WImageViewAnimationStyle animationStyle;
}
@property WImageViewAnimationStyle animationStyle;
@property (nonatomic,retain) NSDictionary *dicInfo;

@end
