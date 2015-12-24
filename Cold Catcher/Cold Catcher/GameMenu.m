//
//  GameMenu.m
//  Cold Catcher
//
//  Created by Carl Milazzo on 12/29/14.
//  Copyright (c) 2014 Carl Milazzo. All rights reserved.
//

#import "GameMenu.h"

static float const padding = 5;

@implementation GameMenu
{
	double halfHeight;
	double halfWidth;
	CGSize gameScreen;
	CGPoint kCenter;
	
	SKLabelNode *_Title;
	
	//buttons
	SKSpriteNode *timeAttack;
	SKSpriteNode *endless;
	SKSpriteNode *highScores;
	SKSpriteNode *optionsButton;
	
	BOOL timedGame;
	BOOL endlessGame;
	BOOL highScore;
	BOOL options;
}

-(id)initWithSize:(CGSize)size
{
	if (self = [super initWithSize:size])
	{
		halfHeight = self.size.height/2;
		halfWidth = self.size.width/2;
		gameScreen = size;
		kCenter = CGPointMake(gameScreen.width/2, gameScreen.height/2);
		
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
		
		
		//add buttons
		CGSize buttonSize = CGSizeMake(180,60);
		CGFloat xOffset = halfWidth*2/5;
		CGFloat yTopOffset = 0; //buttonSize.height/2-(buttonSize.height/2);
		CGFloat yBottomOffset = buttonSize.height*3/2+padding*2-(buttonSize.height/2);
		//time attack mode
		timeAttack = [self CreateButtonWithSize:buttonSize andText:@"Time Attack"];
		timeAttack.position = CGPointMake(kCenter.x - xOffset, kCenter.y-yTopOffset);
		timeAttack.name = @"timeAttack";
		[self addChild:timeAttack];
		
		//endless mode
		endless = [self CreateButtonWithSize:buttonSize andText:@"Endless"];
		endless.position = CGPointMake(kCenter.x + xOffset, kCenter.y-yTopOffset);
		endless.name = @"endless";
		[self addChild:endless];
		
		//high scores
		highScores = [self CreateButtonWithSize:buttonSize andText:@"High Scores"];
		highScores.position = CGPointMake(kCenter.x - xOffset, kCenter.y-yBottomOffset);
		highScores.name = @"highScores";
		[self addChild:highScores];
		
		//options
		optionsButton = [self CreateButtonWithSize:buttonSize andText:@"Options"];
		optionsButton.position = CGPointMake(kCenter.x + xOffset, kCenter.y-yBottomOffset);
		optionsButton.name = @"Options";
		[self addChild:optionsButton];
		
		//make sure the triggers are set to false
		timedGame = NO;
		endlessGame = NO;
		highScore = NO;
		options = NO;
	}
	return self;
}


#pragma mark Touches
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	/* Called when a touch begins */
	
	for (UITouch *touch in touches) {
		CGPoint touchPoint = [touch locationInNode:self];
		//if they tap a button
		if(CGRectContainsPoint([timeAttack frame], touchPoint))
		{
			timedGame = YES;
			[timeAttack setScale:0.9];
		}
		if(CGRectContainsPoint([endless frame], touchPoint))
		{
			endlessGame = YES;
			[endless setScale:0.9];
		}
		if(CGRectContainsPoint([highScores frame], touchPoint))
		{
			highScore = YES;
			[highScores setScale:0.9];
		}
		if(CGRectContainsPoint([optionsButton frame], touchPoint))
		{
			options = YES;
			[optionsButton setScale:0.9];
		}
	}
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	for (UITouch *touch in touches) {
		CGPoint touchPoint = [touch locationInNode:self];
		//if they tap the screen
		if(CGRectContainsPoint([timeAttack frame], touchPoint) && timedGame)
		{
			self.timedGamePressed = YES;
		}
		if(CGRectContainsPoint([endless frame], touchPoint) && endlessGame)
		{
			self.endlessGamePressed = YES;
		}
		if(CGRectContainsPoint([highScores frame], touchPoint) && highScore)
		{
			self.highScoresPressed = YES;
		}
		if(CGRectContainsPoint([optionsButton frame], touchPoint) && options)
		{
			self.optionsScreenPressed = YES;
		}
	}
	
	[timeAttack setScale:1];
	[endless setScale:1];
	[highScores setScale:1];
	[optionsButton setScale:1];
	
	timedGame = NO;
	endlessGame = NO;
	highScore = NO;
	options = NO;
}

#pragma mark buttons
-(SKSpriteNode *)CreateButtonWithSize:(CGSize)size andText:(NSString*)text
{
	SKSpriteNode *button = [[SKSpriteNode alloc] initWithColor:[UIColor clearColor] size:size];
	
	SKSpriteNode *bottom = [self drawRoundedRect:CGRectMake(0, 0, size.width, size.height) radius:10 color:[UIColor grayColor]];
	bottom.zPosition = 0;
	[button addChild:bottom];
	
	SKSpriteNode *top = [self drawRoundedRect:CGRectMake(0, 0, size.width-(padding*2), size.height-(padding*2)) radius:5 color:[UIColor whiteColor]];
	top.zPosition = 1;
	[button addChild: top];
	
	
	SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
	[label setText:text];
	label.fontSize = 30;
	label.fontColor = [UIColor blackColor];
	label.position = CGPointMake(0, -padding*2);
	label.zPosition = 2;
	
	[button addChild:label];
	return button;
}

- (SKSpriteNode *) drawRoundedRect:(CGRect)rect radius:(int)corner_radius color:(UIColor *)color
{
	//get context
	bool opaque = NO;
	CGFloat scale= 0;
	UIGraphicsBeginImageContextWithOptions(rect.size, opaque, scale);
	
	CGContextRef c = UIGraphicsGetCurrentContext();
	
	int x_left = rect.origin.x;
	int x_left_center = rect.origin.x + corner_radius;
	int x_right_center = rect.origin.x + rect.size.width - corner_radius;
	int x_right = rect.origin.x + rect.size.width;
	
	int y_top = rect.origin.y;
	int y_top_center = rect.origin.y + corner_radius;
	int y_bottom_center = rect.origin.y + rect.size.height - corner_radius;
	int y_bottom = rect.origin.y + rect.size.height;
	
	//Begin!
	CGContextBeginPath(c);
	CGContextMoveToPoint(c, x_left, y_top_center);
	
	//First corner
	CGContextAddArcToPoint(c, x_left, y_top, x_left_center, y_top, corner_radius);
	CGContextAddLineToPoint(c, x_right_center, y_top);
	
	//Second corner
	CGContextAddArcToPoint(c, x_right, y_top, x_right, y_top_center, corner_radius);
	CGContextAddLineToPoint(c, x_right, y_bottom_center);
	
	//Third corner
	CGContextAddArcToPoint(c, x_right, y_bottom, x_right_center, y_bottom, corner_radius);
	CGContextAddLineToPoint(c, x_left_center, y_bottom);
	
	//Fourth corner
	CGContextAddArcToPoint(c, x_left, y_bottom, x_left, y_bottom_center, corner_radius);
	CGContextAddLineToPoint(c, x_left, y_top_center);
	
	//Done
	CGContextClosePath(c);
	
	CGContextSetFillColorWithColor(c, color.CGColor);
	
	CGContextFillPath(c);
	
	// Drawing complete, retrieve the finished image and cleanup
	UIImage *Imageref = UIGraphicsGetImageFromCurrentImageContext();
	SKTexture *texture = [SKTexture textureWithImage:Imageref];
	SKSpriteNode *button = [SKSpriteNode spriteNodeWithTexture:texture];
	
	UIGraphicsEndImageContext();
	return button;
}


@end