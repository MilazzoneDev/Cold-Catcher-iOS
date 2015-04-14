//
//  Cell.m
//  Cold Catcher
//
//  Created by Carl Milazzo on 12/29/14.
//  Copyright (c) 2014 Carl Milazzo. All rights reserved.
//

#import "Cell.h"
#import "GameScene.h"
#import "Bacteria.h"
#import "Utils.h"

static CGFloat const kAccel = 1; //percent of max speed to accelerate each second
//static CGFloat const kMaxInsideCellSize = 0.4; //used for particles size

typedef enum {
	kDrawingOrderCell,
	kDrawingOrderParticle
}kDrawingOrder;

@implementation Cell
{
	
}

+(CGFloat)getAccel
{
	return kAccel;
}

#pragma mark initializers
//player init only
-(id)initPlayer:(CGFloat)startingRadius withSpeedOf:(CGFloat)MaxSpeed
{
	if(self = [super init])
	{
		self.radius = startingRadius;
		self.color = [UIColor whiteColor];
		self.maxSpeed = MaxSpeed;
		[self initSprite];
	}
	return self;
}

//enemy init only
-(id)initEnemyCell:(CGFloat)startingRadius withSpeedOf:(CGFloat)MaxSpeed 
{
	if(self = [super init])
	{
		self.radius = startingRadius;
		self.maxSpeed = MaxSpeed;
		self.color = [UIColor purpleColor];
		[self initSprite];
	}
	return self;
}

//both bacteria and player
-(void)initSprite
{
	self.sprite = [SKShapeNode shapeNodeWithCircleOfRadius:self.radius];
	self.sprite.fillColor = self.color;
	self.sprite.strokeColor = [UIColor blackColor];
	//self.sprite.
	self.sprite.zPosition = kDrawingOrderCell;
	self.curVelocity = CGPointZero;
	[self addChild:self.sprite];
	self.adjustedRadius = self.radius;
	
	//new emitter
	/*NSString *particlePath = [[NSBundle mainBundle] pathForResource:@"InsideCell" ofType:@"sks"];
	self.insideCell = [NSKeyedUnarchiver unarchiveObjectWithFile:particlePath];
	self.insideCell.position = CGPointMake(0, 0);
	self.insideCell.zPosition = kDrawingOrderParticle;
	self.insideCell.name = @"particles";
	[self addChild:self.insideCell];
	*/
	[self updateSprite];
}

#pragma mark updates
//used to update traits (not used for motion)
-(void)playerUpdate
{
	[self update];
	[Bacteria playerUpdate:self.radius];
	
}

//update each frame (both bacteria and player)
-(void)update
{
	//update playscale
	CGFloat playscale = [GameScene getScale];
	if(playscale == 1)
	{
		self.adjustedRadius = self.radius;
	}
	else
	{
		//we need to change the radius
		[self updateRadiusToPlayScale];
	}
}

-(void)MoveToSeekPoint:(CGFloat)dt
{
	//get the distance to final point
	CGPoint distLeftVec = CGPointSubtract(_seekPoint, _adjustedPosition);
	CGFloat distLeft = CGPointLength(distLeftVec);
	
	//get the desired velocity
	CGPoint desiredVec = CGPointMultiplyScalar(CGPointNormalize(distLeftVec),_maxSpeed);
	
	//get the current speed
	CGFloat newSpeed = CGPointLength(_curVelocity) + (_maxSpeed*([Cell getAccel]*dt));
	newSpeed = (newSpeed > _maxSpeed) ? _maxSpeed:newSpeed;
	
	
	CGPoint AddedVec = CGPointAdd(desiredVec, _curVelocity);
	
	CGPoint newVelocity;
	if(distLeft > newSpeed*dt)
	{
		newVelocity = CGPointMultiplyScalar(CGPointNormalize(AddedVec), newSpeed);
	}
	else
	{
		newVelocity = CGPointZero;
		_adjustedPosition = _seekPoint;
		if([self isMemberOfClass:[Bacteria class]])
		{
			_seekPoint = [(Bacteria *)self randomMove];
		}
	}
	
	self.curVelocity = newVelocity;
	
	//move actual position according to scale
	
	if([GameScene isSceneUpdatingScale])
	{
		//_curVelocity = CGPointZero;
		//move normally
		_adjustedPosition = CGPointAdd(_adjustedPosition, CGPointMultiplyScalar(_curVelocity, dt));
		
		//change to scaled position
		CGPoint newPosition = _adjustedPosition;
		//scale down the adjusted position
		//get percentage for new position
		newPosition = CGPointMake(newPosition.x/[GameScene getScreenSize].width,
								  newPosition.y/[GameScene getScreenSize].height);
		//scale to new rectangle
		newPosition = CGPointMultiply(newPosition,
									  CGPointMake([GameScene getScreenSize].width*[GameScene getScale],
												  [GameScene getScreenSize].height*[GameScene getScale])
									  );
		
		//shift to center
		newPosition = CGPointAdd(newPosition,
								 CGPointMake(
											 [GameScene getScreenSize].width/2-[GameScene getScreenSize].width*[GameScene getScale]/2,
											 [GameScene getScreenSize].height/2-[GameScene getScreenSize].height*[GameScene getScale]/2)
								 );
		
		self.position = newPosition;
		
	}
	else
	{
		//move normally
		self.position = CGPointAdd(self.position, CGPointMultiplyScalar(_curVelocity,dt));
		_adjustedPosition = self.position;
	}
	
}

//used to change the size for playscale purposes
-(void)updateRadiusToPlayScale
{
	self.radius = [GameScene getScale] * self.adjustedRadius;
	[self updateSprite];
}

//used for being eaten and eating
-(void)changeRadius:(CGFloat)changeAmt
{
	self.adjustedRadius += changeAmt;
	self.radius = self.adjustedRadius * [GameScene getScale];
	[self updateSprite];
}

-(void)updateSprite
{
	[self.sprite removeFromParent];
	//update sprite
	self.sprite = [SKShapeNode shapeNodeWithCircleOfRadius:self.radius];
	self.sprite.fillColor = self.color;
	self.sprite.strokeColor = [UIColor blackColor];
	self.sprite.lineWidth = 1;
	[self addChild:self.sprite];
	
	//update emitter
	/*self.insideCell.particleSpeedRange = self.radius;
	CGFloat sizePercentage = self.radius / [GameScene getMaxCharacterSize];
	self.insideCell.particleScale = kMaxInsideCellSize * sizePercentage;
	self.insideCell.particleScaleSpeed = -1 * (kMaxInsideCellSize * sizePercentage /4);
	*/
}

@end
