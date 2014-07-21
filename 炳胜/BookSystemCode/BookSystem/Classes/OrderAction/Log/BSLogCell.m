//
//  BSLogCell.m
//  BookSystem
//
//  Created by Dream on 11-5-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BSLogCell.h"
#import "BSAdditionCell.h"
#import "BSDataProvider.h"
#import "CVLocalizationSetting.h"
#import "BSShiftFoodViewController.h"

@implementation BSLogCell
@synthesize fCount,delegate,dicInfo,lblAdditionPrice,aryAdditions,arySelectedAdditions,aryCustomAddition,arySearchMatched,tfPrice,lblUnit,indexPath,butSelect_dh,butSelect;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        BSDataProvider *dp = [BSDataProvider sharedInstance];
        self.aryAdditions = [dp getAdditions];
        self.arySearchMatched = [NSMutableArray arrayWithArray:self.aryAdditions];
        
        self.arySelectedAdditions = [NSMutableArray array];
        self.aryCustomAddition = [NSMutableArray array];
        CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
//        imgvFood = [[UIImageView alloc] initWithFrame:CGRectMake(0, 6, 122, 96)];
//        [self.contentView addSubview:imgvFood];
//        [imgvFood release];
//        imgvFood.userInteractionEnabled = YES;
//        UIButton *btnunit = [UIButton buttonWithType:UIButtonTypeCustom];
//        btnunit.frame = imgvFood.bounds;
//        [self.contentView addSubview:btnunit];
//        [btnunit addTarget:self action:@selector(changeUnit) forControlEvents:UIControlEventTouchUpInside];
        
        float fNoPhotoOffset = kNoPhotoOffset;
        
        lblName = [[UILabel alloc] initWithFrame:CGRectMake(140-fNoPhotoOffset, 15, 440, 25)];
        lblName.backgroundColor = [UIColor clearColor];
        lblName.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:lblName];
        [lblName release];
        
        NSString *countpath = [[NSBundle mainBundle] pathForResource:@"LogCellCountBtn" ofType:@"png"];
        UIImage *countimg = [[UIImage alloc] initWithContentsOfFile:countpath];
        
        UIButton *btnDel = [UIButton buttonWithType:UIButtonTypeCustom];
        btnDel.frame = CGRectMake(140-fNoPhotoOffset, 40, 95, 25);
        btnDel.titleLabel.font = [UIFont systemFontOfSize:16];
        [btnDel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnDel setBackgroundImage:countimg forState:UIControlStateNormal];
        [self.contentView addSubview:btnDel];
        [btnDel addTarget:self action:@selector(deleteSelf) forControlEvents:UIControlEventTouchUpInside];
        [btnDel setTitle:@"删除" forState:UIControlStateNormal];
        
//        btnCount = [UIButton buttonWithType:UIButtonTypeCustom];
//        btnCount.frame = CGRectMake(300-fNoPhotoOffset, 40, 95, 25);
//        btnCount.titleLabel.font = [UIFont systemFontOfSize:16];
//        [btnCount setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [btnCount setBackgroundImage:countimg forState:UIControlStateNormal];
//        [self.contentView addSubview:btnCount];
//        [btnCount addTarget:self action:@selector(countClicked) forControlEvents:UIControlEventTouchUpInside];
        tfCount = [[UITextField alloc] initWithFrame:CGRectMake(300-fNoPhotoOffset, 40, 95, 25)];
        tfCount.backgroundColor = [UIColor whiteColor];
        tfCount.delegate = self;
        tfCount.borderStyle = UITextBorderStyleNone;
        tfCount.font = [UIFont systemFontOfSize:16];
        tfCount.clearButtonMode = UITextFieldViewModeWhileEditing;
        [self.contentView addSubview:tfCount];
        [tfCount release];
        tfCount.keyboardType = UIKeyboardTypeNumberPad;
        
        
//        btnPrice = [UIButton buttonWithType:UIButtonTypeCustom];
//        btnPrice.frame = CGRectMake(395-fNoPhotoOffset, 40, 95, 25);
//        tfPrice.font = [UIFont systemFontOfSize:16];
//        [btnPrice setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [self.contentView addSubview:btnPrice];
//        [btnPrice setBackgroundImage:countimg forState:UIControlStateNormal];
//        [btnPrice addTarget:self action:@selector(priceClicked) forControlEvents:UIControlEventTouchUpInside];
        
        tfPrice = [[UITextField alloc] initWithFrame:CGRectMake(395-fNoPhotoOffset+5, 40, 95, 25)];
        tfPrice.backgroundColor = [UIColor whiteColor];
        tfPrice.delegate = self;
        tfPrice.borderStyle = UITextBorderStyleNone;
        tfPrice.font = [UIFont systemFontOfSize:16];
        tfPrice.clearButtonMode = UITextFieldViewModeWhileEditing;
        [self.contentView addSubview:tfPrice];
        [tfPrice release];
        tfPrice.keyboardType = UIKeyboardTypeNumberPad;
        
        lblUnit = [[UILabel alloc] initWithFrame:CGRectMake(465-fNoPhotoOffset, 45, 95, 25)];
        lblUnit.textAlignment = UITextAlignmentRight;
        lblUnit.font = [UIFont systemFontOfSize:16];
        lblUnit.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:lblUnit];
        [lblUnit release];
        
        UIButton *btnunit = [UIButton buttonWithType:UIButtonTypeCustom];
        btnunit.frame = lblUnit.frame;
        [self.contentView addSubview:btnunit];
        [btnunit addTarget:self action:@selector(changeUnit) forControlEvents:UIControlEventTouchUpInside];

        
        lblAdditionPrice = [[UILabel alloc] initWithFrame:CGRectMake(535-fNoPhotoOffset, 45, 95, 25)];
        lblAdditionPrice.textAlignment = UITextAlignmentRight;
        lblAdditionPrice.font = [UIFont systemFontOfSize:16];
        lblAdditionPrice.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:lblAdditionPrice];
        [lblAdditionPrice release];
        
        
        lblTotalPrice = [[UILabel alloc] initWithFrame:CGRectMake(535-fNoPhotoOffset, 15, 95, 25)];
        lblTotalPrice.textAlignment = UITextAlignmentRight;
        lblTotalPrice.backgroundColor = [UIColor clearColor];
        lblTotalPrice.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:lblTotalPrice];
        [lblTotalPrice release];
        
        lblAddition = [[UILabel alloc] initWithFrame:CGRectMake(140-fNoPhotoOffset, 70, 440, 25)];
        lblAddition.backgroundColor = [UIColor clearColor];
        lblAddition.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:lblAddition];
        [lblAddition release];
        lblAddition.text = [langSetting localizedString:@"Additions:"];//@"附加项:";
        
        UIImage *imgPlusNormal = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"plusnormal" ofType:@"png"]];
        UIImage *imgPlusPressed = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"pluspressed" ofType:@"png"]];
        UIImage *imgMinusNormal = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"minusnormal" ofType:@"png"]];
        UIImage *imgMinusPressed = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"minuspressed" ofType:@"png"]];
        
        btnAdd = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnAdd setImage:imgPlusNormal forState:UIControlStateNormal];
        [btnAdd setImage:imgPlusPressed forState:UIControlStateHighlighted];
        [btnAdd sizeToFit];
        btnAdd.center = CGPointMake(605-fNoPhotoOffset+60, 30);//620,30,675,30
        [self.contentView addSubview:btnAdd];
        [btnAdd addTarget:self action:@selector(add) forControlEvents:UIControlEventTouchUpInside];
        
        btnReduce = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnReduce setImage:imgMinusNormal forState:UIControlStateNormal];
        [btnReduce setImage:imgMinusPressed forState:UIControlStateHighlighted];
        [btnReduce sizeToFit];
        btnReduce.center = CGPointMake(660-fNoPhotoOffset+60, 30);//620,30,675,30
        [self.contentView addSubview:btnReduce];
        [btnReduce addTarget:self action:@selector(reduce) forControlEvents:UIControlEventTouchUpInside];
        
        UIImage *imgEditNormal = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"btn2normal" ofType:@"png"]];
        UIImage *imgEditPressed = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"btn2pressed" ofType:@"png"]];
        btnEdit = [UIButton buttonWithType:UIButtonTypeCustom];
        btnEdit.titleLabel.font = [UIFont systemFontOfSize:14];
        [btnEdit setBackgroundImage:imgEditNormal forState:UIControlStateNormal];
        [btnEdit setBackgroundImage:imgEditPressed forState:UIControlStateHighlighted];
        [btnEdit setTitle:[langSetting localizedString:@"EditAdditions"] forState:UIControlStateNormal];
        [btnEdit sizeToFit];
        btnEdit.frame = CGRectMake(580-fNoPhotoOffset+60, 60, 108, 49);
        [self.contentView addSubview:btnEdit];
        [imgEditNormal release];
        [imgEditPressed release];
        [btnEdit addTarget:self action:@selector(setAddition) forControlEvents:UIControlEventTouchUpInside];
        
        imgEditNormal = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"btn2normal" ofType:@"png"]];
        imgEditPressed = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"btn2pressed" ofType:@"png"]];
        btnDetail = [UIButton buttonWithType:UIButtonTypeCustom];
        btnDetail.titleLabel.font = [UIFont systemFontOfSize:14];
        [btnDetail setBackgroundImage:imgEditNormal forState:UIControlStateNormal];
        [btnDetail setBackgroundImage:imgEditPressed forState:UIControlStateHighlighted];
        [btnDetail setTitle:@"套餐详细" forState:UIControlStateNormal];
        [btnDetail sizeToFit];
        btnDetail.frame = CGRectMake(580-fNoPhotoOffset+70, 30, 108, 49);
        [self.contentView addSubview:btnDetail];
        [imgEditNormal release];
        [imgEditPressed release];
        [btnDetail addTarget:self action:@selector(showPackDetail) forControlEvents:UIControlEventTouchUpInside];
        btnDetail.hidden = YES;
        
        butBacSelect = [UIButton buttonWithType:UIButtonTypeCustom];
        butBacSelect.frame = CGRectMake(76-fNoPhotoOffset, 15, 40, 40);
        [butBacSelect setBackgroundImage:[UIImage imageNamed:@"select_no"] forState:UIControlStateNormal];
        [butBacSelect addTarget:self action:@selector(selectState:) forControlEvents:UIControlEventTouchUpInside];
        butBacSelect.hidden = YES;
        [self.contentView addSubview:butBacSelect];
        
        butSelect = [UIButton buttonWithType:UIButtonTypeCustom];
        butSelect.frame = CGRectMake(76-fNoPhotoOffset, 15, 40, 40);
        [butSelect setBackgroundImage:[UIImage imageNamed:@"select_yes"] forState:UIControlStateNormal];
        [butSelect addTarget:self action:@selector(selectState:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:butSelect];
        
//        butSelect = [UIButton buttonWithType:UIButtonTypeCustom];
//        butSelect.frame = CGRectMake(1, 1, 38, 38);
//        [butSelect setBackgroundImage:[UIImage imageNamed:@"Selected"] forState:UIControlStateNormal];
//        butSelect.hidden = NO;
//        butSelect_dh = NO;
//        [butBacSelect addSubview:butSelect];
        
        lblSelected = [UILabel createLabelWithFrame:CGRectMake(70-fNoPhotoOffset, 70, 50, 22) font:[UIFont boldSystemFontOfSize:16] textColor:[UIColor whiteColor]];
        lblSelected.textAlignment = UITextAlignmentCenter;
        [self.contentView addSubview:lblSelected];
        
        UILabel *lblLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 108, 688, 2)];
        lblLine.backgroundColor = [UIColor grayColor];
        [self addSubview:lblLine];
        [lblLine release];
        
        [countimg release];
        [imgPlusNormal release];
        [imgPlusPressed release];
        [imgMinusNormal release];
        [imgMinusPressed release];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    self.aryCustomAddition = nil;
    self.arySelectedAdditions = nil;
    self.aryAdditions = nil;
    self.arySearchMatched = nil;
    self.indexPath = nil;
    [pop release];
    self.dicInfo = nil;
    [popCount release];
    [super dealloc];
}


- (void)setInfo:(NSDictionary *)info{
    CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
    
    BOOL isPack = [[info objectForKey:@"isPack"] boolValue];
    
    if (isPack){
        btnDetail.hidden = NO;
        btnEdit.hidden = !btnDetail.hidden;
        btnAdd.hidden = !btnDetail.hidden;
        btnReduce.hidden = !btnDetail.hidden;
        
        BOOL bPrice = NO;
        self.dicInfo = info;
        NSArray *aryA = [dicInfo objectForKey:@"addition"];
        [aryCustomAddition removeAllObjects];
        [arySelectedAdditions removeAllObjects];
        //    [arySearchMatched removeAllObjects];
        if ([aryA count]>0){
            for (int i=0;i<[aryA count];i++){
                if (![[aryA objectAtIndex:i] objectForKey:@"ITCODE"])
                    [aryCustomAddition addObject:[aryA objectAtIndex:i]];
                else
                    [arySelectedAdditions addObject:[aryA objectAtIndex:i]];
            }
        }
        //    [arySearchMatched addObjectsFromArray:aryCustomAddition];
        //    [arySearchMatched addObjectsFromArray:aryAdditions];
        tfCount.text = @"1.00";
        fCount = [tfCount.text floatValue];
        NSDictionary *foodInfo = info;
        NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docPath = [docPaths objectAtIndex:0];
        UIImage *img = [[UIImage alloc] initWithContentsOfFile:[docPath stringByAppendingPathComponent:[foodInfo objectForKey:@"image"]]];
        if (!img)
            img = [[UIImage alloc] initWithContentsOfFile:[docPath stringByAppendingPathComponent:@"defaultFoodPic.jpg"]];
        [imgvFood setImage:img];
        [img release];
        
        if ([[foodInfo objectForKey:@"sendFlag"] isEqualToString:@"0"]) {
            butSelect.hidden = YES;
            butBacSelect.hidden = NO;
        }else{
            butSelect.hidden = NO;
            butBacSelect.hidden = YES;
        }
        
        lblName.text = [foodInfo objectForKey:@"DES"];
        NSString *price = [foodInfo objectForKey:@"PRICE"];
        NSString *unit = @"元/份";
        
        lblUnit.text = unit;
        tfPrice.text = [NSString stringWithFormat:@"%@",price];
        tfPrice.enabled = bPrice;
        
        fPrice = [tfPrice.text floatValue];
        
        NSArray *ary = [info objectForKey:@"addition"];
        NSMutableString *str = [NSMutableString string];
        [str appendString:[langSetting localizedString:@"Additions:"]];
        
        int count = [ary count];
        float fAdditionPrice = 0;
        for (int i=0;i<count;i++){
            fAdditionPrice += [[[ary objectAtIndex:i] objectForKey:@"PRICE1"] floatValue];
            if (0!=i)
                [str appendString:@","];
            [str appendString:[[ary objectAtIndex:i] objectForKey:@"DES"]];
        }
        
        lblAdditionPrice.text = nil;
        
        lblAddition.text = nil;
        
        float fTotal = [tfCount.text floatValue]*[tfPrice.text floatValue];
        lblTotalPrice.text = [NSString stringWithFormat:@"%.2f",fTotal];
    }else{
        btnDetail.hidden = YES;
        btnEdit.hidden = !btnDetail.hidden;
        btnAdd.hidden = !btnDetail.hidden;
        btnReduce.hidden = !btnDetail.hidden;
        
        if ([[info objectForKey:@"sendFlag"] isEqualToString:@"0"]) {
            butSelect.hidden = YES;
            butBacSelect.hidden = NO;
        }else{
            butSelect.hidden = NO;
            butBacSelect.hidden = YES;
        }
        
        BOOL bPrice = [[[info objectForKey:@"food"] objectForKey:@"PRIORMTH"] intValue];
        self.dicInfo = info;
        NSArray *aryA = [dicInfo objectForKey:@"addition"];
        [aryCustomAddition removeAllObjects];
        [arySelectedAdditions removeAllObjects];
        //    [arySearchMatched removeAllObjects];
        if ([aryA count]>0){
            for (int i=0;i<[aryA count];i++){
                if (![[aryA objectAtIndex:i] objectForKey:@"ITCODE"])
                    [aryCustomAddition addObject:[aryA objectAtIndex:i]];
                else
                    [arySelectedAdditions addObject:[aryA objectAtIndex:i]];
            }
        }
        //    [arySearchMatched addObjectsFromArray:aryCustomAddition];
        //    [arySearchMatched addObjectsFromArray:aryAdditions];
        tfCount.text = [NSString stringWithFormat:@"%.2f",[[info objectForKey:@"total"] floatValue]];
        fCount = [tfCount.text floatValue];
        NSDictionary *foodInfo = [info objectForKey:@"food"];
        NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docPath = [docPaths objectAtIndex:0];
        UIImage *img = [[UIImage alloc] initWithContentsOfFile:[docPath stringByAppendingPathComponent:[foodInfo objectForKey:@"picSmall"]]];
        if (!img)
            img = [[UIImage alloc] initWithContentsOfFile:[docPath stringByAppendingPathComponent:@"defaultFoodPic.jpg"]];
        [imgvFood setImage:img];
        [img release];
        
        lblName.text = [foodInfo objectForKey:@"DES"];
        NSString *price = [foodInfo objectForKey:[info objectForKey:@"priceKey"]];
        NSString *unit = [foodInfo objectForKey:[info objectForKey:@"unitKey"]];
        lblUnit.text = [NSString stringWithFormat:@"元/%@",unit];
        tfPrice.text = [NSString stringWithFormat:@"%@",price];
        tfPrice.enabled = bPrice;
        
        fPrice = [tfPrice.text floatValue];
        
        NSArray *ary = [info objectForKey:@"addition"];
        NSMutableString *str = [NSMutableString string];
        [str appendString:[langSetting localizedString:@"Additions:"]];
        
        int count = [ary count];
        float fAdditionPrice = 0;
        for (int i=0;i<count;i++){
            fAdditionPrice += [[[ary objectAtIndex:i] objectForKey:@"PRICE1"] floatValue];
            if (0!=i)
                [str appendString:@","];
            [str appendString:[[ary objectAtIndex:i] objectForKey:@"DES"]];
        }
        
        lblAdditionPrice.text = [NSString stringWithFormat:@"%0.2f",fAdditionPrice];
        
        lblAddition.text = str;
        
        float fTotal = [tfCount.text floatValue]*[tfPrice.text floatValue];
        lblTotalPrice.text = [NSString stringWithFormat:@"%.2f",fTotal];
    }
    
    self.arySearchMatched = [NSMutableArray arrayWithArray:aryAdditions];
    for (int i=aryCustomAddition.count-1;i>=0;i--)
        [arySearchMatched insertObject:[aryCustomAddition objectAtIndex:i] atIndex:0];
}

#pragma mark Handle Button Events
- (void)selectState:(UIButton *)but{
//    if (butSelect_dh) {
//       [delegate cell:self selectFood:0];
//    }else{
//       [delegate cell:self selectFood:1];
//    }
    [delegate cell:self selectFood:1];
}

//- (BOOL)butSelect_dh{
//    return butSelect_dh;
//}
//
//- (void)butSelect_dh:(BOOL)bSelected_{
//    butSelect_dh = bSelected_;
//    if (butSelect_dh) {
//        butSelect.hidden = NO;
//    }else{
//        butSelect.hidden = YES;
//    }
//}

- (void)add{
    fCount += 1.0f;
    tfCount.text = [NSString stringWithFormat:@"%.2f",fCount];
    lblTotalPrice.text = [NSString stringWithFormat:@"%.2f",[tfPrice.text floatValue]*fCount];
    [delegate cell:self countChanged:fCount];
}

- (void)reduce{
    if (fCount-1>0){
        fCount -= 1.0f;
        tfCount.text = [NSString stringWithFormat:@"%.2f",fCount];
        lblTotalPrice.text = [NSString stringWithFormat:@"%.2f",[tfPrice.text floatValue]*fCount];
        [delegate cell:self countChanged:fCount];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"是否确定要从列表中移除这个菜品?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"移除", nil];
        [alert show];
        [alert release];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"移除"]){
        [delegate cell:self countChanged:0];
    }
}

#pragma mark bSelected's Getter & Setter
- (BOOL)bSelected{
    return bSelected;
}

- (void)setBSelected:(BOOL)bSelected_{
    bSelected = bSelected_;
    
    if (bSelected){
        lblSelected.backgroundColor = [UIColor colorWithRed:0.0f green:155.0f/255.0f blue:52.0f/255.0f alpha:1.0f];
        lblSelected.text = @"叫起";
//        for (UILabel *lbl in self.contentView.subviews){
//            if ([lbl isKindOfClass:[UILabel class]])
//                lbl.textColor = [UIColor whiteColor];
//        }
    }
    else{
        lblSelected.backgroundColor = [UIColor clearColor];
        lblSelected.text = nil;
//        for (UILabel *lbl in self.contentView.subviews){
//            if ([lbl isKindOfClass:[UILabel class]])
//                lbl.textColor = [UIColor blackColor];
//        }
    }
}

- (void)setAddition{
    if (!pop){
        UIViewController *vc = [[UIViewController alloc] init];
        
        vAddition = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
        barAddition = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
        barAddition.barStyle = UIBarStyleBlack;
        //       barAddition.showsBookmarkButton = YES;
        //       barAddition.tintColor = [UIColor whiteColor];
        barAddition.delegate = self;
        [vAddition addSubview:barAddition];
        [barAddition release];
        [vc.view addSubview:vAddition];
        [vAddition release];
        
        
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeContactAdd];
        //      [btn setTitle:@"+" forState:UIControlStateNormal];
        btn.frame = CGRectMake(150, 0, 50, 50);
        [vAddition addSubview:btn];
        [btn addTarget:self action:@selector(addCustiomAddition) forControlEvents:UIControlEventTouchUpInside];
        
        tvAddition = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, 200, 250) style:UITableViewStylePlain];
        tvAddition.delegate = self;
        tvAddition.dataSource = self;
        [vc.view addSubview:tvAddition];
        [tvAddition release];
        pop = [[UIPopoverController alloc] initWithContentViewController:vc];
        [pop setPopoverContentSize:CGSizeMake(200, 300)];
        [vc release];
    }
    [pop presentPopoverFromRect:self.frame inView:self.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

}

- (void)showPackDetail{
    NSString *suitid = [NSString stringWithFormat:@"%d",[[dicInfo objectForKey:@"PACKID"] intValue]];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:suitid,@"suitid",[NSNumber numberWithBool:YES],@"blockAction", nil];
    
    BSShiftFoodViewController *vcShiftFood = [[BSShiftFoodViewController alloc] init];
    vcShiftFood.dicInfo = dict;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vcShiftFood];
    [vcShiftFood release];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    [(UIViewController *)delegate presentModalViewController:nav animated:YES];
    [nav release];
}

#pragma mark TableView Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSArray *aryCustom = [self.dicInfo objectForKey:@"addition"];
//    NSMutableArray *aryCustomDics = [NSMutableArray array];
//    int count = [aryCustomAddition count];
    
    NSArray *ary = arySearchMatched;
    static NSString *identifier = @"AdditionCell";
    
    BSAdditionCell *cell = (BSAdditionCell *)[tableView dequeueReusableCellWithIdentifier:identifier];

    if (!cell){
        cell = [[[BSAdditionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setHeight:[self tableView:tableView heightForRowAtIndexPath:indexPath]];
    }
    
    NSDictionary *dict;
//    if (indexPath.row<count)
//        dict = [aryCustomAddition objectAtIndex:indexPath.row];
//    else
//        dict = [ary objectAtIndex:indexPath.row-count];
    dict = [ary objectAtIndex:indexPath.row];
    [cell setContent:dict];
    
    BOOL isSelected = NO;
//    if (indexPath.row<count){
//        isSelected = YES;
//    }
//    else{
        for (NSDictionary *dic in arySelectedAdditions){
            if ([[dict objectForKey:@"DES"] isEqualToString:[dic objectForKey:@"DES"]])
                isSelected = YES;
        }
    
    for (NSDictionary *dic in aryCustomAddition){
        if ([[dict objectForKey:@"DES"] isEqualToString:[dic objectForKey:@"DES"]])
            isSelected = YES;
    }
    
//    }
    
    
    cell.bSelected = isSelected;
    
    

    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return [aryAdditions count]+[aryCustomAddition count];
    return [arySearchMatched count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)ip{
    
//    int count = [aryCustomAddition count];
//    if (indexPath.row<count){
//        [aryCustomAddition removeObjectAtIndex:indexPath.row];];
//    }
    NSDictionary *dictSelected = [arySearchMatched objectAtIndex:ip.row];
    if ([aryCustomAddition containsObject:dictSelected]) {
        [aryCustomAddition removeObjectAtIndex:ip.row];
        [arySearchMatched removeObjectAtIndex:ip.row];
    }
    else{
        BSAdditionCell *cell = (BSAdditionCell *)[tableView cellForRowAtIndexPath:ip];
        cell.bSelected = !cell.bSelected;
        BOOL needAdd = YES;
        int index = -1;

        for (NSDictionary *dicAdd in arySelectedAdditions){
            if ([[dicAdd objectForKey:@"DES"] isEqualToString:[dictSelected objectForKey:@"DES"]]){
                needAdd = NO;
                index = [arySelectedAdditions indexOfObject:dicAdd];
                break;
            }
        }
        
        if (cell.bSelected && needAdd)
            [arySelectedAdditions addObject:[arySearchMatched objectAtIndex:ip.row]];
        else if (!cell.bSelected && !needAdd){
            [arySelectedAdditions removeObjectAtIndex:index];
        }

    }
    
    NSMutableArray *aryAll = [NSMutableArray arrayWithArray:arySelectedAdditions];
    [aryAll addObjectsFromArray:aryCustomAddition];
    
    
    NSMutableDictionary *dictNew = [NSMutableDictionary dictionaryWithDictionary:self.dicInfo];
    if ([aryAll count]>0)
        [dictNew setObject:aryAll forKey:@"addition"];
    else
        [dictNew removeObjectForKey:@"addition"];
    
    [delegate cell:self additionChanged:aryAll];
    [tvAddition reloadData];
    
    [barAddition resignFirstResponder];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}


- (void)countClicked{
    if (!popCount){
        UIViewController *vc = [[UIViewController alloc] init];
        
        UIPickerView *picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 130, 196)];
        picker.showsSelectionIndicator = YES;
        picker.delegate = self;
        picker.dataSource = self;
        picker.tag = 999;
        [vc.view addSubview:picker];
        [picker release]; 
        
        popCount = [[UIPopoverController alloc] initWithContentViewController:vc];
        [popCount setPopoverContentSize:CGSizeMake(130, 196)];
        [vc release];
    }
    
    UIPickerView *pickerView = (UIPickerView *)[popCount.contentViewController.view viewWithTag:999];
    if  (!pickerView) {
        pickerView = (UIPickerView *)[popCount.contentViewController.view viewWithTag:kPriceTag];
        if (!pickerView) {
            pickerView = (UIPickerView *)[popCount.contentViewController.view viewWithTag:kCountTag];
        }
    }
    pickerView.tag = kCountTag;
    
    int row = (int)fCount;
    int component = (((int)(fCount*10))%10);
    int count3 = (((int)(fCount*100))%10);
    [pickerView selectRow:row inComponent:0 animated:NO];
    [pickerView selectRow:component inComponent:1 animated:NO];
    [pickerView selectRow:count3 inComponent:2 animated:NO];
    [pickerView reloadAllComponents];
}

- (void)priceClicked{
    if (!popCount){
        UIViewController *vc = [[UIViewController alloc] init];
        
        
        
        
        UIPickerView *picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 130, 196)];
        picker.showsSelectionIndicator = YES;
        picker.delegate = self;
        picker.dataSource = self;
        picker.tag = 999;
        [vc.view addSubview:picker];
        [picker release]; 
        
        popCount = [[UIPopoverController alloc] initWithContentViewController:vc];
        [popCount setPopoverContentSize:CGSizeMake(130, 196)];
        [vc release];
    }
    
    UIPickerView *pickerView = (UIPickerView *)[popCount.contentViewController.view viewWithTag:999];
    if  (!pickerView) {
        pickerView = (UIPickerView *)[popCount.contentViewController.view viewWithTag:kCountTag];
        if (!pickerView) {
            pickerView = (UIPickerView *)[popCount.contentViewController.view viewWithTag:kPriceTag];
        }
    }
    pickerView.tag = kPriceTag;
    
    
    int row = (int)fPrice;
    int component = (((int)(fPrice*10))%10);
    int count3 = (((int)(fPrice*100))%10);
    [pickerView selectRow:row inComponent:0 animated:NO];
    [pickerView selectRow:component inComponent:1 animated:NO];
    [pickerView selectRow:count3 inComponent:2 animated:NO];
    [pickerView reloadAllComponents];
//    [popCount presentPopoverFromRect:btnPrice.frame inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

#pragma mark UIPickerView Delegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [NSString stringWithFormat:@"%d",row];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (kCountTag==pickerView.tag)
        return 0==component?100:10;
    else
        return 0==component?1000:10;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    return 0==component?50:30;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    float value;
    int index0 = [pickerView selectedRowInComponent:0];
    int index1 = [pickerView selectedRowInComponent:1];
    int index2 = [pickerView selectedRowInComponent:2];
    
    value = index0+(float)index1*0.1f+(float)index2*0.01f;
    
    
    if (kCountTag==pickerView.tag){
        fCount = value;
        tfCount.text = [NSString stringWithFormat:@"%.2f",fCount];
        lblTotalPrice.text = [NSString stringWithFormat:@"%.2f",fPrice*fCount];
        [delegate cell:self countChanged:fCount];
    }
    else{
        fPrice = value;
        tfPrice.text = [NSString stringWithFormat:@"%.2f",fPrice];
        lblTotalPrice.text = [NSString stringWithFormat:@"%.2f",fPrice*fCount];
        [delegate cell:self priceChanged:fPrice];
    }
    
}


- (void)addCustiomAddition{
    if ([barAddition.text length]>0){
        for (NSDictionary *dic in aryCustomAddition){
            if ([[dic objectForKey:@"DES"] isEqualToString:barAddition.text])
                return;
        }
        NSDictionary *dicToAdd = [NSDictionary dictionaryWithObjectsAndKeys:barAddition.text,@"DES",@"0.0",@"PRICE1", nil];
        [aryCustomAddition addObject:dicToAdd];
        
        [arySearchMatched removeAllObjects];
        [arySearchMatched addObjectsFromArray:aryCustomAddition];
        [arySearchMatched addObjectsFromArray:aryAdditions];
        barAddition.text = nil;
        
        [tvAddition reloadData];
        
        NSMutableArray *aryAll = [NSMutableArray arrayWithArray:arySelectedAdditions];
        [aryAll addObjectsFromArray:aryCustomAddition];
        
        NSMutableDictionary *dictNew = [NSMutableDictionary dictionaryWithDictionary:self.dicInfo];
        if ([aryAll count]>0)
            [dictNew setObject:aryAll forKey:@"addition"];
        else
            [dictNew removeObjectForKey:@"addition"];
        
        [delegate cell:self additionChanged:aryAll];
        
   //     [tvAddition reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark SearchBarDelegate
NSInteger intSort4(id num1,id num2,void *context){
    int v1 = [[(NSDictionary *)num1 objectForKey:@"ITCODE"] intValue];
    int v2 = [[(NSDictionary *)num2 objectForKey:@"ITCODE"] intValue];
    
    if (v1 < v2)
        return NSOrderedAscending;
    else if (v1 > v2)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if ([searchText length]>0){
        searchText = [searchText uppercaseString];

        
        NSArray *ary = [NSArray arrayWithArray:aryAdditions];
        
        // clean buffer after
        self.arySearchMatched = [NSMutableArray array];

        int count = [ary count];
        for (int i=0;i<count;i++){
            NSDictionary *dic = [ary objectAtIndex:i];
            
            NSString *strITCODE = [[dic objectForKey:@"ITCODE"] uppercaseString];
            NSString *strINIT = [[dic objectForKey:@"INIT"] uppercaseString];
            NSString *strDES = [dic objectForKey:@"DES"];
            if ([strITCODE rangeOfString:searchText].location!=NSNotFound ||
                [strINIT rangeOfString:searchText].location!=NSNotFound ||
                [strDES rangeOfString:searchText].location!=NSNotFound){
                [arySearchMatched addObject:dic];
            }
        }
        self.arySearchMatched = [NSMutableArray arrayWithArray:[arySearchMatched sortedArrayUsingFunction:intSort4 context:NULL]];
        
        for (int i=aryCustomAddition.count-1;i>=0;i--)
            [arySearchMatched insertObject:[aryCustomAddition objectAtIndex:i] atIndex:0];
//        NSArray *aryCustom = [self.dicInfo objectForKey:@"addition"];
//        
//        int j=0;
//        for (NSDictionary *dic in aryCustom){
//            if (![dic objectForKey:@"ITCODE"])
//                j++;
//        }
        
//        if (bJump)
//            [tvAddition scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:dJump+j inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    else{
        self.arySearchMatched = [NSMutableArray arrayWithArray:aryAdditions];
        
        self.arySearchMatched = [NSMutableArray arrayWithArray:[arySearchMatched sortedArrayUsingFunction:intSort4 context:NULL]];
        
        for (int i=aryCustomAddition.count-1;i>=0;i--)
            [arySearchMatched insertObject:[aryCustomAddition objectAtIndex:i] atIndex:0];
    }
    [tvAddition reloadData];

}


- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar{
    [self performSelector:@selector(addCustiomAddition)];
}


- (void)deleteSelf{
    [delegate cell:self countChanged:0];
}

#pragma mark -
#pragma mark Changed Unit
- (void)changeUnit{
    [delegate unitOfCellChanged:self];
}



#pragma mark -  UITextField Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *point = @"•。.";
    NSString *number = @"1234567890";
    NSRange pointrange = [point rangeOfString:string];
    NSRange numberrange = [number rangeOfString:string];
    
    NSArray *ary = [textField.text componentsSeparatedByString:@"."];
    if (ary.count==2){
        NSString *back = [ary objectAtIndex:1];
        if ([back length]>=2 && ![string isEqualToString:@""])
            return NO;
    }else if (1==ary.count){
        if (textField.text.length>=5 && ![string isEqualToString:@""] && pointrange.location==NSNotFound)
            return NO;
    }
    
    if (pointrange.location!=NSNotFound){
        NSRange pointrange0 = [textField.text rangeOfString:@"."];
        if (pointrange0.location==NSNotFound)
            textField.text = [textField.text stringByAppendingString:@"."];
        
        return NO;
    }else if (numberrange.location!=NSNotFound){
        return YES;
    }else if ([string isEqualToString:@""])
        return YES;
    
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if ([(NSObject *)delegate respondsToSelector:@selector(endEditting:)]);
        [delegate endEditting:self];
    if (textField.text.floatValue>0){
        float value;
        value = textField.text.floatValue;
        
        if (tfCount==textField){
            fCount = value;
            tfCount.text = [NSString stringWithFormat:@"%.2f",fCount];
            lblTotalPrice.text = [NSString stringWithFormat:@"%.2f",fPrice*fCount];
            [delegate cell:self countChanged:fCount];
        }else if (tfPrice==textField){
            fPrice = value;
            tfPrice.text = [NSString stringWithFormat:@"%.2f",fPrice];
            lblTotalPrice.text = [NSString stringWithFormat:@"%.2f",fPrice*fCount];
            [delegate cell:self priceChanged:fPrice];
        }
    }else{
        if (tfCount==textField)
            tfCount.text = [NSString stringWithFormat:@"%.2f",fCount];
        else if (tfPrice==textField)
            tfPrice.text = [NSString stringWithFormat:@"%.2f",fPrice];
    }
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if ([(NSObject *)delegate respondsToSelector:@selector(beingEditting:)]);
        [delegate beingEditting:self];
}
@end
