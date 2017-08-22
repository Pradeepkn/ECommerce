//
//  UIColor+ECColor.m
//  ECApp
//
//  Created by Pradeep on 7/16/17.
//  Copyright © 2017 Pradeep. All rights reserved.
//

#import "UIColor+ECColor.h"

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

@implementation UIColor (ECColor)

+ (UIColor *)theme {
    return RGBACOLOR(245, 250, 254, 1.0);
}

+ (UIColor *)subTheme {
    return RGBACOLOR(86, 106, 223, 1.0);
}

+ (UIColor *)navigationBar {
    return RGBACOLOR(108, 127, 252, 1.0);
}

+ (UIColor *)menuBg {
    return RGBACOLOR(58, 61, 77, 1.0);
}

+ (UIColor *)menuItemBg {
    return RGBACOLOR(48, 52, 62, 1.0);
}

+ (UIColor *)pageMenuBg {
    return RGBACOLOR(83, 105, 218, 1.0);
}

+ (UIColor *)unselectedPageMenuLabel {
    return RGBACOLOR(162, 183, 253, 1.0);
}

@end
