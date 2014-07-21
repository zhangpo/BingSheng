//
//  BSLogCell.h
//  BookSystem
//
//  Created by Dream on 11-5-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kPriceTag       700
#define kCountTag       701
#define kNoPhotoOffset  60.0f
@class BSLogCell;

@protocol  BSLogCellDelegate

- (void)cell:(BSLogCell *)cell countChanged:(float)count;
- (void)cell:(BSLogCell *)cell priceChanged:(float)price;
- (void)cell:(BSLogCell *)cell additionChanged:(NSMutableArray *)additons;
- (void)unitOfCellChanged:(BSLogCell *)cell;
- (void)beingEditting:(BSLogCell *)cell;
- (void)endEditting:(BSLogCell *)cell;
- (void)cell:(BSLogCell *)cell selectFood:(NSInteger)flag;

@end

@interface BSLogCell : UITableViewCell <UITableViewDelegate,UITableViewDataSource,UIPickerViewDelegate,UIPickerViewDataSource,UIAlertViewDelegate,UISearchBarDelegate,UITextFieldDelegate>{
    UIImageView *imgvFood;
    UILabel *lblName,*lblTotalPrice,*lblAddition,*lblAdditionPrice,*lblUnit;
    UIButton *btnAdd,*btnReduce,*btnEdit,*btnDelete,*btnDetail;
    UITextField *tfCount,*tfPrice;
 //   UITextField *tfAddition;
    UISearchBar *barAddition;
    UIView *vAddition;
    UITableView *tvAddition;
    UILabel *lblSelected;
    
    id<BSLogCellDelegate> delegate;
    
    float fCount,fPrice;
    
    BOOL bSelected;
    
    NSDictionary *dicInfo;
    UIPopoverController *pop,*popCount;
    
    
    NSArray *aryAdditions;
    NSMutableArray *arySelectedAdditions,*aryCustomAddition;
    NSMutableArray *arySearchMatched;
    
//    UIButton *butSelect;
    UIButton *butBacSelect;
//    BOOL butSelect_dh;
    
}
@property BOOL bSelected;
@property BOOL butSelect_dh;
@property (nonatomic,assign)UIButton *butSelect;
@property (nonatomic,assign) id<BSLogCellDelegate> delegate;
@property float fCount;
@property (nonatomic,retain) NSDictionary *dicInfo;
@property (nonatomic,assign) UILabel *lblAdditionPrice,*lblUnit;
@property (nonatomic,assign) UITextField *tfPrice;
@property (nonatomic,retain) NSArray *aryAdditions;
@property (nonatomic,retain) NSMutableArray *arySelectedAdditions,*aryCustomAddition,*arySearchMatched;
- (void)setInfo:(NSDictionary *)info;
@property (nonatomic,strong) NSIndexPath *indexPath;

@end
