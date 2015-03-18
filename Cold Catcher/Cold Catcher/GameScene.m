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
static CGFloat const kInitialCellRadius = 15.0;


//constants
static CGFloat const kMaxEnemies = 5;
static CGFloat const kMinSpawnTime = 2;
static CGFloat const kMaxPlayerSize = 80; //screan dementions
static CGFloat const kMinCellSize = 2; //screen dementions
static CGFloat const kPlayScaleChange = kInitialCellRadius/kMaxPlayerSize;
static CGFloat const kPlayScalePerSec = 0.5;
static CGFloat const kScoreDivider = 1.0/1000000.0; //1μm = 0.000001m || 1 m = 1000000 μm


@implementation GameScene
{
	//time used for update
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
	return kMaxPlayerSize;
}

-(void)changeScore:(float)newScore
{
	self.maxScore = MAX(self.maxScore,newScore);
	//change score second because the key value observer is linked to this one
	self.score = newScore;
}

#pragma mark Initializers
//used to make a new game
-(id)initNewGameWithSize:(CGSize)size {
	if (self = [super initWithSize:size]) {
		[self initConstants:size];
		
		//create player
		_player = [[Cell alloc] initPlayer:kInitialCellRadius withSpeedOf:kInitialMaxCellSpeed];
		[self addChild:_player];
		[_player setPosition:kCenter];
		_player.seekPoint = kCenter;
		_playerEatSpeed = 5.0;
		//enemy starting stats
		_enemyEatSpeed = 2.0;
		
		//start score
		_maxScore = 0;
		[self changeScore:_player.radius*kScoreDivider];
	}
	return self;
}

-(void)initConstants:(CGSize)size
{
	_lastTime = (double)CFAbsoluteTimeGetCurrent();
	gameScreen = size;
	kCenter = CGPointMake(gameScreen.width/2, gameScreen.height/2);
	
	//create background
	background = [[SKSpriteNode alloc] initWithColor:[UIColor redColor] size:gameScreen];
	[self addChild:background];
	background.position = kCenter;
	
	//init enemy array
	_bacteria = [[NSMutableArray alloc] init];
	_lastSpawn = 0;
	self.gameOver = NO;
	
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
	
}

-(void)updatePlayer:(CGFloat)dt
{
	[_player playerUpdate];
	
	[_player MoveToSeekPoint:dt];

	if(_player.radius < kMinCellSize)
	{
		[self endGame];
	}
	
}

-(void)updateEnemies:(CGFloat)dt
{
	//move enemies
	for(int i=0; i < _bacteria.count; i++)
	{
		Bacteria *bacteria = _bacteria[i];
		[bacteria enemyUpdate];

		[bacteria MoveToSeekPoint:dt];
		
		//check if this one needs to be deleted
		if(bacteria.radius < kMinCellSize)
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
}


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
		if(_player.radius > kMaxPlayerSize)
		{
			zoombar = [SKShapeNode shapeNodeWithRect:CGRectMake(0, 0, gameScreen.width, gameScreen.height)];
			zoombar.fillColor = [SKColor clearColor];
			zoombar.strokeColor = [SKColor blackColor];
			[self addChild:zoombar];
			isUpdatingScale = YES;
		}
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
				[self changeScore:_score+(playerChangeAmt*kScoreDivider)];
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
