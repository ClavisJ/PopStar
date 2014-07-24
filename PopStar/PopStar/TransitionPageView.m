//
//  TransitionPageView.m
//  PopStar
//
//  Created by rimi on 14-7-21.
//  Copyright (c) 2014年 brighttj. All rights reserved.
//

#import "TransitionPageView.h"

@interface TransitionPageView ()



@end

@implementation TransitionPageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor blackColor];
        
        // 计算剩余星星应得的分数
//        int reduce = -20;
//        int score = 2000;
//        
//        for (int i = 0; i < 10; i++) {
//            
//            reduce += 40;
//            
//            score -= reduce;
//            NSLog(@"score = %d", score);
//        }
        
        [self tipMoveIn];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [super touchesBegan:touches withEvent:event];
    

}

- (void)tipMoveIn {
    // 切换动画
    UILabel *levelLabel = [[UILabel alloc] init];
    levelLabel.bounds = CGRectMake(0, 0, 100, 30);
    levelLabel.center = CGPointMake(CGRectGetMaxX(self.bounds) + CGRectGetMidX(levelLabel.bounds), CGRectGetMidY(self.bounds) - 50);
    //        levelLabel.center = CGPointMake(100, 200);
    levelLabel.textColor = [UIColor whiteColor];
    levelLabel.textAlignment = NSTextAlignmentCenter;
    levelLabel.text = @"level1";
    levelLabel.font = [UIFont fontWithName:@"Courier New" size:20];
    levelLabel.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:levelLabel];
    [levelLabel release];
    
    [UIView animateWithDuration:0.5 animations:^{
        levelLabel.center = CGPointMake(CGRectGetMidX(self.bounds), levelLabel.center.y);
    }];
}

@end
