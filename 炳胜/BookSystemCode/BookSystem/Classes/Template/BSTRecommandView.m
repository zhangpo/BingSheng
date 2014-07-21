//
//  BSTRecommandView.m
//  BookSystem
//
//  Created by Wu Stan on 12-6-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BSTRecommandView.h"
#import "UIButtonEx.h"
#import "BSCommentView.h"
#import "WPhotoCell.h"
#import <QuartzCore/QuartzCore.h>
#import "CVLocalizationSetting.h"
#import <MediaPlayer/MediaPlayer.h>
#import "BSDataProvider.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

@implementation BSTRecommandView

@synthesize aryAddition,strUnitKey,strPriceKey;
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.aryAddition = nil;
    self.strUnitKey = nil;
    self.strPriceKey = nil;
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame info:(NSDictionary *)info
{
    self = [super initWithFrame:frame info:info];
    if (self) {
        // Initialization code
        BSDataProvider *dp = [BSDataProvider sharedInstance];
        NSDictionary *foodInfo = [BSDataProvider getDataFromSQLByCommand:[NSString stringWithFormat:@"select * from food where ITCODE = '%@'",[info objectForKey:@"foodid"]]];
        
            
        NSDictionary *frameConfig = [info objectForKey:@"frame"];
        NSDictionary *resourceConfig = [dp resourceConfig];
        
        
        CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
        bShowButton = [[NSUserDefaults standardUserDefaults] boolForKey:@"ShowButton"];
        bShowButton = YES;
        fFoodCount = 1;
        dAddition = 0;
        


        
        NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"textColor"];
        
        if (!colorData){
            colorData = [NSKeyedArchiver archivedDataWithRootObject:[UIColor blackColor]];
            [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:@"textColor"];
        }
        
        UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
        
        UILabel *lblIntro = [[UILabel alloc] initWithFrame:CGRectFromString([frameConfig objectForKey:@"Description"])];
        lblIntro.font = [UIFont systemFontOfSize:13];
        lblIntro.textColor = color;
        lblIntro.backgroundColor = [UIColor clearColor];
        lblIntro.lineBreakMode = UILineBreakModeWordWrap;
        lblIntro.numberOfLines = 9;
        lblIntro.text = [[foodInfo objectForKey:@"REMEMO"] stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
        [self addSubview:lblIntro];
        [lblIntro release];
        
        
//        CGRect rect = CGRectFromString([frameConfig objectForKey:@"Price"]);
//        {{545,805},{84,45}}
        CGRect rect=CGRectMake(545, 805, 84, 45);
        lblPrice = [UILabel createLabelWithFrame:rect font:[UIFont boldSystemFontOfSize:rect.size.height-2] textColor:[UIColor redColor]];
        lblPrice.textAlignment = UITextAlignmentRight;
        lblPrice.text = [foodInfo objectForKey:[[NSUserDefaults standardUserDefaults] stringForKey:@"price"]];
        lblPrice.frame=CGRectMake(625-[lblPrice.text length]*30, 805, [lblPrice.text length]*30, 45);
        [self addSubview:lblPrice];
        
        rect = CGRectFromString([frameConfig objectForKey:@"Unit"]);
        lblUnit = [UILabel createLabelWithFrame:rect font:[UIFont boldSystemFontOfSize:rect.size.height-2] textColor:pageColor];
        lblUnit.text = [NSString stringWithFormat:@"元/%@",[foodInfo objectForKey:@"UNIT"]];
//        {{635,818},{150,35}}
//        lblUnit.frame=CGRectMake(635, 818, 80, 35);
        
        lblUnit.backgroundColor=[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:0.7];
        [self addSubview:lblUnit];
        
        
        rect=CGRectMake(20, 805, 300, 30);
        UILabel *lblChineseName = [UILabel createLabelWithFrame:rect font:[UIFont boldSystemFontOfSize:rect.size.height-2] textColor:pageColor];
        lblChineseName.backgroundColor=[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:0.8];
        lblChineseName.text = [[foodInfo objectForKey:@"DES"] stringByReplacingOccurrencesOfString:@"^" withString:@"\n"];
        lblChineseName.frame=CGRectMake(20, 805,  [lblChineseName.text length]*30, 30);
        [self addSubview:lblChineseName];
        
        rect = CGRectFromString([frameConfig objectForKey:@"EnglishName"]);
        UILabel *lblEnglishName = [UILabel createLabelWithFrame:rect font:[UIFont systemFontOfSize:rect.size.height] textColor:pageColor];
        lblEnglishName.text = [[foodInfo objectForKey:@"DESCE"] stringByReplacingOccurrencesOfString:@"^" withString:@"\n"];
        [self addSubview:lblEnglishName];
        
        UIButton *btnPriceUnit = [UIButton buttonWithType:UIButtonTypeCustom];
//        {{540,800},{185,55}}
//        btnPriceUnit.frame = CGRectFromString([frameConfig objectForKey:@"ChangeUnit"]);
        btnPriceUnit.frame=CGRectMake(540, 800, 250, 55);
        [self addSubview:btnPriceUnit];
        [btnPriceUnit addTarget:self action:@selector(changeUnit:) forControlEvents:UIControlEventTouchUpInside];
        
        
        if ([[foodInfo  objectForKey:@"sPriceTyp"] boolValue])
            btnPriceUnit.hidden = NO;
        else
            btnPriceUnit.hidden = YES;
        
        
        NSLog(@"Show Button:%@",btnPriceUnit.hidden?@"NO":@"YES");
        


        rect = CGRectFromString([frameConfig objectForKey:@"CountTitle"]);
        UILabel *lbl1 = [UILabel createLabelWithFrame:rect font:[UIFont systemFontOfSize:rect.size.height] textColor:pageColor];
        lbl1.text = [langSetting localizedString:@"Count:"];// @"数量:";
//        {{20,960},{86,28}}
        lbl1.frame=CGRectMake(20, 960, 60, 28);
        lbl1.textAlignment=UITextAlignmentCenter;
        lbl1.backgroundColor=[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:0.8];
        [self addSubview:lbl1];
        
        rect = CGRectFromString([frameConfig objectForKey:@"Count"]);
        btnCount = [UIButton buttonWithType:UIButtonTypeCustom];
        btnCount.frame = rect;
        [btnCount setTitle:@"1.0" forState:UIControlStateNormal];
        btnCount.titleLabel.font = [UIFont boldSystemFontOfSize:rect.size.height-2];
        [btnCount setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [btnCount addTarget:self action:@selector(countClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnCount];
        
        NSString *plusname = [[resourceConfig objectForKey:@"button"] objectForKey:@"plus"];
        NSString *minusname = [[resourceConfig objectForKey:@"button"] objectForKey:@"minus"];
        NSString *additionsname = [[resourceConfig objectForKey:@"button"] objectForKey:@"additions"];
        NSString *confirmname = [[resourceConfig objectForKey:@"button"] objectForKey:@"confirm"];
        UIImage *imgplus = [UIImage imageWithContentsOfFile:[plusname documentPath]];
        UIImage *imgminus = [UIImage imageWithContentsOfFile:[minusname documentPath]];
        UIImage *imgadditions = [UIImage imageWithContentsOfFile:[additionsname documentPath]];
        UIImage *imgconfirm = [UIImage imageWithContentsOfFile:[confirmname documentPath]];
        
        rect = CGRectFromString([frameConfig objectForKey:@"Plus"]);
        UIButton *btnAdd = [UIButton buttonWithType:UIButtonTypeCustom];
        btnAdd.frame = rect;
        [btnAdd setBackgroundImage:imgplus forState:UIControlStateNormal];
        [btnAdd addTarget:self action:@selector(add) forControlEvents:UIControlEventTouchUpInside];
        btnAdd.hidden = !bShowButton;
        [self addSubview:btnAdd];
        
        rect = CGRectFromString([frameConfig objectForKey:@"Minus"]);
        UIButton *btnMinus = [UIButton buttonWithType:UIButtonTypeCustom];
        btnMinus.frame = rect;
        [btnMinus setBackgroundImage:imgminus forState:UIControlStateNormal];
        [btnMinus addTarget:self action:@selector(reduce) forControlEvents:UIControlEventTouchUpInside];
        btnMinus.hidden = !bShowButton;
        [self addSubview:btnMinus];
        
        rect = CGRectFromString([frameConfig objectForKey:@"Additions"]);
        btnFujia = [UIButton buttonWithType:UIButtonTypeCustom];
        btnFujia.frame = rect;
        [btnFujia setBackgroundImage:imgadditions forState:UIControlStateNormal];
        [btnFujia addTarget:self action:@selector(setAddition) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnFujia];
        
        rect = CGRectFromString([frameConfig objectForKey:@"Confirm"]);
        UIButton *btnOK = [UIButton buttonWithType:UIButtonTypeCustom];
        btnOK.frame = rect;
        [btnOK setBackgroundImage:imgconfirm forState:UIControlStateNormal];
        [btnOK addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnOK];
      
        rect = CGRectFromString([frameConfig objectForKey:@"Ordered"]);
        imgvOrdered = [[UIImageView alloc] initWithFrame:rect];
        [self addSubview:imgvOrdered];
        [imgvOrdered release];
        if (rect.size.width>0){
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"orderedbig.png"];
            [imgvOrdered setImage:[UIImage imageWithContentsOfFile:path]];
//            [imgvOrdered setImage:[UIImage imgWithContentsOfFile:[[info objectForKey:@"ordered"] documentPath]]];
        }
        imgvOrdered.hidden = YES;
        
        
//        BOOL isfullscreen = [[[info objectForKey:@"video"] objectForKey:@"type"] isEqualToString:@"fullscreen"];
        if ([info objectForKey:@"video"]){
            int time = [[[info objectForKey:@"video"] objectForKey:@"time"] intValue];
            vPlayer = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:[[info objectForKey:@"video"] objectForKey:@"url"]]];
            AVPlayerLayer *vlayer = [AVPlayerLayer playerLayerWithPlayer:vPlayer];
            NSString *videoframe = [frameConfig objectForKey:@"Video"]?[frameConfig objectForKey:@"Video"]:[frameConfig objectForKey:@"Photo"];
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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshOrderStatus) name:@"RefreshOrderStatus" object:nil];
    }
    return self;
}

- (void)showVideo:(UIButton *)btn{
    if (vPlayer.rate==0)
        [vPlayer play];
    else
        [vPlayer pause];
}

- (void)refreshOrderStatus{
    NSArray *itcodes = [[dicInfo objectForKey:@"foodid"] componentsSeparatedByString:@","];
    
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

- (void)imageClicked:(UIButton *)sender{
    //    v = [[BSOrderView alloc] initWithDict:[self.aryDict objectAtIndex:sender.tag]];
    //    v.delegate = self;
    //    [backView addSubview:v];
    //    [self.view bringSubviewToFront:v];
    //    [v release];
//    WPhotoCell *vPhotoCell = [[WPhotoCell alloc] initWithFrame:CGRectMake(0, 0, 768, 1004)];
//    vPhotoCell.alpha = 0;
//    vPhotoCell.animationStyle = WImageViewAnimationStyleCrossOver;
//    [self addSubview:vPhotoCell];
//    [vPhotoCell release];
//    
//    
//    NSString *imgname = [dicInfo objectForKey:@"picBig"];
//    vPhotoCell.dicInfo = [NSDictionary dictionaryWithObjectsAndKeys:imgname,@"image", nil];
//    
//    [UIView animateWithDuration:0.2f animations:^{
//        vPhotoCell.alpha = 1; 
//    }];
}

- (void)goBack{
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowClassDetail" object:nil userInfo:self.dicInfo];
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
    
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    NSDictionary *foodInfo = [BSDataProvider getDataFromSQLByCommand:[NSString stringWithFormat:@"select * from food where ITCODE = '%@'",[dicInfo objectForKey:@"foodid"]]];
    
    lblPrice.text = [foodInfo objectForKey:[[NSUserDefaults standardUserDefaults] stringForKey:@"price"]];
    lblUnit.text = [NSString stringWithFormat:@"元/%@",[foodInfo objectForKey:@"UNIT"]];
    
    NSMutableArray *mutmut = [NSMutableArray array];
    for (int i=0;i<5;i++){
        NSString *unit = [foodInfo objectForKey:0==i?@"UNIT":[NSString stringWithFormat:@"UNIT%d",i+1]];
        NSString *price = [foodInfo objectForKey:0==i?@"PRICE":[NSString stringWithFormat:@"PRICE%d",i+1]];
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
        BSDataProvider *dp = [BSDataProvider sharedInstance];
        NSDictionary *foodInfo = [BSDataProvider getDataFromSQLByCommand:[NSString stringWithFormat:@"select * from food where ITCODE = '%@'",[dicInfo objectForKey:@"foodid"]]];
        

        lblPrice.text = [foodInfo objectForKey:[[NSUserDefaults standardUserDefaults] stringForKey:@"price"]];
        lblUnit.text = [NSString stringWithFormat:@"元/%@",[foodInfo objectForKey:@"UNIT"]];
        
        int j = 0;
        int mutIndex = buttonIndex-1;
        
        for (int i=0;i<5;i++){
            NSString *unit = [foodInfo objectForKey:0==i?@"UNIT":[NSString stringWithFormat:@"UNIT%d",i+1]];
            if (unit && [unit length]>0){
                if (j==mutIndex){
                    self.strUnitKey = 0==i?@"UNIT":[NSString stringWithFormat:@"UNIT%d",i+1];
                    self.strPriceKey = 0==i?@"PRICE":[NSString stringWithFormat:@"PRICE%d",i+1];
                    lblPrice.text = [foodInfo objectForKey:strPriceKey];
                    lblUnit.text = [NSString stringWithFormat:@"元/%@",[foodInfo objectForKey:strUnitKey]];
                }
                j++;
            }
            
        }
        
        
    }
}

- (void)confirm{
    //    CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
    BSDataProvider *dp = [BSDataProvider sharedInstance];
//    NSLog(@"Dic Info:%@",dicInfo);
    
    NSString *cmd = [NSString stringWithFormat:@"select * from food where ITCODE = '%@'",[self.dicInfo objectForKey:@"foodid"]];
//    NSLog(@"CMD:%@",cmd);
    NSDictionary *foodInfo = [BSDataProvider getDataFromSQLByCommand:[NSString stringWithFormat:@"select * from food where ITCODE = '%@'",[self.dicInfo objectForKey:@"foodid"]]];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:foodInfo forKey:@"food"];
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
//    NSString *imgname = [foodInfo objectForKey:@"picBig"];
    NSString *imgname = [NSString stringWithFormat:@"%@.png",[foodInfo objectForKey:@"ITCODE"]];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:imgname];
    [imgv setImage:[UIImage imageWithContentsOfFile:path]];
    
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
        
        
        
        
        UIPickerView *picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 80, 196)];
        picker.showsSelectionIndicator = YES;
        picker.delegate = self;
        picker.dataSource = self;
        picker.tag = 999;
        [vc.view addSubview:picker];
        [picker release]; 
        
//        NSLog(@"%f %f",picker.frame.size.width,picker.frame.size.height);
        pop = [[UIPopoverController alloc] initWithContentViewController:vc];
        [pop setPopoverContentSize:CGSizeMake(80, 196)];
        [vc release];
    }
    
    UIPickerView *pickerView = (UIPickerView *)[pop.contentViewController.view viewWithTag:999];
    
    int row = (int)fFoodCount;
    int component = (((int)(fFoodCount*10))%10);
    [pickerView selectRow:row inComponent:0 animated:NO];
    [pickerView selectRow:component inComponent:1 animated:NO];

    [pop presentPopoverFromRect:btnCount.frame inView:self permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
}

#pragma mark UIPickerView Delegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [NSString stringWithFormat:@"%d",row];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 2;
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
    
    value = index0+(float)index1*0.1f;
    
    
    fFoodCount = value;
    [btnCount setTitle:[NSString stringWithFormat:@"%.1f",fFoodCount] forState:UIControlStateNormal];
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
