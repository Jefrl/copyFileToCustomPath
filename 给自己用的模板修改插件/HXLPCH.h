//
//  HXLPCH.h
//  给自己用的模板修改插件
//
//  Created by Jefrl on 2017/6/22.
//  Copyright © 2017年 Jefrl. All rights reserved.
//

#ifndef HXLPCH_h
#define HXLPCH_h

// 关于错误的打印
#define NSLogError(error)  if (error) { NSLog(@"%@", error); return;}
// 统一日志输出
#ifdef DEBUG  // 调试阶段
#define NSLog(...)  NSLog(@"$--%d-->: %s\nLog: %@ :<--%d--$\n\n", __LINE__, __func__, [NSString stringWithFormat:__VA_ARGS__], __LINE__)
#else  // 发布阶段
#define NSLog(...)
#endif

// 将数据写到桌面的plist
#define WriteToPlist(data, filename, type) [data writeToFile:[NSString stringWithFormat:@"/Users/Jefrl/Desktop/%@%@.plist", filename, type] atomically:YES];

// 头文件
#import "UIView+HXLGeometry.h"


#endif /* HXLPCH_h */
