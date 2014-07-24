//
//  Tool.h
//  PopStar
//
//  Created by rimi on 14-7-23.
//  Copyright (c) 2014年 brighttj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tool : NSObject


+ (CGRect)getRectInPlistWithKey:(NSString *)key;
+ (UIImage *)getSubImageInCompleteImage:(UIImage *)completeImage rect:(CGRect)rect;

@end
