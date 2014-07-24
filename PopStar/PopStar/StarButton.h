//
//  StarButton.h
//  PopStar
//
//  Created by rimi on 14-7-18.
//  Copyright (c) 2014年 brighttj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StarButton : UIButton {
    
    NSInteger _type;
}

@property (nonatomic, assign, readonly) NSInteger type;

- (id)initWithType:(NSInteger)type;

@end
