//
//  HXLPCH.h
//  给自己用的模板修改插件
//
//  Created by Jefrl on 2017/6/22.
//  Copyright © 2017年 Jefrl. All rights reserved.
//

#ifndef HXLPCH_h
#define HXLPCH_h


// 只允许导入到 OC 相关文件
#ifndef __ObJC__

// RGB 指定颜色与不透明度 (不透明: 1 透明: 0)
#define RGBColor(r, g, b, a) [UIColor colorWithRed: r / 255.0 green: g / 255.0 blue: b / 255.0 alpha: a]

// 随机颜色(不透明)
#define RGBRandomColor RGBColor(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256), 1);

// 当前屏幕尺寸
#define SCREEN_BOUNDS [UIScreen mainScreen].bounds
#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
// 导航条 & UITabBar 条的高度
#define NAVIGATIONBAR_HEIGHT (20 + 44)
#define TABBAR_HEIGHT 49

// 统一日志输出
#ifdef DEBUG  // 调试阶段
#define NSLog(...)  NSLog(@"$--%d-->: %s\nLog: %@ :<--%d--$\n\n", __LINE__, __func__, [NSString stringWithFormat:__VA_ARGS__], __LINE__)
#else  // 发布阶段
#define NSLog(...)
#endif

// 主窗口
#define KEYWINDOW [UIApplication sharedApplication].keyWindow

// 将数据写到桌面的plist
#define WriteToPlist(data, filename, type) [data writeToFile:[NSString stringWithFormat:@"/Users/Jefrl/Desktop/%@%@.plist", filename, type] atomically:YES];

// 弱引用
#define HXL_WEAKSELF __weak typeof(self) weakSelf = self;

/** 需要全文引用的头文件 */
// 三方类

// 网络工具类

// Const 文件

// 分类

// 基类

// 公共 URL

/** 各个类中的宏 */



//=================================================================
//                       区域一
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

// 定义字体大小 (加粗)
#define FONT_B_11 [UIFont boldSystemFontOfSize:11.0f]
#define FONT_B_12 [UIFont boldSystemFontOfSize:12.0f]
#define FONT_B_13 [UIFont boldSystemFontOfSize:13.0f]
#define FONT_B_14 [UIFont boldSystemFontOfSize:14.0f]
#define FONT_B_15 [UIFont boldSystemFontOfSize:15.0f]
#define FONT_B_16 [UIFont boldSystemFontOfSize:16.0f]
#define FONT_B_17 [UIFont boldSystemFontOfSize:17.0f]
#define FONT_B_18 [UIFont boldSystemFontOfSize:18.0f]

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
#define LIGHTGRAY_COLOR [UIColor lightGrayColor]






#endif


#endif /* HXLPCH_h */
