//
//  HXLPCH.h
//  给自己用的模板修改插件
//
//  Created by Jefrl on 2017/6/22.
//  Copyright © 2017年 Jefrl. All rights reserved.
//

#ifndef HXLPCH_h
#define HXLPCH_h

//=================================================================
//                       字体颜色区域
//=================================================================
// 定义字体大小 (正常)
#define FONT_11 [UIFont systemFontOfSize:11.0f]
#define FONT_12 [UIFont systemFontOfSize:12.0f]
#define FONT_13 [UIFont systemFontOfSize:13.0f]
#define FONT_14 [UIFont systemFontOfSize:14.0f]
#define FONT_15 [UIFont systemFontOfSize:15.0f]
#define FONT_16 [UIFont systemFontOfSize:16.0f]
#define FONT_17 [UIFont systemFontOfSize:17.0f]
#define FONT_18 [UIFont systemFontOfSize:18.0f]
#define FONT_30 [UIFont systemFontOfSize:30.0f]
#define FONT_38 [UIFont systemFontOfSize:38.0f]

// 定义字体大小 (加粗)
#define FONT_B_11 [UIFont boldSystemFontOfSize:11.0f]
#define FONT_B_12 [UIFont boldSystemFontOfSize:12.0f]
#define FONT_B_13 [UIFont boldSystemFontOfSize:13.0f]
#define FONT_B_14 [UIFont boldSystemFontOfSize:14.0f]
#define FONT_B_15 [UIFont boldSystemFontOfSize:15.0f]
#define FONT_B_16 [UIFont boldSystemFontOfSize:16.0f]
#define FONT_B_17 [UIFont boldSystemFontOfSize:17.0f]
#define FONT_B_18 [UIFont boldSystemFontOfSize:18.0f]
#define FONT_B_37 [UIFont boldSystemFontOfSize:37.0f]
#define FONT_B_38 [UIFont boldSystemFontOfSize:38.0f]

// 颜色
#define RED_COLOR    [UIColor redColor]
#define ORANGE_COLOR [UIColor orangeColor]
#define YELLOW_COLOR [UIColor yellowColor]
#define GREEN_COLOR  [UIColor greenColor]
#define BLUE_COLOR   [UIColor blueColor]
#define CYAN_COLOR   [UIColor cyanColor]
#define PURPLE_COLOR [UIColor purpleColor]
#define BLACK_COLOR  [UIColor blackColor]
#define WHITE_COLOR  [UIColor whiteColor]
#define GRAY_COLOR   [UIColor grayColor]
#define BROWN_COLOR  [UIColor brownColor]
// 浅灰色
#define LIGHTGRAY_COLOR [UIColor lightGrayColor]
// 整体底部衬托灰色
#define GRAY_PUBLIC_COLOR RGBColor(233, 233, 233, 1)
// 整体外部呈现灰色
#define GRAY_WHITE_COLOR RGBColor(240, 240, 240, 1)
// RGB 指定颜色与不透明度 (不透明: 1 透明: 0)
#define RGBColor(r, g, b, a) [UIColor colorWithRed: r / 255.0 green: g / 255.0 blue: b / 255.0 alpha: a]
// 随机颜色(不透明)
#define RGBRandomColor RGBColor(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256), 1);

// 主窗口
#define KEYWINDOW [UIApplication sharedApplication].keyWindow
// 关于错误的打印
#define Error(error) if (error) { NSLog(@"%@", error); }
// 关于错误的打印
#define NSLogError(error)  if (error) { NSLog(@"%@", error); return;}

// 统一日志输出
#define NSLogTest NSLog(@"")
#ifdef DEBUG  // 调试阶段

#define NSLog(...)  NSLog(@"$--%d-->: %s\nLog: %@ :<--%d--$\n\n", __LINE__, __func__, [NSString stringWithFormat:__VA_ARGS__], __LINE__)
#else  // 发布阶段

#define NSLog(...)
#endif

//=================================================================
//                       硬件或设备信息读取区域
//=================================================================
// 当前屏幕尺寸
#define HXL_SCREEN [UIScreen mainScreen]
#define HXL_SCREEN_BOUNDS [UIScreen mainScreen].bounds
#define HXL_SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define HXL_SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
// 设备类型判断
#define ScreenMaxL (MAX(HXL_SCREEN_WIDTH, HXL_SCREEN_HEIGHT))
#define ScreenMinL (MIN(HXL_SCREEN_WIDTH, HXL_SCREEN_HEIGHT))
#define IsiPhone4   (IsiPhone && ScreenMaxL < 568.0)
#define IsiPhone5   (IsiPhone && ScreenMaxL == 568.0)
#define IsiPhone6Or7   (IsiPhone && ScreenMaxL == 667.0)
#define IsiPhone6POr7P  (IsiPhone && ScreenMaxL == 736.0)

#define IsiPad      (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IsiPhone    (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IsRetain    ([[UIScreen mainScreen] scale] >= 2.0)
// 读取当前 app 版本
#define CURRENT_VERSION(versionKey) [NSBundle mainBundle].infoDictionary[versionKey]
// iOS系统版本
#define Is_iOS_11_Later      [[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0
#define Is_iOS_10_Later      [[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0
#define Is_iOS_9_Later      [[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0
#define Is_iOS_8_Later      [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0
#define Is_iOS_7_Later      [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0

//=================================================================
//                       其他引用自定义区域
//=================================================================

// 将数据写到桌面的plist
#define WriteToPlist(dictionary, filename, type) [dictionary writeToFile:[NSString stringWithFormat:@"/Users/Jefrl/Desktop/01 - Comment/%@%@.plist", filename, type] atomically:YES];

// 弱引用
#define HXL_WEAKSELF   __weak typeof(self) weakSelf = self
#define HXL_STRONGSELF __strong typeof(self) strongSelf = weakSelf

/** 需要全文引用的头文件 */
// Const 文件
// #import "HXLConst.h"
#import "UIView+HXLGeometry.h"
#import "SVProgressHUD.h"

#endif /* HXLPCH_h */
