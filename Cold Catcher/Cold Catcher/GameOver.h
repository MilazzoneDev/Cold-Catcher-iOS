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

//used for time attack mode
-(id)initWithSize:(CGSize)size finalTime:(float)finalTime didWin:(BOOL)didWin;
//used for endless mode
-(id)initWithSize:(CGSize)size finalScore:(float)finalScore withModifier:(NSString *)finalModifier;


@end
