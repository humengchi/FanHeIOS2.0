//
//  HonorListViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/7/19.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "HonorListViewController.h"
#import "HonorEditViewController.h"

@interface HonorListViewController ()

@property (nonatomic, weak) IBOutlet UIButton *addBtn;

@end

@implementation HonorListViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark - method
- (IBAction)navBackButtonClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addButtonClicked:(id)sender{
    HonorEditViewController *vc = [CommonMethod getVCFromNib:[HonorEditViewController class]];
    vc.honorEditSuccess = ^(HONOR_TYPE type, HonorModel *model) {
        [self.honorArray addObject:model];
        [self.tableView reloadData];
        if(self.honorListChange){
            self.honorListChange(self.honorArray);
        }
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)editButtonClicked:(UIButton*)sender{
    __weak typeof(self) weakSelf = self;
    HonorEditViewController *vc = [CommonMethod getVCFromNib:[HonorEditViewController class]];
    vc.model = self.honorArray[sender.tag];
    vc.honorEditSuccess = ^(HONOR_TYPE type, HonorModel *model) {
        int count = weakSelf.honorArray.count;
        for(int i=0; i<count; i++){
            HonorModel *honorModel = weakSelf.honorArray[i];
            if(honorModel.honorid.integerValue == model.honorid.integerValue){
                if(type == HONOR_TYPE_DELETE){
                    [weakSelf.honorArray removeObject:model];
                }else{
                    honorModel.honor = model.honor;
                }
                break;
            }
        }
        [self.tableView reloadData];
        if(self.honorListChange){
            self.honorListChange(self.honorArray);
        }
    };
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDelegate/datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.honorArray.count){
        return self.honorArray.count;
    }else{
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.honorArray.count){
        HonorModel *model = self.honorArray[indexPath.row];
        NSString *honorStr = model.honor;
        CGFloat height = (NSInteger)[NSHelper heightOfString:honorStr font:FONT_SYSTEM_SIZE(17) width:WIDTH-63]+37;
        return height;
    }else{
        return HEIGHT-64;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    for(UIView *view in cell.contentView.subviews){
        [view removeFromSuperview];
    }
    if(self.honorArray.count){
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 5)];
        lineLabel.backgroundColor = kTableViewBgColor;
        [cell.contentView addSubview:lineLabel];
        
        HonorModel *model = self.honorArray[indexPath.row];
        NSString *honorStr = model.honor;
        CGFloat height = (NSInteger)[NSHelper heightOfString:honorStr font:FONT_SYSTEM_SIZE(17) width:WIDTH-63]+1;
        UILabel *label = [UILabel createrLabelframe:CGRectMake(16, 22, WIDTH-63, height) backColor:WHITE_COLOR textColor:HEX_COLOR(@"41464e") test:honorStr font:17 number:1 nstextLocat:NSTextAlignmentLeft];
        label.numberOfLines = 0;
        [cell.contentView addSubview:label];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.titleLabel.font = FONT_SYSTEM_SIZE(17);
        btn.tag = indexPath.row;
        btn.frame = CGRectMake(WIDTH-47, 8, 47, 47);
        [btn setImage:kImageWithName(@"btn_myindex_editgrey") forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(editButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btn];
        cell.backgroundColor = WHITE_COLOR;
    }else{
        UILabel *label = [UILabel createrLabelframe:CGRectMake(0, self.tableView.frame.size.height/2-34, WIDTH, 17) backColor:kTableViewBgColor textColor:HEX_COLOR(@"818c9e") test:@"秀出自己的荣誉、事例" font:17 number:1 nstextLocat:NSTextAlignmentCenter];
        [cell.contentView addSubview:label];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.titleLabel.font = FONT_SYSTEM_SIZE(17);
        btn.frame = CGRectMake((WIDTH-118)/2, self.tableView.frame.size.height/2, 118, 40);
        [btn setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
        [btn setBackgroundImage:kImageWithName(@"btn_rm_off_red") forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(addButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitle:@"添加荣誉" forState:UIControlStateNormal];
        [cell.contentView addSubview:btn];
        cell.backgroundColor = kTableViewBgColor;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
