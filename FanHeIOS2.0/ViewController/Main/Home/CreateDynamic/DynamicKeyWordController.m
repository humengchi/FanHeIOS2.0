//
//  DynamicKeyWordController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/2/23.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "DynamicKeyWordController.h"

@interface DynamicKeyWordController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic, weak) IBOutlet UIButton *commitBtn;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *searchArray;

@end

@implementation DynamicKeyWordController

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kTableViewBgColor;
    self.dataArray = [NSMutableArray array];
    self.searchArray = [NSMutableArray array];
    //确定是水平滚动，还是垂直滚动
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:
     UICollectionViewScrollDirectionVertical];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame: CGRectMake(10, 115, WIDTH-20, HEIGHT-115) collectionViewLayout:flowLayout];
    self.collectionView.dataSource=self;
    self.collectionView.delegate=self;
    [self.collectionView setBackgroundColor:kTableViewBgColor];
    
    //注册Cell，必须要有
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"myHeaderView"];
    [self.view addSubview:self.collectionView];
    
    [self loadData];
    
    [self initTableView:CGRectMake(0, 115, WIDTH, HEIGHT-112)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.hidden = YES;
}

#pragma mark - method
- (IBAction)customNavBackButtonClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)rightButtonClicked:(id)sender{
    if(self.DynamicKeyWord){
        self.DynamicKeyWord(self.textField.text);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 标签网络请求
- (void)loadData{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [self requstType:RequestType_Get apiName:API_NAME_GET_DYNAMIC_GET_KYWORD paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            weakSelf.dataArray = [[CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]] mutableCopy];
            [weakSelf.collectionView reloadData];
        }else{
            [MBProgressHUD showError:[responseObject objectForKey:@"msg"] toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

#pragma mark - 搜说关键字
- (void)getKeyWordHttpData:(NSString*)searchStr{
    __weak typeof(self) weakSelf = self;
    
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@",searchStr] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_DYNAMIC_SEARCH_KYWORD paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            weakSelf.searchArray = [[CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]] mutableCopy];
            [weakSelf.tableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    UITextRange *selectedRange = [textField markedTextRange];
    UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
    if(string.length&&![NSHelper justChinessAndEnlish:string]){
        return NO;
    }
    if(position && (range.length==0 || string.length==0)){
        return YES;
    }else{
        NSString *str = [textField.text stringByReplacingCharactersInRange:NSMakeRange(range.location, range.length) withString:string];
        if(str.length>10){
            self.textField.text = [str substringToIndex:10];
        }
        [self.searchArray removeAllObjects];
        [self.tableView reloadData];
        [self getKeyWordHttpData:str];
        self.tableView.hidden = str.length==0;
        self.commitBtn.enabled = string.length>0;
    }
    return YES;
}

#pragma mark--UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.searchArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 52;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    cell.textLabel.textColor = KTextColor;
    cell.textLabel.font = FONT_SYSTEM_SIZE(14);
    [self setLabelText:self.searchArray[indexPath.row] searchText:self.textField.text color:@"818C9E" font:14 label:cell.textLabel];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *tagStr = self.searchArray[indexPath.row];
    if(self.DynamicKeyWord){
        self.DynamicKeyWord(tagStr);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setLabelText:(NSString*)text searchText:(NSString*)searchText color:(NSString*)color font:(CGFloat)font label:(UILabel*)label{
    NSMutableAttributedString *atr = [[NSMutableAttributedString alloc] initWithString:text];
    [atr setAttributes:@{NSFontAttributeName:FONT_SYSTEM_SIZE(font), NSForegroundColorAttributeName:HEX_COLOR(color)} range:NSMakeRange(0, text.length)];
    
    for(NSString *str in [searchText lowercaseString].componentsSeparated){
        NSRange range = [text rangeOfString:str];
        [atr setAttributes:@{NSFontAttributeName:FONT_SYSTEM_SIZE(font), NSForegroundColorAttributeName:kDefaultColor} range:range];
    }
    for(NSString *str in [searchText uppercaseString].componentsSeparated){
        NSRange range = [text rangeOfString:str];
        [atr setAttributes:@{NSFontAttributeName:FONT_SYSTEM_SIZE(font), NSForegroundColorAttributeName:kDefaultColor} range:range];
    }
    label.attributedText = atr;
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
    return self.dataArray.count;
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
    NSString *tagStr = [NSString stringWithFormat:@"#%@#",self.dataArray[indexPath.row]];
    CGFloat strWidth = [NSHelper widthOfString:tagStr font:FONT_SYSTEM_SIZE(13) height:29];
    strWidth = (WIDTH-80)/3.0;
    UILabel *label = [UILabel createrLabelframe:CGRectMake(0, 0, strWidth, 29) backColor:WHITE_COLOR textColor:HEX_COLOR(@"41464E") test:tagStr font:13 number:1 nstextLocat:NSTextAlignmentCenter];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [CALayer updateControlLayer:label.layer radius:3 borderWidth:.5 borderColor:HEX_COLOR(@"afb6c1").CGColor];
    [cell.contentView addSubview:label];
    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个Item 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((WIDTH-80)/3.0, 29);
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(15, 10, 15, 10);
}

#pragma mark --UICollectionViewDelegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *tagStr = self.dataArray[indexPath.row];
    if(self.DynamicKeyWord){
        self.DynamicKeyWord(tagStr);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
