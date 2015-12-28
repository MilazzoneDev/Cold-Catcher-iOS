//
//  Bacteria.m
//  Cold Catcher
//
//  Created by Carl Milazzo on 12/30/14.
//  Copyright (c) 2014 Carl Milazzo. All rights reserved.
//

#import "Bacteria.h"
#import "GameScene.h"
#import "Utils.h"

static float playerSize;


@implementation Bacteria

#pragma mark update
+(void)playerUpdate:(CGFloat)newSize
{
	playerSize = newSize;
}

-(id)initEnemy:(CGFloat)startingRadius withSpeedof:(CGFloat)MaxSpeed
{
	if(self = [super initEnemyCell:startingRadius withSpeedOf:MaxSpeed])
	{
		[super setSeekPoint:[self randomMove]];
		[self enemyUpdate:0];
	}
	return self;
}

-(void)enemyUpdate:(CGFloat)dt
{
	[super update:dt];
	[self enemyColorUpdate];
}

#pragma mark enemy update functions
//updates enemy color (if player is bigger/smaller)
-(void)enemyColorUpdate
{
	if(self.radius <= playerSize)
	{
		self.color = [UIColor greenColor];
	}
	else
	{
		self.color = [UIColor purpleColor];
	}
	[[super sprite] setFillColor:self.color];
}

//gives the enemy a new move
-(CGPoint)randomMove
{
	CGFloat randX = RandomFloatRange(self.radius, [GameScene getScreenSize].width-self.radius);
	CGFloat randY = RandomFloatRange(self.radius, [GameScene getScreenSize].height-self.radius);
	
	return CGPointMake(randX, randY);
}

//used to spawn a new enemy
-(CGPoint)randomOffScreenPosition
{
	int randnum = (int)RandomFloatRange(0, 4);
	CGFloat randX = 0;
	CGFloat randY = 0;
	
	if(randnum == 0|| randnum == 2)
	{
		//starts on top or bottom
		randY = (randnum==0 ? -1:1)*self.radius + (randnum==0 ? 0:1)*[GameScene getScreenSize].height;
		randX = RandomFloatRange(0, [GameScene getScreenSize].width);
	}
	else
	{
		//starts on right or left side
		randX = (randnum==3 ? -1:1)*self.radius + (randnum==3 ? 0:1)*[GameScene getScreenSize].width;
		randY = RandomFloatRange(0, [GameScene getScreenSize].height);
	}
	return CGPointMake(randX, randY);
}

@end
