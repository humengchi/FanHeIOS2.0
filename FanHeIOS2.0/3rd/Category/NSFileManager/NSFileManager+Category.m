//
//  NSFileManager+Category.m
//  ChannelPlus
//
//  Created by Peter on 14/12/25.
//  Copyright (c) 2014年 Peter. All rights reserved.
//

#import "NSFileManager+Category.h"

@implementation NSFileManager (Category)

+ (NSString *)getDocumentDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

+ (void)createFolderInDirectory:(NSString *)directory folder:(NSString *)folder
{
    NSString *folderPath = [NSString stringWithFormat:@"%@%@", directory, folder];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    BOOL isDir = FALSE;
    BOOL isDirExist = [fileManager fileExistsAtPath:folderPath isDirectory:&isDir];
    if(!(isDirExist && isDir))    {
        BOOL bCreateDir = [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
        if(!bCreateDir){
            NSLog(@"Create Mid Directory Failed.");
        }
    }

}

+ (void)createFileDirectories:(NSString *)dictory {    // 判断存放mid、mov的文件夹是否存在,不存在则创建对应文件夹
    NSString *midPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"db"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = FALSE;
    BOOL isDirExist = [fileManager fileExistsAtPath:midPath isDirectory:&isDir];
    if(!(isDirExist && isDir))    {
        BOOL bCreateDir = [fileManager createDirectoryAtPath:midPath withIntermediateDirectories:YES attributes:nil error:nil];
        if(!bCreateDir){
            NSLog(@"Create Mid Directory Failed.");
        }
        NSLog(@"%@",midPath);
    }
    NSString *movPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"mov"];
    isDir = FALSE;
    isDirExist = [fileManager fileExistsAtPath:movPath isDirectory:&isDir];
    if(!(isDirExist && isDir)){
        BOOL bCreateDir = [fileManager createDirectoryAtPath:movPath withIntermediateDirectories:YES attributes:nil error:nil];
        if(!bCreateDir){
            NSLog(@"Create Mov Directory Failed.");
        }
        NSLog(@"%@",movPath);
    }
}

+ (void)copyDBItemToFolder:(NSString *)folderName
{
    
}

+ (void)copyItemToFolder:(NSString *)folderName fileName:(NSString *)fileName dataBasePath:(NSString *)dbPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *filePath = [[folderName stringByAppendingPathComponent:fileName] stringByAppendingString:@".db"];
        
    NSLog(@"user db path:%@", filePath);
    NSLog(@"----数据库大小>>>>>>>>%llu",[[fileManager attributesOfItemAtPath:filePath error:nil] fileSize]/(1024*1024));
    
    NSString * resourcePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"db"];
    if([fileManager fileExistsAtPath:filePath] == NO && filePath && resourcePath) {
        [fileManager copyItemAtPath:resourcePath toPath:filePath error:nil];
    }
}



+ (BOOL)fileExistWithName:(NSString *)fileName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *filePath = [[documentsDirectory stringByAppendingPathComponent:@"db"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db", fileName]];
    
    
    return [fileManager fileExistsAtPath:filePath];
}

+ (NSString *)getFileContent:(NSString *)fileName
{
    NSError *error=nil;
    NSString *str=[NSString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:&error];
    
    return str;
}

+ (NSMutableArray *)getAllFileNamesInDirectory:(NSString*)directory{
    NSMutableArray *retVal = [[NSMutableArray alloc] init];
    NSFileManager *nsFile = [NSFileManager defaultManager];
    NSError *err = nil;
    
    if ([nsFile fileExistsAtPath:directory]) {
        NSArray *sysList = [nsFile contentsOfDirectoryAtPath:directory error:&err];
        
        if (sysList && sysList.count > 0) {
            for (NSString *fileName in sysList) {
                if ([fileName isEqualToString: @"."] || [fileName isEqualToString:@".."] || [fileName isEqualToString:@".DS_Store"])
                    continue;
                [retVal addObject:fileName];
            }
        }
    }else{
        if (![[NSFileManager defaultManager] createDirectoryAtPath:directory
                                       withIntermediateDirectories:YES
                                                        attributes:nil
                                                             error:&err]) {
            NSLog(@"Error creating Directory!\nerror: %@\ndirectory: %@", err,directory);
        }else{
            NSLog(@"Success creating Directory: %@",directory);
        }
    }
    return retVal;
}


// 将文件转移到指定目录文件夹,先加.bak后重命名
+ (BOOL)copyFileFromDirectory:(NSString*)fromDir toDirectory:(NSString*)toDir fileName:(NSString*)fileName{
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", fromDir,fileName];
    if([fromDir hasSuffix:@"/"]){
        filePath = [fromDir stringByAppendingString:fileName];
    }
    
    if (!fromDir || [fromDir isEqualToString:@""] ) {
        NSLog(@"Warn fromDir is nil!");
        return NO;
    }
    if (!toDir || [toDir isEqualToString:@""] ) {
        NSLog(@"Warn toDir is nil!");
        return NO;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath] ) {
        NSLog(@"Warn fileName is no exist!");
        return NO;
    }

    NSLog(@"fromDir:%@\ntoDir:%@\nfileName:%@\n",fromDir,toDir,fileName);
    NSError *err = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:fromDir]) {
        if (![[NSFileManager defaultManager] createDirectoryAtPath:fromDir
                                       withIntermediateDirectories:YES
                                                        attributes:nil
                                                             error:&err]) {
            NSLog(@"Error creating Directory!\nerror: %@\ndirectory: %@", err,fromDir);
            return NO;
        }else{
            NSLog(@"Success creating Directory: %@",fromDir);
        }
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:toDir]) {
        if (![[NSFileManager defaultManager] createDirectoryAtPath:toDir
                                       withIntermediateDirectories:YES
                                                        attributes:nil
                                                             error:&err]) {
            NSLog(@"Error creating Directory!\nerror: %@\ndirectory: %@", err,toDir);
            return NO;
        }else{
            NSLog(@"Success creating Directory: %@",toDir);
        }
    }
    NSString *fileBakName = [NSString stringWithFormat:@"%@.bak",fileName];
    
    NSString *fileBakPath = [NSString stringWithFormat:@"%@/%@", toDir,fileBakName];
    if([toDir hasSuffix:@"/"]){
        fileBakPath = [toDir stringByAppendingString:fileBakName];
    }
    
    if (![[NSFileManager defaultManager] copyItemAtPath:filePath toPath:fileBakPath error:&err]) {
        NSLog(@"Error copy file (%@): %@", fileBakName, err);
        return NO;
    }else{
        NSLog(@"Success copy file (%@)",fileBakName);
        NSString *newFilePath = [NSString stringWithFormat:@"%@/%@", toDir,fileName];
        if([toDir hasSuffix:@"/"]){
            newFilePath = [toDir stringByAppendingString:fileName];
        }
        if (![[NSFileManager defaultManager] moveItemAtPath:fileBakPath toPath:newFilePath error:&err]) {
            NSLog(@"Error renaming file (%@) to (%@) .\nerror : %@", fileBakName , fileName, err);
            return NO;
        }
        NSLog(@"Success renaming file (%@) to (%@)", fileBakName, fileName);
        return YES;
    }
}


@end
