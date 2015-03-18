//
//  GameMenu.m
//  Cold Catcher
//
//  Created by Carl Milazzo on 12/29/14.
//  Copyright (c) 2014 Carl Milazzo. All rights reserved.
//

#import "GameMenu.h"


@implementation GameMenu
{
	double halfHeight;
	double halfWidth;
	
	SKLabelNode *_Title;
	
	SKLabelNode *_touch;
	
	BOOL newGame;
	BOOL oldGame;
}

-(id)initWithSize:(CGSize)size
{
	if (self = [super initWithSize:size])
	{
		halfHeight = self.size.height/2;
		halfWidth = self.size.width/2;
		
		
		SKSpriteNode *bg;
		bg = [SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:size];
		
		bg.position = CGPointMake(halfWidth, halfHeight);
		[self addChild:bg];
		
		_Title = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
		[_Title setText:@"Cold Catcher"];
		_Title.fontSize = 30;
		_Title.fontColor = [UIColor blackColor];
		_Title.position = CGPointMake(halfWidth,halfHeight+halfHeight/2);
		
		[self addChild:_Title];
		
		_touch = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
		[_touch setText:@"(touch to begin)"];
		_touch.fontSize = 15;
		_touch.fontColor = [UIColor blackColor];
		_touch.position = CGPointMake(halfWidth,halfHeight);
		
		[self addChild:_touch];
		
		//make sure the triggers are set to false
		newGame = NO;
		oldGame = NO;
	}
	return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	/* Called when a touch begins */
	
	for (UITouch *touch in touches) {
		CGPoint touchPoint = [touch locationInNode:self];
		//if they tap the screen
		if(CGRectContainsPoint(self.scene.frame, touchPoint))
		{
			newGame = YES;
		}
	}
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	for (UITouch *touch in touches) {
		CGPoint touchPoint = [touch locationInNode:self];
		//if they tap the screen
		if(CGRectContainsPoint(self.scene.frame, touchPoint) && newGame)
		{
			self.newGamePressed = YES;
		}
	}
	newGame = NO;
	oldGame = NO;
}


@end