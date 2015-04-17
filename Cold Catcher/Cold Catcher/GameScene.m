//
//  GameScene.m
//  Cold Catcher
//
//  Created by Carl Milazzo on 12/29/14.
//  Copyright (c) 2014 Carl Milazzo. All rights reserved.
//

#import "GameScene.h"
#import "Utils.h"
#import "Cell.h"
#import "Bacteria.h"

static CGFloat CurrentScale = 1.0f;//used to scale down (zoom out)
static CGSize gameScreen;//size of screen
static CGPoint kCenter;//center of the screen (used a lot)
BOOL isUpdatingScale;

//initial values and constant values
static CGFloat const kInitialMaxCellSpeed = 300.0; // per second
static CGFloat const kInitialCellRadius = 0.05;//percent screen height


//constants
static CGFloat const kMaxEnemies = 5;
static CGFloat const kMinSpawnTime = 2;
static CGFloat const kTimedEndGame = 0.01; //1cm = 0.01m
static CGFloat const kMaxPlayerSize = 0.25; //radius divided by screen size
static CGFloat const kMinCellSize = 0.005; //screen dementions
static CGFloat const kPlayScaleChange = kInitialCellRadius/kMaxPlayerSize;
static CGFloat const kPlayScalePerSec = 0.5;
static CGFloat const kScoreDivider = 1.0/1000000.0; //1μm = 0.000001m || 1m = 1000000μm



@implementation GameScene
{
	//time used to find dt (change in time between frames)
	double _lastTime;
	//time last enemy was spawned
	double _lastSpawn;
	//colored background
	SKSpriteNode *background;
	//game actors
	Cell *_player;
	NSMutableArray *_bacteria;
	//game numbers
	CGFloat _playerEatSpeed;
	CGFloat _enemyEatSpeed;
	//used to visualize zoomout
	SKShapeNode *zoombar;

}

#pragma mark properties
+(void)changePlayScale:(CGFloat)newScale
{
	CurrentScale = newScale;
}

+(CGFloat)getScale
{
	return CurrentScale;
}

+(BOOL)isSceneUpdatingScale
{
	return isUpdatingScale;
}

+(CGPoint)getCenter
{
	return kCenter;
}

+(CGSize)getScreenSize
{
	return gameScreen;
}

+(CGFloat)getMaxCharacterSize
{
	return kMaxPlayerSize*gameScreen.height;
}

-(CGFloat)getMinCellSize
{
	return kMinCellSize*gameScreen.height;
}

-(CGFloat)getMaxPlayerSize
{
	return kMaxPlayerSize*gameScreen.height;
}

-(CGFloat)getInitialPlayerSize
{
	return kInitialCellRadius*gameScreen.height;
}

-(void)changeScore:(float)newScore
{
	self.maxScore = MAX(self.maxScore,newScore);
	//change score second because the key value observer is linked to this one
	self.score = newScore;
}

#pragma mark Initializers
//used to make a new game

-(id)initEndlessGameWithSize:(CGSize)size {
	
	if(self = [super initWithSize:size])
	{
		[self initGame:size];
		self.isTimed = NO;
	}
	return self;
}

-(id)initTimedGameWithSize:(CGSize)size
{
	if(self = [super initWithSize:size])
	{
		[self initGame:size];
		self.isTimed = YES;
		self.gameTime = 0.0;
	}
	return self;
}

-(void)initGame:(CGSize)size
{

	[self initConstants:size];
	//create player
	_player = [[Cell alloc] initPlayer:[self getInitialPlayerSize] withSpeedOf:kInitialMaxCellSpeed];
	[self addChild:_player];
	[_player setPosition:kCenter];
	_player.seekPoint = kCenter;
	_playerEatSpeed = 25.0; //5
	//enemy starting stats
	_enemyEatSpeed = 2.0;
	
	//start score
	_maxScore = 0;
	[self changeScore:15*kScoreDivider];
}

//initializes various variables that are needed for gameplay
-(void)initConstants:(CGSize)size
{
	
	_lastTime = (double)CFAbsoluteTimeGetCurrent();
	gameScreen = size;
	kCenter = CGPointMake(gameScreen.width/2, gameScreen.height/2);
	_numZoomOuts = 0;
	
	//create background
	[self loadBackground];
	
	
	//init enemy array
	_bacteria = [[NSMutableArray alloc] init];
	_lastSpawn = 0;
	self.gameOver = NO;
	
}

//creates a gradiant background for the game
-(void)loadBackground
{
	//get context
	bool opaque = NO;
	CGFloat scale= 0;
	UIGraphicsBeginImageContextWithOptions(gameScreen, opaque, scale);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// Create the colors
	UIColor *darkOp = [UIColor redColor];
	UIColor *lightOp = [UIColor colorWithRed:1.0 green:0.5 blue:0.5 alpha:1.0];
 
	// Create the gradient
	CGFloat locations[2];
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	NSMutableArray *colors = [NSMutableArray arrayWithCapacity:3];
	[colors addObject:(id)lightOp.CGColor];
	locations[0] = 0.0;
	[colors addObject:(id)darkOp.CGColor];
	locations[1] = 1.0;
	
	CGGradientRef ret = CGGradientCreateWithColors(space, (CFArrayRef)colors, locations);
	CGColorSpaceRelease(space);
	
	// Setup complete, do drawing here
	CGContextDrawRadialGradient(context, ret, kCenter, 0, kCenter, gameScreen.width/2.3, kCGGradientDrawsAfterEndLocation);
	
	// Drawing complete, retrieve the finished image and cleanup
	UIImage *Imageref = UIGraphicsGetImageFromCurrentImageContext();
	SKTexture *texture = [SKTexture textureWithImage:Imageref];
	background = [SKSpriteNode spriteNodeWithTexture:texture];
	// Add background to screen
	[self addChild:background];
	background.position = kCenter;
	background.zPosition = -1;
	UIGraphicsEndImageContext();
}

#pragma mark Update
-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
	// calculate deltaTime
	double time = (double)CFAbsoluteTimeGetCurrent();
	CGFloat dt = time - _lastTime;
	_lastTime = time;
	
	
	[self updatePlayer:dt];
	
	[self updateEnemies:dt];

	[self handleCollisions:dt];
	
	[self updatePlayScale:dt];
	
	[self checkEndGame];
	
	[self updateTime:dt];
	
}

//allows the plaeyr to move and checks for player end game
-(void)updatePlayer:(CGFloat)dt
{
	[_player playerUpdate];
	
	[_player MoveToSeekPoint:dt];
}

//updates enemies movement and spawns new enemies
-(void)updateEnemies:(CGFloat)dt
{
	//move enemies
	for(int i=0; i < _bacteria.count; i++)
	{
		Bacteria *bacteria = _bacteria[i];
		[bacteria enemyUpdate];

		[bacteria MoveToSeekPoint:dt];
		
		//check if this one needs to be deleted
		if(bacteria.radius < [self getMinCellSize])
		{
			[bacteria removeFromParent];
			[_bacteria removeObjectAtIndex:i];
			i--;
		}
	}
	
	//do we need more enemies
	if(_bacteria.count < kMaxEnemies)
	{
		_lastSpawn+=dt;
		if(_lastSpawn >= kMinSpawnTime)
		{
			//get the max speed of the enemy
#warning need to change enemy speed based on difficulty
			CGFloat enemySpeed = kInitialMaxCellSpeed/2;
			//make an enemy
			Bacteria *newEnemy = [[Bacteria alloc] initEnemy:[self getRandomEnemySize] withSpeedof:enemySpeed];
			newEnemy.position = [newEnemy randomOffScreenPosition];
			[_bacteria addObject:newEnemy];
			
			[self addChild:_bacteria[[_bacteria count]-1]];
			//reset last spawn
			_lastSpawn = 0;
		}
	}
#warning need to change enemy eat speed based on difficulty
}

//will change the screen size and give zoom out effect
-(void)updatePlayScale:(CGFloat)dt
{
	if(isUpdatingScale)
	{
		//change scale
		CurrentScale -= kPlayScalePerSec*dt;
		
		//update zoombar (used for visual purposes)
		[zoombar removeFromParent];
		zoombar = [SKShapeNode shapeNodeWithRect:CGRectMake(0, 0, gameScreen.width*CurrentScale, gameScreen.height*CurrentScale)];
		zoombar.position = CGPointMake(gameScreen.width/2-zoombar.frame.size.width/2, gameScreen.height/2-zoombar.frame.size.height/2);
		[self addChild:zoombar];
		
		
		//check scale
		if(CurrentScale <= kPlayScaleChange)
		{
			CurrentScale = 1.0;
			isUpdatingScale = NO;
			[zoombar removeFromParent];
		}
	}
	else
	{
		
		if(_player.radius > [self getMaxPlayerSize])
		{
			zoombar = [SKShapeNode shapeNodeWithRect:CGRectMake(0, 0, gameScreen.width, gameScreen.height)];
			zoombar.fillColor = [SKColor clearColor];
			zoombar.strokeColor = [SKColor blackColor];
			[self addChild:zoombar];
			_numZoomOuts++;
			isUpdatingScale = YES;
		}
	}
}

-(void)checkEndGame
{
	//if player is too small, end the game
	if(_player.radius < [self getMinCellSize])
	{
		[self endGame];
	}
	//if all enemies are larger, end the game
	int largerEnemies = 0;
	for(int i = 0; i < _bacteria.count; i++)
	{
		Bacteria *bacteria = _bacteria[i];
		if(bacteria.radius > _player.radius)
		{
			largerEnemies++;
		}
	}
	if(largerEnemies == kMaxEnemies)
	{
		[self endGame];
	}
	//if it's a timed game check if they have reched the end game
	if(_isTimed && ([self maxScore] >= kTimedEndGame))
	{
		[self endGame];
	}
}

-(void)updateTime:(CGFloat)dt
{
	if(self.isTimed)
	{
		self.gameTime += dt;
	}
}

#pragma mark collision
-(void)handleCollisions:(CGFloat)dt
{
	//collide player wtih enemies
	for(int i = 0; i<_bacteria.count; i++)
	{
		Bacteria *bacteria = _bacteria[i];
		
		//check collide with cells
		if([self checkCollide:_player with:bacteria])
		{
			//eat or be eaten if not changing scale
			if(!isUpdatingScale)
			{
				CGFloat playerChangeAmt;
				CGFloat enemyChangeAmt;
				//player eat bacteria
				if(_player.radius > bacteria.radius)
				{
					playerChangeAmt = _playerEatSpeed*dt;
					enemyChangeAmt = _playerEatSpeed*dt*-1;
				}
				//bacteria eat player
				else
				{
					playerChangeAmt = _enemyEatSpeed*dt*-1;
					enemyChangeAmt = _enemyEatSpeed*dt;
				}
			
				[_player changeRadius:playerChangeAmt];
				[bacteria changeRadius:enemyChangeAmt];
#warning still not correctly adding more score for larger sizes
				//change speed of score to correlate with actual size (roughly)
				float ScaleFix = (_numZoomOuts>0)? (1/kPlayScaleChange * _numZoomOuts): 1;
				[self changeScore:_score+(playerChangeAmt*kScoreDivider*ScaleFix)];
			}
			
			//collision
			[self collide:_player with:bacteria];
		}
	}
	
	//enemies collide
	for(int i = 0; i<_bacteria.count; i++)
	{
		Bacteria *bacteriaOne = _bacteria[i];
		for(int j = i+1; j<_bacteria.count; j++)
		{
			Bacteria *bacteriaTwo = _bacteria[j];
			if([self checkCollide:bacteriaOne with:bacteriaTwo])
			{
				if(bacteriaOne.radius > bacteriaTwo.radius)
				{
					[self collide:bacteriaOne with:bacteriaTwo];
				}
				else
				{
					[self collide:bacteriaTwo with:bacteriaOne];
				}
			}
		}
	}
}

//checks if a collision is currently happening
-(BOOL)checkCollide:(Cell *)cellOne with:(Cell *)cellTwo
{
	CGPoint distanceVec = CGPointSubtract(cellOne.position, cellTwo.position);
	CGFloat distance = CGPointLength(distanceVec);
	
	if(distance < (cellOne.radius+cellTwo.radius))
	{
		//we have collided
		return YES;
	}
	//no collision
	return NO;
}

//moves cells if a collision happened
-(void)collide:(Cell *)cellOne with:(Cell *)cellTwo
{
	CGPoint vectorBetween = CGPointSubtract(cellTwo.position,cellOne.position);
	CGFloat angle = CGPointToAngle(vectorBetween);
	CGFloat distanceBetween = CGPointLength(vectorBetween);
	CGFloat distanceToMove = (cellOne.radius) + (cellTwo.radius) - distanceBetween;
	
	//move the enemy
	CGFloat newX = cellTwo.position.x + (cos(angle)*distanceToMove);
	CGFloat newY = cellTwo.position.y + (sin(angle)*distanceToMove);
	
	cellTwo.position = CGPointMake(newX, newY);
}


#pragma mark Change cells
//changes the player seek point to make sure the player stays entirely on-screen
-(void)changePlayerSeek:(CGPoint)seek
{
	//keep the character on the screen
	// X
	if(seek.x > gameScreen.width - _player.radius)
	{
		seek = CGPointMake(gameScreen.width-_player.radius, seek.y);
	}
	else if(seek.x < _player.radius)
	{
		seek = CGPointMake(_player.radius, seek.y);
	}
	// Y
	if(seek.y > gameScreen.height - _player.radius)
	{
		seek = CGPointMake(seek.x, gameScreen.height-_player.radius);
	}
	else if(seek.y < _player.radius)
	{
		seek = CGPointMake(seek.x,_player.radius);
	}
	
	_player.seekPoint = seek;
}

//creates a random enemy size based on player size
-(CGFloat)getRandomEnemySize
{
	CGFloat newEnemySize;
	//find the smallest enemy
	CGFloat smallest = CGFLOAT_MAX;
	
	for(int i = 0; i < [_bacteria count]; i++)
	{
		Bacteria *enemy = _bacteria[i];
		if(enemy.radius < smallest)
		{
			smallest = enemy.radius;
		}
	}
	
	if(smallest < _player.radius)
	{
		newEnemySize = RandomFloatRange(_player.radius/2, _player.radius * 1.5);
	}
	else
	{
		newEnemySize = RandomFloatRange(_player.radius/2, _player.radius);
	}
	
	return newEnemySize;
}

#pragma mark end game
//used to interact with the view controller to remove the game screen
-(void)endGame
{
	self.gameOver = YES;
}

#pragma mark Touch events
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	/* Called when a touch begins */
	for (UITouch *touch in touches)
	{
		CGPoint touchLocation = [touch locationInNode:self];
		[self changePlayerSeek:touchLocation];
	}
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	for (UITouch *touch in touches)
	{
		CGPoint touchLocation = [touch locationInNode:self];
		[self changePlayerSeek:touchLocation];
	}
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	for (UITouch *touch in touches)
	{
		CGPoint touchLocation = [touch locationInNode:self];
		[self changePlayerSeek:touchLocation];
	}
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	for (UITouch *touch in touches)
	{
		CGPoint touchLocation = [touch locationInNode:self];
		[self changePlayerSeek:touchLocation];
	}
}

#pragma mark pause game
-(void)pauseGame
{
	self.scene.view.paused = YES;
}
-(void)playGame
{
	self.scene.view.paused = NO;
	_lastTime = (double)CFAbsoluteTimeGetCurrent();
}

@end
