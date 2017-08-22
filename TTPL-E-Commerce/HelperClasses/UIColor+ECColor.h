//
//  UIColor+ECColor.h
//  ECApp
//
//  Created by Pradeep on 7/16/17.
//  Copyright © 2017 Pradeep. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (ECColor)

+ (UIColor *)theme;

+ (UIColor *)subTheme;

+ (UIColor *)navigationBar;

+ (UIColor *)menuBg;

+ (UIColor *)menuItemBg;

+ (UIColor *)pageMenuBg;

+ (UIColor *)selectedMenuBg;
    
+ (UIColor *)selectedPageMenuLabel;
    
+ (UIColor *)unselectedPageMenuLabel;

@end
