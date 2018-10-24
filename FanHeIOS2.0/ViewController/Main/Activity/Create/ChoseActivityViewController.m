//
//  ChoseActivityViewController.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/5/10.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ChoseActivityViewController.h"

@interface ChoseActivityViewController ()
@property (nonatomic ,strong) UIButton *searchBt;
@property (nonatomic ,strong) NSMutableArray *choseArray;
@property (nonatomic ,strong) UIView *timeBackView;
@property (nonatomic ,strong) UIView *moneyBackView;
@property (nonatomic ,strong) NSMutableArray *titleArray;
@end

@implementation ChoseActivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleArray = [NSMutableArray arrayWithArray:self.actSelectedTagArray];
    [self createCustomNavigationBar:@"活动标签"];
    [self createNavBarButtonItemsTagActivity];
    self.choseArray = [NSMutableArray new];
    //智能筛选
    for (NSDictionary *dic  in [DataModelInstance shareInstance].userModel.capacityArray) {
        NSString *name = dic[@"name"];
        NSMutableArray *titleArray  = [NSMutableArray new];
        NSArray *dicArray = dic[@"childtag"];
        
        for (NSDictionary *subDic in dicArray) {
            ReportModel *model = [[ReportModel alloc]init];
            model.postid = subDic[@"id"];
            model.title = subDic[@"name"];
            [titleArray addObject:model];
        }
        NSDictionary *dic = @{name:titleArray};
        [self.choseArray addObject:dic];
    }
    [self createrV];

}
//导航栏右边按钮
- (void)createNavBarButtonItemsTagActivity{
    self.searchBt = [UIButton buttonWithType:UIButtonTypeCustom];
    self.searchBt.frame = CGRectMake(WIDTH - 60, 20, 50, 40);
    [self.searchBt setTitle:@"确定" forState:UIControlStateNormal];
    [self.searchBt setTitleColor:[UIColor colorWithHexString:@"E6E8EB"] forState:UIControlStateNormal];
    self.searchBt.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [self.searchBt setTitleColor:[UIColor colorWithHexString:@"E24943"] forState:UIControlStateSelected];
    [self.searchBt addTarget:self action:@selector(gotoSearchButtonClickedActivity:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.searchBt];
}
- (void)gotoSearchButtonClickedActivity:(UIButton *)btn{
    
    if(self.titleArray){
        self.activitySeletedTagsStr([self.titleArray componentsJoinedByString:@","]);
    }
    [self.navigationController popViewControllerAnimated:YES];

}
- (void)createrV{
    UIScrollView *scrooleView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, WIDTH, HEIGHT - 64)];
    UIView *backViewGeader = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 50)];
    backViewGeader.backgroundColor = [UIColor whiteColor];
    
    
    UILabel *label = [UILabel createLabel:CGRectMake(16, 16, WIDTH - 16, 17) font:[UIFont systemFontOfSize:17] bkColor:[UIColor whiteColor] textColor:[UIColor colorWithHexString:@"41464E"]];
    label.text = @"请为您的活动选择标签:";
    [backViewGeader addSubview:label];
    [self.view addSubview:scrooleView];
    [scrooleView addSubview:backViewGeader];
    NSDictionary *dic = self.choseArray[0];
    NSArray *moneyArray1 = dic[dic.allKeys[0]];
    NSDictionary *dic1 = self.choseArray[1];
    NSArray *moneyArray2 = dic1[dic1.allKeys[0]];
    NSDictionary *dic2 = self.choseArray[2];
    NSArray *moneyArray3 = dic2[dic2.allKeys[0]];
for (NSInteger i = 0; i < self.choseArray.count ; i++) {
    NSDictionary *dic = self.choseArray[i];
    NSArray *moneyArray = dic[dic.allKeys[0]];
    
    CGFloat x = 16;
    CGFloat y = 16;
    CGFloat wideth = (WIDTH - 32 - 42)/3.0;
    CGFloat heigth = 29;
    
    CGFloat backHeigth = 0;
    CGFloat backY = 0;
    CGFloat heigthFrist= 0;
    
    CGFloat cow1 = ceilf(moneyArray1.count/3.0);
      CGFloat heigth1 = cow1*(heigth + y) + 32;
    
        CGFloat cow2 = ceilf(moneyArray2.count/3.0);
        CGFloat heigth2 = cow2*(heigth + y) + 32;
   
        CGFloat cow3 =  ceilf(moneyArray3.count/3.0);
         CGFloat heigth3 = cow3*(heigth + y) + 32;
    if (i == 0) {
        backY = 0;
        backHeigth = heigth1 + 16 ;
        heigthFrist = heigth1 + 32;
    }else if(i == 1){
          backY = heigth1 + 16;
         backHeigth = heigth1 + heigth2 + 16;
        heigthFrist = heigth2 + 32;
    }else{
        backY =  heigth1 + heigth2 + 32;
        backHeigth = heigth1 + heigth2+ heigth3 + 16;
        heigthFrist = heigth3 + 16;

    }
    
    scrooleView.contentSize = CGSizeMake(WIDTH, backHeigth + 80);
    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0, backY+50, WIDTH, 32)];
    backView.backgroundColor = [UIColor colorWithHexString:@"EFEFF4"];
    UILabel *titleLabel = [UILabel createLabel:CGRectMake(x, 9, WIDTH - 36,14) font:[UIFont systemFontOfSize:14] bkColor:[UIColor colorWithHexString:@"EFEFF4"] textColor:[UIColor colorWithHexString:@"818C9E"]];
    titleLabel.text = dic.allKeys[0];
    [backView addSubview:titleLabel];
    [scrooleView addSubview:backView];
    
    self.timeBackView = [[UIView alloc]initWithFrame:CGRectMake(0, backY + 32 + 50, WIDTH, heigthFrist)];
    self.timeBackView.backgroundColor = [UIColor whiteColor];
    self.timeBackView.userInteractionEnabled = YES;
    [scrooleView addSubview:self.timeBackView];
     CGFloat start_X = 16;
        for(int i = 0; i < moneyArray.count; i++){
            
            NSInteger col = i/3;
            NSInteger cow = i%3;
            ReportModel *model = moneyArray[i];
            NSString *str = model.title;
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
             btn.frame = CGRectMake((16 + wideth)*cow + start_X, y + (y+29)*col, wideth, 29);
            btn.titleLabel.font = [UIFont systemFontOfSize:13];
            [btn setTitle:str forState:UIControlStateNormal];
            for (NSInteger i = 0; i < self.actSelectedTagArray.count; i++) {
                if ([self.actSelectedTagArray[i] isEqualToString:str]) {
                    btn.selected = YES;
                }
            }
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_hd_sxws"]forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_hd_qd"]forState:UIControlStateSelected];
            
                [btn setTitleColor:HEX_COLOR(@"FFFFFF") forState:UIControlStateSelected];
                [btn setTitleColor:HEX_COLOR(@"41464E") forState:UIControlStateNormal];
            
            [btn addTarget:self action:@selector(choseCityTagSearch:) forControlEvents:UIControlEventTouchUpInside];
           
            [self.timeBackView addSubview:btn];
            
        }
    
    }
   
}
- (void)choseCityTagSearch:(UIButton *)btn{
    if (self.titleArray.count >= 3) {
        NSString *str =    btn.titleLabel.text;
        if ([self.titleArray containsObject:str]) {
            [self.titleArray removeObject:str];
            btn.selected = NO;
        }else{
            [MBProgressHUD showError:@"最多只能选中3个标签" toView:self.view];
            return;
        }
       
    }else{
        NSString *str =    btn.titleLabel.text;
        if ([self.titleArray containsObject:str]) {
            [self.titleArray removeObject:str];
            btn.selected = NO;
        }else{
            [self.titleArray addObject:str];
            btn.selected = YES;
        }
    }
    if(self.titleArray.count > 0){
        self.searchBt.selected = YES;
    }else{
        self.searchBt.selected = NO;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
