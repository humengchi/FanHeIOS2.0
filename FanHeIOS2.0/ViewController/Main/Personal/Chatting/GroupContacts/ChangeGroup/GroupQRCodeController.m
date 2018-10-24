//
//  GroupQRCodeController.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/8/18.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "GroupQRCodeController.h"

@interface GroupQRCodeController ()
@property (nonatomic ,strong)  EMGroup *group;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UIImageView *qcrodeImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;


@end

@implementation GroupQRCodeController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
//    EMError *error = nil;
//    self.group = [[EMClient sharedClient].groupManager getGroupSpecificationFromServerWithId:self.groupID error:&error];
    self.view.backgroundColor = kTableViewBgColor;
    [self createCustomNavigationBar:@"群二维码"];
    [CALayer updateControlLayer:self.coverImageView.layer radius:21 borderWidth:0 borderColor:nil];
    NSLog(@"%@",self.groupID);
    
    self.nameLabel.text = self.group.subject;
   
    self.qcrodeImageView.image = [QRCodeGenerator qrImageForString:[NSString stringWithFormat:@"%@%@",GroupURL, self.groupID] imageSize:self.qcrodeImageView.bounds.size.width];
    
    UIImage *localImage = [UIImage imageWithContentsOfFile:SAVE_GROUP_HEADER_IMAGE(self.groupID)];
    [[EMClient sharedClient].groupManager  getGroupSpecificationFromServerWithId:self.groupID completion:^(EMGroup *aGroup, EMError *aError) {
        self.group = aGroup;
        if(localImage){
            self.coverImageView.image = localImage;
        }else if([CommonMethod paramArrayIsNull:self.group.occupants].count) {
            [self checkFriendsNameAndHeader:self.group];
            
        }

    }];
    
    UIButton *quitBtn =  [NSHelper createButton:CGRectMake(62, HEIGHT - 55, WIDTH - 124, 40) title:@"保存到相册" unSelectImage:[UIImage imageNamed:@""] selectImage:nil target:self selector:@selector(saveImageAction:)];
    [quitBtn setBackgroundImage:[UIImage imageNamed:@"btn_rm_off_red"] forState:UIControlStateNormal];
    [self.view addSubview:quitBtn];
    
    // Do any additional setup after loading the view from its nib.
}
- (void)checkFriendsNameAndHeader:(EMGroup *)group{
    NSArray *array = [CommonMethod paramArrayIsNull:group.occupants];
    if (array.count==0) {
        return;
    }
    [(BaseViewController*)self updateGroupUsersDB:group occupants:group.occupants handler:^(BOOL result, NSMutableArray *dataArray) {
        if(result){
            UIImage *localImage = [UIImage imageWithContentsOfFile:SAVE_GROUP_HEADER_IMAGE(group.groupId)];
            if(localImage){
              
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.coverImageView.image = localImage;
                });
            }else{
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    UIImage *image = [UIImage createImageWithUserModelArray:dataArray];
                    NSData *imageData = UIImagePNGRepresentation(image);
                    [imageData writeToFile:SAVE_GROUP_HEADER_IMAGE(group.groupId) atomically:YES];
                  
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.coverImageView.image = image;
                    });
                });
            }
        }
    }];
}

- (void)saveImageAction:(UIButton *)btn
{
    UIImage *image = [self getImageFromView:self.view];
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    [self showHint:@"保存成功"];
    NSLog(@"image = %@, error = %@, contextInfo = %@  --- %@", image, error, contextInfo,@"保存成功");
}
- (UIImage *)getImageFromView:(UIView *)view {
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)joinGroupBtn:(UIButton *)sender {
}
@end
