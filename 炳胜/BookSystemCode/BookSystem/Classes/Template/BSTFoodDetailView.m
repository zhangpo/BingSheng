//
//  BSTFoodDetailView.m
//  BookSystem
//
//  Created by Wu Stan on 12-5-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BSTFoodDetailView.h"
#import "UIButtonEx.h"
#import "BSCommentView.h"
#import "WPhotoCell.h"
#import <QuartzCore/QuartzCore.h>
#import "CVLocalizationSetting.h"
#import <MediaPlayer/MediaPlayer.h>
#import "BSDataProvider.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

@implementation BSTFoodDetailView
@synthesize aryAddition,strUnitKey,strPriceKey;

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (vPlayer.rate!=0)
        [vPlayer pause];
    self.aryAddition = nil;
    self.strUnitKey = nil;
    self.strPriceKey = nil;
    
    [super dealloc];
}

- (void)refreshOrderStatus{
    NSArray *itcodes = [[dicInfo objectForKey:@"ITCODE"] componentsSeparatedByString:@","];
    
    
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    NSMutableArray *ary = [dp orderedFood];
    
    BOOL bFinded = NO;
    for (NSString *itcode in itcodes){
        for (NSDictionary *food in ary){
            if (![[food objectForKey:@"isPack"] boolValue]
                && [[[food objectForKey:@"food"] objectForKey:@"ITCODE"] isEqualToString:itcode]){
                bFinded = YES;
                break;
            }
        }
        if (bFinded)
            break;
    }
    
    
    imgvOrdered.hidden = !bFinded;
}

- (id)initWithFrame:(CGRect)frame info:(NSDictionary *)info
{
    self = [super initWithFrame:frame info:info];
    if (self) {
        // Initialization code
        BOOL isPop = [[info objectForKey:@"isPop"] boolValue];
        BSDataProvider *dp = [BSDataProvider sharedInstance];
        NSDictionary *foodDetailConfig = [dp foodDetailConfig];
        NSDictionary *resourceConfig = [dp resourceConfig];
        
        float xscale = frame.size.width/768.0f;
        float yscale = frame.size.height/1004.0f;
        
        if (isPop){
            NSMutableDictionary *mut = [NSMutableDictionary dictionaryWithDictionary:foodDetailConfig];
            for (NSString *key in mut.allKeys){
                CGRect originframe = CGRectFromString([mut objectForKey:key]);
                originframe.origin.x *= xscale;
                originframe.origin.y *= yscale;
                originframe.size.width *= xscale;
                originframe.size.height *= yscale;
                
                [mut setObject:NSStringFromCGRect(originframe) forKey:key];
                
                foodDetailConfig = [NSDictionary dictionaryWithDictionary:mut];
            }
        }
        
        
        NSArray *comments = [dp pGetFoodComment:[NSDictionary dictionaryWithObjectsAndKeys:[info objectForKey:@"foodid"],@"itcode", nil]];
        
        
        if (!comments && [comments count]>0){
            NSMutableDictionary *mut = [NSMutableDictionary dictionaryWithDictionary:info];
            [mut setObject:comments forKey:@"comments"];
            self.dicInfo = [NSDictionary dictionaryWithDictionary:mut];
        }
        
        CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
        bShowButton = [[NSUserDefaults standardUserDefaults] boolForKey:@"ShowButton"];
        fFoodCount = 1;
        dAddition = 0;
        
        NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docPath = [docPaths objectAtIndex:0];
        NSString *bigPath = [docPath stringByAppendingPathComponent:[info objectForKey:@"picBig"]];
        //        NSString *introPath = [docPath stringByAppendingPathComponent:[info  objectForKey:@"intro"]];
        
        UIImage *imgPic = [UIImage imgWithContentsOfFile:bigPath];
        //        UIImage *imgIntro = [UIImage imgWithContentsOfFile:introPath];
        
        
        
        
        
        BOOL isfullscreen = [[[info objectForKey:@"video"] objectForKey:@"type"] isEqualToString:@"fullscreen"];
        if (![info objectForKey:@"video"]){
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectFromString([foodDetailConfig objectForKey:@"Photo"]);
            btn.layer.cornerRadius = 5;
            btn.layer.masksToBounds = YES;
            [btn setBackgroundImage:imgPic forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(imageClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
        }else{
            if (isfullscreen){
                UIButtonEx *btnPlay = [UIButtonEx buttonWithType:UIButtonTypeCustom];
                btnPlay.frame = CGRectMake(15+737-60, 128+586-62, 60, 62);
                [btnPlay setImage:[UIImage imageNamed:@"BSPlayButton.png"] forState:UIControlStateNormal];
                [self addSubview:btnPlay];
                [btnPlay addTarget:self action:@selector(showVideo:) forControlEvents:UIControlEventTouchUpInside];
                
            }else{
                int time = [[[info objectForKey:@"video"] objectForKey:@"time"] intValue];
                vPlayer = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:[[info objectForKey:@"video"] objectForKey:@"url"]]];
                AVPlayerLayer *vlayer = [AVPlayerLayer playerLayerWithPlayer:vPlayer];
                NSString *videoframe = [foodDetailConfig objectForKey:@"Video"]?[foodDetailConfig objectForKey:@"Video"]:[foodDetailConfig objectForKey:@"Photo"];
                vlayer.frame = CGRectFromString(videoframe);
                [self.layer addSublayer:vlayer];
                [vPlayer release];
                [vPlayer seekToTime:CMTimeMake(time*60, 60)];
                
                UIButtonEx *btnPlay = [UIButtonEx buttonWithType:UIButtonTypeCustom];
                btnPlay.frame = CGRectMake(15+737-60, 128+586-62, 60, 62);
                [btnPlay setImage:[UIImage imageNamed:@"BSPlayButton.png"] forState:UIControlStateNormal];
                [self addSubview:btnPlay];
                [btnPlay addTarget:self action:@selector(showVideo:) forControlEvents:UIControlEventTouchUpInside];
                btnPlay.center = CGPointMake(vlayer.frame.origin.x+vlayer.frame.size.width/2, vlayer.frame.origin.y+vlayer.frame.size.height/2);
            }
        }
        
        //        UIImageView *imgvPic = [[UIImageView alloc] initWithFrame:CGRectMake(40, 80, 688, 550)];
        //        imgvPic.layer.masksToBounds = YES;
        //        imgvPic.layer.cornerRadius = 5;
        //        [imgvPic setImage:imgPic];
        //        [self addSubview:imgvPic];
        //        [imgvPic release];
        //        imgvPic.tag = 333;
        
        //        UIButtonEx *btnPic = [UIButtonEx buttonWithType:UIButtonTypeCustom];
        //        btnPic.backgroundColor = [UIColor clearColor];
        //        btnPic.opaque = YES;
        //        [btnPic addTarget:self action:@selector(imageClicked:) forControlEvents:UIControlEventTouchUpInside];
        //        btnPic.frame = CGRectMake(15, 128, 737, 586);
        //        [self addSubview:btnPic];
        
                
        NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"textColor"];
        
        if (!colorData){
            colorData = [NSKeyedArchiver archivedDataWithRootObject:[UIColor blackColor]];
            [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:@"textColor"];
        }
        
        UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
        
        UILabel *lblIntro = [[UILabel alloc] initWithFrame:CGRectFromString([foodDetailConfig objectForKey:@"Description"])];
        lblIntro.font = [UIFont systemFontOfSize:13];
        lblIntro.textColor = pageColor;
        lblIntro.backgroundColor = [UIColor clearColor];
        lblIntro.lineBreakMode = UILineBreakModeWordWrap;
        lblIntro.numberOfLines = 9;
        lblIntro.text = [[info objectForKey:@"REMEMO"] stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
        [self addSubview:lblIntro];
        [lblIntro release];
        
        
//        CGRect rect = CGRectFromString([foodDetailConfig objectForKey:@"Price"]);
        CGRect rect = CGRectMake(530, 805, 100, 45);
        lblPrice = [UILabel createLabelWithFrame:rect font:[UIFont boldSystemFontOfSize:rect.size.height-2] textColor:[UIColor redColor]];
        lblPrice.textAlignment = UITextAlignmentRight;
        lblPrice.text = [info objectForKey:[[NSUserDefaults standardUserDefaults] stringForKey:@"price"]];
        [self addSubview:lblPrice];
        
        rect = CGRectFromString([foodDetailConfig objectForKey:@"Unit"]);
        lblUnit = [UILabel createLabelWithFrame:rect font:[UIFont boldSystemFontOfSize:rect.size.height-2] textColor:pageColor];
        lblUnit.text = [NSString stringWithFormat:@"元/%@",[info objectForKey:@"UNIT"]];
        [self addSubview:lblUnit];
        
        rect = CGRectFromString([foodDetailConfig objectForKey:@"ChineseName"]);
        UILabel *lblChineseName = [UILabel createLabelWithFrame:rect font:[UIFont boldSystemFontOfSize:rect.size.height-2] textColor:pageColor];
        lblChineseName.text = [[info objectForKey:@"DES"] stringByReplacingOccurrencesOfString:@"^" withString:@"\n"];
        //(CGRect) rect = origin=(x=20, y=805) size=(width=200, height=30)
        lblChineseName.frame = CGRectMake(20, 805, 400, 80);
        [self addSubview:lblChineseName];
        
        rect = CGRectFromString([foodDetailConfig objectForKey:@"EnglishName"]);
        UILabel *lblEnglishName = [UILabel createLabelWithFrame:rect font:[UIFont systemFontOfSize:rect.size.height] textColor:pageColor];
        lblEnglishName.text = [[info objectForKey:@"DESCE"] stringByReplacingOccurrencesOfString:@"^" withString:@"\n"];
        [self addSubview:lblEnglishName];
        
        UIButton *btnPriceUnit = [UIButton buttonWithType:UIButtonTypeCustom];
        btnPriceUnit.frame = CGRectFromString([foodDetailConfig objectForKey:@"ChangeUnit"]);
        [self addSubview:btnPriceUnit];
        [btnPriceUnit addTarget:self action:@selector(changeUnit:) forControlEvents:UIControlEventTouchUpInside];
        
        
        if ([[info  objectForKey:@"sPriceTyp"] boolValue])
            btnPriceUnit.hidden = NO;
        else
            btnPriceUnit.hidden = YES;
//        NSLog(@"Show Button:%@",btnPriceUnit.hidden?@"NO":@"YES");
        
        rect = CGRectFromString([foodDetailConfig objectForKey:@"Comments"]);
        UIButtonEx *btnComment = [UIButtonEx buttonWithType:UIButtonTypeRoundedRect];
        btnComment.tag = 2222;
        btnComment.frame = rect;
        [self addSubview:btnComment];
        [btnComment addTarget:self action:@selector(showComments:) forControlEvents:UIControlEventTouchUpInside];
        
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 9, 100, rect.size.height-18)];
        lbl.font = [UIFont systemFontOfSize:lbl.frame.size.height];
        lbl.backgroundColor = [UIColor clearColor];
        lbl.textAlignment = UITextAlignmentRight;
        lbl.textColor = pageColor;
        [btnComment addSubview:lbl];
        [lbl release];
        lbl.text = [NSString stringWithFormat:@"%d份评价",[comments count]];
        lbl.tag = 3333;
        
        int level = 0;
        for (NSDictionary *comment in comments){
            level += [[comment objectForKey:@"level"] intValue];
        }
        
        level = floorf(((float)level)/((float)([comments count]))+0.5f);
        
        BSCommentView *vComment = [[BSCommentView alloc] initWithFrame:CGRectMake(110, 9,  32*5+2*4, lbl.frame.size.height)];
        vComment.tag = 444;
        vComment.userInteractionEnabled = NO;
        [btnComment addSubview:vComment];
        [vComment release];
        if ([comments count]>0)
            vComment.level = level;
        else
            vComment.level = 0;
        
        
        
        NSString *backname = [[resourceConfig objectForKey:@"button"] objectForKey:@"back"];
        
        rect = CGRectFromString([foodDetailConfig objectForKey:@"Back"]);
        UIButton *btnContents = [UIButton buttonWithType:UIButtonTypeCustom];
        btnContents.frame = rect;
        [btnContents setBackgroundImage:[UIImage imgWithContentsOfFile:[backname documentPath]] forState:UIControlStateNormal];
        [btnContents setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnContents addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnContents];
        btnContents.hidden = isPop;
        
        
        
        
        
        rect = CGRectFromString([foodDetailConfig objectForKey:@"CountTitle"]);
        UILabel *lbl1 = [UILabel createLabelWithFrame:rect font:[UIFont systemFontOfSize:rect.size.height]];
        lbl1.text = [langSetting localizedString:@"Count:"];// @"数量:";
        lbl1.backgroundColor = [UIColor clearColor];
        [self addSubview:lbl1];
        
        rect = CGRectFromString([foodDetailConfig objectForKey:@"Count"]);
        btnCount = [UIButton buttonWithType:UIButtonTypeCustom];
        btnCount.frame = rect;
        [btnCount setTitle:@"1.00" forState:UIControlStateNormal];
        btnCount.titleLabel.font = [UIFont boldSystemFontOfSize:rect.size.height-2];
        [btnCount setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [btnCount addTarget:self action:@selector(countClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnCount];
        
        NSString *plusname = [[resourceConfig objectForKey:@"button"] objectForKey:@"plus"];
        NSString *minusname = [[resourceConfig objectForKey:@"button"] objectForKey:@"minus"];
        NSString *additionsname = [[resourceConfig objectForKey:@"button"] objectForKey:@"additions"];
        NSString *confirmname = [[resourceConfig objectForKey:@"button"] objectForKey:@"confirm"];
        UIImage *imgplus = [UIImage imgWithContentsOfFile:[plusname documentPath]];
        UIImage *imgminus = [UIImage imgWithContentsOfFile:[minusname documentPath]];
        UIImage *imgadditions = [UIImage imgWithContentsOfFile:[additionsname documentPath]];
        UIImage *imgconfirm = [UIImage imgWithContentsOfFile:[confirmname documentPath]];
        
        rect = CGRectFromString([foodDetailConfig objectForKey:@"Plus"]);
        UIButton *btnAdd = [UIButton buttonWithType:UIButtonTypeCustom];
        btnAdd.frame = rect;
        [btnAdd setBackgroundImage:imgplus forState:UIControlStateNormal];
        [btnAdd addTarget:self action:@selector(add) forControlEvents:UIControlEventTouchUpInside];
        btnAdd.hidden = !bShowButton;
        [self addSubview:btnAdd];
        
        rect = CGRectFromString([foodDetailConfig objectForKey:@"Minus"]);
        UIButton *btnMinus = [UIButton buttonWithType:UIButtonTypeCustom];
        btnMinus.frame = rect;
        [btnMinus setBackgroundImage:imgminus forState:UIControlStateNormal];
        [btnMinus addTarget:self action:@selector(reduce) forControlEvents:UIControlEventTouchUpInside];
        btnMinus.hidden = !bShowButton;
        [self addSubview:btnMinus];
        
        rect = CGRectFromString([foodDetailConfig objectForKey:@"Additions"]);
        btnFujia = [UIButton buttonWithType:UIButtonTypeCustom];
        btnFujia.frame = rect;
        [btnFujia setBackgroundImage:imgadditions forState:UIControlStateNormal];
        [btnFujia addTarget:self action:@selector(setAddition) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnFujia];
        
        rect = CGRectFromString([foodDetailConfig objectForKey:@"Confirm"]);
        UIButton *btnOK = [UIButton buttonWithType:UIButtonTypeCustom];
        btnOK.frame = rect;
        [btnOK setBackgroundImage:imgconfirm forState:UIControlStateNormal];
        [btnOK addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnOK];
        
        
        rect = CGRectFromString([foodDetailConfig objectForKey:@"Ordered"]);
        imgvOrdered = [[UIImageView alloc] initWithImage:[UIImage imgWithContentsOfFile:[[[resourceConfig objectForKey:@"button"] objectForKey:@"ordered"] documentPath]]];
        imgvOrdered.frame = rect;
        [self addSubview:imgvOrdered];
        [imgvOrdered release];
        imgvOrdered.hidden = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshOrderStatus) name:@"RefreshOrderStatus" object:nil];
        [self refreshOrderStatus];
        //        UIButton *btnShare = [UIButton buttonWithType:UIButtonTypeCustom];
        //        btnShare.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        //        btnShare.frame = CGRectMake(630, 18+924, 80, 44);
        //        [btnShare setBackgroundImage:imgNormal forState:UIControlStateNormal];
        //        [btnShare setBackgroundImage:imgPressed forState:UIControlStateHighlighted];
        //        btnShare.center = CGPointMake(670, 40+924);
        //        //    [btnComment setTitle:[langSetting localizedString:@"Additions"] forState:UIControlStateNormal];
        //        [btnShare setTitle:@"分享菜品" forState:UIControlStateNormal];
        //        [btnShare addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
        //        btnShare.hidden = !bShowButton;
        
        
        //    UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
        //    btnCancel.frame = CGRectMake(630, 18, 80, 44);
        //    [btnCancel setBackgroundImage:imgNormal forState:UIControlStateNormal];
        //    [btnCancel setBackgroundImage:imgPressed forState:UIControlStateHighlighted];
        //    btnCancel.center = CGPointMake(670, 40);
        //    [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
        //    [btnCancel addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        
        
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */
- (void)imageClicked:(UIButton *)sender{
    //    v = [[BSOrderView alloc] initWithDict:[self.aryDict objectAtIndex:sender.tag]];
    //    v.delegate = self;
    //    [backView addSubview:v];
    //    [self.view bringSubviewToFront:v];
    //    [v release];
    WPhotoCell *vPhotoCell = [[WPhotoCell alloc] initWithFrame:CGRectMake(0, 0, 768, 1004)];
    vPhotoCell.alpha = 0;
    vPhotoCell.animationStyle = WImageViewAnimationStyleCrossOver;
    [self addSubview:vPhotoCell];
    [vPhotoCell release];
    
    
    NSString *imgname = [dicInfo objectForKey:@"picBig"];
    vPhotoCell.dicInfo = [NSDictionary dictionaryWithObjectsAndKeys:imgname,@"image", nil];
    
    [UIView animateWithDuration:0.2f animations:^{
        vPhotoCell.alpha = 1;
    }];
}

- (void)goBack{ 
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowCategoryDetail"
                                                        object:nil
                                                      userInfo:self.dicInfo];
}


#pragma mark Handle Order Events
- (void)setAddition{
    if (!vAddition){
        NSDictionary *dic = dicInfo;
        vAddition = [[BSAddtionView alloc] initWithFrame:CGRectMake(0, 0, 492, 354) info:dic];
        vAddition.delegate = self;
    }
    if (!vAddition.superview){
        vAddition.center = CGPointMake(btnFujia.center.x,924+btnFujia.center.y);
        [self addSubview:vAddition];
        [vAddition firstAnimation];
        [vAddition release];
    }
    else{
        [vAddition removeFromSuperview];
        vAddition = nil;
    }
    
}

- (void)add{
    fFoodCount = [btnCount.titleLabel.text floatValue];
    if (fFoodCount<0)
        fFoodCount = 1;
    fFoodCount+=1.0f;
    [btnCount setTitle:[NSString stringWithFormat:@"%.2f",fFoodCount] forState:UIControlStateNormal];
}

- (void)reduce{
    fFoodCount = [btnCount.titleLabel.text floatValue];
    if (fFoodCount>1){
        fFoodCount-=1.0f;
        [btnCount setTitle:[NSString stringWithFormat:@"%.2f",fFoodCount] forState:UIControlStateNormal];
    }
}

- (void)changeUnit:(UIButton *)btn{
    btnUnit = btn;
    
    NSDictionary *food = dicInfo;
    
    lblPrice.text = [food objectForKey:[[NSUserDefaults standardUserDefaults] stringForKey:@"price"]];
    lblUnit.text = [NSString stringWithFormat:@"元/%@",[food objectForKey:@"UNIT"]];
    
    NSMutableArray *mutmut = [NSMutableArray array];
    for (int i=0;i<5;i++){
        NSString *unit = [food objectForKey:0==i?@"UNIT":[NSString stringWithFormat:@"UNIT%d",i+1]];
        NSString *price = [food objectForKey:0==i?@"PRICE":[NSString stringWithFormat:@"PRICE%d",i+1]];
        if (unit && [unit length]>0)
            [mutmut addObject:[NSDictionary dictionaryWithObjectsAndKeys:price,@"price",unit,@"unit", nil]];
    }
    
    if ([mutmut count]>1){
        int count = [mutmut count];
        
        NSMutableArray *mut = [NSMutableArray array];
        for (int j=0;j<[mutmut count];j++){
            NSString *title = [NSString stringWithFormat:@"%d元/%@",[[[mutmut objectAtIndex:j] objectForKey:@"price"] intValue],[[mutmut objectAtIndex:j] objectForKey:@"unit"]];
            [mut addObject:title];
        }
        
        UIActionSheet *as = nil;
        if (2==count)
            as = [[UIActionSheet alloc] initWithTitle:@"请选择单位和价格" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:[mut objectAtIndex:0],[mut objectAtIndex:1],nil];
        else if (3==count)
            as = [[UIActionSheet alloc] initWithTitle:@"请选择单位和价格" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:[mut objectAtIndex:0],[mut objectAtIndex:1],[mut objectAtIndex:2],nil];
        else if (4==count)
            as = [[UIActionSheet alloc] initWithTitle:@"请选择单位和价格" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:[mut objectAtIndex:0],[mut objectAtIndex:1],[mut objectAtIndex:2],[mut objectAtIndex:3],nil];
        else if (5==count)
            as = [[UIActionSheet alloc] initWithTitle:@"请选择单位和价格" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:[mut objectAtIndex:0],[mut objectAtIndex:1],[mut objectAtIndex:2],[mut objectAtIndex:3],[mut objectAtIndex:4],nil];
        
        [as showFromRect:btn.frame inView:btn.superview animated:YES];
        //        [as showInView:self.view];
        [as release];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (0!=buttonIndex){
        NSDictionary *food = dicInfo;
        
        lblPrice.text = [food objectForKey:[[NSUserDefaults standardUserDefaults] stringForKey:@"price"]];
        lblUnit.text = [food objectForKey:@"UNIT"];
        
        int j = 0;
        int mutIndex = buttonIndex-1;
        
        for (int i=0;i<5;i++){
            NSString *unit = [food objectForKey:0==i?@"UNIT":[NSString stringWithFormat:@"UNIT%d",i+1]];
            if (unit && [unit length]>0){
                if (j==mutIndex){
                    self.strUnitKey = 0==i?@"UNIT":[NSString stringWithFormat:@"UNIT%d",i+1];
                    self.strPriceKey = 0==i?@"PRICE":[NSString stringWithFormat:@"PRICE%d",i+1];
                    lblPrice.text = [food objectForKey:strPriceKey];
                    lblUnit.text = [NSString stringWithFormat:@"元/%@",[food objectForKey:strUnitKey]];
                }
                j++;
            }
            
        }
        
        
    }
}

- (void)confirm{
    //    CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:dicInfo forKey:@"food"];
    [dict setObject:btnCount.titleLabel.text forKey:@"total"];
    
    
    
    
    if (self.aryAddition)
        [dict setObject:aryAddition forKey:@"addition"];
    
    if (self.strUnitKey){
        [dict setObject:strUnitKey forKey:@"unitKey"];
        [dict setObject:strPriceKey forKey:@"priceKey"];
    }
    
    [dp orderFood:dict];
    
    self.aryAddition = nil;
    self.strUnitKey = @"UNIT";
    self.strPriceKey = @"PRICE";
    
    
    UIImageView *imgv = [[UIImageView alloc] initWithFrame:CGRectMake(15, 128, 737, 586)];
    [self addSubview:imgv];
    [imgv release];
    NSString *imgname = [dicInfo objectForKey:@"picBig"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:imgname];
    
    [imgv setImage:[UIImage imgWithContentsOfFile:path]];
    
    
    [UIView animateWithDuration:0.3f animations:^{
        imgv.frame = CGRectMake(364, kTopButtonY-20, 40, 40);
    }completion:^(BOOL finished) {
        //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[langSetting localizedString:@"Food Ordered"] delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
        //        [alert show];
        //        [alert release];
        
        [imgv removeFromSuperview];
    }];
}

- (void)cancel{
    self.aryAddition = nil;
}

- (void)additionSelected:(NSArray *)ary{
    self.aryAddition = ary;
    [vAddition removeFromSuperview];
    vAddition = nil;
}

- (void)countClicked{
    if (!pop){
        UIViewController *vc = [[UIViewController alloc] init];
        
        
        
        
        UIPickerView *picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 120, 196)];
        picker.showsSelectionIndicator = YES;
        picker.delegate = self;
        picker.dataSource = self;
        picker.tag = 999;
        [vc.view addSubview:picker];
        [picker release];
        
//        NSLog(@"%f %f",picker.frame.size.width,picker.frame.size.height);
        pop = [[UIPopoverController alloc] initWithContentViewController:vc];
        [pop setPopoverContentSize:CGSizeMake(120, 196)];
        [vc release];
    }
    
    UIPickerView *pickerView = (UIPickerView *)[pop.contentViewController.view viewWithTag:999];
    
    int row = (int)fFoodCount;
    int component = (((int)(fFoodCount*10))%10);
    int count3 = (((int)(fFoodCount*100))%10);
    [pickerView selectRow:row inComponent:0 animated:NO];
    [pickerView selectRow:component inComponent:1 animated:NO];
    [pickerView selectRow:count3 inComponent:2 animated:NO];
    [pop presentPopoverFromRect:btnCount.frame inView:self permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
}

#pragma mark UIPickerView Delegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [NSString stringWithFormat:@"%d",row];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 0==component?100:10;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    return 0==component?40:30;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    float value;
    
    int index0 = [pickerView selectedRowInComponent:0];
    int index1 = [pickerView selectedRowInComponent:1];
    int index2 = [pickerView selectedRowInComponent:2];
    
    value = index0+(float)index1*0.1f+(float)index2*0.01f;
    
    
    fFoodCount = value;
    [btnCount setTitle:[NSString stringWithFormat:@"%.2f",fFoodCount] forState:UIControlStateNormal];
}

- (void)showVideo:(UIButton *)btn{
    if (vPlayer){
        if (vPlayer.rate==0)
            [vPlayer play];
        else
            [vPlayer pause];
    }else{
        MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:[dicInfo objectForKey:@"video"]]];
        player.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        //        [self presentMoviePlayerViewControllerAnimated:player];
        [self.vcParent presentModalViewController:player animated:YES];
        [player release];
    }
    
}
//
//- (void)enterFullscreen{
//    MPMoviePlayerViewController *movieplayer = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:[[aryDict objectAtIndex:currentPage] objectForKey:@"video"]]];
//    movieplayer.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
//    [self presentMoviePlayerViewControllerAnimated:movieplayer];
//    [movieplayer release];
//
//    [player.view removeFromSuperview];
//    [player release];
//    player = nil;
//
//}



- (void)showComments:(UIButton *)btn{
    [vcPop release];
    tvFoodComment = nil;
    vCommentFood = nil;
    btnCCC = (UIButtonEx *)btn;
    
    UIViewController *vcComments = [[UIViewController alloc] init];
    vcPop = [[UIPopoverController alloc] initWithContentViewController:vcComments];
    [vcPop setPopoverContentSize:CGSizeMake(435, 700)];
    [vcComments release];
    UITableView *tv = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 435, 700)];
    tv.delegate = self;
    tv.dataSource = self;
    [vcComments.view addSubview:tv];
    [tv release];
    
    [vcPop presentPopoverFromRect:btn.frame inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}

#pragma mark -
#pragma mark UITableView Data Source & Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (0==indexPath.row){
        static NSString *identifier2 = @"CommentIdentifier";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier2];
        
        if (!cell){
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier2] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            BSCommentView *vcomment = [[BSCommentView alloc] initWithFrame:CGRectMake(10, 5, 0, 0)];
            vcomment.userInteractionEnabled = YES;
            [cell.contentView addSubview:vcomment];
            [vcomment release];
            vcomment.tag = 1111;
            
            UITextView *tv = [[UITextView alloc] initWithFrame:CGRectMake(10, 5+31+5, vcomment.frame.size.width, 50)];
            tv.layer.cornerRadius = 5;
            tv.layer.borderColor = [UIColor blackColor].CGColor;
            tv.layer.borderWidth = 1;
            [cell.contentView addSubview:tv];
            [tv release];
            tv.tag = 999;
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            btn.frame = CGRectMake(167, 100, 100, 35);
            [btn setTitle:@"评论菜品" forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(commentFood) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:btn];
            
        }
        
        tvFoodComment = (UITextView  *)[cell.contentView viewWithTag:999];
        vCommentFood = (BSCommentView *)[cell.contentView viewWithTag:1111];
        
        return cell;
        
    }else{
        static NSString *identifer = @"CellIdentifier";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
        
        if (!cell){
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer] autorelease];
            
            BSCommentView *vcomment = [[BSCommentView alloc] initWithFrame:CGRectMake(10, 10, 0, 0)];
            vcomment.userInteractionEnabled = NO;
            [cell.contentView addSubview:vcomment];
            [vcomment release];
            vcomment.tag = 100;
            
            UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectZero];
            [cell.contentView addSubview:lbl];
            [lbl release];
            lbl.tag = 201;
            
        }
        
        
        BSCommentView *vcomment = (BSCommentView *)[cell.contentView viewWithTag:100];
        UILabel *lbl = (UILabel *)[cell.contentView viewWithTag:201];
        
        NSDictionary *dict = dicInfo;
        NSArray *arycomments = [dict objectForKey:@"comments"];
        
        lbl.text = [[arycomments objectAtIndex:indexPath.row-1] objectForKey:@"comment"];
        if ([lbl.text length]==0)
            lbl.text = @"评论:";
        else
            lbl.text = [NSString stringWithFormat:@"评论:%@",lbl.text];
        
        int lines = floorf([lbl.text sizeWithFont:lbl.font].width/(vcomment.frame.size.width+20)+0.5f)+1;
        lbl.frame = CGRectMake(10, 10+vcomment.frame.size.height+10, vcomment.frame.size.width,[lbl.text sizeWithFont:lbl.font].height*lines);
        
        vcomment.level = [[[arycomments objectAtIndex:indexPath.row-1] objectForKey:@"level"] intValue];
        
        return cell;
    }
    
    
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSDictionary *dict = dicInfo;
    NSArray *arycomments = [dict objectForKey:@"comments"];
    
    return [arycomments count]+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (0==indexPath.row)
        return 140;
    
    NSDictionary *dict = dicInfo;
    NSArray *arycomments = [dict objectForKey:@"comments"];
    
    NSString *text = [[arycomments objectAtIndex:indexPath.row-1] objectForKey:@"comment"];
    if ([text length]==0)
        text = @"评论:";
    else
        text = [NSString stringWithFormat:@"评论:%@",text];
    
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:17]];
    
    int lines = floorf(size.width/(32*5+2*4)+0.5f)+1;
    
    return (20+31+size.height*lines);
    
}


- (void)commentFood{
    NSString *comment = tvFoodComment.text;
    NSString *level = [NSString stringWithFormat:@"%d",vCommentFood.level];
    NSString *itcode = [dicInfo objectForKey:@"ITCODE"];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:comment,@"comment",level,@"level",itcode,@"itcode", nil];
    
    BOOL b = [[BSDataProvider sharedInstance] pCommentFood:dict];
    
    
    if (b){
        NSMutableDictionary *mut = [NSMutableDictionary dictionaryWithDictionary:dicInfo];
        NSMutableArray *mutary = [NSMutableArray arrayWithArray:[mut objectForKey:@"comments"]];
        [mutary insertObject:dict atIndex:0];
        [mut setObject:mutary forKey:@"comments"];
        
        [vcPop dismissPopoverAnimated:YES];
        
        
        
        UIButtonEx *btnComment = btnCCC;
        
        
        NSArray *comments = mutary;
        
        UILabel *lbl = (UILabel *)[btnComment viewWithTag:3333];
        lbl.text = [NSString stringWithFormat:@"%d份评价",[comments count]];
        
        int dlevel = 0;
        for (NSDictionary *comment in comments){
            dlevel += [[comment objectForKey:@"level"] intValue];
        }
        dlevel = floorf(dlevel/[comments count]+0.5f);
        
        BSCommentView *vComment = (BSCommentView *)[btnComment viewWithTag:444];
        if ([comments count]>0)
            vComment.level = dlevel;
        else
            vComment.level = 0;
        
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"发送评论失败,请稍候再重试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
    
    
    
}

- (void)share{
    if (!vLogin){
        vLogin = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 1004)];
        vLogin.backgroundColor = [UIColor clearColor];[UIColor colorWithWhite:0 alpha:0.4f];
        vLogin.hidden = YES;
        [self addSubview:vLogin];
        [vLogin release];
        
        UIImageView *imgv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 420, 260)];
        imgv.center = CGPointMake(384, 502);
        [vLogin addSubview:imgv];
        [imgv release];
        imgv.userInteractionEnabled = YES;
        imgv.backgroundColor = [UIColor colorWithWhite:.96 alpha:1];
        imgv.layer.cornerRadius = 10;
        imgv.layer.borderWidth = 1;
        imgv.layer.borderColor = [UIColor blackColor].CGColor;
        //        imgv.layer.shadowOpacity = 0.5f;
        //        imgv.layer.shadowOffset = CGSizeMake(5, 5);
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 420, 30)];
        lbl.textAlignment = UITextAlignmentCenter;
        lbl.backgroundColor = [UIColor clearColor];
        lbl.font = [UIFont boldSystemFontOfSize:22];
        [imgv addSubview:lbl];
        [lbl release];
        lbl.text = @"登陆新浪微博";
        
        lbl = [[UILabel alloc] initWithFrame:CGRectMake(40, 80, 100, 25)];
        lbl.backgroundColor = [UIColor clearColor];
        lbl.font = [UIFont systemFontOfSize:18];
        lbl.text = @"新浪账号:";
        [imgv addSubview:lbl];
        [lbl release];
        
        lbl = [[UILabel alloc] initWithFrame:CGRectMake(40, 125, 100, 25)];
        lbl.backgroundColor = [UIColor clearColor];
        lbl.font = [UIFont systemFontOfSize:18];
        lbl.text = @"登陆密码:";
        [imgv addSubview:lbl];
        [lbl release];
        
        UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(125, 80, 200, 25)];
        tf.borderStyle = UITextBorderStyleRoundedRect;
        [imgv addSubview:tf];
        [tf release];
        tf.font = [UIFont systemFontOfSize:15];
        tf.placeholder = @"邮箱、用户名或手机号码";
        
        tf = [[UITextField alloc] initWithFrame:CGRectMake(125, 125, 200, 25)];
        tf.borderStyle = UITextBorderStyleRoundedRect;
        [imgv addSubview:tf];
        [tf release];
        tf.font = [UIFont systemFontOfSize:15];
        tf.placeholder = @"6-18位数字、符号和字母的组合";
        
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(80, 190, 110, 32);
        btn.backgroundColor = [UIColor whiteColor];
        btn.layer.cornerRadius = 5;
        btn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        btn.layer.borderWidth = 1;
        [btn setTitle:@"登陆" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [imgv addSubview:btn];
        
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(230, 190, 110, 32);
        btn.backgroundColor = [UIColor whiteColor];
        btn.layer.cornerRadius = 5;
        btn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        btn.layer.borderWidth = 1;
        [btn setTitle:@"取消" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(removeLoginWindow) forControlEvents:UIControlEventTouchUpInside];
        [imgv addSubview:btn];
        
    }
    
    vLogin.alpha = 0;
    vLogin.hidden = NO;
    [UIView animateWithDuration:0.3f animations:^{
        vLogin.alpha = 1; 
    }];
}

- (void)removeLoginWindow{
    [UIView animateWithDuration:0.3f animations:^{
        vLogin.alpha = 0; 
    }completion:^(BOOL finished) {
        vLogin.hidden = YES;
    }];
}

@end
