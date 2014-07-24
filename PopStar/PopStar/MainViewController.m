//
//  MainViewController.m
//  PopStar
//
//  Created by rimi on 14-7-16.
//  Copyright (c) 2014年 brighttj. All rights reserved.
//

#import "MainViewController.h"
#import "TransitionPageView.h"
#import "GameViewController.h"
#import "Tool.h"

@import AudioToolbox;

@interface MainViewController () {
    
    UIButton *_resumebutton;
    UILabel *_highScoreLabel;
    UIButton *_volumeButton;
    NSInteger _hightScore;
    SystemSoundID _selectSoundID;            // 选中音效的ID
    BOOL _shouldPlaySound;                   // 是否播放音效
}

- (void)initializeDataSource;
- (void)initializeAppearance;
- (void)buttonPress:(UIButton *)sender;
- (void)buttonFallAnimation;
- (void)newGame;
- (void)resume;
- (void)changeVolume;
- (BOOL)existGameData;

@end

@implementation MainViewController

/**
 *  设置状态栏是否隐藏
 *
 *  @return 标识状态栏是否隐藏
 */
-(BOOL)prefersStatusBarHidden {
    
    return YES;
}

- (void)dealloc {
    
    [_resumebutton release];
    [_highScoreLabel release];
    [_volumeButton release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initializeDataSource];
    [self initializeAppearance];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    // 判断当前是否可以继续游戏
    _resumebutton.enabled = [self existGameData];
    
    // 更新最高分数
    _highScoreLabel.text = [NSString stringWithFormat:@"%ld", _hightScore];
    
    // 按钮下落动画
    [self buttonFallAnimation];
}

- (void)initializeDataSource {
    
    _shouldPlaySound = YES;
    
    // 关联音效ID
    NSURL *url = [[NSBundle mainBundle] URLForAuxiliaryExecutable:@"触发人音.caf"];
    AudioServicesCreateSystemSoundID((CFTypeRef)url, &_selectSoundID);
}

- (void)initializeAppearance {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 完整的精灵图片
    UIImage *completeImage = [UIImage imageNamed:@"CandyUI"];
    
    // 背景图片
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    NSString *backgroundImagePath = [[NSBundle mainBundle] pathForAuxiliaryExecutable:@"背景A.png"];
    UIImage *backgroundImage = [[UIImage alloc] initWithContentsOfFile:backgroundImagePath];
    backgroundImageView.image = backgroundImage;
    backgroundImageView.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:backgroundImageView];
    [backgroundImage release];
    [backgroundImageView release];
    
    // LOGO
    NSString *logoImagePath = [[NSBundle mainBundle] pathForAuxiliaryExecutable:@"pop.png"];
    UIImage *logoImage = [[UIImage alloc] initWithContentsOfFile:logoImagePath];
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:logoImage];
    logoImageView.bounds = CGRectMake(0, 0, 300, 200);
    logoImageView.center = CGPointMake(CGRectGetMidX(self.view.bounds), 170);
    logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:logoImageView];
    [logoImage release];
    [logoImageView release];
    
    // 新建游戏按钮
    UIButton *newGamebutton = [UIButton buttonWithType:UIButtonTypeCustom];
    [newGamebutton setImage:[UIImage imageNamed:@"NewGame"] forState:UIControlStateNormal];
    newGamebutton.bounds = CGRectMake(0, 0, 170, 70);
    newGamebutton.center = CGPointMake(CGRectGetMidX(self.view.bounds), 340);
    newGamebutton.tag = 10;
    [newGamebutton addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:newGamebutton];
    
    // 继续游戏按钮
    _resumebutton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [_resumebutton setImage:[UIImage imageNamed:@"Resume"] forState:UIControlStateNormal];
    _resumebutton.bounds = CGRectMake(0, 0, 170, 70);
    _resumebutton.center = CGPointMake(CGRectGetMidX(self.view.bounds), 420);
    _resumebutton.tag = 11;
    [_resumebutton addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
    _resumebutton.enabled = [self existGameData];
    [self.view addSubview:_resumebutton];
    

    // 最高分数图片
    CGRect rect = [Tool getRectInPlistWithKey:@"最好记录.png"];
    UIImageView *highScoreImageView = [[UIImageView alloc] initWithImage:[Tool getSubImageInCompleteImage:completeImage rect:rect]];
    highScoreImageView.frame = CGRectMake(20, 10, 100, 30);
    highScoreImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:highScoreImageView];
    [highScoreImageView release];
    
    
    // 最高分数
    _highScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(135, 12, 130, 25)];
    _highScoreLabel.text = [NSString stringWithFormat:@"%ld", _hightScore];
    _highScoreLabel.font = [UIFont fontWithName:@"Bodoni 72 Smallcaps" size:20];
    _highScoreLabel.textAlignment = NSTextAlignmentCenter;
    _highScoreLabel.textColor = [UIColor whiteColor];
    _highScoreLabel.backgroundColor = [UIColor colorWithRed:15/255.0 green:76/255.0 blue:168/255.0 alpha:0.8];
    _highScoreLabel.layer.cornerRadius = 10;
    _highScoreLabel.clipsToBounds = YES;
    [self.view addSubview:_highScoreLabel];
    [_highScoreLabel release];
    
    
    // 音效按钮
    _volumeButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    rect = [Tool getRectInPlistWithKey:@"声音开1.png"];
    [_volumeButton setBackgroundImage:[Tool getSubImageInCompleteImage:completeImage rect:rect] forState:UIControlStateNormal];
    rect = [Tool getRectInPlistWithKey:@"声音关1.png"];
    [_volumeButton setBackgroundImage:[Tool getSubImageInCompleteImage:completeImage rect:rect] forState:UIControlStateSelected];
    _volumeButton.frame = CGRectMake(280, 12, 30, 30);
    [_volumeButton addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
    _volumeButton.tag = 12;
    [self.view addSubview:_volumeButton];
    
    

}

- (void)buttonPress:(UIButton *)sender {
    
    // 音效播放
    if (_shouldPlaySound) {
        AudioServicesPlaySystemSound(_selectSoundID);
    }
    
    NSInteger index = sender.tag - 10;
    
    switch (index) {
            
        // 开始新游戏
        case 0:
            [self newGame];
            break;
        // 继续游戏
        case 1:
            [self resume];
            break;
        // 设置是否有音效
        case 2:
            [self changeVolume];
            break;
        
        default:
            break;
    }
}


- (void)buttonFallAnimation {
    
    UIButton *newGameButton = (UIButton *)[self.view viewWithTag:10];
    newGameButton.center = CGPointMake(newGameButton.center.x, -50);
    
    UIButton *resumeButton = (UIButton *)[self.view viewWithTag:11];
    resumeButton.center = CGPointMake(newGameButton.center.x, -50);
    
    // 继续游戏按钮掉落动画
    [UIView animateWithDuration:0.25 animations:^{
        resumeButton.center = CGPointMake(newGameButton.center.x, 450);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            
            resumeButton.center = CGPointMake(newGameButton.center.x, 420);
        }];
    }];
    
    // 开始游戏按钮掉落动画
    [UIView animateWithDuration:0.15 delay:0.2 options:UIViewAnimationOptionTransitionNone animations:^{
        newGameButton.center = CGPointMake(newGameButton.center.x, 450);
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.1 animations:^{
            
            newGameButton.center = CGPointMake(newGameButton.center.x, 340);
        }];
    }];
}

- (void)newGame {
    
    // 界面消失
    GameViewController *gameVC = [[GameViewController alloc] initWithWhetherStartNewGame:YES shouldPlaySound:!_volumeButton.selected];
    [self presentViewController:gameVC animated:NO completion:nil];
    [gameVC release];
}

- (void)resume {
    
    // 游戏界面
    GameViewController *gameVC = [[GameViewController alloc] initWithWhetherStartNewGame:NO shouldPlaySound:!_volumeButton.selected];
    [self presentViewController:gameVC animated:NO completion:nil];
    [gameVC release];
}

- (void)changeVolume {
    
    UIButton *volumeButton = (UIButton *)[self.view viewWithTag:12];
    volumeButton.selected = !volumeButton.selected;
    _shouldPlaySound = !volumeButton.selected;
}

- (BOOL)existGameData {
    
    // 获取文件路径
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *plistPath = [documentDirectory stringByAppendingPathComponent:@"gameData.plist"];
    
    // 获取列表
    NSMutableDictionary *gameData = [NSMutableDictionary dictionaryWithDictionary:[NSMutableDictionary dictionaryWithContentsOfFile:plistPath]];
    
//    NSLog(@"GameData = %@", gameData);
    _hightScore = [gameData[@"highScore"] intValue];
    
    return gameData[@"starPosition"] == nil ? NO : YES;
}

@end
