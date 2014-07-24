//
//  StarButton.m
//  PopStar
//
//  Created by rimi on 14-7-18.
//  Copyright (c) 2014年 brighttj. All rights reserved.
//

#import "StarButton.h"
#import "Tool.h"

@implementation StarButton

- (id)initWithType:(NSInteger)type {
    
    self = [super init];
    if (self) {
        _type = type;
        
        // 根据当前的类型设置星星图片
        if (_type == 0) {
            [self setImage:[UIImage imageNamed:@"item1"] forState:UIControlStateNormal];
        }
        else if (_type == 1) {
            [self setImage:[UIImage imageNamed:@"item2"] forState:UIControlStateNormal];
        }
        else if (_type == 2) {
            [self setImage:[UIImage imageNamed:@"item3"] forState:UIControlStateNormal];
        }
        else if (_type == 3) {
            [self setImage:[UIImage imageNamed:@"item4"] forState:UIControlStateNormal];
        }
        else if (_type == 4) {
            [self setImage:[UIImage imageNamed:@"item5"] forState:UIControlStateNormal];
        }
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
