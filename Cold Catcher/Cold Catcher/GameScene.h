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
@property (nonatomic, assign) BOOL gameOver;
@property (nonatomic, assign) float numZoomOuts;

+(void)changePlayScale:(CGFloat)newScale;
+(CGFloat)getScale;
+(BOOL)isSceneUpdatingScale;
+(CGPoint)getCenter;
+(CGSize)getScreenSize;
+(CGFloat)getMaxCharacterSize;

-(void)changeScore:(float)newScore;

-(id)initEndlessGameWithSize:(CGSize)size;
-(id)initTimedGameWithSize:(CGSize)size;

-(void)pauseGame;
-(void)playGame;


@end
