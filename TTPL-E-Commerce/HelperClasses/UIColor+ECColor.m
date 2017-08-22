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
    return RGBACOLOR(98, 181, 75, 1.0);
}

+ (UIColor *)menuBg {
    return RGBACOLOR(255, 255, 255, 1.0);
}

+ (UIColor *)menuItemBg {
    return RGBACOLOR(98, 181, 75, 1.0);
}

+ (UIColor *)pageMenuBg {
    return RGBACOLOR(168,214,156, 1.0);
}
    
+ (UIColor *)selectedMenuBg {
    return RGBACOLOR(63,116,48, 1.0);
}

+ (UIColor *)selectedPageMenuLabel {
    return RGBACOLOR(63,116,48, 1.0);
}
    
+ (UIColor *)unselectedPageMenuLabel {
    return RGBACOLOR(170, 215, 158, 1.0);
}

@end
