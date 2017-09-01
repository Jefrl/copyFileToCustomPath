//
//  ViewController.m
//  给自己用的模板修改插件
//
//  Created by Jefrl on 2017/6/22.
//  Copyright © 2017年 Jefrl. All rights reserved.
//

#import "ViewController.h"

// 需求枚举值;
typedef NS_ENUM(NSInteger, HXLPathType){
    HXLPathEmpty = 0, // 目标文件夹内为空 (用来新创建, 新的日志结构)
    HXLPathExist = 1,  // 目标文件夹内非空 (用来新增文件, 若同名则替换同名文件)
    HXLPathRemove = 2, // 目标文件夹内删除指定文件
    HXLPathSudoRemove = 3 // 目标文件夹内删除指定文件并包含文件夹 (权限扩大)
};

// 默认所有月份31天
static NSInteger const day = 31;

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *createDiarySwitch;
@property (weak, nonatomic) IBOutlet UISwitch *updateDiarySwitch;
@property (weak, nonatomic) IBOutlet UISwitch *removeDiarySwitch;
@property (weak, nonatomic) IBOutlet UISwitch *sudoRemoveDiarySwitch;
@property (weak, nonatomic) IBOutlet UITextField *updateStartDate;
@property (weak, nonatomic) IBOutlet UITextField *removeStartDate;
@property (weak, nonatomic) IBOutlet UITextField *sudoRemoveStartDate;
@property (weak, nonatomic) IBOutlet UITextView *instructionTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeightLayoutConstraint;

/** 指定修改范围 */
@property (nonatomic, readwrite, assign) NSInteger appointCount;
/** 文件管理者 */
@property (nonatomic, readwrite, strong) NSFileManager *fm;
/** 源文件夹路径 (即整理好的将要拷贝的输入文件夹路径) */
@property (nonatomic, readwrite, strong) NSString *fromPath;
/** 月份文件夹路径 (即被操作的输出文件夹路径) */
@property (nonatomic, readwrite, strong) NSString *monthPath;
/** 操作类型 */
@property (nonatomic, readwrite, assign) HXLPathType operation;

@end

@implementation ViewController

//=================================================================
//          文件路径设置区域
//          具体使用说明请看 README 自述文件, 并配截图!
//=================================================================
#pragma mark =================== 文件路径设置区域 ===================
- (void)viewDidLoad {
    [super viewDidLoad];
    
    /** 01. fromPath 源文件夹路径 (即整理好的将要拷贝的输入文件夹路径) */
    /** 02. monthPath 月份文件夹路径 (即被操作的输出文件夹路径) */
    self.fromPath = @"/Users/Jefrl/Desktop/便利小插件/测试文件/from";
    self.monthPath = @"/Users/Jefrl/Desktop/便利小插件/测试文件/09月";
    
    [self setupTextView];
}

- (void)setupTextView
{
    self.instructionTextView.userInteractionEnabled = NO;
    NSString *instructionText = @" 使用说明: \n 1. 所有操作都默认从 01 至 31 日; \n 2. 若设定起始日期,  那么操作范围从指定日期(包含当天) 至 31 日; \n 3. 添加操作时, 同名文件的覆盖,  以及删除指定文件的操作, 都只针对文件操作, 不处理文件夹; \n 4. 注意, 最后一个操作表示扩展了删除操作权限, 文件夹也可以删除 !!!";
    
    NSArray *array = [instructionText componentsSeparatedByString:@"\n"];
    CGFloat height = 0;
    for (NSString *string in array) {
        CGSize TextSize = [string boundingRectWithSize:CGSizeMake(HXL_SCREEN_WIDTH - 20, HXL_SCREEN_HEIGHT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : FONT_13} context:nil].size;
        height += TextSize.height;
    }
    self.instructionTextView.text = instructionText;
    self.textViewHeightLayoutConstraint.constant = height + 10;
    [self.view layoutIfNeeded];
}

#pragma mark ===================== GUI 图形界面 segue 区域 =====================
- (IBAction)createSwitch:(UISwitch *)sender {
    sender.on = !sender.on;
    
    if (sender.isOn) {
        self.updateDiarySwitch.on = NO;
        self.removeDiarySwitch.on = NO;
        self.sudoRemoveDiarySwitch.on = NO;
        
        self.updateStartDate.enabled = NO;
        self.updateStartDate.textColor = [UIColor grayColor];
        self.removeStartDate.enabled = NO;
        self.removeStartDate.textColor = [UIColor grayColor];
        self.sudoRemoveStartDate.enabled = NO;
        self.sudoRemoveStartDate.textColor = [UIColor grayColor];
        [self.view endEditing:YES];
    }
}
- (IBAction)updateSwitch:(UISwitch *)sender {
    
    if (sender.isOn) {
        self.createDiarySwitch.on = NO;
        self.removeDiarySwitch.on = NO;
        self.sudoRemoveDiarySwitch.on = NO;
        
        self.updateStartDate.enabled = YES;
        self.updateStartDate.textColor = [UIColor blackColor];
        self.removeStartDate.enabled = NO;
        self.removeStartDate.textColor = [UIColor grayColor];
        self.sudoRemoveStartDate.enabled = NO;
        self.sudoRemoveStartDate.textColor = [UIColor grayColor];
        
        [self.updateStartDate becomeFirstResponder];
    }
    else {
        self.updateStartDate.enabled = NO;
    }
}
- (IBAction)removeSwitch:(UISwitch *)sender {
    
    if (sender.isOn) {
        self.createDiarySwitch.on = NO;
        self.updateDiarySwitch.on = NO;
        self.sudoRemoveDiarySwitch.on = NO;
        
        self.updateStartDate.enabled = NO;
        self.updateStartDate.textColor = [UIColor grayColor];
        self.removeStartDate.enabled = YES;
        self.removeStartDate.textColor = [UIColor blackColor];
        self.sudoRemoveStartDate.enabled = NO;
        self.sudoRemoveStartDate.textColor = [UIColor grayColor];
        
        [self.removeStartDate becomeFirstResponder];
    }
    else {
        self.removeStartDate.enabled = NO;
    }
}

- (IBAction)sudoRemoveSwitch:(UISwitch *)sender {
    
    if (sender.isOn) {
        self.createDiarySwitch.on = NO;
        self.updateDiarySwitch.on = NO;
        self.removeDiarySwitch.on = NO;
        
        self.updateStartDate.enabled = NO;
        self.updateStartDate.textColor = [UIColor grayColor];
        self.removeStartDate.enabled = NO;
        self.removeStartDate.textColor = [UIColor grayColor];
        self.sudoRemoveStartDate.enabled = YES;
        self.sudoRemoveStartDate.textColor = [UIColor blackColor];
        
        [self.sudoRemoveStartDate becomeFirstResponder];
    }
    else {
        self.sudoRemoveStartDate.enabled = NO;
    }
    
}

- (IBAction)generateBtnClick:(UIButton *)sender {
    NSInteger flag = 0;
    self.createDiarySwitch.isOn ? flag++ : flag;
    self.updateDiarySwitch.isOn ? flag++ : flag;
    self.removeDiarySwitch.isOn ? flag++ : flag;
    self.sudoRemoveDiarySwitch.isOn ? flag++ : flag;
    
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
    if (self.sudoRemoveDiarySwitch.isOn) {
        self.operation =  HXLPathSudoRemove;
        self.appointCount = [self.sudoRemoveStartDate.text integerValue];
    }
    
    if (flag == 1 && (self.appointCount < 1 || self.appointCount > 31)) {
        [SVProgressHUD showErrorWithStatus:@"起始日期的设置, 应该在 01 - 31 之间"];
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
        message = @"生成目录结构操作, 确认执行么 !";
        [self handleFileOperationMessage:message handler:^{
            [self createFileOperationType:operationType];
        }];
    }
    
    if (operationType == HXLPathExist) { // 2. 目标文件夹内部已有日志结构
        message = @"增添文件, 覆盖同名文件的操作, 确认执行么 ?";
        [self handleFileOperationMessage:message handler:^{
            [self addFileOperationType:operationType];
        }];
    }
    
    if (operationType == HXLPathRemove) { // 3. 目标文件夹内部删除指定文件
        message = @"仅删除指定文件操作(不包含文件夹), 确认执行么 ?";
        [self handleFileOperationMessage:message handler:^{
            [self removeFileOperationType:operationType];
        }];
    }
    if (operationType == HXLPathSudoRemove) { // 3. 目标文件夹内部删除指定
        message = @"注意: 指定的文件夹也会删除, 确认执行么 ?";
        [self handleFileOperationMessage:message handler:^{
            [self removeFileOperationType:operationType];
        }];
    }
}

/** UIAlertController && UIAlertAction 警告提示 */
- (void)handleFileOperationMessage:(NSString *)message handler:( void (^)())myBlock
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
        // NSLog(@"%@", action);
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
    
    if (operationType != HXLPathEmpty) {
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
    [self addFileOperationType:operationType];

}

- (void)removeFileOperationType:(HXLPathType)operationType {
    if ([self invalidDetectionWithOperationType:operationType]) return;
    // 获取来源文件, 初始路径下的一级子目录文件名
    NSError *error = nil;
    NSArray *fromPaths = [self.fm subpathsOfDirectoryAtPath:self.fromPath error:&error];
    NSLogError(error)
    
    for (NSString *fpath in fromPaths) {
        if ([fpath containsString:@".DS_Store"]) continue; // 过滤
        if (operationType == HXLPathRemove) { // 只删除同名文件, 不删同名文件夹;
            if (![fpath containsString:@"."]) continue;
        } else { /** 可以删除文件夹, 不过滤文件夹路径 */}
        
        [self removeSameNameFileFromPath:fpath andOperationType:operationType];
    }
    [SVProgressHUD showSuccessWithStatus:@"删除操作已完成 !"];
    [SVProgressHUD dismissWithDelay:1];
}

- (void)addFileOperationType:(HXLPathType)operationType {
    if (operationType != HXLPathEmpty) { // 创建操作已经校验过了;
        if ([self invalidDetectionWithOperationType:operationType]) return;
    }
    
    // 获取来源文件, 初始路径下的一级子目录文件名
    NSError *error = nil;
    NSArray *fromPaths = [self.fm subpathsOfDirectoryAtPath:self.fromPath error:&error];
    NSLogError(error)
    
    for (NSString *fpath in fromPaths) {
        if ([fpath containsString:@".DS_Store"]) continue;
        // 拼接所有子文件绝对路径
        NSString *subFromPath = [self.fromPath stringByAppendingPathComponent:fpath];
        // 拷贝
        if (operationType == HXLPathExist) { // 添加或覆盖文件操作, 那么找出同名文件路径并删除;
            [self removeSameNameFileFromPath:fpath andOperationType:operationType];
            [self copyFromPath:fpath subFromPath:subFromPath];
        }
        else { // 创建日志操作
            [self createFileFromPath:fpath subFromPath:subFromPath];
        }
    }
    
    if (operationType == HXLPathExist) {
        [SVProgressHUD showSuccessWithStatus:@"增添文件操作已完成 !"];
    } else {
        [SVProgressHUD showSuccessWithStatus:@"创建操作已完成 !"];
    }
    [SVProgressHUD dismissWithDelay:1];
}

#pragma mark ===================== 核心功能性方法 =====================
- (void)removeSameNameFileFromPath:(NSString *)fpath andOperationType:(HXLPathType)operationType
{
    // 获取目标文件, 需存放路径下的所有子目录
    NSError *error = nil;
    NSArray * monthPaths = [self.fm subpathsOfDirectoryAtPath:self.monthPath error:&error];
    NSLogError(error)
    
    for (NSString *mpath in monthPaths) { // 找出同名文件路径并删除;
        if ( [mpath containsString:@".DS_Store"] || [mpath isEqualToString:@"README.md"]) continue; // 系统文件过滤; 月份的自述文件永不操作;
        
        // 获取日期数字
        NSString *firstMonthPath = [mpath componentsSeparatedByString:@"/"].firstObject;
        NSInteger count = [firstMonthPath integerValue];
        if (count < self.appointCount) continue; // 凡小于指定日期均不执行删除操作;
        if ([fpath isEqualToString:mpath] || ![mpath containsString:@"/"]) continue; // 月份直接目录下的所有文件月, 文件夹, 避免用户误操作的安全隐患;
        
        NSString *newPath = [mpath substringFromIndex:[mpath rangeOfString:@"/"].location + 1]; // 进入操作目录区
        if (HXLPathSudoRemove == operationType) { // 只有最大权限的 HXLSudoRemove 删除操作, 才可以删除同名文件夹
        } else { // 添加操作中的覆盖同名文件, 与仅仅删除文件的操作, 只处理同名文件, 绝不处理同名文件夹, 坚持安全的设计原则 !!
            if (![newPath containsString:@"."]) continue;
        }
        
        if ([fpath isEqualToString:newPath]) { // 日期内部的同名路径名删除
            NSString *removeFilePath = [self.monthPath stringByAppendingPathComponent:mpath];
            
            NSError *error = nil;
            [self.fm removeItemAtPath:removeFilePath error:&error];
            NSLogError(error)
        }
        // 日期内部, 个人习惯的 README0X 的特殊删除处理
        if ([fpath isEqualToString:@"README.md"] && [newPath containsString:@"README"]) {
            NSString *removeFilePath = [self.monthPath stringByAppendingPathComponent:mpath];
            
            NSError *error = nil;
            [self.fm removeItemAtPath:removeFilePath error:&error];
            NSLogError(error)
        }
        
    }
}

- (void)createFileFromPath:(NSString *)fpath subFromPath:(NSString *)subFromPath
{
    // 获取目标文件, 需存放路径下的初级子目录
    NSError *error = nil;
    NSArray *datePaths = [self.fm contentsOfDirectoryAtPath:self.monthPath error:&error];
    NSLogError(error)
    
    if ([fpath isEqualToString:@"README.md"]) { // 来源文件夹包含自述文件, 月份目录下的自述文件拷贝一份
        NSString *subToPath = [self.monthPath stringByAppendingPathComponent:fpath];
        NSError *error = nil;
        [self.fm copyItemAtPath:subFromPath toPath:subToPath error:&error];
        NSLogError(error)
    }
    
    for (NSString *dateName in datePaths) {
        if ([dateName containsString:@".DS_Store"] || [dateName isEqualToString:@"README.md"]) continue;
        NSString *dateFloderPath = [self.monthPath stringByAppendingPathComponent:dateName]; // 日期目录的路径
        if ([fpath isEqualToString:@"README.md"]) { // 自述文件, 个人习惯 README0X 拼接处理
            NSString *copyFilePath = [dateFloderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"README%@.md", dateName]];
            [self.fm copyItemAtPath:subFromPath toPath:copyFilePath error:&error];
            NSLogError(error)
            continue;
        }
        else { // 非自述文件 (其他文件夹, 文件大胆建立)
            NSString *copyFilePath = [dateFloderPath stringByAppendingPathComponent:fpath];
            [self.fm copyItemAtPath:subFromPath toPath:copyFilePath error:&error];
            NSLogError(error)
        }
    }
}


- (void)copyFromPath:(NSString *)fpath subFromPath:(NSString *)subFromPath
{
    // 获取目标文件, 需存放路径下的初级子目录
    NSError *error = nil;
    NSArray *monthFilePaths = [self.fm contentsOfDirectoryAtPath:self.monthPath error:&error];
    NSLogError(error)

    if (![fpath containsString:@"."]) { // 文件夹
        for (NSString *dateName in monthFilePaths) { // 遍历进入 01 02 ...31
            if ([dateName containsString:@".DS_Store"] || [dateName isEqualToString:@"README.md"]) continue;
            if ([dateName integerValue] < self.appointCount) continue;
            NSString *dateFloderPath = [self.monthPath stringByAppendingPathComponent:dateName];
            NSArray *dateFolderPaths = [self.fm subpathsOfDirectoryAtPath:dateFloderPath  error:&error];
            NSLogError(error)
            if (![dateFolderPaths containsObject:fpath]) { // 写入
                NSString *copyFolderPath = [dateFloderPath stringByAppendingPathComponent:fpath];
                [self.fm copyItemAtPath:subFromPath toPath:copyFolderPath error:&error];
                NSLogError(error)
            }
        }
        
    }
    else { // 非文件夹
        for (NSString *dateName in monthFilePaths) { // 遍历进入 01 02 ...31
            if ([dateName containsString:@".DS_Store"] || [dateName isEqualToString:@"README.md"]) continue;
            if ([dateName integerValue] < self.appointCount) continue;
            NSString *dateFloderPath = [self.monthPath stringByAppendingPathComponent:dateName];
            // 同名文件交给删除模块搞定了, 直接写入
            // 如果是自述文件 README.md, 我习惯在名字后面加上日期 README0X.md,
            if ([fpath isEqualToString:@"README.md"]) {
                NSString *copyFolderPath = [dateFloderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"README%@.md", dateName]];
                [self.fm copyItemAtPath:subFromPath toPath:copyFolderPath error:&error];
                NSLogError(error)
            }
            else {
                NSString *copyFolderPath = [dateFloderPath stringByAppendingPathComponent:fpath];
                [self.fm copyItemAtPath:subFromPath toPath:copyFolderPath error:&error];
                NSLogError(error)
            }
        }
    }
    
}

@end
