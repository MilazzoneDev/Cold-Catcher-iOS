//
//  GameOver.h
//  Cold Catcher
//
//  Created by Carl Milazzo on 3/5/15.
//  Copyright (c) 2015 Carl Milazzo. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameOver : SKScene

@property (nonatomic, assign) BOOL menuPressed;
//global setup for final score
+(void)setupScoreImages;
//used for time attack mode
-(id)initWithSize:(CGSize)size finalTime:(float)finalTime didWin:(BOOL)didWin;
//used for endless mode
-(id)initWithSize:(CGSize)size finalSize:(float)finalSize withModifier:(NSString *)finalModifier andScore:(float)finalScore;


@end
