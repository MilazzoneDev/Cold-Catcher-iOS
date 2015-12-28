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
static int const kMaxCellSegments = 50;
static int const kMinCellSegments = 8;
//percent of total size
static CGFloat const kMaxWallDistance = 0.90f;
static CGFloat const kAvgWallDistance = 0.75f;
static CGFloat const kMinWallDistance = 0.40f;
static CGFloat const kMaxWallMove = 0.5;
static CGFloat const kAvgWallMove = 0.25;
static CGFloat const kMinWallMove = 0.1;

typedef enum {
	kDrawingOrderBackground,
	kDrawingOrderCell,
	kDrawingOrderParticle
}kDrawingOrder;

@implementation Cell
{
	//used to calculate spline
	CGPoint* wallPoints;
	CGPoint* wallSpokes;
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
		//self.color = [UIColor whiteColor];
		self.color = [UIColor colorWithWhite:1 alpha:1];
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
	[self initCellShape];
	
	/*self.sprite = [SKShapeNode shapeNodeWithCircleOfRadius:self.radius];
	self.sprite.fillColor = self.color;
	self.sprite.strokeColor = [UIColor blackColor];
	self.sprite.zPosition = kDrawingOrderCell;
	*/
	self.curVelocity = CGPointZero;
	//[self addChild:self.sprite];
	self.adjustedRadius = self.radius;
	
	//new emitter
	/*NSString *particlePath = [[NSBundle mainBundle] pathForResource:@"InsideCell" ofType:@"sks"];
	self.insideCell = [NSKeyedUnarchiver unarchiveObjectWithFile:particlePath];
	self.insideCell.position = CGPointMake(0, 0);
	self.insideCell.zPosition = kDrawingOrderParticle;
	self.insideCell.name = @"particles";
	[self addChild:self.insideCell];
	*/
	[self DrawSizeUpdate];
}

//new init to show cell shape
-(void)initCellShape
{
	//need to make sure it is 1 less than kMaxCellSegments to make sure we can wrap back around
	[self recalculateSpokes];
	//self.wallDistances = [[NSMutableArray alloc]initWithCapacity:kMaxCellSegments];
	self.wallDistances = [NSMutableArray arrayWithCapacity:kMaxCellSegments];
	wallPoints = (CGPoint*)malloc(kMaxCellSegments * sizeof(CGPoint));
	wallSpokes = (CGPoint*)malloc(kMaxCellSegments * 2 * sizeof(CGPoint));
	
	//set all wallDistances to avg and wallpoints
	CGFloat avgDistance = self.radius* kAvgWallDistance;
	CGFloat angle = (M_PI*2/self.numWallSegments);
	for (int i = 0; i<self.numWallSegments; i++)
	{
		self.wallDistances[i] = [NSNumber numberWithFloat:avgDistance];
		wallPoints[i] = CGPointMake(sinf(angle*i)*avgDistance, cosf(angle*i)*avgDistance);
		
		//NSLog(@"X:%f,Y:%f",self.wallPoints[i].x,self.wallPoints[i].y);
		
		//spokes
		wallSpokes[i*2] = CGPointZero;
		wallSpokes[i*2+1] = CGPointMake(sinf(angle*i)*self.radius, cosf(angle*i)*self.radius);
	}
	//set last segment to first so it wraps around
	wallPoints[self.numWallSegments] = wallPoints[0];
	
	//set the rest of the spokes to zero
	for(int i = self.numWallSegments; i<kMaxCellSegments; i++)
	{
		self.wallDistances[i] = [NSNumber numberWithFloat:avgDistance];
		wallSpokes[i] = CGPointZero;
	}
	
}

#pragma mark updates
//used to update traits (not used for motion)
-(void)playerUpdate:(CGFloat)dt
{
	[self update:dt];
	[Bacteria playerUpdate:self.radius];
	
}

//update each frame (both bacteria and player)
-(void)update:(CGFloat)dt
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
	
	//cell movement
	[self moveWall:dt];
	[self updateWall];
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

#pragma mark Size Change
//used to change the size for playscale purposes
-(void)updateRadiusToPlayScale
{
	self.radius = [GameScene getScale] * self.adjustedRadius;
	[self DrawSizeUpdate];
}

//used for being eaten and eating
-(void)changeRadius:(CGFloat)changeAmt
{
	self.adjustedRadius += changeAmt;
	self.radius = self.adjustedRadius * [GameScene getScale];
	[self DrawSizeUpdate];
}

//used to recalculate the number of spokes we have on the cell
-(void)recalculateSpokes
{
	//need to make sure it is 1 less than kMaxCellSegments to make sure we can wrap back around
	/*if(self.radius/2 > kMaxCellSegments-1)
	{
		self.numWallSegments = kMaxCellSegments-1;
	}
	else if(self.radius/2 < kMinCellSegments)
	{
		self.numWallSegments = kMinCellSegments;
	}
	else
	{
		self.numWallSegments = floorf(self.radius/2);
	}*/
	
	self.numWallSegments = Clamp(floorf(self.radius/2), kMinCellSegments, kMaxCellSegments-1);
}

-(void)updateSpokes
{
	[self recalculateSpokes];
	//set all spoke points
	CGFloat angle = (M_PI*2/self.numWallSegments);
	//we only change every other spoke to make it pointy
	for (int i = 0; i<self.numWallSegments; i++)
	{
		//spokes
		//self.wallSpokes[i*2] = CGPointZero; //Don't need to change will be the same
		wallSpokes[i*2+1] = CGPointMake(sinf(angle*i)*self.radius, cosf(angle*i)*self.radius);
	}
	//NSLog(@"%i",self.numWallSegments);
}

-(void)moveWall:(CGFloat)dt
{
	//set all wallDistances to avg and wallpoints
	CGFloat avgDistance = self.radius* kAvgWallDistance;
	CGFloat angle = (M_PI*2/self.numWallSegments);
	
	/*//simple average method of drawing (always the average circle)
	//update walls every other frame to save performance (this has issues with drawing upon shrinking)
	for (int i = 0; i<self.numWallSegments; i++)
	{
		self.wallDistances[i] = [NSNumber numberWithFloat:avgDistance];
		self.wallPoints[i] = CGPointMake(sinf(angle*i)*avgDistance, cosf(angle*i)*avgDistance);
		//NSLog(@"X:%f,Y:%f",self.wallPoints[i].x,self.wallPoints[i].y);
	}
	//set last segment to first so it wraps around
	self.wallPoints[self.numWallSegments] = self.wallPoints[0];
	*/
	
	//simple movement method of drawing (not dependant on movement or anything)
	for (int i = 0; i<self.numWallSegments; i++)
	{
		//only move some of the wall
		if(RandomSign()>0)
		{
			//use a random number to move the wall
			CGFloat randomnumber = RandomFloatRange(kMinWallMove, kMaxWallMove);
			CGFloat wallDistanceNumber = [(NSNumber *)self.wallDistances[i] floatValue];
			CGFloat newDistance = (RandomSign()*randomnumber*dt*self.radius) + wallDistanceNumber;
			if(newDistance < avgDistance*self.radius)
			{
				newDistance += (randomnumber*dt*self.radius);
			}
			else if(newDistance > avgDistance*self.radius)
			{
				newDistance += (randomnumber*dt*self.radius);
			}
			CGFloat newClampedDistance = Clamp(newDistance, kMinWallDistance*self.radius, kMaxWallDistance*self.radius);
			self.wallDistances[i] = [NSNumber numberWithFloat:newClampedDistance];
			
			//set wall points because it was changed
			wallPoints[i] = CGPointMake(sinf(angle*i)*newClampedDistance,cosf(angle*i)*newClampedDistance);
		}
		
	}
	//set last segment to first so it wraps around
	wallPoints[self.numWallSegments] = wallPoints[0];
	
	//change wall switcher
	//wallswitcher = !wallswitcher;
}

#pragma mark Drawing
//will be called each frame to move the wall
-(void)updateWall
{
	//draw the new wall
	[self.sprite removeFromParent];
	
	self.sprite = [SKShapeNode shapeNodeWithSplinePoints:wallPoints count:[self numWallSegments]+1];
	self.sprite.fillColor = self.color;
	self.sprite.zPosition = kDrawingOrderCell;
	self.sprite.strokeColor = [UIColor blackColor];
	self.sprite.lineWidth = 1;
	[self addChild:self.sprite];
}

//called only when the size of the cell changes
-(void)DrawSizeUpdate
{
	[self updateSpokes];
	[self.spriteBackground removeFromParent];
	
	/*
	//old drawing of just a circle
	//update sprite
	self.sprite = [SKShapeNode shapeNodeWithCircleOfRadius:self.radius];
	self.sprite.fillColor = self.color;
	self.sprite.strokeColor = [UIColor blackColor];
	self.sprite.lineWidth = 1;
	[self addChild:self.sprite];
	*/
	//update emitter
	/*self.insideCell.particleSpeedRange = self.radius;
	CGFloat sizePercentage = self.radius / [GameScene getMaxCharacterSize];
	self.insideCell.particleScale = kMaxInsideCellSize * sizePercentage;
	self.insideCell.particleScaleSpeed = -1 * (kMaxInsideCellSize * sizePercentage /4);
	*/
	
	//only needs to reset background on size change
	self.spriteBackground = [SKShapeNode shapeNodeWithPoints:wallSpokes count:[self numWallSegments]*2];
	self.spriteBackground.zPosition = kDrawingOrderBackground;
	self.spriteBackground.fillColor = [UIColor clearColor];
	self.spriteBackground.strokeColor = [UIColor blackColor];
	self.spriteBackground.lineWidth = 1;
	[self addChild:self.spriteBackground];
	
}


-(void)dealloc
{
	if(wallPoints) free(wallPoints);
	if(wallSpokes) free(wallSpokes);
}

@end
