//
//  UIImage+PPCategory.m
//  PhotoLibrary
//
//  Created by 王战胜 on 2017/2/22.
//  Copyright © 2017年 gocomtech. All rights reserved.
//

#import "UIImage+PPCategory.h"

@implementation UIImage (PPCategory)
- (UIImage *)scaleToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [self drawInRect:CGRectMake(0.0, 0.0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

@end
