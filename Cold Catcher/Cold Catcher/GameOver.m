//
//  GameOver.m
//  Cold Catcher
//
//  Created by Carl Milazzo on 3/5/15.
//  Copyright (c) 2015 Carl Milazzo. All rights reserved.
//

#import "GameOver.h"

@implementation GameOver
{
	double halfHeight;
	double halfWidth;
	
	SKLabelNode *_Title;
	SKLabelNode *_finalScore;
	SKLabelNode *_touch;
	
	BOOL backToMenu;
}

-(id)initWithSize:(CGSize)size finalScore:(float)finalScore withModifier:(NSString *)finalModifier
{
	if (self = [super initWithSize:size])
	{
		halfHeight = self.size.height/2;
		halfWidth = self.size.width/2;
		
		//background
		SKSpriteNode *bg;
		bg = [SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:size];
		
		bg.position = CGPointMake(halfWidth, halfHeight);
		[self addChild:bg];
		
		//title
		_Title = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
		_Title.position = CGPointMake(halfWidth, self.size.height*2/3);
		_Title.fontSize = 30;
		_Title.fontColor = [UIColor blackColor];
		[_Title setText:@"Game Over"];
		[self addChild:_Title];
		
		//final score
		_finalScore = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
		_finalScore.position = CGPointMake(halfWidth, self.size.height/2);
		_finalScore.fontSize = 20;
		_finalScore.fontColor = [UIColor blackColor];
		[_finalScore setText:[NSString stringWithFormat:@"final score: %.2f%@",finalScore,finalModifier]];
		[self addChild:_finalScore];
		
		
		//touch to continue message
		_touch = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
		_touch.position = CGPointMake(halfWidth, self.size.height/3);
		_touch.fontSize = 20;
		_touch.fontColor = [UIColor blackColor];
		[_touch setText:@"(touch to continue)"];
		[self addChild:_touch];
		
		backToMenu = NO;
		
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
			backToMenu = YES;
		}
	}
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	for (UITouch *touch in touches) {
		CGPoint touchPoint = [touch locationInNode:self];
		//if they tap the screen
		if(CGRectContainsPoint(self.scene.frame, touchPoint) && backToMenu)
		{
			self.menuPressed = YES;
		}
	}
	backToMenu = NO;
}

@end
