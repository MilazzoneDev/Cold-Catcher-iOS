//
//  GameUI.m
//  Cold Catcher
//
//  Created by Carl Milazzo on 5/25/15.
//  Copyright (c) 2015 Carl Milazzo. All rights reserved.
//

#import "GameUI.h"

//score constants
static float const kSizeMicrometer = 0.000001;//1μm = 0.000001m
static float const kSizeMilimeter = 0.001; //1mm = 0.001m
static float const kSizeCentimeter = 0.01; //1cm = 0.01m
static float const kSizeMeter = 1;
static float const kSizeKilometer = 1000; //1000m = 1km

static float const padding = 10;

@implementation GameUI
{
	CGRect gameframe;
	
	UILabel *maxScoreLabel; //scorelabel
	UILabel *scoreLabel; //scorelabel2
	//Label for timed mode showing the time in game
	UILabel *timerLabel;
}

//initializes the UI for the game
-(id)initWithFrame:(CGRect)frame isTimed:(BOOL)isTimed
{
	if(self = [super initWithFrame:frame])
	{
		self.backgroundColor = [UIColor clearColor];
		gameframe = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
		
		//score label
		maxScoreLabel = [[UILabel alloc] init];
		maxScoreLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
		maxScoreLabel.textColor = [UIColor darkGrayColor];
		maxScoreLabel.frame = CGRectMake(0, 0, gameframe.size.width, 14);
		maxScoreLabel.textAlignment = NSTextAlignmentLeft;
		maxScoreLabel.numberOfLines = 0;
		[self addSubview:maxScoreLabel];
		
		scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, maxScoreLabel.frame.size.height, gameframe.size.width, 14)];
		scoreLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
		scoreLabel.textColor = [UIColor darkGrayColor];
		scoreLabel.frame = CGRectMake(0, maxScoreLabel.frame.size.height, gameframe.size.width, 14);
		scoreLabel.textAlignment = NSTextAlignmentLeft;
		scoreLabel.numberOfLines = 0;
		[self addSubview:scoreLabel];
		
		if(isTimed)
		{
			timerLabel = [[UILabel alloc] init];
			timerLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
			timerLabel.textColor = [UIColor darkGrayColor];
			timerLabel.frame = CGRectMake(0, maxScoreLabel.frame.size.height, gameframe.size.width, 14);
			timerLabel.textAlignment = NSTextAlignmentCenter;
			timerLabel.numberOfLines = 0;
			[self addSubview:timerLabel];
		}
		
	}
	return self;
}

//fix maxScore to correct symbol
-(void)updateMaxScoreLabel:(float)maxScore
{
	scoreModifier maxScoreModified = [GameUI scoreFixer:maxScore];
	maxScoreLabel.text = [NSString stringWithFormat:@"Max Score: %.2f%@",maxScoreModified.number,maxScoreModified.character];
}

//fix current score to correct symbol
-(void)updateScoreLabel:(float)score
{
	scoreModifier scoreModified = [GameUI scoreFixer:score];
	scoreLabel.text = [NSString stringWithFormat:@"Score:%.2f%@",scoreModified.number,scoreModified.character];
}

-(void)updateTimerLabel:(float)time
{
	int minutes = time / 60;
	float seconds = (time-(minutes*60));
	timerLabel.text = [NSString stringWithFormat:@"%d:%.1f",minutes,seconds];
}

+(scoreModifier)scoreFixer:(float)score
{
	float number = score;
	NSString *character;
	
	if(number > kSizeKilometer)
	{
		number = number / kSizeKilometer;
		character = @"km";
	}
	else if(number > kSizeMeter)
	{
		number = number;
		character = @"m";
	}
	else if(number > kSizeCentimeter)
	{
		number = number / kSizeCentimeter;
		character = @"cm";
	}
	else if(number > kSizeMilimeter)
	{
		number = number / kSizeMilimeter;
		character = @"mm";
	}
	else
	{
		number = number / kSizeMicrometer;
		character = @"μm";
	}
	
	scoreModifier returnedScoreModifier;
	returnedScoreModifier.number = number;
	returnedScoreModifier.character = character;
	
	return returnedScoreModifier;
}




//draws the background
- (void)drawRect:(CGRect)rect {
	// Drawing code
	CGContextRef _context = UIGraphicsGetCurrentContext();

	//adds the background
	CGRect rectangle2 = CGRectMake(maxScoreLabel.frame.origin.x - padding, maxScoreLabel.frame.origin.y - padding, gameframe.size.width/4 + padding, maxScoreLabel.frame.size.height*3 + padding);
	
	[self drawRoundedRect:_context rect:rectangle2 radius:10 color:[UIColor blackColor]];
	
	CGRect rectangle = CGRectMake(maxScoreLabel.frame.origin.x - padding, maxScoreLabel.frame.origin.y - padding, gameframe.size.width/4, maxScoreLabel.frame.size.height*3);
	
	[self drawRoundedRect:_context rect:rectangle radius:10 color:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1]];

	
	
}


- (void) drawRoundedRect:(CGContextRef)c rect:(CGRect)rect radius:(int)corner_radius color:(UIColor *)color
{
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
}


@end
