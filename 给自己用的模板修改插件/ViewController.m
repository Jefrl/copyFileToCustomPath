//
//  ViewController.m
//  给自己用的模板修改插件
//
//  Created by Jefrl on 2017/6/22.
//  Copyright © 2017年 Jefrl. All rights reserved.
//

#import "ViewController.h"

//=================================================================
//                       自定义起始路径(即准备将要拷贝的文件夹路径),
//                            存放路径(即将要存放的文件夹路径)
//
// 暂仅供本人需求的习惯场合使用, 后面会慢慢根据多种需求添加, 或自行 fork 添加!
//=================================================================
static NSString *fromPath = @"/Users/Jefrl/Desktop/from";
static NSString *toPath = @"/Users/Jefrl/Desktop/06月";

@interface ViewController ()
/** 文件管理者 */
@property (nonatomic, readwrite, strong) NSFileManager *fm;


@end

@implementation ViewController

- (NSFileManager *)fm
{
    if (_fm == nil) {
        _fm = [NSFileManager defaultManager];
    }
    return _fm;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始拷贝
    [self setupCopy];
    
}

- (void)setupCopy
{
    // 获取目标文件, 初始路径下的子目录
    NSError *error = nil;
    NSArray *fromPaths = [self.fm contentsOfDirectoryAtPath:fromPath error:&error];
    if (error != nil) {
        NSLog(@"%@", error);
        exit(-1);
    }
    
    for (NSString *fpath in fromPaths) {
        if ([fpath containsString:@".DS_Store"]) {
            continue;
        }
        
        NSString *subFromPath = [fromPath stringByAppendingPathComponent:fpath];
        // 拷贝
        [self copyFileFromPath:fpath subFromPath:subFromPath];
    }
}

- (void)copyFileFromPath:(NSString *)fpath subFromPath:(NSString *)subFromPath
{
    // 找出同名文件路径并删除;
    [self removeSameNameFileFromPath:fpath];
    // 实现拷贝
    [self copyFromPath:fpath subFromPath:subFromPath];

}

- (void)copyFromPath:(NSString *)fpath subFromPath:(NSString *)subFromPath
{
    // 获取目标文件, 需存放路径下的初级子目录
    NSError *error = nil;
    NSArray *toPaths = [self.fm contentsOfDirectoryAtPath:toPath error:&error];
    if (error != nil) {
        NSLog(@"%@", error);
        exit(-1);
    }
    
    for (NSString *tpath in toPaths) { // 实现拷贝
        if ([tpath containsString:@".DS_Store"] || [tpath containsString:@"README"]) {
            continue;
        }
        
        NSString *subToPath = [[toPath stringByAppendingPathComponent:tpath] stringByAppendingPathComponent:fpath];
        
        [self.fm copyItemAtPath:subFromPath toPath:subToPath error:&error];
        if (error != nil) {
            NSLog(@"%@", error);
            exit(-1);
        }
    }
}

- (void)removeSameNameFileFromPath:(NSString *)fpath
{
    // 获取目标文件, 需存放路径下的所有子目录
    NSError *error = nil;
    NSArray *toAllPaths = [self.fm subpathsOfDirectoryAtPath:toPath error:&error];
    if (error != nil) {
        NSLog(@"%@", error);
        exit(-1);
    }
    
    for (NSString *path in toAllPaths) { // 找出同名文件路径并删除;
        if ([path containsString:fpath]) {
            NSString *removeFilePath = [toPath stringByAppendingPathComponent:path];
            
            NSError *error = nil;
            [self.fm removeItemAtPath:removeFilePath error:&error];
            if (error != nil) {
                NSLog(@"%@", error);
                exit(-1);
            }
        }
        
    }
}


/*
 Log: (
 ".DS_Store",
 images,
 "job.md",
 "learning.md",
 "life.md",
 "README01.md"
 ) :<--27--$

 Log: (
 ".DS_Store",
 01,
 "01/.DS_Store",
 "01/images",
 "01/job.md",
 "01/learning.md",
 "01/life.md",
 "01/README01.md",
 02,
 "02/.DS_Store",
 "02/images",
 "02/job.md",
 "02/learning.md",
 "02/life.md",
 "02/README02.md",

 */

@end
