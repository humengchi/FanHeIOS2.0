//
//  PersonInterestTagController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/7/20.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "PersonInterestTagController.h"
#import "ULBCollectionViewFlowLayout.h"

@interface PersonInterestTagController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ULBCollectionViewDelegateFlowLayout, UIAlertViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UICollectionView  *collectionView;
@property (nonatomic, strong) NSMutableArray    *recommendArray;

@property (weak, nonatomic) IBOutlet UILabel    *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton   *publishBtn;

@end

@implementation PersonInterestTagController

- (void)viewDidLoad {
    [super viewDidLoad];
    //移除滑动手势
    for (UIPanGestureRecognizer *ges in self.view.gestureRecognizers){
        [self.view removeGestureRecognizer:ges];
    }
    if(self.isSelfTag){
        self.titleLabel.text = @"个人标签";
    }else{
        self.titleLabel.text = @"兴趣标签";
    }
    if(self.dataArray==nil){
        self.dataArray = [NSMutableArray array];
    }
    self.recommendArray = [NSMutableArray arrayWithObjects:@"旅行", @"阅读", @"社交", @"摄影", @"篮球", @"足球", @"羽毛球", @"健身", @"徒步", @"音乐", @"购物", @"美食", @"吉他", @"影视", @"扑克", @"聚会", nil];
    
//    self.publishBtn.enabled = self.dataArray.count>0;
    
    [self initCollectionView];
}

- (void)initCollectionView{
    //确定是水平滚动，还是垂直滚动
    ULBCollectionViewFlowLayout *flowLayout=[[ULBCollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, WIDTH-0, HEIGHT-64) collectionViewLayout:flowLayout];
    self.collectionView.dataSource=self;
    self.collectionView.delegate=self;
    [self.collectionView setBackgroundColor:kTableViewBgColor];
    
    //注册Cell，必须要有
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"myHeaderView"];
    [self.view addSubview:self.collectionView];
}


#pragma mark - method
- (IBAction)backNavButtonClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)confirmButtonClicked:(UIButton*)sender{
    [self newThreadForAvoidButtonRepeatClick:sender];
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"保存中..." toView:self.view];
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:self.isSelfTag?@(1):@(2) forKey:@"type"];
    [requestDict setObject:[self.dataArray componentsJoinedByString:@","] forKey:@"tag"];
    [self requstType:RequestType_Post apiName:API_NAME_POST_USER_SETMYTAG paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [MBProgressHUD showSuccess:@"保存成功!" toView:weakSelf.view];
            if(weakSelf.saveTagSuccess){
                weakSelf.saveTagSuccess(weakSelf.dataArray);
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
        }else{
            [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

#pragma mark -- UICollectionViewDataSource
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    NSString *str;
    if(self.isSelfTag){
        str = @"添加描述自己的职业、成就的个人标签，让更多人快速认识你";
    }else{
        if(section==0){
            str = @"添加描述自己兴趣、爱好标签，让更多人快速认识你";
        }else{
            str = @"推荐标签";
        }
    }
    CGFloat height = [NSHelper heightOfString:str font:FONT_SYSTEM_SIZE(14) width:WIDTH-32];
    if(height > FONT_SYSTEM_SIZE(14).lineHeight){
        return CGSizeMake(WIDTH, 56);
    }else{
        return CGSizeMake(WIDTH,33);
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *headView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"myHeaderView" forIndexPath:indexPath];
    for(UIView *view in headView.subviews){
        [view removeFromSuperview];
    }
    headView.backgroundColor = kTableViewBgColor;
    UILabel *label = [UILabel createLabel:CGRectMake(16, 10, WIDTH-32, 16) font:FONT_SYSTEM_SIZE(14) bkColor:kTableViewBgColor textColor:HEX_COLOR(@"818c9e")];
    label.numberOfLines = 2;
    NSString *str;
    if(self.isSelfTag){
        str = @"添加描述自己的职业、成就的个人标签，让更多人快速认识你";
    }else{
        if(indexPath.section==0){
            str = @"添加描述自己兴趣、爱好标签，让更多人快速认识你";
        }else{
            str = @"推荐标签";
        }
    }
    CGFloat height = [NSHelper heightOfString:str font:FONT_SYSTEM_SIZE(14) width:WIDTH-32];
    if(height > FONT_SYSTEM_SIZE(14).lineHeight){
        label.frame = CGRectMake(16, 5, WIDTH-32, 46);
        [label setParagraphText:str lineSpace:9];
    }else{
        label.frame = CGRectMake(16, 10, WIDTH-32, 14);
        label.text = str;
    }
    [headView addSubview:label];
    return headView;
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    if(self.isSelfTag){
        return 1;
    }else{
        return 2;
    }
}

//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(section==0){
//        self.publishBtn.enabled = self.dataArray.count>0;
        return self.dataArray.count+1;
    }else{
        return self.recommendArray.count;
    }
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * CellIdentifier = @"UICollectionViewCell";
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    for(UIGestureRecognizer *gesture in cell.gestureRecognizers){
        [cell removeGestureRecognizer:gesture];
    }
    for(UIView *view in cell.contentView.subviews){
        [view removeFromSuperview];
    }
    NSString *str;
    NSString *textColor = @"";
    NSString *bgColor = @"";
    NSString *borderColor = @"";
    if(indexPath.section==0){
        if(indexPath.row<self.dataArray.count){
            if(self.isSelfTag){
                textColor = @"1abc9c";
                bgColor = @"ffffff";
                borderColor = @"1abc9c";
            }else{
                textColor = @"3498db";
                bgColor = @"ffffff";
                borderColor = @"3498db";
            }
            str = [NSString stringWithFormat:@"%@",self.dataArray[indexPath.row]];
        }else{
            if(self.isSelfTag){
                str = @"输入个人标签";
                textColor = @"ffffff";
                bgColor = @"1abc9c";
                borderColor = @"1abc9c";
            }else{
                str = @"输入兴趣标签";
                textColor = @"ffffff";
                bgColor = @"3498db";
                borderColor = @"3498db";
            }
        }
    }else{
        str = [NSString stringWithFormat:@"%@",self.recommendArray[indexPath.row]];
        if([self.dataArray containsObject:str]){
            textColor = @"3498db";
            bgColor = @"ffffff";
            borderColor = @"3498db";
        }else{
            textColor = @"818c9e";
            bgColor = @"ffffff";
            borderColor = @"818c9e";
        }
    }
    CGFloat strWidth = [NSHelper widthOfString:str font:FONT_SYSTEM_SIZE(13) height:29]+15;
    strWidth = strWidth<(WIDTH-32)?strWidth:(WIDTH-32);
    UILabel *label = [UILabel createrLabelframe:CGRectMake(0, 0, strWidth, 29) backColor:HEX_COLOR(bgColor) textColor:HEX_COLOR(textColor) test:str font:13 number:1 nstextLocat:NSTextAlignmentCenter];
    [CALayer updateControlLayer:label.layer radius:2 borderWidth:0.5 borderColor:HEX_COLOR(borderColor).CGColor];
    [cell.contentView addSubview:label];
    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个Item 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *str;
    if(indexPath.section==0){
        if(indexPath.row<self.dataArray.count){
            str = [NSString stringWithFormat:@"%@",self.dataArray[indexPath.row]];
        }else{
            if(self.isSelfTag){
                str = @"输入个人标签";
            }else{
                str = @"输入兴趣标签";
            }
        }
    }else{
        str = [NSString stringWithFormat:@"%@",self.recommendArray[indexPath.row]];
    }
    CGFloat strWidth = [NSHelper widthOfString:str font:FONT_SYSTEM_SIZE(13) height:29]+15;
    strWidth = (strWidth<(WIDTH-32))?strWidth:(WIDTH-32);
    return CGSizeMake(strWidth, 27);
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(15, 15, 15, 15);
}

//这个是两行cell之间的间距（上下行cell的间距）
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 8;
}

//两个cell之间的间距（同一行的cell的间距）
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 8;
}

- (UIColor *)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout colorForSectionAtIndex:(NSInteger)section{
    return WHITE_COLOR;
}

#pragma mark --UICollectionViewDelegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==0){
        if(indexPath.row < self.dataArray.count){
            [self.dataArray removeObjectAtIndex:indexPath.row];
            [self.collectionView reloadData];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:self.isSelfTag?@"请填写个人标签，最长10个汉字":@"请填写兴趣标签，最长10个汉字" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
            UITextField *textField = [alert textFieldAtIndex:0];
            textField.delegate = self;
            textField.placeholder = @"输入标签";
            textField.returnKeyType = UIReturnKeyDone;
            [alert show];
        }
    }else{
        NSString *tag = self.recommendArray[indexPath.row];
        if(![self.dataArray containsObject:tag]){
            [self.dataArray addObject:tag];
            [self.collectionView reloadData];
        }
    }
}

#pragma mark -UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    UITextField *textField = [alertView textFieldAtIndex:0];
    if(buttonIndex==1 && textField.text.length){
        if(![self.dataArray containsObject:textField.text]){
            [self.dataArray addObject:textField.text];
            [self.collectionView reloadData];
        }else{
            [self.view showToastMessage:@"标签内容重复"];
        }
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    UITextRange *selectedRange = [textField markedTextRange];
    UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
    if(position && (range.length==0 || string.length==0)){
        return YES;
    }else{
        NSString *str = [textField.text stringByReplacingCharactersInRange:NSMakeRange(range.location, range.length) withString:string];
        if(str.length>10){
            textField.text = [str substringToIndex:10];
            return NO;
        }
    }
    return YES;
}
@end
