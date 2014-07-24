//
//  Tool.m
//  PopStar
//
//  Created by rimi on 14-7-23.
//  Copyright (c) 2014年 brighttj. All rights reserved.
//

#import "Tool.h"

@implementation Tool

/**
 *  从plist中获取子图位置
 *
 *  @param key <#key description#>
 *
 *  @return <#return value description#>
 */
+ (CGRect)getRectInPlistWithKey:(NSString *)key {
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"CandyUI" ofType:@"plist"];
    
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    
    
    
    NSString *rectString = dic[@"frames"][key][@"textureRect"];
    rectString = [rectString stringByReplacingOccurrencesOfString:@"{" withString:@""];
    rectString = [rectString stringByReplacingOccurrencesOfString:@"}" withString:@""];
    
    NSArray *rectArray = [rectString componentsSeparatedByString:@","];
    
    CGRect rect =  CGRectMake([rectArray[0] intValue], [rectArray[1] intValue], [rectArray[2] intValue], [rectArray[3] intValue]);
    return rect;
}

/**
 *  截取子图
 *
 *  @param completeImage <#completeImage description#>
 *  @param rect          <#rect description#>
 *
 *  @return <#return value description#>
 */
+ (UIImage *)getSubImageInCompleteImage:(UIImage *)completeImage rect:(CGRect)rect {
    
    CGImageRef subImageRef = CGImageCreateWithImageInRect(completeImage.CGImage, rect);
	CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
	
    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    
    return smallImage;
}

@end
