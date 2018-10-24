//
//  GuestsAppayController.m
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/15.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "GuestsAppayController.h"

@interface GuestsAppayController ()

@end

@implementation GuestsAppayController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustomNavigationBar:@"嘉宾报名"];
    [self initScrollView:CGRectMake(0, 64, WIDTH, HEIGHT - 64)];
    UILabel *backLabel = [UILabel createLabel:CGRectMake(0, 0, WIDTH, 5) font:[UIFont systemFontOfSize:0] bkColor:[UIColor colorWithHexString:@"EFEFF4"] textColor:[UIColor whiteColor]];
    
    [self.scrollView addSubview:backLabel];
    UILabel *titleLabel = [UILabel createLabel:CGRectMake(0, 21, WIDTH, 20) font:[UIFont boldSystemFontOfSize:18] bkColor:[UIColor whiteColor] textColor:[UIColor blackColor]];
    titleLabel.text = @"关于我们";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.scrollView addSubview:titleLabel];
    UILabel *lineLabel = [UILabel createLabel:CGRectMake(16, 75, WIDTH - 32, 1) font:nil bkColor:[UIColor grayColor] textColor:[UIColor whiteColor]];
    [self.scrollView addSubview:lineLabel];
    NSString *sideStr = @"  《“大家”聊金融》是泛合金融咖啡俱乐部推出的金融类人物访谈栏目，本栏目直击金融行业热点话题，关注最新市场动态，引导行业政策导向，把握市场发展先机。通过面对面的交流方式，走进金融业领袖人物及企业高层的思想维度，凝炼各领域真知灼见，我们将与众多业界人士一起倾听您对行业、公司的看法，领略您的经验分享智慧。\n \n  本栏目旨在为金融行业人事提供观点交流、经验分享的平台，您可以就您擅长的金融领域相关话题畅谈，我们将为您提供最专业的报道内容以供金融业同行分享、学习。";
    CGFloat heigth = [NSHelper heightOfString:sideStr font:[UIFont systemFontOfSize:14] width:WIDTH - 32];
    UILabel *sideLabel = [UILabel createLabel:CGRectMake(16, 60, WIDTH - 32, heigth) font:[UIFont systemFontOfSize:14] bkColor:[UIColor whiteColor] textColor:[UIColor colorWithHexString:@"41464E"]];
    sideLabel.numberOfLines = 0;
    sideLabel.text = sideStr;
    [self.scrollView addSubview:sideLabel];
    CGFloat concentHeigth = sideLabel.frame.size.height + sideLabel.frame.origin.y;
    UILabel *secndlineLabel = [UILabel createLabel:CGRectMake(0, concentHeigth + 15, WIDTH , 5) font:nil bkColor:[UIColor colorWithHexString:@"EFEFF4"] textColor:[UIColor whiteColor]];
    
    [self.scrollView addSubview:secndlineLabel];
    
    concentHeigth = concentHeigth+20;
    //
    UILabel *conterLabel = [UILabel createLabel:CGRectMake(0, concentHeigth + 16, WIDTH, 12) font:[UIFont boldSystemFontOfSize:18] bkColor:[UIColor whiteColor] textColor:[UIColor colorWithHexString:@"41464E"]];
    conterLabel.textAlignment = NSTextAlignmentCenter;
    conterLabel.text = @"联系我们";
    [self.scrollView addSubview:conterLabel];
    concentHeigth = concentHeigth + 56;
    
    
    NSArray *phoneArray = @[@"栏目热线：021-65250002 转 810",@"联系人：Tim",@"邮箱：public@51jinmai.com"];
    for (NSInteger i = 0; i < phoneArray.count ; i++) {
        UILabel *phoneLabel = [UILabel createLabel:CGRectMake(16, concentHeigth + (14+9)*i, WIDTH - 32, 14) font:[UIFont systemFontOfSize:14] bkColor:[UIColor whiteColor] textColor:[UIColor colorWithHexString:@"818C9E"]];
        phoneLabel.userInteractionEnabled = YES;
        phoneLabel.tag = i;
        UITapGestureRecognizer *tapPhone = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(takePhoneAction:)];
        [phoneLabel addGestureRecognizer:tapPhone];
        [self.scrollView addSubview:phoneLabel];
        if (i == 0) {
            phoneLabel.attributedText = [self tranferStrPhone:phoneArray[i] length:5];
        }
        if (i == 1) {
            phoneLabel.attributedText = [self tranferStr:phoneArray[i] length:4];
        }
        if (i == 2) {
            phoneLabel.attributedText = [self tranferStr:phoneArray[i] length:3];
        }
    }
    concentHeigth =   concentHeigth + (14+9)*3+6;
    UIView *backView = [NSHelper createrViewFrame:CGRectMake(0, concentHeigth, WIDTH, HEIGHT - concentHeigth) backColor:@"EFEFF4"];
    [self.scrollView addSubview:backView];
    
}
- (void)takePhoneAction:(UITapGestureRecognizer *)g{
    NSInteger index = g.view.tag;
    if (index == 0) {
        NSString *str = [NSString stringWithFormat:@"tel:%@",@"021-65250002,810"];
        UIWebView *callWebView = [[UIWebView alloc]init];
        [callWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
        [self.view addSubview:callWebView];//也可以不加到页面上
    }
    if (index == 2) {
        [MBProgressHUD showSuccess:@"复制成功" toView:nil];
        NSString *contentUrl = [NSString stringWithFormat:@"%@",@"public@51jinmai.com"];
        UIPasteboard *generalPasteBoard = [UIPasteboard generalPasteboard];
        [generalPasteBoard setString:contentUrl];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSMutableAttributedString *)tranferStr:(NSString *)str length:(NSInteger)length{
    NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:str];
    if (str.length < 10) {
        [AttributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"41464E"] range:NSMakeRange(length, str.length - length)];
    }else{
        [AttributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"4393E2"] range:NSMakeRange(length, str.length - length)];
    }
    return AttributedStr;
}
- (NSMutableAttributedString *)tranferStrPhone:(NSString *)str length:(NSInteger)length{
    NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:str];
    [AttributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"4393E2"] range:NSMakeRange(length, str.length - length)];
    [AttributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"41464E"] range:NSMakeRange(str.length - 5,5)];
    return AttributedStr;
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
