//
//  ViewController.m
//  给自己用的模板修改插件
//
//  Created by Jefrl on 2017/6/22.
//  Copyright © 2017年 Jefrl. All rights reserved.
//

//=================================================================
//          自定义区域说明
// 1. 每个月最多有31天, 按31天自定义月份天数;
// 2. 年月日中的文件夹, 几月几号中的几号自述文件 README.md 个人习惯喜欢让文件名加上与几号同名的后缀, 如 10 号就是 README10.md 的命名;
// 3. 其他月份中, 考虑到可能写入了内容, 那么在 HXLPathExist 替换模式下就确保月份中 README.md 文件不替换, 不更改;

//=================================================================
//          后续想添加的需求记录: (20170830已完成)
//       需求一: 指定某个日期(包含这个日期), 从此往后到31日, 均替更新文件
//    [self generateRequireFile:HXLPathEmpty]; // 空则创建日志结构
//    [self generateRequireFile:HXLPathExist]; // 非空添加文件
//    [self generateRequireFile:HXLPathRemove]; // 非空删除文件
//=================================================================

#import "ViewController.h"
#import "SVProgressHUD.h"

// 需求枚举值;
typedef NS_ENUM(NSInteger, HXLPathType){
    HXLPathEmpty = 0, // 目标文件夹内为空 (用来新创建日志结构)
    HXLPathExist = 1,  // 目标文件夹内非空 (用来新增文件, 替换同名文件)
    HXLPathRemove = 2 // 目标文件夹内删除指定文件
};

// 默认所有月份31天
static NSInteger const day = 31;


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *createDiarySwitch;
@property (weak, nonatomic) IBOutlet UISwitch *updateDiarySwitch;
@property (weak, nonatomic) IBOutlet UISwitch *removeDiarySwitch;
@property (weak, nonatomic) IBOutlet UITextField *updateStartDate;
@property (weak, nonatomic) IBOutlet UITextField *removeStartDate;

/** 指定修改范围 */
@property (nonatomic, readwrite, assign) NSInteger appointCount;
/** 文件管理者 */
@property (nonatomic, readwrite, strong) NSFileManager *fm;
/** fromPath 源文件夹路径 (即整理好的将要拷贝的文件夹路径) */
@property (nonatomic, readwrite, strong) NSString *fromPath;
/** monthPath 月份文件夹路径 (即将要存放的最外层文件夹路径) */
@property (nonatomic, readwrite, strong) NSString *monthPath;
/** operation */
@property (nonatomic, readwrite, assign) HXLPathType operation;

@end

@implementation ViewController
#pragma mark ===================== 初始化文件配置区域 =====================
- (void)viewDidLoad {
    [super viewDidLoad];
    // 配置文件路径
    self.fromPath = @"/Users/Jefrl/Desktop/上海乐住/测试文件/from";
    self.monthPath = @"/Users/Jefrl/Desktop/上海乐住/测试文件/9月";
}
- (IBAction)createSwitch:(UISwitch *)sender {
    sender.on = !sender.on;
    
    if (sender.isOn) {
        self.updateDiarySwitch.on = NO;
        self.removeDiarySwitch.on = NO;
        [self.view endEditing:YES];
        
        self.updateStartDate.enabled = NO;
        self.updateStartDate.textColor = [UIColor grayColor];
        self.removeStartDate.enabled = NO;
        self.removeStartDate.textColor = [UIColor grayColor];
    }
}
- (IBAction)updateSwitch:(UISwitch *)sender {
    sender.on = !sender.on;
    self.updateStartDate.enabled = NO;
    
    if (sender.isOn) {
        self.createDiarySwitch.on = NO;
        self.removeDiarySwitch.on = NO;
        
        self.updateStartDate.enabled = YES;
        [self.updateStartDate becomeFirstResponder];
        self.updateStartDate.textColor = [UIColor blackColor];
        self.removeStartDate.enabled = NO;
        self.removeStartDate.textColor = [UIColor grayColor];
    }
}
- (IBAction)removeSwitch:(UISwitch *)sender {
    sender.on = !sender.on;
    self.removeStartDate.enabled = NO;
    
    if (sender.isOn) {
        self.createDiarySwitch.on = NO;
        self.updateDiarySwitch.on = NO;
        self.updateStartDate.enabled = NO;
        self.updateStartDate.textColor = [UIColor grayColor];
        self.removeStartDate.enabled = YES;
        self.removeStartDate.textColor = [UIColor blackColor];
        [self.removeStartDate becomeFirstResponder];
    }
}

- (IBAction)generateBtnClick:(UIButton *)sender {
    NSInteger flag = 0;
    self.createDiarySwitch.isOn ? flag++ : flag;
    self.updateDiarySwitch.isOn ? flag++ : flag;
    self.removeDiarySwitch.isOn ? flag++ : flag;
    
    if (flag != 1) {
        [SVProgressHUD showErrorWithStatus:@"请选择一个! 你想执行操作 ?"];
        [SVProgressHUD dismissWithDelay:2];
        return;
    }
    
    // 获取界面设定值;
    if (self.createDiarySwitch.isOn) {
        self.operation = HXLPathEmpty;
    }
    if (self.updateDiarySwitch.isOn) {
        self.operation = HXLPathExist;
        self.appointCount = [self.updateStartDate.text integerValue];
    }
    if (self.removeDiarySwitch.isOn) {
        self.operation = HXLPathRemove;
        self.appointCount = [self.removeStartDate.text integerValue];
    }
    
    if ((self.updateDiarySwitch.isOn || self.removeDiarySwitch.isOn) && (self.appointCount < 1 || self.appointCount > 31)) {
        [SVProgressHUD showErrorWithStatus:@"起始日期设置, 应该在 01 - 31 之间"];
        [SVProgressHUD dismissWithDelay:2];
        return;
    }
    
    [self generateRequireFile:self.operation];
    
}

#pragma mark ===================== 懒加载区域 =====================
- (NSFileManager *)fm
{
    if (_fm == nil) {
        _fm = [NSFileManager defaultManager];
    }
    return _fm;
}

#pragma mark ===================== 消息区域 =====================
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

/** 生成需求文件 */
- (void)generateRequireFile:(HXLPathType)operationType {
    if (self.fromPath.length == 0 || self.monthPath.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"NO ! 空路径 !!!"];
        [SVProgressHUD dismissWithDelay:2];
        return;
    }
    
    NSString *message;
    if (operationType == HXLPathEmpty) { // 1. 目标文件夹内部为空
        message = @"正在执行, 生成日志目录结构的操作, 确认执行么 ?!";
        [self handleFileOperationType:operationType message:message handler:^{
            [self createFileOperationType:operationType];
        }];
    }
    
    if (operationType == HXLPathExist) { // 2. 目标文件夹内部已有日志结构
        message = @"正在执行, 增添文件或覆盖同名文件操作, 确认执行么 ?!";
        [self handleFileOperationType:operationType message:message handler:^{
            [self copyFileOperationType:operationType];
        }];
    }
    
    if (operationType == HXLPathRemove) { // 3. 目标文件夹内部删除指定文件
        message = @"正在执行, 删除指定文件操作, 确认执行么 ?!";
        [self handleFileOperationType:operationType message:message handler:^{
            [self removeFileOperationType:HXLPathRemove];
        }];
    }
}

/** UIAlertController && UIAlertAction 警告提示 */
- (void)handleFileOperationType:(HXLPathType)operationType message:(NSString *)message handler:( void (^)())myBlock
{
    UIAlertController *actionSheetController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [actionSheetController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = [NSString stringWithFormat:@"输入路径: %@", self.fromPath];
    }];
    [actionSheetController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = [NSString stringWithFormat:@"输出路径: %@", self.monthPath];
    }];
    
    UIAlertAction *determineAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:myBlock];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"%@", action);
    }];
    
    [actionSheetController addAction:determineAction];
    [actionSheetController addAction:cancelAction];
    [self presentViewController:actionSheetController animated:YES completion:nil];
}

/** 按类型校验 */
- (BOOL)invalidDetectionWithOperationType:(HXLPathType)operationType
{
    NSArray *contentArray = [self.fm contentsOfDirectoryAtPath:self.monthPath error:nil];
    
    if (operationType == HXLPathEmpty) {
        // 校验是否已存在日志结构
        if (contentArray.count > 1) { // 如果不只有系统文件 ".DS_Store"
            NSString *mothFileName = [self.monthPath componentsSeparatedByString:@"/"].lastObject;
            NSString *title = [NSString stringWithFormat:@"输出文件夹 \"%@\"\\ 内部已存在日志目录, 请更改操作 !!", mothFileName];
            [SVProgressHUD showErrorWithStatus:title];
            [SVProgressHUD dismissWithDelay:2];
            return YES;
        }
    }
    
    if (operationType == HXLPathExist || operationType == HXLPathRemove) {
        // 校验是否为空
        if (contentArray.count == 1) { // 如果 只有系统文件 ".DS_Store"
            NSString *mothFileName = [self.monthPath componentsSeparatedByString:@"/"].lastObject;
            NSString *title = [NSString stringWithFormat:@"输出文件夹 \"%@\" 内部为空, 请先创建日志目录 !!", mothFileName];
            [SVProgressHUD showErrorWithStatus:title];
            [SVProgressHUD dismissWithDelay:2];
            return YES;
        }
    }
    return NO;
}

- (void)createFileOperationType:(HXLPathType)operationType
{
    if ([self invalidDetectionWithOperationType:operationType]) return;
    // 创建子目录
    NSError *error = nil;
    for (NSInteger i = 0; i < day; i++) {
        [self.fm createDirectoryAtPath:[NSString stringWithFormat:@"%@/%02ld", self.monthPath, (long)(i + 1)] withIntermediateDirectories:YES attributes:nil error:&error];
        NSLogError(error)
    }
    // 创建文件
    [self copyFileOperationType:operationType];

}

- (void)removeFileOperationType:(HXLPathType)operationType {
    if ([self invalidDetectionWithOperationType:operationType]) return;
    // 获取来源文件, 初始路径下的一级子目录文件名
    NSError *error = nil;
    NSArray *fromPaths = [self.fm subpathsOfDirectoryAtPath:self.fromPath error:&error];
    NSLogError(error)
    
    for (NSString *fpath in fromPaths) {
        if ([fpath containsString:@".DS_Store"]) continue; // 过滤
        if (![fpath containsString:@"."]) continue; // 只删除同名文件, 不删同名文件夹;
        [self removeSameNameFileFromPath:fpath];
    }
    [SVProgressHUD showSuccessWithStatus:@"删除操作已完成 !"];
    [SVProgressHUD dismissWithDelay:1];
}

- (void)copyFileOperationType:(HXLPathType)operationType {
    if (operationType != HXLPathEmpty) { // 创建操作已经校验过了;
        if ([self invalidDetectionWithOperationType:operationType]) return;
    }
    
    // 获取来源文件, 初始路径下的一级子目录文件名
    NSError *error = nil;
    NSArray *fromPaths = [self.fm subpathsOfDirectoryAtPath:self.fromPath error:&error];
    NSLogError(error)
    
    for (NSString *fpath in fromPaths) {
        if ([fpath containsString:@".DS_Store"]) continue;
        // 拼接好每个文件的路径
        NSString *subFromPath = [self.fromPath stringByAppendingPathComponent:fpath];
        // 拷贝
        if (operationType == HXLPathExist) { // 内部已存在子目录, 那么找出同名文件路径并删除;
            if (![fpath containsString:@"."]) continue; // 只删除同名文件, 不删同名文件夹;
            [self removeSameNameFileFromPath:fpath];
        }
        
        [self copyFromPath:fpath subFromPath:subFromPath andOperationType:operationType];
    }

    if (operationType == HXLPathEmpty) {
        [SVProgressHUD showSuccessWithStatus:@"创建操作已完成 !"];
    } else {
        [SVProgressHUD showSuccessWithStatus:@"增添文件操作已完成 !"];
    }
    [SVProgressHUD dismissWithDelay:1];
}

#pragma mark ===================== 核心功能性方法 =====================
- (void)removeSameNameFileFromPath:(NSString *)fpath
{
    // 获取目标文件, 需存放路径下的所有子目录
    NSError *error = nil;
    NSArray *toAllPaths = [self.fm subpathsOfDirectoryAtPath:self.monthPath error:&error];
    NSLogError(error)
    
    for (NSString *path in toAllPaths) { // 找出同名文件路径并删除;
        // 同名替换时不替换月份下的 README 文件, 过滤系统文件, 确保只处理文件, 不处理文件夹
        if ([path isEqualToString:fpath] || [path containsString:@".DS_Store"] || ![path containsString:@"."]) continue;
        // 获取日期数字
        NSInteger count = [[path componentsSeparatedByString:@"/"].firstObject integerValue];
        if (count < self.appointCount) continue; // 日期要大于等于指定日期才执行删除;
        
        if ([path containsString:fpath] ) { // 日 期后面的同名路径名 就可以删了
            NSString *removeFilePath = [self.monthPath stringByAppendingPathComponent:path];
//            NSLog(@"fpath: %@, path: %@", fpath, path);
            
            NSError *error = nil;
            [self.fm removeItemAtPath:removeFilePath error:&error];
            NSLogError(error)
        }
        // 个人习惯的特殊 README0X 的删除处理
        if ([fpath containsString:@"README"] && [path containsString:@"README"]) { //
            NSString *removeFilePath = [self.monthPath stringByAppendingPathComponent:path];
            NSError *error = nil;
            [self.fm removeItemAtPath:removeFilePath error:&error];
            NSLogError(error)
        }
        
    }
}


- (void)copyFromPath:(NSString *)fpath subFromPath:(NSString *)subFromPath andOperationType:(HXLPathType)operationType
{
    if (operationType == HXLPathEmpty) { // 目标文件为创建操作, 且源文件夹包含自述文件, 那么
        if ([fpath isEqualToString:@"README.md"]) { // 月份下后初级子目录下的自述文件单独拷贝一份
            NSString *subToPath = [self.monthPath stringByAppendingPathComponent:fpath];
            NSError *error = nil;
            [self.fm copyItemAtPath:subFromPath toPath:subToPath error:&error];
            NSLogError(error)
        }
    }

    // 获取目标文件, 需存放路径下的初级子目录
    NSError *error = nil;
    NSArray *toPaths = [self.fm contentsOfDirectoryAtPath:self.monthPath error:&error];
    NSLogError(error)
    for (NSString *tpath in toPaths) { // 实现拷贝
         // NSLog(@"%@", tpath);
        if ([tpath containsString:@".DS_Store"] || [tpath isEqualToString:@"README.md"]) continue; //排除隐藏文件
        if (operationType != HXLPathEmpty) { // 非创建操作;
            NSInteger count = [[tpath componentsSeparatedByString:@"/"].firstObject integerValue];
            if (count < self.appointCount) continue; // 遍历日期如果小于指定日期, 则过滤掉;
        }
        
        NSString *subToPath = [self.monthPath stringByAppendingPathComponent:tpath];
         // NSLog(@"%@", subToPath);
        
        NSString *newSubToPath;
        if ([fpath isEqualToString:@"README.md"]) { // 如果是几号文件夹下的自述文件, 个人习惯 README0X 拼接处理
            newSubToPath = [subToPath stringByAppendingPathComponent:[NSString stringWithFormat:@"README%@.md", tpath]];
            // NSLog(@"%@", newSubToPath);
            [self.fm copyItemAtPath:subFromPath toPath:newSubToPath error:&error];
            NSLogError(error)
            continue;
        }
        
        newSubToPath = [subToPath stringByAppendingPathComponent:fpath];
        // NSLog(@"%@", newSubToPath);
        
        // 终于可以大胆拷贝了!
        [self.fm copyItemAtPath:subFromPath toPath:newSubToPath error:&error];
        if (operationType != HXLPathEmpty) {
            NSLogError(error)
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
