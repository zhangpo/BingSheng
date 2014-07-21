//
//  ColorGradientSelectorView.h
//  Wabo
//
//  Created by Stan Wu on 11-9-26.
//  Copyright 2011年 CheersDigi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>



@interface ColorGradientSelectorView : UIView{
    UIColor *middleColor,*selectedColor;
    
    unsigned char* imgdata;
    

}
@property (nonatomic,retain) UIColor *middleColor,*selectedColor;



@end
