//
//  OptionsMenu.m
//  Cold Catcher
//
//  Created by Carl Milazzo on 1/28/15.
//  Copyright (c) 2015 Carl Milazzo. All rights reserved.
//

#import "OptionsMenu.h"

static float const padding = 10;

@implementation OptionsMenu

-(id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if(self)
	{
		NSString *font = @"Academy Engraved LET";
		
		[self setUserInteractionEnabled:YES];
		//options title
		float titleWidth = self.bounds.size.width-padding*42;
		float titleHeight = 70;
		float titleX = padding*21;
		float titleY = padding*2;
		UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(titleX, titleY, titleWidth, titleHeight)];
		[title setText:[NSString stringWithFormat:@"Options"]];
		[title setTextAlignment:NSTextAlignmentCenter];
		[title setFont:[UIFont fontWithName:font size:50]];
		[self addSubview:title];
		
		//create a button to leave the options menu
		float doneWidth = self.bounds.size.width*3/16 - padding*2;
		float doneHeight = self.bounds.size.height/8 - padding;
		float doneX = self.bounds.size.width - doneWidth - padding*2;
		float doneY = self.bounds.size.height - doneHeight - padding*2;
		UIButton *done = [[UIButton alloc] initWithFrame:CGRectMake(doneX, doneY+padding/2, doneWidth, doneHeight)];
		//done.titleLabel.font = [UIFont fontWithName:font size:20];
		[done.titleLabel setFont:[UIFont fontWithName:font size:20]];
		[done.titleLabel setTextAlignment:NSTextAlignmentCenter];
		[done setTitle:@"Done" forState:UIControlStateNormal];
		[done setTitle:@"Done" forState:UIControlStateHighlighted];
		[done setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[done addTarget:self action:@selector(DonePressed:) forControlEvents:UIControlEventTouchUpInside];
		
		[self addGestureRecogniser:self];
		
		[self addSubview:done];
		
	}
	return self;
}

#pragma mark Interactive UI elements
-(IBAction)DonePressed:(id)sender
{
	//NSLog(@"done pressed");
	self.donePressed = YES;
}

-(void)addGestureRecogniser:(UIView *)touchView{
	
	UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(DonePressed:)];
	swipe.direction = UISwipeGestureRecognizerDirectionUp;
	[touchView addGestureRecognizer:swipe];
}

- (void)drawRect:(CGRect)rect {
	// Drawing code
	//adds the background
	CGRect rectangle = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
	CGContextRef _context = UIGraphicsGetCurrentContext();
	
	[self drawRoundedRect:_context rect:rectangle radius:10 color:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1]];
	
	//adds a boarder to the title
	float titleWidth = self.bounds.size.width-padding*42;
	float titleHeight = 70;
	float titleX = padding*21;
	float titleY = padding*2;
	CGRect titleRect = CGRectMake(titleX, titleY, titleWidth, titleHeight-10);
	CGRect biggerTitleRect = CGRectMake(titleRect.origin.x - padding, titleRect.origin.y-padding, titleRect.size.width+padding*2, titleRect.size.height+padding*2);
	[self drawRoundedRect:_context rect:biggerTitleRect radius:10 color:[UIColor grayColor]];
	[self drawRoundedRect:_context rect:titleRect radius:10 color:[UIColor whiteColor]];
	
	
	//adds a boarder to the done button
	float doneWidth = self.bounds.size.width*3/16 - padding*2;
	float doneHeight = self.bounds.size.height/8 - padding;
	float doneX = self.bounds.size.width - doneWidth - padding*2;
	float doneY = self.bounds.size.height - doneHeight - padding*2;
	
	CGRect doneRect = CGRectMake(doneX, doneY, doneWidth, doneHeight);
	CGRect biggerDoneRect = CGRectMake(doneRect.origin.x - padding, doneRect.origin.y-padding, doneRect.size.width+padding*2, doneRect.size.height+padding*2);
	[self drawRoundedRect:_context rect:biggerDoneRect radius:10 color:[UIColor grayColor]];
	[self drawRoundedRect:_context rect:doneRect radius:10 color:[UIColor whiteColor]];
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
