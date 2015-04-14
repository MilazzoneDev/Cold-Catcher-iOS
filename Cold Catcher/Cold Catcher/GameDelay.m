//
//  GameDelay.m
//  Cold Catcher
//
//  Created by Carl Milazzo on 3/7/15.
//  Copyright (c) 2015 Carl Milazzo. All rights reserved.
//

#import "GameDelay.h"

@implementation GameDelay
{
	UILabel *delayMessage;
	int delayTime;
	
	NSTimer *delayTimer;
}

-(id)initWithFrame:(CGRect)frame
{
	if(self = [super initWithFrame:frame])
	{
		delayTime = 3;
		delayMessage = [[UILabel alloc] initWithFrame:frame];
		delayMessage.text = [NSString stringWithFormat:@"%d",delayTime];
		delayMessage.font = [UIFont fontWithName:@"Helvetica" size:35];
		delayMessage.textAlignment = NSTextAlignmentCenter;
		[self addSubview:delayMessage];
		delayTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
		_delayFinished = NO;
	}
	return self;
}
		 
-(void)updateTimer
{
	delayTime-=1;
	if(delayTime > 0)
	{
		delayMessage.text = [NSString stringWithFormat:@"%d",delayTime];
	}
	else
	{
		delayMessage.text = @"";
		[delayTimer invalidate];
		delayTimer = nil;
		self.delayFinished = YES;
	}
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
