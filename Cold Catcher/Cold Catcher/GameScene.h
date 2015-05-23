//
//  GameScene.h
//  Cold Catcher
//

//  Copyright (c) 2014 Carl Milazzo. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameScene : SKScene

@property (nonatomic, assign) float score; //size in meters
@property (nonatomic, assign) float maxScore; //max size in meters
@property (nonatomic, assign) BOOL gameOver; //used to communicate a gameover
@property (nonatomic, assign) float numZoomOuts; //used to track current difficulty based on size in game
@property (nonatomic, assign) float gameTime; //used to track time in game (timed mode only)
@property (nonatomic, assign) BOOL isTimed; //used to track timed mode vs endless mode

+(void)changePlayScale:(CGFloat)newScale;
+(CGFloat)getScale;
+(BOOL)isSceneUpdatingScale;
+(CGPoint)getCenter;
+(CGSize)getScreenSize;
+(CGFloat)getMaxCharacterSize;
+(float)getMaxTimeAttackSize;

-(void)changeScore:(float)newScore;

-(id)initEndlessGameWithSize:(CGSize)size;
-(id)initTimedGameWithSize:(CGSize)size;

-(void)pauseGame;
-(void)playGame;


@end
