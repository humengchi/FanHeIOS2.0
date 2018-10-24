//
//  NSFileManager+Category.h
//  ChannelPlus
//
//  Created by Peter on 14/12/25.
//  Copyright (c) 2014年 Peter. All rights reserved.
//

#import <Foundation/Foundation.h>

#define USER_FOLDER @"/User"
#define USER_UPLOAD_FOLDER @"/Upload"
#define USER_CACHE_FOLDER @"/Cache"
#define USER_LOG_FOLDER [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/User/Log/"]

#define DB_FILE_NAME @"JinMai"

@interface NSFileManager (Category)

+ (NSString *)getDocumentDirectory;

+ (void)createFolderInDirectory:(NSString *)directory folder:(NSString *)folder;

+ (void)createFileDirectories:(NSString *)dictory;

+ (void)copyItemToFolder:(NSString *)folderName fileName:(NSString *)fileName dataBasePath:(NSString *)dbPath;

+ (BOOL)fileExistWithName:(NSString *)fileName ;

+ (NSString *)getFileContent:(NSString *)fileName;

+ (NSMutableArray *)getAllFileNamesInDirectory:(NSString*)directory;

+ (BOOL)copyFileFromDirectory:(NSString*)fromDir toDirectory:(NSString*)toDir fileName:(NSString*)fileName;
@end
