//
//  RegisterJobInputViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/2.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "RegisterJobInputViewController.h"
#import "UICollectionViewLeftAlignedLayout.h"

@interface RegisterJobInputViewController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray   *businessDataArray;

@property (weak, nonatomic) IBOutlet UIButton   *confirmBtn;

@property (nonatomic, strong) NSMutableArray    *dataArray;

@end

@implementation RegisterJobInputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //移除滑动手势
    for (UIPanGestureRecognizer *ges in self.view.gestureRecognizers){
        [self.view removeGestureRecognizer:ges];
    }
    
    self.dataArray = [NSMutableArray array];
    self.businessDataArray = [NSMutableArray array];
    
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self initSearchBar:CGRectMake(40, 20, WIDTH-95, 44)];
    self.searchBar.showsCancelButton = NO;
    [self.searchBar setBackgroundColor:WHITE_COLOR];
    [self.searchBar setBackgroundImage:kImageWithColor(WHITE_COLOR, self.searchBar.bounds)];
    
    
    
    [self.searchBar setSearchFieldBackgroundImage:[kImageWithName(@"searchBackground") imageWithColor:HEX_COLOR(@"E6E8EB")] forState:UIControlStateNormal];
    [self.searchBar setSearchFieldBackgroundImage:[kImageWithName(@"searchBackground") imageWithColor:HEX_COLOR(@"E6E8EB")] forState:UIControlStateDisabled];
    if(self.jobParamType == JOB_PARAM_COMPANY || self.jobParamType == JOB_PARAM_ADDBUSINESS){
        self.searchBar.text = self.comapyStr;
        [self.searchBar setPlaceholder:@" 请输入公司名称"];
        if (self.comapyStr.length) {
            [self searchData];
        }
        
    }else if(self.jobParamType == JOB_PARAM_POSITION){
        self.searchBar.text = self.comapyStr;
        [self.searchBar setPlaceholder:@" 请输入职位名称"];
        if (self.comapyStr.length) {
            [self searchData];
        }
    }else{
        [self.searchBar setPlaceholder:@" 请输入业务名称"];
        [self initCollectionView];
    }
    [self.searchBar becomeFirstResponder];
    
    self.confirmBtn.enabled = self.searchBar.text.length>0;
}

- (void)initCollectionView{
    //确定是水平滚动，还是垂直滚动
    //   UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    //   [flowLayout setScrollDirection:
    //    UICollectionViewScrollDirectionVertical];
    
    UICollectionViewLeftAlignedLayout *flowLayout=[[UICollectionViewLeftAlignedLayout alloc] init];
    [flowLayout setScrollDirection:
     UICollectionViewScrollDirectionVertical];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, WIDTH-0, HEIGHT-64) collectionViewLayout:flowLayout];
    self.collectionView.dataSource=self;
    self.collectionView.delegate=self;
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    
    //注册Cell，必须要有
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"myHeaderView"];
    [self.view addSubview:self.collectionView];
    [self searchData];
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify = @"";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify   ];
    }
    NSString *str = self.dataArray[indexPath.row];
    if(self.jobParamType == JOB_PARAM_BUSINESS){
        str = [NSString stringWithFormat:@"%@", str];
    }
    NSMutableAttributedString *atr = [[NSMutableAttributedString alloc] initWithString:str];
    [atr setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17.0], NSForegroundColorAttributeName:HEX_COLOR(@"41464E")} range:NSMakeRange(0, str.length)];
    NSRange range = [str rangeOfString:self.searchBar.text];
    [atr setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17.0], NSForegroundColorAttributeName:HEX_COLOR(@"E23608")} range:range];
    cell.textLabel.attributedText = atr;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.searchBar.text = self.dataArray[indexPath.row];
    [self confirmButtonClicked:self.confirmBtn];
}

#pragma mark - Keyboard status
- (void)keyboardWillShowOrHide:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect keyboardEnd = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardEnd.size.height;
    [UIView animateWithDuration:duration animations:^{
        if([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
            self.tableView.frame = CGRectMake(0, 64, WIDTH, HEIGHT-64-keyboardHeight);
        }else{
            self.tableView.frame = CGRectMake(0, 64, WIDTH, HEIGHT-64);
        }
    }];
}

#pragma mark -- UICollectionViewDataSource
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(WIDTH,5);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *headView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"myHeaderView" forIndexPath:indexPath];
    for(UIView *view in headView.subviews){
        [view removeFromSuperview];
    }
    return headView;
}

//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.businessDataArray.count;
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
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
    NSString *str = [NSString stringWithFormat:@"%@",self.businessDataArray[indexPath.row]];
    CGFloat strWidth = [NSHelper widthOfString:str font:FONT_SYSTEM_SIZE(17) height:27]+10;
    strWidth = strWidth>(WIDTH-50)/4.0?strWidth:(WIDTH-50)/4.0;;
    UILabel *label = [UILabel createrLabelframe:CGRectMake(0, 0, strWidth, 27) backColor:HEX_COLOR(@"E6E8EB") textColor:KTextColor test:str font:17 number:1 nstextLocat:NSTextAlignmentCenter];
    
    [cell.contentView addSubview:label];
    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个Item 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *str = [NSString stringWithFormat:@"%@",self.businessDataArray[indexPath.row]];
    CGFloat strWidth = [NSHelper widthOfString:str font:FONT_SYSTEM_SIZE(17) height:27]+10;
    strWidth = strWidth>(WIDTH-50)/4.0?strWidth:(WIDTH-50)/4.0;
    return CGSizeMake(strWidth, 27);
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(15, 15, 15, 15);
}

#pragma mark --UICollectionViewDelegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    self.searchBar.text = self.businessDataArray[indexPath.row];
    //    [self searchData];
    if(self.delegate && [self.delegate respondsToSelector:@selector(RegisterJobInputViewControllerDelegateChoiceParam:isCompany:)]){
        [self.delegate RegisterJobInputViewControllerDelegateChoiceParam:self.searchBar.text isCompany:self.jobParamType];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - method
- (IBAction)backNavButtonClicked:(id)sender{
    [self newThreadForAvoidButtonRepeatClick:sender];
    [self.searchBar resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)confirmButtonClicked:(UIButton*)sender{
    [self newThreadForAvoidButtonRepeatClick:sender];
    [self.searchBar resignFirstResponder];
     NSString *strUrl = [self.searchBar.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"%@",strUrl);
    if (strUrl.length == 0) {
         if(self.jobParamType == JOB_PARAM_COMPANY || self.jobParamType == JOB_PARAM_ADDBUSINESS){
            [self showHint:@" 请输入公司名称"];
            return;
        }else if(self.jobParamType == JOB_PARAM_POSITION){
            [self showHint:@" 请输入职位名称"];
            return;
        }else{
            [self showHint:@" 请输入业务名称"];
            return;
        }
    }else{
        if(self.delegate && [self.delegate respondsToSelector:@selector(RegisterJobInputViewControllerDelegateChoiceParam:isCompany:)]){
            if((self.jobParamType == JOB_PARAM_COMPANY || self.jobParamType == JOB_PARAM_ADDBUSINESS) && ![NSHelper justCompany:self.searchBar.text]){
                [MBProgressHUD showError:@"公司只能包含中英文" toView:self.view];
                return;
            }
            if(self.jobParamType == JOB_PARAM_BUSINESS && ![NSHelper justChinessAndEnlish:self.searchBar.text]){
                [MBProgressHUD showError:@"擅长业务只能包含中英文" toView:self.view];
                return;
            }
            if(self.jobParamType==JOB_PARAM_ADDBUSINESS){
                [self.delegate RegisterJobInputViewControllerDelegateChoiceParam:self.searchBar.text isCompany:self.jobParamType];
                [self dismissViewControllerAnimated:YES completion:nil];
                return;
            }

            if((self.jobParamType==JOB_PARAM_COMPANY && [self.searchBar.text isEqualToString:[DataModelInstance shareInstance].userModel.company]) || (self.jobParamType==JOB_PARAM_POSITION && [self.searchBar.text isEqualToString:[DataModelInstance shareInstance].userModel.position])){
                [self.delegate RegisterJobInputViewControllerDelegateChoiceParam:self.searchBar.text isCompany:self.jobParamType];
                [self dismissViewControllerAnimated:YES completion:nil];
                return;
            }
            UserModel *userModel = [DataModelInstance shareInstance].userModel;
            if (userModel.hasValidUser.integerValue == 1) {
                if (self.isWorkHistory != YES) {
                    [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"你修改了关键信息，需重新申请认证。是否需要修改？" cancelButtonTitle:@"确定" otherButtonTitle:@"取消" cancle:^{
                        [self.delegate RegisterJobInputViewControllerDelegateChoiceParam:self.searchBar.text isCompany:self.jobParamType];
                        [self dismissViewControllerAnimated:YES completion:nil];
                    } confirm:^{
                    }];
                }else{
                    [self.delegate RegisterJobInputViewControllerDelegateChoiceParam:self.searchBar.text isCompany:self.jobParamType];
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }else{
                [self.delegate RegisterJobInputViewControllerDelegateChoiceParam:self.searchBar.text isCompany:self.jobParamType];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }
}

- (void)searchData{
    NSString *strUrl = [self.searchBar.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (strUrl.length == 0) {
        if(self.jobParamType == JOB_PARAM_COMPANY || self.jobParamType == JOB_PARAM_ADDBUSINESS){
            [self showHint:@" 请输入公司名称"];
            return;
        }else if(self.jobParamType == JOB_PARAM_POSITION){
            [self showHint:@" 请输入职位名称"];
            return;
        }else{
            [self showHint:@" 请输入业务名称"];
            return;
        }
    }
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    if(self.searchBar.text && self.searchBar.text.length){
        [requestDict setObject:[NSString stringWithFormat:@"/%@",self.searchBar.text] forKey:@"param"];
    }
    NSString *apiStr = @"";
    if(self.jobParamType == JOB_PARAM_COMPANY || self.jobParamType == JOB_PARAM_ADDBUSINESS){
        apiStr = API_NAME_MATCH_PROPERTY_COMPANY;
    }else if(self.jobParamType == JOB_PARAM_POSITION){
        apiStr = API_NAME_MATCH_PROPERTY_POSITION;
    }else{
        apiStr = API_NAME_MATCH_PROPERTY_BUSINESS;
    }
    [self requstType:RequestType_Get apiName:apiStr paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            if(weakSelf.searchBar.text && weakSelf.searchBar.text.length){
                weakSelf.dataArray = [[CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]] mutableCopy];
                [weakSelf.tableView reloadData];
                if(weakSelf.jobParamType == JOB_PARAM_BUSINESS){
                    weakSelf.collectionView.hidden = YES;
                }
            }else{
                weakSelf.businessDataArray = [[CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]] mutableCopy];
                [weakSelf.collectionView reloadData];
            }
        }else{
            [MBProgressHUD showError:[responseObject objectForKey:@"msg"] toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

#pragma mark -- SearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self searchData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if(searchText.length > 0 && searchText.length <= 30){
        [self searchData];
    }else if(searchText.length > 30){
        self.searchBar.text = [searchText substringToIndex:30];
        [MBProgressHUD showError:@"名称不能超过30个字" toView:self.view];
    }else{
        [self.dataArray removeAllObjects];
        [self.tableView reloadData];
        if(self.jobParamType == JOB_PARAM_BUSINESS){
            self.collectionView.hidden = NO;
        }
    }
    self.confirmBtn.enabled = self.searchBar.text.length>0;
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar{
    
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

@end
