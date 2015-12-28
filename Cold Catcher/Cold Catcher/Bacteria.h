//
//  Bacteria.h
//  Cold Catcher
//
//  Created by Carl Milazzo on 12/30/14.
//  Copyright (c) 2014 Carl Milazzo. All rights reserved.
//

#import "Cell.h"

@interface Bacteria : Cell

+(void)playerUpdate:(CGFloat)newSize;
-(id)initEnemy:(CGFloat)startingRadius withSpeedof:(CGFloat)MaxSpeed;
-(void)enemyUpdate:(CGFloat)dt;
-(CGPoint)randomMove;
-(CGPoint)randomOffScreenPosition;

@end
