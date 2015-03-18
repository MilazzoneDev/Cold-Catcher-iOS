//
//  OptionsButton.m
//  Cold Catcher
//
//  Created by Carl Milazzo on 1/28/15.
//  Copyright (c) 2015 Carl Milazzo. All rights reserved.
//

#import "OptionsButton.h"
#import "Utils.h"

static float const shrinkAmt = 0.8;
static float const lightColor = 114.0;
static float const darkColor = 60.0;

@implementation OptionsButton
{
	UIImageView *_buttonImageView;
	CGPoint _shiftAmt;
}


-(id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if(self)
	{
		[self setUserInteractionEnabled:YES];
		
		_buttonImageView = [[UIImageView alloc] initWithFrame:self.bounds];
		_buttonImageView.contentMode = UIViewContentModeScaleAspectFit;
		_buttonImageView.image = [UIImage imageNamed:@"OptionsButton"];
		_buttonImageView.image = [_buttonImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		[_buttonImageView setTintColor:[UIColor colorWithRed:lightColor/255.0 green:lightColor/255.0 blue:lightColor/255.0 alpha:1]];
		[self addSubview:_buttonImageView];
		
		_shiftAmt = CGPointMake(self.frame.size.width*((1-shrinkAmt)/2), self.frame.size.height*((1-shrinkAmt)/2));
	}
	return self;
}



-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	//[self setTintColor:[UIColor blackColor]];
	[_buttonImageView setTintColor:[UIColor colorWithRed:darkColor/255.0 green:darkColor/255.0 blue:darkColor/255.0 alpha:1]];
	[_buttonImageView setFrame:CGRectMake(_buttonImageView.frame.origin.x+_shiftAmt.x, _buttonImageView.frame.origin.y+_shiftAmt.y, _buttonImageView.frame.size.width*shrinkAmt, _buttonImageView.frame.size.width*shrinkAmt)];
	
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	for (UITouch *touch in touches) {
		CGPoint touchPoint = [touch locationInView:[self superview]];
		
		if(CGRectContainsPoint(self.frame, touchPoint))
		{
			self.optionsPressed = YES;
		}
	}
	
	[_buttonImageView setTintColor:[UIColor colorWithRed:lightColor/255.0 green:lightColor/255.0 blue:lightColor/255.0 alpha:1]];
	[_buttonImageView setFrame:CGRectMake(_buttonImageView.frame.origin.x-_shiftAmt.x, _buttonImageView.frame.origin.y-_shiftAmt.y, _buttonImageView.frame.size.width/shrinkAmt, _buttonImageView.frame.size.width/shrinkAmt)];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[_buttonImageView setTintColor:[UIColor colorWithRed:lightColor/255.0 green:lightColor/255.0 blue:lightColor/255.0 alpha:1]];
	[_buttonImageView setFrame:CGRectMake(_buttonImageView.frame.origin.x-_shiftAmt.x, _buttonImageView.frame.origin.y-_shiftAmt.y, _buttonImageView.frame.size.width/shrinkAmt, _buttonImageView.frame.size.width/shrinkAmt)];
}

@end
