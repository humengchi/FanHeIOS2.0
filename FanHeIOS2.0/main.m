//
//  main.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/6/16.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}

/*
echo 'start build FanHeIOS2.0'

pwd

whoami

export LANG=en_US.UTF-8

export LANGUAGE=en_US.UTF-8

export LC_ALL=en_US.UTF-8

#工程环境路径

workspace_path=.

#项目名称

project_name="FanHeIOS2.0"

echo"第一步，更新库文件"

/usr/local/bin/pod update --verbose --no-repo-update

echo "第二步，清除缓存文件...................."

xcodebuild clean

rm -rf archive

rm -f $project_name.ipa

echo "第三步，设置打包环境，准备开始打ipa包...................."

sed -i '' 's/\app-store\<\/string\>/\development\<\/string\>/' archieveOpt.plist

sed -i '' 's/ProvisioningStyle = Automatic;/ProvisioningStyle = Manual;/' $project_name.xcodeproj/project.pbxproj

echo "第四步，执行编译生成.app命令"

xcodebuild archive -workspace $project_name.xcworkspace -scheme $project_name -configuration Release -archivePath archive/$project_name.xcarchive CODE_SIGN_IDENTITY="iPhone Distribution: haiqing wu (9M98VC6642)" PROVISIONING_PROFILE_SPECIFIER="development_patient_kevin"

echo "第五步，执行编译生成.ipa命令"

xcodebuild -exportArchive -exportOptionsPlist archieveOpt.plist -archivePath archive/$project_name.xcarchive -exportPath ./ -configuration Release
*/
