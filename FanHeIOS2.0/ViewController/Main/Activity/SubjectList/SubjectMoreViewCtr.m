//
//  SubjectMoreViewCtr.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/5/4.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "SubjectMoreViewCtr.h"
#import "ReportView.h"
@interface SubjectMoreViewCtr ()
@property (nonatomic ,strong) ReportView *reportView;
@end

@implementation SubjectMoreViewCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustomNavigationBar:@"专题活动"];
    [self initScrollView:CGRectMake(0, 64, WIDTH, HEIGHT - 64)];
    self.scrollView.scrollEnabled = YES;
    [self createrMoreTabViewHeaderView];
    // Do any additional setup after loading the view.
}
#pragma mark------- 表示图
- (void)createrMoreTabViewHeaderView{
    self.reportView = [[ReportView alloc]init];
    NSInteger index = self.array.count/4;
    NSInteger col = self.array.count%4;
    if (col > 0) {
        index += 1;
    }
    self.reportView.frame = CGRectMake(0,0, WIDTH, 100*index);
    [self.reportView createrReport:self.array isAllShow:YES];
    [self.scrollView addSubview:self.reportView];
    self.scrollView.contentSize = CGSizeMake(WIDTH, 100*index + 64);
    
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
