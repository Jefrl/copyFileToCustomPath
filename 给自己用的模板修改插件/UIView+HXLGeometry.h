//
//  UIView+HXLGeometry.h
//  BaiSiBuDeJie
//
//  Created by Jefrl on 17/3/4.
//  Copyright © 2017年 com.Jefrl.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (HXLGeometry)

/**
 UIView 扩展一个判断图片的真实类型的方法
 
 @param data 图片的二进制流
 @return 图片类型字符串
 */
- (NSString *)contentTypeForImageData:(NSData *)data;

/** xib 的加载 */
+ (instancetype)loadViewFormXib:(NSInteger)index;
/** 当前 View 是否在主窗口上 */
- (BOOL)isShowKeyWindow;

// 分类如果增添了属性, 那么要自己实现对应的 set, get 方法

/** UIView.frame.origin.x */
@property (nonatomic, assign) CGFloat x;
/** UIView.frame.origin.y */
@property (nonatomic, assign) CGFloat y;
/** UIView.frame.size.width */
@property (nonatomic, assign) CGFloat width;
/** UIView.frame.size.height */
@property (nonatomic, assign) CGFloat height;
/** UIView.frame.origin.x */
@property (nonatomic, assign) CGFloat originX;
/** UIView.frame.origin.y */
@property (nonatomic, assign) CGFloat originY;
/** UIView.center.x */
@property (nonatomic, assign) CGFloat centerX;
/** UIView.center.y */
@property (nonatomic, assign) CGFloat centerY;

/** UIView.frame.origin */
@property (nonatomic, readwrite, assign) CGPoint origin;
/** UIView.frame.size */
@property (nonatomic, assign) CGSize size;




@end
