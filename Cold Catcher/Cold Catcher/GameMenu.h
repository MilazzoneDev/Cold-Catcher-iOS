//
//  GameMenu.h
//  Cold Catcher
//
//  Created by Carl Milazzo on 12/29/14.
//  Copyright (c) 2014 Carl Milazzo. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameMenu : SKScene

@property (nonatomic, assign) BOOL timedGamePressed;
@property (nonatomic, assign) BOOL endlessGamePressed;
@property (nonatomic, assign) BOOL highScoresPressed;
@property (nonatomic, assign) BOOL optionsPressed;

@end
