//
//  UIView+HXLGeometry.m
//  BaiSiBuDeJie
//
//  Created by Jefrl on 17/3/4.
//  Copyright © 2017年 com.Jefrl.www. All rights reserved.
//

#import "UIView+HXLGeometry.h"

@implementation UIView (HXLGeometry)

/**
 UIView 扩展一个判断图片的真实类型的方法
 
 @param data 图片的二进制流
 @return 图片类型字符串
 */
- (NSString *)contentTypeForImageData:(NSData *)data
{
    uint8_t c;
    [data getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return @"jpeg";
        case 0x89:
            return @"png";
        case 0x47:
            return @"gif";
        case 0x49:
        case 0x4D:
            return @"tiff";
        case 0x52:
            if ([data length] < 12) {
                return nil;
            }
            
            NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
            if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                return @"webp";
            }
            return @"未判断出来";
    }
    return @"未判断出来";
    
}

/** xib 的加载 */
+ (instancetype)loadViewFormXib:(NSInteger)index {
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil];
    return array[index];
}


/**
 当前 View 是否在主窗口上

 @return BOOL
 */
- (BOOL)isShowKeyWindow
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    // 将 View 的坐标 frame 的参照物从 superView 转换成主窗口为参照物的 newFrame;
    CGRect newFrame = [self.superview convertRect:self.frame toView:keyWindow];
    // 判断是否有交叠部分;
    BOOL isIntersect = CGRectIntersectsRect(newFrame, keyWindow.bounds);
    
    BOOL flag = !self.isHidden && self.alpha > 0.01 && self.window == keyWindow && isIntersect;
    
    return flag;
}

- (void)setX:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)x {
    return self.frame.origin.x;
}

- (void)setY:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)y {
    return self.frame.origin.y;
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setOriginX:(CGFloat)originX
{
    CGPoint origin = self.origin;
    origin.x = originX;
    self.origin = origin;
}

- (CGFloat)originX
{
    return self.origin.x;
}

- (void)setOriginY:(CGFloat)originY
{
    CGPoint origin = self.origin;
    origin.y = originY;
    self.origin = origin;
}

- (CGFloat)originY
{
    return self.origin.x;
}

- (void)setCenterX:(CGFloat)centerX {
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}


- (CGFloat)centerX {
    return self.center.x;
}

- (void)setCenterY:(CGFloat)centerY {
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGFloat)centerY {
    return self.center.y;
}

// 范围性质, center 系统本身有
- (void)setOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGPoint)origin {
    return self.frame.origin;
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGSize)size {
    return self.frame.size;
}


@end
