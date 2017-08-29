//
//  ViewController.m
//  给自己用的模板修改插件
//
//  Created by Jefrl on 2017/6/22.
//  Copyright © 2017年 Jefrl. All rights reserved.
//

#import "ViewController.h"
// 需求枚举值;
typedef NS_ENUM(NSInteger, HXLPath){
    HXLPathDefault= 0, // 默认最外层文件夹内部子目录不变 (即加入新文件或替换同名文件)
    HXLPathCustom = 1  // 最外层文件夹为空文件夹, 在其内部重新创建日志的子目录
};

//=================================================================
//          自定义区域说明
//    1. 起始路径(即整理好的将要拷贝的文件夹路径),
static NSString *fromPath = @"/Users/Jefrl/Desktop/上海乐住/from";
//    2. 存放路径(即将要存放的最外层文件夹路径)
static NSString *toPath = @"/Users/Jefrl/Desktop/上海乐住/to";
//    3. 每个月最多有31天, 暂按31天自定义; 后面有时间慢慢扩展;
static NSInteger day = 31;
//    4. 宏定义了当前操作是替换子目录中的文件, 还是重新创建自定义目录
#define HXLPathType HXLPathDefault
//
//=================================================================

// 注意: 年月日中的文件夹, 几月几号中的几号自述文件 README.md 个人习惯喜欢让文件名加上与几号同名的后缀, 如 10 号就是 README10.md 的命名;
// 其他月份, 年份中, 考虑到可能写入了内容, 那么在 HXLPathDefault 替换模式下就保持 README.md 文件不替换, 不更改;

//=================================================================
//          后续想添加的需求记录:
//       需求一: 指定某个日期(包含这个日期), 从此往后到31日, 均替更新文件
//=================================================================



@interface ViewController ()
/** 文件管理者 */
@property (nonatomic, readwrite, strong) NSFileManager *fm;
@property (weak, nonatomic) IBOutlet UITextField *inputTextField;
@property (weak, nonatomic) IBOutlet UITextField *outputTextField;
@property (weak, nonatomic) IBOutlet UISwitch *DefaultSwitch;


@end

@implementation ViewController

- (NSFileManager *)fm
{
    if (_fm == nil) {
        _fm = [NSFileManager defaultManager];
    }
    return _fm;
}

- (IBAction)generateBtnClick:(UIButton *)sender {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始拷贝
    [self setupCopy:HXLPathType];
    
}



- (void)setupCopy:(HXLPath)pathType
{
    // 处理目标文件, 存放路径下的子目录
    if (pathType == HXLPathCustom) { // 自定义子目录
        NSError *error = nil;
        // 创建子目录
        for (NSInteger i = 0; i < day; i++) {
            
            [self.fm createDirectoryAtPath:[NSString stringWithFormat:@"%@/%02ld", toPath, (long)(i + 1)] withIntermediateDirectories:YES attributes:nil error:&error];
            
            if (error != nil) {
                NSLog(@"%@", error);
                exit(-1);
            }

        }
    }
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
        // 拼接好每个文件的路径
        NSString *subFromPath = [fromPath stringByAppendingPathComponent:fpath];
        // 拷贝
        [self copyFileFromPath:fpath subFromPath:subFromPath andPathType:pathType];
    }
}

- (void)copyFileFromPath:(NSString *)fpath subFromPath:(NSString *)subFromPath andPathType:(HXLPath)pathType
{
    if (pathType == HXLPathDefault) { // 默认内部子目录
        // 找出同名文件路径并删除;
        [self removeSameNameFileFromPath:fpath];
    }
    // 实现拷贝
    [self copyFromPath:fpath subFromPath:subFromPath andPathType:pathType];

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
        NSString *newFpath = [fpath componentsSeparatedByString:@"."][0];
        if ([path containsString:newFpath] && ![path isEqualToString:fpath] && ![path containsString:@".DS_Store"]) { // 同名替换时不替换月份或初级目录下的同名文件
            NSString *removeFilePath = [toPath stringByAppendingPathComponent:path];
            
            NSError *error = nil;
            [self.fm removeItemAtPath:removeFilePath error:&error];
            // 日期目录下的文件或文件夹, 为替换文件, 再深一级的子目录暂无需求, 故注释
//            if (error != nil) {
//                NSLog(@"%@", error);
//                exit(-1);
//            }
        }
        
    }
}

- (void)copyFromPath:(NSString *)fpath subFromPath:(NSString *)subFromPath andPathType:(HXLPath)pathType
{
    NSError *error = nil;
    
    // 获取目标文件, 需存放路径下的初级子目录
    NSArray *toPaths = [self.fm contentsOfDirectoryAtPath:toPath error:&error];
    
    if (error != nil) {
        NSLog(@"%@", error);
        exit(-1);
    }
    
    if (pathType == HXLPathCustom) { // 如果是自定义模式
        if ([fpath isEqualToString:@"README.md"]) {
            // 月份下后初级子目录下的自述文件单独拷贝一份
            NSString *subToPath = [toPath stringByAppendingPathComponent:fpath];
            [self.fm copyItemAtPath:subFromPath toPath:subToPath error:&error];
            
            if (error != nil) {
                NSLog(@"%@", error);
                exit(-1);
            }
            
        }
        
    }

    // 次级子目录的自述文件, 作者自己的特定的习惯命名, 需加上几号
    for (NSString *tpath in toPaths) { // 实现拷贝
        // NSLog(@"%@", tpath);
        if ([tpath containsString:@".DS_Store"] || [tpath isEqualToString:@"README.md"]) { // 排除隐藏文件
            continue;
        }
        
        NSString *subToPath = [toPath stringByAppendingPathComponent:tpath];
        // NSLog(@"%@", subToPath);
        
        if ([fpath isEqualToString:@"README.md"]) { // 如果是几号文件夹下的自述文件, 拼接成 "README/tpath.md" 的名称
           
            NSString *newSubToPath = [subToPath stringByAppendingPathComponent:[NSString stringWithFormat:@"README%@.md", tpath]];
            // NSLog(@"%@", newSubToPath);
            [self.fm copyItemAtPath:subFromPath toPath:newSubToPath error:&error];
            if (error != nil) {
                NSLog(@"%@", error);
                exit(-1);
            }
            continue;
        }
        
        subToPath = [subToPath stringByAppendingPathComponent:fpath];
        // NSLog(@"%@", subToPath);
        // 终于可以大胆拷贝了!
        [self.fm copyItemAtPath:subFromPath toPath:subToPath error:&error];
        if (error != nil) {
            NSLog(@"%@", error);
            exit(-1);
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
