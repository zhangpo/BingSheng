//
//  ColorPickerView.h
//  Wabo
//
//  Created by Stan Wu on 11-9-26.
//  Copyright 2011年 CheersDigi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorGradientSelectorView.h"

@protocol ColorPickerViewDelegate
- (void)circleColorSelected:(UIColor *)color;
- (void)colorSelected:(UIColor *)color;
- (UIColor *)lastSelectedColor;

@end

@interface ColorPickerView : UIView{
    UIImageView *imgvCircle,*imgvCurrentColor,*imgvPreColor;
    UIView *vCircle,*vSquare;
    ColorGradientSelectorView *vGradient;
    UIButton *btnSwitch;
    
    
    
    id<ColorPickerViewDelegate> delegate;
}
@property (nonatomic,assign) id<ColorPickerViewDelegate> delegate;


- (id)initWithFrame:(CGRect)frame delegate:(id<ColorPickerViewDelegate>)delegate_;
@end
