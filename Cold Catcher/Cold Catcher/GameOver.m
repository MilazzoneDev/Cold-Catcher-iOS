//
//  GameOver.m
//  Cold Catcher
//
//  Created by Carl Milazzo on 3/5/15.
//  Copyright (c) 2015 Carl Milazzo. All rights reserved.
//

#import "GameOver.h"

static NSArray *scoreIdentifier;
static NSArray *scoreImage;
static NSString *textType;

@implementation GameOver
{
	double halfHeight;
	double halfWidth;
	
	SKLabelNode *_Title;
	SKLabelNode *_finalSize;
	SKLabelNode *_compare;
	SKLabelNode *_touch;
	
	BOOL _backToMenu;
}

+(void)setupScoreImages
{
	NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ScoreData" ofType:@"plist"]];
	//NSLog(@"dictionary = %@", dictionary);
	scoreIdentifier = [dictionary objectForKey:@"ScoreCheck"]; //size of objects
	//NSLog(@"array = %@", scoreIdentifier);
	scoreImage = [dictionary objectForKey:@"ScoreImage"]; //name of objects
	//NSLog(@"array = %@", scoreImage);
	
	textType = @"Helvetica";
}

#pragma mark Time Attack ending
-(id)initWithSize:(CGSize)size finalTime:(float)finalTime didWin:(BOOL)didWin;
{
	if(self = [super initWithSize:size])
	{
		halfHeight = self.size.height/2;
		halfWidth = self.size.width/2;
		
		//background
		SKSpriteNode *bg;
		bg = [SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:size];
		
		bg.position = CGPointMake(halfWidth, halfHeight);
		[self addChild:bg];
		
		//title
		[self SetTitle:@"Game Over"];
		
		//final score
		_finalSize = [SKLabelNode labelNodeWithFontNamed:textType];
		_finalSize.position = CGPointMake(halfWidth, self.size.height/2);
		_finalSize.fontSize = 20;
		_finalSize.fontColor = [UIColor blackColor];
		int minutes = finalTime / 60;
		float seconds = (finalTime-(minutes*60));
		[_finalSize setText:[NSString stringWithFormat:@"final time: %d:%.1f",minutes,seconds]];
		[self addChild:_finalSize];
		
		
		//touch to continue message
		_touch = [SKLabelNode labelNodeWithFontNamed:textType];
		_touch.position = CGPointMake(halfWidth, self.size.height/3);
		_touch.fontSize = 20;
		_touch.fontColor = [UIColor blackColor];
		[_touch setText:@"(touch to continue)"];
		[self addChild:_touch];
		
		_backToMenu = NO;
	}
	
	return self;
}

#pragma mark Endless mode ending
-(id)initWithSize:(CGSize)size finalSize:(float)finalSize withModifier:(NSString *)finalModifier andScore:(float)finalScore
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
		[self SetTitle:@"Game Over"];
		
		//final score
		_finalSize = [SKLabelNode labelNodeWithFontNamed:textType];
		_finalSize.position = CGPointMake(halfWidth, self.size.height/2);
		_finalSize.fontSize = 20;
		_finalSize.fontColor = [UIColor blackColor];
		[_finalSize setText:[NSString stringWithFormat:@"final score: %.2f%@",finalSize,finalModifier]];
		[self addChild:_finalSize];
		
		
		//image
		int imageLocation = [self CompareSize:finalScore];
		_compare = [SKLabelNode labelNodeWithFontNamed:textType];
		_compare.position = CGPointMake(halfWidth/2, self.size.height/4);
		_compare.fontSize = 20;
		_compare.fontColor = [UIColor blackColor];
		[_compare setText:[NSString stringWithFormat:@"You grew bigger than %@",scoreImage[imageLocation]]];
		[self addChild:_compare];
#warning incomplete image code
		
		//touch to continue message
		_touch = [SKLabelNode labelNodeWithFontNamed:textType];
		_touch.position = CGPointMake(halfWidth, self.size.height/3);
		_touch.fontSize = 20;
		_touch.fontColor = [UIColor blackColor];
		[_touch setText:@"(touch to continue)"];
		[self addChild:_touch];
		
		_backToMenu = NO;
		
	}
	return self;
}

-(void)SetTitle:(NSString*)text
{
	_Title = [SKLabelNode labelNodeWithFontNamed:textType];
	_Title.position = CGPointMake(halfWidth, self.size.height*2/3);
	_Title.fontSize = 30;
	_Title.fontColor = [UIColor blackColor];
	[_Title setText:text];
	[self addChild:_Title];
}

-(int)CompareSize:(float)finalSize
{
	for(int i=0; i< [scoreIdentifier count]; i++)
	{
		if([scoreIdentifier[i] floatValue] > finalSize)
		{
			return i-1;
		}
	}
	//larger than the last item
	return ((int)[scoreIdentifier count]-1);
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	/* Called when a touch begins */
	
	for (UITouch *touch in touches) {
		CGPoint touchPoint = [touch locationInNode:self];
		//if they tap the screen
		if(CGRectContainsPoint(self.scene.frame, touchPoint))
		{
			_backToMenu = YES;
		}
	}
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	for (UITouch *touch in touches) {
		CGPoint touchPoint = [touch locationInNode:self];
		//if they tap the screen
		if(CGRectContainsPoint(self.scene.frame, touchPoint) && _backToMenu)
		{
			self.menuPressed = YES;
		}
	}
	_backToMenu = NO;
}

@end
