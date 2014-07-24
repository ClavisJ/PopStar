//
//  GameViewController.m
//  PopStar
//
//  Created by rimi on 14-7-23.
//  Copyright (c) 2014年 brighttj. All rights reserved.
//

#import "GameViewController.h"
#import "StarButton.h"
#import "Tool.h"

#define COLUMN 10
#define ROW 10
#define TYPENUMBER 5
#define STAR_TAG_BASE 10

@import AudioToolbox;

@interface GameViewController () {
    
    NSMutableArray *_selectedStarButtonTag;  // 选中的星星的tag
    NSMutableArray *_starNumberInColumn;     // 每列星星的个数
    NSArray *_scoreArray;                    // 每关分数
    NSDictionary *_starPositionDictionary;   // 从plist里面读取到的数据
    NSArray *_removeStarArray;               // 保存删除所有星星
    NSInteger _stage;                        // 关卡数
    NSInteger _score;                        // 当前得分
    NSInteger _highScore;                    // 最高分数
    UILabel *_scoreLabel;
    UILabel *_stageLabel;
    UILabel *_targetLabel;
    UILabel *_highScoreLabel;
    UILabel *_tipLabel;                      // 提示你当前选中的星星值多少分
    BOOL _whetherStartNewGame;               // 是否开始新游戏
    BOOL _shouldPlaySound;                   // 是否播放音效
    SystemSoundID _selectSoundID;            // 选中音效的ID
    SystemSoundID _failSoundID;              // 失败音效的ID
    SystemSoundID _breakSoundID;             // 星星破碎的音效ID
    SystemSoundID _stageClearSoundID;        // 达到目标分数的音效ID
    SystemSoundID _successSoundID;           // 成功过关的音效
}


- (void)readGameData;
- (void)initializeDataSource;
- (void)initializeAppearance;
- (void)initializeStarButton;

- (void)buttonPress:(UIButton *)sender;
- (void)starButtonPress:(StarButton *)sender;

- (void)selectALLSameTypeStarButton:(StarButton *)sender;
- (BOOL)wheaterOutOfUpBounds:(NSInteger)index;
- (BOOL)wheaterOutOfDownBounds:(NSInteger)index;
- (BOOL)wheaterOutOfLeftBounds:(NSInteger)index;
- (BOOL)wheaterOutOfRightBounds:(NSInteger)index;

- (void)highlightSelectedStarButton;
- (void)cancelHighlightSelectedStarButton;
- (void)removeAllSelectedStar;
- (void)starFall;

- (void)calculateScore;
- (void)scoreChangeToCurrentScore;

- (BOOL)isGameOver;
- (void)gameOver;

- (void)getAllRemoveStar;
- (void)removeALLStar;
- (void)startNextStage;

- (void)gamePause;
- (void)gameGoOn;
- (void)gameSave;
- (void)gameExit;
- (void)gameOverSaveData;

- (NSString *)currentTarget;
- (void)updateHighScore;
- (void)changeVolume;

- (NSComparisonResult)compare:(NSDictionary *)otherDictionary;

@end

@implementation GameViewController

-(BOOL)prefersStatusBarHidden {
    
    return YES;
}

- (id)initWithWhetherStartNewGame:(BOOL)whetherStartNewGame  shouldPlaySound:(BOOL)shouldPlaySound{
    
    self = [super init];
    if (self) {
        _whetherStartNewGame = whetherStartNewGame;
        _shouldPlaySound = shouldPlaySound;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initializeDataSource];
    [self initializeAppearance];
    
}

- (void)dealloc {
    
    [_selectedStarButtonTag release];
    [_starNumberInColumn release];
    [_scoreArray release];
    [_starPositionDictionary release];
    [_removeStarArray release];
    [_scoreLabel release];
    [_stageLabel release];
    [_targetLabel release];
    [_highScoreLabel release];
    [super dealloc];
}

- (void)initializeDataSource {
    
    // 初始化每关分数
    _scoreArray = [@[@1000, @3000, @6000, @8000, @10000, @13000, @15000, @17000, @20000] retain];
    
    // 初始化存放选中星星的tag
    _selectedStarButtonTag = [[NSMutableArray alloc] init];
    
    // 初始化保存删除时的所有星星的tag
    _removeStarArray = [[NSMutableArray alloc] init];
    
    // 默认从第一关开始
    _stage = 1;
    
    // 当前分数为0
    _score = 0;
    
    // 最高分数
    _highScore = 0;
    
    [self readGameData];
    
    // 关联音效ID
    NSURL *url = [[NSBundle mainBundle] URLForAuxiliaryExecutable:@"失败.caf"];
    AudioServicesCreateSystemSoundID((CFTypeRef)url, &_failSoundID);
    url = [[NSBundle mainBundle] URLForAuxiliaryExecutable:@"breakgrass6.wav"];
    AudioServicesCreateSystemSoundID((CFTypeRef)url, &_breakSoundID);
    url = [[NSBundle mainBundle] URLForAuxiliaryExecutable:@"炸.caf"];
    AudioServicesCreateSystemSoundID((CFTypeRef)url, &_selectSoundID);
    url = [[NSBundle mainBundle] URLForAuxiliaryExecutable:@"触发人音.caf"];
    AudioServicesCreateSystemSoundID((CFTypeRef)url, &_stageClearSoundID);
    url = [[NSBundle mainBundle] URLForAuxiliaryExecutable:@"鞭炮音效.wav"];
    AudioServicesCreateSystemSoundID((CFTypeRef)url, &_successSoundID);
}

/**
 *  读取数据
 */
- (void)readGameData {
    
    // 获取文件路径
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *plistPath = [documentDirectory stringByAppendingPathComponent:@"gameData.plist"];
    
    // 获取列表
    NSMutableDictionary *gameDate = [NSMutableDictionary dictionaryWithDictionary:[NSMutableDictionary dictionaryWithContentsOfFile:plistPath]];
    
    _highScore = [gameDate[@"highScore"] intValue];
    
    
    // 继续游戏
    if (!_whetherStartNewGame) {
        
        // 异常判断
        if (gameDate[@"score"]) {
            _score = [gameDate[@"score"] intValue];
        }
        if (gameDate[@"stage"]) {
            _stage = [gameDate[@"stage"] intValue];
        }
        
        _starPositionDictionary = [[NSDictionary dictionaryWithDictionary:gameDate[@"starPosition"]] retain];
    }
    
    
}

- (void)initializeAppearance {
    self.view.backgroundColor = [UIColor blackColor];
    
    // 完整的精灵图片
    UIImage *completeImage = [UIImage imageNamed:@"CandyUI"];
    
    // 最高分数图片
    CGRect rect = [Tool getRectInPlistWithKey:@"最好记录.png"];
    UIImageView *highScoreImageView = [[UIImageView alloc] initWithImage:[Tool getSubImageInCompleteImage:completeImage rect:rect]];
    highScoreImageView.frame = CGRectMake(20, 10, 100, 30);
    highScoreImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:highScoreImageView];
    [highScoreImageView release];
    
    // 最高分数
    _highScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(135, 12, 130, 25)];
    _highScoreLabel.text = [NSString stringWithFormat:@"%ld", _highScore];
    _highScoreLabel.font = [UIFont fontWithName:@"Bodoni 72 Smallcaps" size:20];
    _highScoreLabel.textAlignment = NSTextAlignmentCenter;
    _highScoreLabel.textColor = [UIColor whiteColor];
    _highScoreLabel.backgroundColor = [UIColor colorWithRed:15/255.0 green:76/255.0 blue:168/255.0 alpha:0.8];
    _highScoreLabel.layer.cornerRadius = 10;
    _highScoreLabel.clipsToBounds = YES;
    [self.view addSubview:_highScoreLabel];
    
    
    // 暂停按钮
    UIButton *pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rect = [Tool getRectInPlistWithKey:@"暂停按钮.png"];
    [pauseButton setBackgroundImage:[Tool getSubImageInCompleteImage:completeImage rect:rect] forState:UIControlStateNormal];
    pauseButton.frame = CGRectMake(280, 12, 25, 25);
    [pauseButton addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
    pauseButton.tag = 200;
    [self.view addSubview:pauseButton];
    
    
    // SCORE
    UILabel *scoreTextLabel = [[UILabel alloc] init];
    scoreTextLabel.bounds = CGRectMake(0, 0, 70, 25);
    scoreTextLabel.center = CGPointMake(CGRectGetMidX(self.view.bounds), 83);
    scoreTextLabel.textColor = [UIColor whiteColor];
    scoreTextLabel.layer.cornerRadius = 10;
    scoreTextLabel.clipsToBounds = YES;
    scoreTextLabel.text = @"SCORE";
    scoreTextLabel.font = [UIFont fontWithName:@"Bodoni 72 Smallcaps" size:18];
    [self.view addSubview:scoreTextLabel];
    [scoreTextLabel release];

    
    // 初始化显示当前分数的label
    _scoreLabel = [[UILabel alloc] init];
    _scoreLabel.bounds = CGRectMake(0, 0, 130, 25);
    _scoreLabel.center = CGPointMake(CGRectGetMidX(self.view.bounds), 105);
    _scoreLabel.backgroundColor = [UIColor colorWithRed:15/255.0 green:76/255.0 blue:168/255.0 alpha:0.8];
    _scoreLabel.textColor = [UIColor whiteColor];
    _scoreLabel.font = [UIFont fontWithName:@"Bodoni 72 Smallcaps" size:20];
    _scoreLabel.textAlignment = NSTextAlignmentCenter;
    _scoreLabel.layer.cornerRadius = 10;
    _scoreLabel.clipsToBounds = YES;
    _scoreLabel.text = [NSString stringWithFormat:@"%ld",_score];
    [self.view addSubview:_scoreLabel];
    
    
    // Tip
    _tipLabel = [[UILabel alloc] init];
    _tipLabel.bounds = CGRectMake(0, 0, 320, 25);
    _tipLabel.center = CGPointMake(CGRectGetMidX(self.view.bounds), 135);
    _tipLabel.textColor = [UIColor whiteColor];
    _tipLabel.font = [UIFont fontWithName:@"Bodoni 72 Smallcaps" size:18];
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_tipLabel];
    
    // STAGE 关卡文字标签
    UILabel *stageTextLabel = [[UILabel alloc] init];
    stageTextLabel.bounds = CGRectMake(0, 0, 70, 25);
    stageTextLabel.center = CGPointMake(45, 55);
    stageTextLabel.textColor = [UIColor whiteColor];
    stageTextLabel.layer.cornerRadius = 10;
    stageTextLabel.clipsToBounds = YES;
    stageTextLabel.text = @"STAGE";
    stageTextLabel.font = [UIFont fontWithName:@"Bodoni 72 Smallcaps" size:18];
    [self.view addSubview:stageTextLabel];
    [stageTextLabel release];
    
    // 具体关卡数目
    _stageLabel = [[UILabel alloc] init];
    _stageLabel.bounds = CGRectMake(0, 0, 30, 25);
    _stageLabel.center = CGPointMake(85, 55);
    _stageLabel.backgroundColor = [UIColor colorWithRed:15/255.0 green:76/255.0 blue:168/255.0 alpha:0.8];
    _stageLabel.textColor = [UIColor whiteColor];
    _stageLabel.textAlignment = NSTextAlignmentCenter;
    _stageLabel.layer.cornerRadius = 10;
    _stageLabel.clipsToBounds = YES;
    _stageLabel.text = [NSString stringWithFormat:@"%ld", _stage];
    _stageLabel.font = [UIFont fontWithName:@"Bodoni 72 Smallcaps" size:20];
//    _stageLabel.text = @"1";
    [self.view addSubview:_stageLabel];

    
    
    // TARGET 目标分数提示文字
    UILabel *targetTextLabel = [[UILabel alloc] init];
    targetTextLabel.bounds = CGRectMake(0, 0, 70, 25);
    targetTextLabel.center = CGPointMake(150, 55);
    targetTextLabel.layer.cornerRadius = 10;
    targetTextLabel.clipsToBounds = YES;
    targetTextLabel.text = @"TARGET";
    targetTextLabel.font = [UIFont fontWithName:@"Bodoni 72 Smallcaps" size:18];
    targetTextLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:targetTextLabel];
    [targetTextLabel release];
    
    // 具体的目标分数
    _targetLabel = [[UILabel alloc] init];
    _targetLabel.bounds = CGRectMake(0, 0, 100, 25);
    _targetLabel.center = CGPointMake(235, 55);
    _targetLabel.backgroundColor = [UIColor colorWithRed:15/255.0 green:76/255.0 blue:168/255.0 alpha:0.8];
    _targetLabel.textColor = [UIColor whiteColor];
    _targetLabel.textAlignment = NSTextAlignmentCenter;
    _targetLabel.layer.cornerRadius = 10;
    _targetLabel.clipsToBounds = YES;
    _targetLabel.text = [NSString stringWithFormat:@"%ld", _stage];
    _targetLabel.font = [UIFont fontWithName:@"Bodoni 72 Smallcaps" size:18];
    [self.view addSubview:_targetLabel];
    _targetLabel.text = [self currentTarget];
    
    
    // 音效按钮
    UIButton *volumeButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    rect = [Tool getRectInPlistWithKey:@"声音开.png"];
    [volumeButton setBackgroundImage:[Tool getSubImageInCompleteImage:completeImage rect:rect] forState:UIControlStateNormal];
    rect = [Tool getRectInPlistWithKey:@"声音关.png"];
    [volumeButton setBackgroundImage:[Tool getSubImageInCompleteImage:completeImage rect:rect] forState:UIControlStateSelected];
    volumeButton.frame = CGRectMake(293, 47, 20, 20);
    [volumeButton addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
    volumeButton.tag = 230;
    NSLog(@"_shouldPlaySound = %d", _shouldPlaySound);
    volumeButton.selected = !_shouldPlaySound;
    [self.view addSubview:volumeButton];
    
    // 初始化星星
    [self initializeStarButton];
}

- (void)initializeStarButton {
    
//    static 
    
    // 初始化星星
    if (_whetherStartNewGame) {
        
        // 初始化存放每一列星星个数的数组
        if (_starNumberInColumn) {
            [_starNumberInColumn removeAllObjects];
        }
        else {
            _starNumberInColumn = [[NSMutableArray alloc] init];
        }
        
        for (int i = 0; i < COLUMN; i++) {
            [_starNumberInColumn addObject:[NSNumber numberWithInt:ROW]];
        }
        
        
        float minSize = self.view.bounds.size.width / COLUMN ; // 星星的长宽
        float maxHeight = self.view.bounds.size.height; // GameView的高度
        
        // 初始化 ROW * COLUMN 的星星矩阵
        for (int i = 0; i < ROW * COLUMN; i++) {
            
            // 行
            int row = i / COLUMN;
            // 列
            int column = i % COLUMN;
            
            // 随机获取StarButton的类型
            int type = arc4random() % TYPENUMBER;
            
            StarButton *starButton;
            
            
            starButton = [[StarButton alloc] initWithType:type];
            
            // 设置大小位置
            starButton.bounds = CGRectMake(0, 0, minSize - 1, minSize - 1); // 留一像素的空隙
            starButton.center = CGPointMake(minSize * column + minSize / 2, maxHeight - minSize / 2 - minSize *row);
            
            // 配置边框
            starButton.layer.borderColor = [UIColor blackColor].CGColor;
            starButton.layer.borderWidth = 1;
            starButton.layer.cornerRadius = 5;
            
            [starButton addTarget:self action:@selector(starButtonPress:) forControlEvents:UIControlEventTouchDown];
            starButton.tag = STAR_TAG_BASE + i;
            
            [self.view addSubview:starButton];
            [starButton release];
        }
        
        if ([self isGameOver]) {
            
            // 需要重新初始化星星
            [self removeALLStar];
            [self initializeStarButton];
        }
    }
    else {
        
        NSLog(@"按照plist文件初始化星星");

        NSArray *allKeys = [_starPositionDictionary allKeys];
        
        float minSize = self.view.bounds.size.width / COLUMN ; // 星星的长宽
        float maxHeight = self.view.bounds.size.height; // GameView的高度
        
        // 初始化存放每一列星星个数的数组
        if (_starNumberInColumn) {
            [_starNumberInColumn removeAllObjects];
        }
        else {
            _starNumberInColumn = [[NSMutableArray alloc] init];
        }
        
        for (int i = 0; i < COLUMN; i++) {
            [_starNumberInColumn addObject:[NSNumber numberWithInt:0]];
        }
        
        for (id key in allKeys) {
            
            int tag = [key intValue];
            int type = [_starPositionDictionary[key] intValue];
            int column = (tag - STAR_TAG_BASE) % COLUMN;
            int row = (tag - STAR_TAG_BASE) / COLUMN;
            
            NSLog(@"tag = %d type = %d", tag, type);
            
            StarButton *starButton = [[StarButton alloc] initWithType:type];
            starButton.tag = tag;
            
            // 设置大小位置
            starButton.bounds = CGRectMake(0, 0, minSize - 1, minSize - 1); // 留一像素的空隙
            starButton.center = CGPointMake(minSize * column + minSize / 2, maxHeight - minSize / 2 - minSize *row);
            
            // 配置边框
            starButton.layer.borderColor = [UIColor blackColor].CGColor;
            starButton.layer.borderWidth = 1;
            starButton.layer.cornerRadius = 5;
            
            [starButton addTarget:self action:@selector(starButtonPress:) forControlEvents:UIControlEventTouchDown];
            
            [self.view addSubview:starButton];
            [starButton release];
            
            // 更新每列星星个数
            int starNumber = [_starNumberInColumn[column] intValue] + 1;
            [_starNumberInColumn replaceObjectAtIndex:column withObject:@(starNumber)];
        }
        
        NSLog(@"_starNumberInColumn = %@", _starNumberInColumn);
        
        _whetherStartNewGame = YES;
    }

}

- (void)buttonPress:(UIButton *)sender {
    
    // 暂停游戏
    if (sender.tag == 200) {
        
        [self gamePause];
    }
    // 继续游戏
    else if (sender.tag == 210) {
        
        [self gameGoOn];
    }
    // 保存并退出
    else if (sender.tag == 220) {
        
        [self gameSave];
    }
    else if (sender.tag == 230) {
        
        [self changeVolume];
    }
    
}

- (void)starButtonPress:(StarButton *)sender {
    
    
//    [self gameOver];
    
    // 音效播放
    if (_shouldPlaySound) {
        AudioServicesPlaySystemSound(_selectSoundID);
    }
    
    // 异常判断
    if (![sender isKindOfClass:[StarButton class]]) {
        NSLog(@"点击的不是星星");
        return;
    }
    
    NSLog(@"tag = %ld type = %ld selected = %d", sender.tag, sender.type, sender.selected);
    
    // 如果在选中状态下点击StarButton，则移除所有选中的星星
    if (sender.selected) {
        [self removeAllSelectedStar];
        return;
    }
    
    // 取消所有StarButton的选中状态
    [self cancelHighlightSelectedStarButton];
    
    // 清空存放选中星星按钮下标的数组
    [_selectedStarButtonTag removeAllObjects];
    
    // 将自身加入数组
    sender.selected = YES;
    [_selectedStarButtonTag addObject:[NSNumber numberWithInt:(int)sender.tag]];
    
    // 选中附近所有相同颜色的StarButton
    [self selectALLSameTypeStarButton:sender];
    
    // 选中两个以上的星星就添加高亮状态
    if (_selectedStarButtonTag.count >= 2) {
        
        [self highlightSelectedStarButton];
        
        // 修改提示文字
        NSInteger score = 5 * pow(_selectedStarButtonTag.count, 2);
        
        _tipLabel.text = [NSString stringWithFormat:@"%ld blocks %ld points", _selectedStarButtonTag.count, score];
        
        // 提示动画
        [UIView animateWithDuration:0.1 animations:^{
            _tipLabel.transform = CGAffineTransformMakeScale(1.5, 1.5);
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.05 animations:^{
                
                _tipLabel.transform = CGAffineTransformScale(_tipLabel.transform, 0.5, 0.5);
                
            } completion:^(BOOL finished) {
                
                [UIView animateWithDuration:0.05 animations:^{
                    
                    _tipLabel.transform = CGAffineTransformIdentity;
                }];
            }];
        }];
    }
    else {
        
        [self cancelHighlightSelectedStarButton];
        
        // 修改提示文字
        _tipLabel.text = @"";
    }
}


/**
 *  选中附近所有相同颜色的StarButton
 *
 *  @param sender 当前的StarButton
 */
- (void)selectALLSameTypeStarButton:(StarButton *)sender {
    
    
    // 异常判断
    if (!sender) {
        return;
    }
    
    // 上
    // 判断是否越界
    if ([self wheaterOutOfUpBounds:sender.tag - STAR_TAG_BASE]) {
        
        StarButton *upStarButton = (StarButton *)[self.view viewWithTag:sender.tag + COLUMN];
        
        // 类型相同,并且还没有遍历这个星星
        if (upStarButton.type == sender.type && [_selectedStarButtonTag indexOfObject:[NSNumber numberWithInt:(int)upStarButton.tag]] == NSNotFound) {
            
            upStarButton.selected = YES;
            [_selectedStarButtonTag addObject:[NSNumber numberWithInt:(int)upStarButton.tag]];
            [self selectALLSameTypeStarButton:upStarButton]; // 递归：将自身作为起点再去遍历
        }
    }
    
    // 下
    // 判断是否越界
    if ([self wheaterOutOfDownBounds:sender.tag - STAR_TAG_BASE]) {
        
        StarButton *downStarButton = (StarButton *)[self.view viewWithTag:sender.tag - COLUMN];
        
        // 类型相同,并且还没有遍历这个星星
        if (downStarButton.type == sender.type && [_selectedStarButtonTag indexOfObject:[NSNumber numberWithInt:(int)downStarButton.tag]] == NSNotFound) {
            
            downStarButton.selected = YES;
            [_selectedStarButtonTag addObject:[NSNumber numberWithInt:(int)downStarButton.tag]];
            [self selectALLSameTypeStarButton:downStarButton]; // 递归：将自身作为起点再去遍历
        }
    }
    
    // 左
    // 判断是否越界
    if ([self wheaterOutOfLeftBounds:sender.tag - STAR_TAG_BASE]) {
        
        StarButton *leftStarButton = (StarButton *)[self.view viewWithTag:sender.tag - 1];
        
        // 类型相同,并且还没有遍历这个星星
        if (leftStarButton.type == sender.type && [_selectedStarButtonTag indexOfObject:[NSNumber numberWithInt:(int)leftStarButton.tag]] == NSNotFound) {
            
            leftStarButton.selected = YES;
            [_selectedStarButtonTag addObject:[NSNumber numberWithInt:(int)leftStarButton.tag]];
            [self selectALLSameTypeStarButton:leftStarButton]; // 递归：将自身作为起点再去遍历
        }
    }
    
    // 右
    // 判断是否越界
    if ([self wheaterOutOfRightBounds:sender.tag - STAR_TAG_BASE]) {
        
        StarButton *rightStarButton = (StarButton *)[self.view viewWithTag:sender.tag + 1];
        
        // 类型相同,并且还没有遍历这个星星
        if (rightStarButton.type == sender.type && [_selectedStarButtonTag indexOfObject:[NSNumber numberWithInt:(int)rightStarButton.tag]] == NSNotFound) {
            
            rightStarButton.selected = YES;
            [_selectedStarButtonTag addObject:[NSNumber numberWithInt:(int)rightStarButton.tag]];
            [self selectALLSameTypeStarButton:rightStarButton]; // 递归：将自身作为起点再去遍历
        }
    }
    
    
}

/**
 *  是否上面的星星越界
 *
 *  @param index 当前位置下标
 *
 *  @return 是否越界
 */
- (BOOL)wheaterOutOfUpBounds:(NSInteger)index {
    
    // 异常判断
    if (index < 0 || index > COLUMN * ROW - 1) {
        return NO;
    }
    
    // 判断上面是否已经为空
    if (![self.view viewWithTag:index + COLUMN + STAR_TAG_BASE]) {
        return NO;
    }
    
    
    if (index + COLUMN > COLUMN * ROW - 1) {
        return NO;
    }
    
    return YES;
}

/**
 *  是否下面的星星越界
 *
 *  @param index 当前位置下标
 *
 *  @return 是否越界
 */
- (BOOL)wheaterOutOfDownBounds:(NSInteger)index {
    
    // 异常判断
    if (index < 0 || index > COLUMN * ROW - 1) {
        return NO;
    }
    
    // 判断下面是否已经为空
    if (![self.view viewWithTag:index - COLUMN + STAR_TAG_BASE]) {
        return NO;
    }
    
    
    if (index - COLUMN < 0) {
        return NO;
    }
    
    return YES;
}

/**
 *  是否左边的星星越界
 *
 *  @param index 当前位置下标
 *
 *  @return 是否越界
 */
- (BOOL)wheaterOutOfLeftBounds:(NSInteger)index {
    
    // 异常判断
    if (index < 0 || index > COLUMN * ROW - 1) {
        return NO;
    }
    
    // 判断左边是否已经为空
    if (![self.view viewWithTag:index - 1 + STAR_TAG_BASE]) {
        return NO;
    }
    
    // 如果不在同一行，则越界
    if (index - 1 < 0 || (index - 1) / COLUMN != index / COLUMN) {
        return NO;
    }
    
    return YES;
}

/**
 *  是否右边的星星越界
 *
 *  @param index 当前位置下标
 *
 *  @return 是否越界
 */
- (BOOL)wheaterOutOfRightBounds:(NSInteger)index {
    
    // 异常判断
    if (index < 0 || index > COLUMN * ROW - 1) {
        return NO;
    }
    
    // 判断右边是否已经为空
    if (![self.view viewWithTag:index + 1 + STAR_TAG_BASE]) {
        return NO;
    }
    
    // 如果不在同一行，则越界
    if (index + 1 > COLUMN * ROW - 1 || (index + 1) / COLUMN != index / COLUMN) {
        return NO;
    }
    
    return YES;
}

/**
 *  高亮显示选中的StarButton
 */
- (void)highlightSelectedStarButton {
    
    for (NSNumber *tag in _selectedStarButtonTag) {
        
        StarButton *starButton = (StarButton *)[self.view viewWithTag:[tag intValue]];
        starButton.layer.borderColor = [UIColor whiteColor].CGColor;
    }
}

/**
 *  取消星星的高亮显示
 */
- (void)cancelHighlightSelectedStarButton {
    
    for (int row = 0; row < ROW; row++) {
        for (int col = 0; col < COLUMN; col++) {
            
            int tag = row * COLUMN +col + STAR_TAG_BASE;
            StarButton *starButton = (StarButton *)[self.view viewWithTag:tag];
            if (starButton) {
                starButton.selected = NO;
                starButton.layer.borderColor = [UIColor blackColor].CGColor;
            }
        }
    }
    
//    for (NSNumber *tag in _selectedStarButtonTag) {
//        
//        StarButton *starButton = (StarButton *)[self.view viewWithTag:[tag intValue]];
//        starButton.selected = NO;
//        starButton.layer.borderColor = [UIColor blackColor].CGColor;
//    }
}

/**
 *  移除所有高亮的星星
 */
- (void)removeAllSelectedStar {
    
    // 音效播放
    if (_shouldPlaySound) {
        AudioServicesPlaySystemSound(_breakSoundID);
    }
    
    for (NSNumber *tag in _selectedStarButtonTag) {
        
        StarButton *starButton = (StarButton *)[self.view viewWithTag:[tag intValue]];
        [starButton removeFromSuperview];
        
    }
    
    // 分数计算
    [self calculateScore];
    
    // 星星掉落
    [self starFall];
    
    // 修改提示文字
    _tipLabel.text = @"";
    
    //    // 清空存放选中星星按钮下标的数组
    //    [_selectedStarButtonTag removeAllObjects];
    
    
//    // 判断游戏是否结束
//    if ([self isGameOver]) {
//        NSLog(@"Game Over");
//    }
}

/**
 *  星星掉落
 */
- (void)starFall {
    
    // 记录星星应该移动的位置
    NSMutableDictionary *moveStepDictionary = [NSMutableDictionary dictionary];
    
    NSLog(@"select %@", _selectedStarButtonTag);
    
    
    // 计算每颗星星应该下落几步
    for (NSNumber *tag in _selectedStarButtonTag) {
        
        // 消失星星的下标
        int index = [tag intValue] - STAR_TAG_BASE;
        // 行
        int row = index / COLUMN;
        // 列
        int column = index % COLUMN;
        
        
        
        // 遍历消失的星星上方的所有星星
        for (int i = row + 1; i < [_starNumberInColumn[column] intValue]; i++) {
            
            int currentTag = i * COLUMN + column + STAR_TAG_BASE;
            
            // 当前星星不消失
            if ([_selectedStarButtonTag indexOfObject:@(currentTag)] == NSNotFound) {
                
                // 更新星星移动位置字典
                NSMutableArray *moveArray = [NSMutableArray arrayWithArray:moveStepDictionary[@(currentTag)]];
                if (moveArray.count == 0) {
                    // 下落步数
                    [moveArray addObject:@(1)];
                    // 左移步数
                    [moveArray addObject:@(0)];
                }
                else {
                    int step = [moveArray[0] intValue] + 1;
                    [moveArray replaceObjectAtIndex:0 withObject:@(step)];
                }
                [moveStepDictionary setObject:moveArray forKey:@(currentTag)];
            }
        }
    }
    
    
    
    
    // 先记录当前每列星星的个数
    NSMutableArray *currentStarNumberInColumn = [NSMutableArray arrayWithArray:_starNumberInColumn];
    
    // 重新计算每列星星个数
    for (NSNumber *tag in _selectedStarButtonTag) {
        
        int colunm = ([tag intValue] - STAR_TAG_BASE) % COLUMN;
        _starNumberInColumn[colunm] = [NSNumber numberWithInt:[_starNumberInColumn[colunm] intValue] - 1];
    }
    
    // 计算应该向左移动几步
    for (int column = 0; column < _starNumberInColumn.count; column++) {
        
        // 列中星星个数为空
        if (![_starNumberInColumn[column] intValue]) {
            
            // 遍历空列之后的所有列中的星星
            for (int col = column + 1; col < _starNumberInColumn.count; col++) {
                
                for (int row = 0; row < [currentStarNumberInColumn[col] intValue]; row ++) {
                    
                    int currentTag = row * COLUMN + col + STAR_TAG_BASE;
                    
                    // 更新星星移动位置字典
                    NSMutableArray *moveArray = [NSMutableArray arrayWithArray:moveStepDictionary[@(currentTag)]];
                    if (moveArray.count == 0) {
                        // 下落步数
                        [moveArray addObject:@(0)];
                        // 左移步数
                        [moveArray addObject:@(1)];
                    }
                    else {
                        int leftStep = [moveArray[1] intValue] + 1;
                        [moveArray replaceObjectAtIndex:1 withObject:@(leftStep)];
                    }
                    [moveStepDictionary setObject:moveArray forKey:@(currentTag)];
                }
                
                
            }
        }
    }
    
//    NSLog(@"moveStepDictionary = %@", moveStepDictionary);
    
    // 获得所有的Key
    NSMutableArray *allKeys = [NSMutableArray arrayWithArray:[moveStepDictionary allKeys]];
    // 对Keys排序 ：列越小越小靠前，列相同行越小越向前
    
    
    
    // 将列数相同的放在同一字典
    NSMutableDictionary *keysDicionary = [NSMutableDictionary dictionary];
    
    for (int i = 0; i < allKeys.count; i++) {
        
        NSNumber *number = allKeys[i];
        int fallIndex = [allKeys[i] intValue] - STAR_TAG_BASE;
        
        int fallColumn = fallIndex % COLUMN;
        
        NSMutableArray *keysArray = [NSMutableArray arrayWithArray:keysDicionary[@(fallColumn)]];
        
        [keysArray addObject:number];
        
        [keysDicionary setObject:keysArray forKey:@(fallColumn)];
        
    }
    
//    NSLog(@"keysDicionary = %@", keysDicionary);
    
    
    allKeys = [NSMutableArray arrayWithArray:[keysDicionary allKeys]];
    [allKeys sortUsingSelector:@selector(compare:)];
//    NSLog(@"allKeys = %@",allKeys);
    
    // 每列进行排序
    for (id key in allKeys) {
        
//        NSLog(@"key = %@", key);
        
        NSMutableArray *keysArray = [NSMutableArray arrayWithArray:keysDicionary[key]];
        
        for (int i = 0; i < [keysArray count]; i++) {
            
            for (int j = 0; j < [keysArray count] - i - 1; j++) {
                
                if (keysArray[j] > keysArray[j + 1]) {
                    
                    id temp = keysArray[j];
                    keysArray[j] = keysArray[j + 1];
                    keysArray[j + 1] = temp;
                }
            }
        }
        
        [keysDicionary setObject:keysArray forKey:key];
    }
    
//    NSLog(@"keysDicionary = %@", keysDicionary);
    
    
    
    // 开始移动
    [UIView animateWithDuration:0.3 animations:^{
        
        for (id key in allKeys) {
            
            NSMutableArray *starArray = [NSMutableArray arrayWithArray:keysDicionary[key]];
            
            for (id object in starArray) {
                
                int fallStep = [moveStepDictionary[object][0] intValue];
                int leftStep = [moveStepDictionary[object][1] intValue];
                
                StarButton *starButton = (StarButton *)[self.view viewWithTag:[object intValue]];
                
                float x = starButton.center.x - leftStep * 32;
                float y = starButton.center.y + fallStep * 32;
                
                
                starButton.center = CGPointMake(x , y);
                starButton.tag = starButton.tag - leftStep - fallStep * COLUMN;
         
                
            }
        }
    } completion:^(BOOL finished) {
        
        // 去除每列星星个数为0的列
        for (int i = 0; i < _starNumberInColumn.count; i++) {
            
            if ([_starNumberInColumn[i] intValue] == 0) {
                
                [_starNumberInColumn removeObjectAtIndex:i];
                i--;
            }
        }
        
        // 清空存放选中星星按钮下标的数组
        [_selectedStarButtonTag removeAllObjects];
        
        // 判断游戏是否结束
        if ([self isGameOver]) {
            
            // 游戏结束方法
            [self gameOver];
            
        }
    }];
    
    
 
    
    // 开始移动
}

/**
 *  计算所得分数
 */
- (void)calculateScore {
    
    
     _score = 5 * pow([_selectedStarButtonTag count], 2) + _score;
    
    [self scoreChangeToCurrentScore];
    
    // 更新最高分
    [self updateHighScore];
    
    
    // 判断是否分数已够过关
    if (_score > [[self currentTarget] intValue]) {
        
        UIImageView *imageView = (UIImageView *)[self.view viewWithTag:250];
        
        // 第一次达成目标分数
        if (!imageView) {
            
            // 音效播放
            if (_shouldPlaySound) {
                AudioServicesPlaySystemSound(_stageClearSoundID);
            }
            
            // 完整的精灵图片
            UIImage *completeImage = [UIImage imageNamed:@"CandyUI"];
            
            // 恭喜通关图片
            CGRect rect = [Tool getRectInPlistWithKey:@"恭喜过关EN.png"];
            UIImageView *stageClearImageView = [[UIImageView alloc] initWithImage:[Tool getSubImageInCompleteImage:completeImage rect:rect]];
            //        passGameImageView.frame = CGRectMake(20, 10, 100, 30);
            stageClearImageView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
            stageClearImageView.bounds = CGRectMake(0, 0, 150, 100);
            stageClearImageView.contentMode = UIViewContentModeScaleAspectFit;
            stageClearImageView.tag = 250;
            [self.view addSubview:stageClearImageView];
            [stageClearImageView release];
            
            // StageClear变小的动画
            [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionTransitionNone animations:^{
                
                stageClearImageView.center = CGPointMake(50, 100);
                stageClearImageView.transform = CGAffineTransformMakeScale(0.4, 0.4);
                
            } completion:^(BOOL finished) {
                
            }];
        }
    }
}

- (void)scoreChangeToCurrentScore {
    
    // 获得当前分数
    NSInteger score = [_scoreLabel.text intValue] + 1;
    
    // 是否修改分数
    if (score <= _score) {
        
        _scoreLabel.text = [NSString stringWithFormat:@"%ld", score];
        [self performSelector:@selector(scoreChangeToCurrentScore) withObject:nil afterDelay:0.005];
    };
}


- (void)scoreChangeToCurrentScore:(NSNumber *)currentScore {
    
    // 获得当前分数
    NSInteger score = [_scoreLabel.text intValue] + 1;
    
    // 是否修改分数
    if (score <= [currentScore intValue]) {
        
        _scoreLabel.text = [NSString stringWithFormat:@"%ld", score];
        [self performSelector:@selector(scoreChangeToCurrentScore:) withObject:currentScore afterDelay:0.005];
    };
}

/**
 *  判断游戏是否接收
 *
 *  @return 游戏是否结束
 */
- (BOOL)isGameOver {
    
    for (int column = 0 ; column < _starNumberInColumn.count; column++) {
        for (int row = 0; row < [_starNumberInColumn[column] intValue]; row++) {
            
            int tag = row * COLUMN +column + STAR_TAG_BASE;
            StarButton *starButton = (StarButton *)[self.view viewWithTag:tag];
            
            if (starButton) {
                
                // 上
                // 判断是否越界
                if ([self wheaterOutOfUpBounds:tag - STAR_TAG_BASE]) {
                    
                    StarButton *upStarButton = (StarButton *)[self.view viewWithTag:tag + COLUMN];
                    
                    // 类型相同,游戏没有结束
                    if (upStarButton.type == starButton.type) {
                        
                        return NO;
                    }
                }
                
                // 下
                // 判断是否越界
                if ([self wheaterOutOfDownBounds:tag - STAR_TAG_BASE]) {
                    
                    StarButton *downStarButton = (StarButton *)[self.view viewWithTag:tag - COLUMN];
                    
                    // 类型相同,游戏没有结束
                    if (downStarButton.type == starButton.type) {
                        
                        return NO;
                    }
                }
                
                // 左
                // 判断是否越界
                if ([self wheaterOutOfLeftBounds:tag - STAR_TAG_BASE]) {
                    
                    StarButton *leftStarButton = (StarButton *)[self.view viewWithTag:tag - 1];
                    
                    // 类型相同,游戏没有结束
                    if (leftStarButton.type == starButton.type ) {
                        
                        return NO;
                    }
                }
                
                // 右
                // 判断是否越界
                if ([self wheaterOutOfRightBounds:tag - STAR_TAG_BASE]) {
                    
                    StarButton *rightStarButton = (StarButton *)[self.view viewWithTag:tag + 1];
                    
                    // 类型相同,游戏没有结束
                    if (rightStarButton.type == starButton.type ) {
                        
                        return NO;
                    }
                }
                
            }
        }
    }
    
    return YES;
}

- (void)gameOver {
    
    NSLog(@"GameOver");
    
    // 计算剩余分数
    
    
    // 通关
    if (_score >= [_targetLabel.text intValue]) {
        
        // 音效播放
        if (_shouldPlaySound) {
            AudioServicesPlaySystemSound(_successSoundID);
        }
        
        // 完整的精灵图片
        UIImage *completeImage = [UIImage imageNamed:@"CandyUI"];
        
        // 恭喜通关图片
        CGRect rect = [Tool getRectInPlistWithKey:@"恭喜过关CN.png"];
        UIImageView *passGameImageView = [[UIImageView alloc] initWithImage:[Tool getSubImageInCompleteImage:completeImage rect:rect]];
//        passGameImageView.frame = CGRectMake(20, 10, 100, 30);
        passGameImageView.center = CGPointMake(CGRectGetMidX(self.view.bounds), -100);
        passGameImageView.bounds = CGRectMake(0, 0, 150, 100);
        passGameImageView.contentMode = UIViewContentModeScaleAspectFit;
        passGameImageView.tag = 320;
        [self.view addSubview:passGameImageView];
        [passGameImageView release];
        
        // 过关动画
        [UIView animateWithDuration:0.7 animations:^{
            
            passGameImageView.center = CGPointMake(passGameImageView.center.x, CGRectGetMidY(self.view.bounds));
        } completion:^(BOOL finished) {
            
            
            
            // 开始下一关
            [self performSelector:@selector(startNextStage) withObject:nil afterDelay:2];
            
        }];
    }
    // 失败
    else {
        
        // 音效播放
        if (_shouldPlaySound) {
            AudioServicesPlaySystemSound(_failSoundID);
        }
        
        UILabel *gameOverLabel = [[UILabel alloc] init];
        gameOverLabel.text = @"Game Over";
        gameOverLabel.font = [UIFont fontWithName:@"Bodoni 72 Smallcaps" size:50];
        gameOverLabel.textColor = [UIColor whiteColor];
        gameOverLabel.center = CGPointMake(CGRectGetMidX(self.view.bounds), -100);
        gameOverLabel.bounds = CGRectMake(0, 0, 320, 100);
        gameOverLabel.textAlignment = NSTextAlignmentCenter;
        gameOverLabel.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:gameOverLabel];
        [gameOverLabel release];
        
        // 过关动画
        [UIView animateWithDuration:0.7 animations:^{
            
            gameOverLabel.center = CGPointMake(gameOverLabel.center.x, CGRectGetMidY(self.view.bounds));
        } completion:^(BOOL finished) {
            
            // 保存数据 保存最高分 清除当前的一些数据
            [self gameOverSaveData];
            
            // 回到主界面
            [self performSelector:@selector(gameExit) withObject:nil afterDelay:0.5];
            
        }];
    }
    NSLog(@"%@  %@", _scoreLabel.text, _targetLabel.text);
    
}

- (void)getAllRemoveStar {
    
}

- (void)removeALLStar {
    
    for (int i = STAR_TAG_BASE; i < COLUMN * ROW + STAR_TAG_BASE; i++) {
        
        StarButton *starButton = (StarButton *)[self.view viewWithTag:i];
        if (starButton) {
            [starButton removeFromSuperview];
        }
    }
}

- (void)startNextStage {
    
    // 删除过关图片
    UIImageView *passGameImageView = (UIImageView *)[self.view viewWithTag:320];
    if (passGameImageView) {
        
        [UIView animateWithDuration:0.3 animations:^{
            
            passGameImageView.center = CGPointMake(passGameImageView.center.x, -100);
            
            
        } completion:^(BOOL finished) {
            [passGameImageView removeFromSuperview];
        }];
    }
    
    
    // 删除所有星星
    [self removeALLStar];
    
//    _score = 0;
//    _scoreLabel.text = [NSString stringWithFormat:@"%ld", _score];
    _stage = _stage + 1;
    _stageLabel.text = [NSString stringWithFormat:@"%ld", _stage];
    
    // 计算当前应该显示的目标分数
    if (_stage > _scoreArray.count) {
        
        NSInteger targetScore = (_stage - _scoreArray.count) * 4000 + [[_scoreArray lastObject] intValue];
        _targetLabel.text = [NSString stringWithFormat:@"%ld", targetScore];
    }
    else {
        
        _targetLabel.text = [NSString stringWithFormat:@"%@", _scoreArray[_stage - 1]];
    }
    
    [self initializeStarButton];
}

/**
 *  暂停游戏
 */
- (void)gamePause {
    
    // 遮罩层
    UIView *maskView = [[UIView alloc] initWithFrame:self.view.frame];
    maskView.backgroundColor = [UIColor clearColor];
    maskView.tag = 300;
    [self.view addSubview:maskView];
    [maskView release];
    
    // 继续按钮
    UIButton *resumeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    resumeButton.center = CGPointMake(CGRectGetMidX(self.view.bounds), -100);
    resumeButton.bounds = CGRectMake(0, 0, 150, 30);
    resumeButton.backgroundColor = [UIColor colorWithRed:1 green:138/255.0 blue:0 alpha:1];
    resumeButton.layer.cornerRadius = 15;
    resumeButton.clipsToBounds = YES;
    [resumeButton setTitle:@"RESUME" forState:UIControlStateNormal];
    resumeButton.titleLabel.font = [UIFont fontWithName:@"Bodoni 72 Smallcaps" size:20];
    [resumeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [resumeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [resumeButton addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
    resumeButton.tag = 210;
    [self.view addSubview:resumeButton];
    
    // 保存并推出按钮
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    saveButton.center = CGPointMake(CGRectGetMidX(self.view.bounds), -30);
    saveButton.bounds = CGRectMake(0, 0, 150, 30);
    saveButton.backgroundColor = [UIColor colorWithRed:1 green:138/255.0 blue:0 alpha:1];
    saveButton.layer.cornerRadius = 15;
    saveButton.clipsToBounds = YES;
    [saveButton setTitle:@"SAVE&EXIT" forState:UIControlStateNormal];
    saveButton.titleLabel.font = [UIFont fontWithName:@"Bodoni 72 Smallcaps" size:20];
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [saveButton addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
    saveButton.tag = 220;
    [self.view addSubview:saveButton];

    
    // 按钮掉落动画
    [UIView animateWithDuration:0.2 animations:^{
        
        resumeButton.center = CGPointMake(resumeButton.center.x, 300);
        saveButton.center = CGPointMake(resumeButton.center.x, 330);
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            
            resumeButton.center = CGPointMake(resumeButton.center.x, 250);
            saveButton.center = CGPointMake(resumeButton.center.x, 320);
        }];
    }];
    

}

// 继续游戏
- (void)gameGoOn {
    
    NSLog(@"gameGoOn");
    
    // 遮罩层
    UIView *maskView = [self.view viewWithTag:300];
    [maskView removeFromSuperview];
    
    // 继续按钮和保存按钮
    UIButton *resumeButton = (UIButton *)[self.view viewWithTag:210];
    UIButton *saveButton = (UIButton *)[self.view viewWithTag:220];
    
    [UIView animateWithDuration:0.1 animations:^{
       
        resumeButton.center = CGPointMake(resumeButton.center.x, -100);
        saveButton.center = CGPointMake(saveButton.center.x, -30);
    } completion:^(BOOL finished) {
        
        [resumeButton removeFromSuperview];
        [saveButton removeFromSuperview];
    }];
}

- (void)gameSave {
    NSLog(@"saveAndExit");
    
    // 保存数据
    
    // 获取文件路径
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *plistPath = [documentDirectory stringByAppendingPathComponent:@"gameData.plist"];
    
    // 获取数据
    NSMutableDictionary *gameDate = [NSMutableDictionary dictionaryWithDictionary:[NSMutableDictionary dictionaryWithContentsOfFile:plistPath]];
    
    // 添加数据
    [gameDate setObject:@(_score) forKey:@"score"];
    [gameDate setObject:@(_stage) forKey:@"stage"];
    
    
    
    if (gameDate[@"highScore"]) {
        
        if ([gameDate[@"highScore"] intValue] < _score) {
            [gameDate setObject:@(_score) forKey:@"highScore"];
        }
    }
    else {
        [gameDate setObject:@(_score) forKey:@"highScore"];
    }
    
    
    
    NSMutableDictionary *starDictionary = [NSMutableDictionary dictionary];
    
    // 保存星星位置
    for (int col = 0; col < _starNumberInColumn.count; col++) {
        
        for (int row = 0; row < [_starNumberInColumn[col] intValue]; row++) {
            
            int tag = row * COLUMN + col + STAR_TAG_BASE;
            StarButton *starButton = (StarButton *)[self.view viewWithTag:tag];
            
            if (starButton) {
                
                [starDictionary setObject:@(starButton.type) forKey:[NSString stringWithFormat:@"%d", tag]];
            }
            else {
                NSLog(@"!!!!!没有找到星星");
            }
        }
    }
    //    NSLog(@"starDictionary = %@", starDictionary);
    //    NSLog(@"starDictionary number = %ld", starDictionary.count);
    
    [gameDate setObject:starDictionary forKey:@"starPosition"];
    
    // 更新文件系统
    BOOL success = [gameDate writeToFile:plistPath atomically:YES];
    NSLog(@"success = %d", success);
    
    // 退出游戏
    [self gameExit];
}

- (void)gameExit {
    
    // 遮罩层
    UIView *maskView = [[UIView alloc] initWithFrame:self.view.frame];
    maskView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:maskView];
    [maskView release];
    
    // 页面渐隐动画
    [UIView animateWithDuration:1 animations:^{

        maskView.backgroundColor = [UIColor blackColor];

    } completion:^(BOOL finished) {

        // 页面推送
        [self.presentingViewController dismissViewControllerAnimated:NO completion:^{


        }];
        
    }];
}


/**
 *  保存最高分 清空数据
 */
- (void)gameOverSaveData {
    
    // 保存数据
    
    // 获取文件路径
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *plistPath = [documentDirectory stringByAppendingPathComponent:@"gameData.plist"];
    

    // 读取数据
    NSMutableDictionary *gameDate = [NSMutableDictionary dictionaryWithDictionary:[NSMutableDictionary dictionaryWithContentsOfFile:plistPath]];
    
    // 新的游戏数据
    NSMutableDictionary *newGameData = [NSMutableDictionary dictionary];
    
    
    // 保存最高分
    if (gameDate[@"highScore"]) {
        
        if ([gameDate[@"highScore"] intValue] < _score) {
            
            [newGameData setObject:@(_score) forKey:@"highScore"];
        }
    }
    else {
        [newGameData setObject:@(_score) forKey:@"highScore"];
    }
    
    NSLog(@"newGameData = %@",newGameData);
    
    // 更新文件系统
    BOOL success = [newGameData writeToFile:plistPath atomically:YES];
    NSLog(@"success = %d", success);
}

- (void)updateHighScore {
    
    // 保存数据
    
    // 获取文件路径
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *plistPath = [documentDirectory stringByAppendingPathComponent:@"gameData.plist"];
    
    // 获取数据
    NSMutableDictionary *gameDate = [NSMutableDictionary dictionaryWithDictionary:[NSMutableDictionary dictionaryWithContentsOfFile:plistPath]];
    
    // 添加数据
    if (gameDate[@"highScore"]) {
        
        if ([gameDate[@"highScore"] intValue] < _score) {
            [gameDate setObject:@(_score) forKey:@"highScore"];
        }
    }
    else {
        [gameDate setObject:@(_score) forKey:@"highScore"];
    }
    
    // 更新文件系统
    BOOL success = [gameDate writeToFile:plistPath atomically:YES];
    NSLog(@"success = %d", success);
    
    // 更新最高分
    _highScoreLabel.text = [NSString stringWithFormat:@"%@", gameDate[@"highScore"]];
}


/**
 *  计算当前关卡的目标分数
 *
 *  @return 当前关卡的目标分数
 */
- (NSString *)currentTarget {
    
    NSString *targetScore;
    
    // 计算当前应该显示的目标分数
    if (_stage > _scoreArray.count) {
        
        NSInteger target = (_stage - _scoreArray.count) * 4000 + [[_scoreArray lastObject] intValue];
        targetScore = [NSString stringWithFormat:@"%ld", target];
    }
    else {
        
        targetScore = [NSString stringWithFormat:@"%@", _scoreArray[_stage - 1]];
    }
    
    return targetScore;
}

- (void)changeVolume {
    
    UIButton *volumeButton = (UIButton *)[self.view viewWithTag:230];
    volumeButton.selected = !volumeButton.selected;
    _shouldPlaySound = !volumeButton.selected;
}

/**
 *  对KEY值是NSNumber的数组进行排序
 *
 *  @param otherDictionary <#otherDictionary description#>
 *
 *  @return <#return value description#>
 */
- (NSComparisonResult)compare:(NSNumber *)otherNumber {
    
    NSNumber *tempNumber = (NSNumber *)self;
    
    return [tempNumber intValue] < [otherNumber intValue] ? NSOrderedDescending :NSOrderedAscending;
}

@end
