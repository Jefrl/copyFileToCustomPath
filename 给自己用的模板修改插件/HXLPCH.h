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
#ifdef __ObJC__

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

// 将数据写到桌面的plist
#define WriteToPlist(data, filename, type) [data writeToFile:[NSString stringWithFormat:@"/Users/Jefrl/Desktop/%@%@.plist", filename, type] atomically:YES];


#endif /* __ObJC__ */


#endif /* HXLPCH_h */
