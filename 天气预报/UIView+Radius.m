//
//  UIView+Radius.m
//  天气预报
//
//  Created by Mr.liu on 16/3/4.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "UIView+Radius.h"

@implementation UIView (Radius)

- (CGFloat)cornerRadius {
    return self.layer.cornerRadius;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = cornerRadius > 0;
}

@end
