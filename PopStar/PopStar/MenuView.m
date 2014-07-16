//
//  MenuView.m
//  PopStar
//
//  Created by rimi on 14-7-16.
//  Copyright (c) 2014年 brighttj. All rights reserved.
//

#import "MenuView.h"

@implementation MenuView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        // 背景图片
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        NSString *backgroundImagePath = [[NSBundle mainBundle] pathForAuxiliaryExecutable:@""];
        
        UIImage *backgroundImage = [[UIImage alloc] initWithContentsOfFile:backgroundImagePath];
        
        // frame = {0, 0, 320, 568}
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
