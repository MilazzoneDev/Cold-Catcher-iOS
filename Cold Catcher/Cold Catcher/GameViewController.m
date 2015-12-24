//
//  GameViewController.m
//  Cold Catcher
//
//  Created by Carl Milazzo on 12/29/14.
//  Copyright (c) 2014 Carl Milazzo. All rights reserved.
//

#import "GameViewController.h"
#import "GameMenu.h"
#import "GameScene.h"
#import "GameUI.h"
#import "OptionsMenu.h"
#import "OptionsButton.h"
#import "GameOver.h"
#import "GameDelay.h"

//values for buttons
static float const padSide = 128;
static float const padPadding = 10;
//options postions values
static float const optionsOnYPosition = padPadding*3;
static float const optionsXPosition = padPadding*3;
static float optionsOffYPosition; //set in setUpOptions

@implementation GameViewController
{
	//UI
	OptionsButton *optionControl;
	GameUI *gameUI;
	
	//views
	SKView *skView;
	GameMenu *menu;
	GameScene *game;
	OptionsMenu *options;
	GameOver *endGame;
	GameDelay *delay;
	
	
	//iAd variables
	BOOL _bannerIsVisible;
	ADBannerView *_iAd;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    skView = [[SKView alloc] initWithFrame:self.view.bounds];
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    /* Sprite Kit applies additional optimizations to improve rendering performance */
    skView.ignoresSiblingOrder = YES;
    
	[self showMenu];
	
	[self.view addSubview:skView];
}

#pragma mark show screens
//loads a GameMenu screen and presents it
-(void)showMenu
{
	
	// Create and configure the scene.
	menu = [[GameMenu alloc] initWithSize:skView.frame.size];
	menu.scaleMode = SKSceneScaleModeAspectFill;
	
	// set up key-value-observers for menu
	[menu addObserver:self forKeyPath:@"timedGamePressed" options:NSKeyValueObservingOptionNew context:nil];
	[menu addObserver:self forKeyPath:@"endlessGamePressed" options:NSKeyValueObservingOptionNew context:nil];
	[menu addObserver:self forKeyPath:@"optionsScreenPressed" options:NSKeyValueObservingOptionNew context:nil];
	[menu addObserver:self forKeyPath:@"highScoresPressed" options:NSKeyValueObservingOptionNew context:nil];
	
	// Present the scene.
	[skView presentScene:menu];
	
	[self showAd];
}

//loads a new GameScene and presents it (along with a delayed start)
//isTimed = timed vs endless game
-(void)initializeGame:(BOOL)isTimed
{
	//load and init the game
	if(isTimed)
	{
		game = [[GameScene alloc]initTimedGameWithSize:skView.frame.size];
	}
	else
	{
		game = [[GameScene alloc]initEndlessGameWithSize:skView.frame.size];
	}
	game.scaleMode = SKSceneScaleModeAspectFill;

#warning iOS 9 is not working well with transitions, need to find a fix here
	//SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
	//[skView presentScene:game transition:reveal];
	
	//using presentScene works for now but a transition would be apreciated here
	[skView presentScene:game];
	
	//load other controls
	[self loadOtherControls];
	
	//setup game delay
	[self performSelector:@selector(loadDelayedStart) withObject:self afterDelay:0.5];
}

//keeps the game from starting instantly
-(void)loadDelayedStart
{
	delay = [[GameDelay alloc]initWithFrame:skView.frame];
	[delay addObserver:self forKeyPath:@"delayFinished" options:NSKeyValueObservingOptionNew context:nil];
	[game setUserInteractionEnabled:NO];
	[self.view addSubview:delay];
	[game pauseGame];
}

-(void)showGameOver
{
	//init end game
	scoreModifier finalModifier = [GameUI scoreFixer:[game maxScore]];
	if(game.isTimed)
	{
		BOOL didWin = ([game maxScore]>=[GameScene getMaxTimeAttackSize]? true : false);
		endGame = [[GameOver alloc] initWithSize:skView.frame.size finalTime:[game gameTime] didWin:didWin];
	}
	else
	{
		endGame = [[GameOver alloc] initWithSize:skView.frame.size finalScore:finalModifier.number withModifier:finalModifier.character];
	}
#warning iOS 9 is not working well with transitions, need to find a fix here
	//SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
	//[skView presentScene:endGame transition:reveal];
	[skView presentScene:endGame];
	
	//key value observers
	[endGame addObserver:self forKeyPath:@"menuPressed" options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark key-value-observers
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	//MENU
	//did we want to start a new game
	if([keyPath isEqualToString:@"timedGamePressed"])
	{
		[self initializeGame:YES];
		[self removeMainMenu];
	}
	if([keyPath isEqualToString:@"endlessGamePressed"])
	{
		[self initializeGame:NO];
		[self removeMainMenu];
	}
#warning finish buttons
	if([keyPath isEqualToString:@"optionsScreenPressed"])
	{
		//stub
	}
	if([keyPath isEqualToString:@"highScoresPressed"])
	{
		//stub
	}
	
	
	//OPTIONS
	//did we want to open the options menu
	if([keyPath isEqualToString:@"optionsPressed"])
	{
		[self showOptions:YES];
	}
	//did we want to close the options menu
	if([keyPath isEqualToString:@"donePressed"])
	{
		[self showOptions:NO];
	}
	
	//DELAY
	//did the game delay finish?
	if([keyPath isEqualToString:@"delayFinished"])
	{
		[game playGame];
		[game setUserInteractionEnabled:YES];
		[delay removeObserver:self forKeyPath:@"delayFinished"];
		[delay removeFromSuperview];
		delay = nil;
	}
	
	//GAME
	//did the score change?
	if([keyPath isEqualToString:@"score"])
	{
		[self updateScore];
	}
	//did the game end?
	if([keyPath isEqualToString:@"gameOver"])
	{
		if([(GameScene *)object gameOver])
		{
			[self showGameOver];
			[self removeGame];
		}
	}
	//update time if in timed mode
	if([keyPath isEqualToString:@"gameTime"])
	{
		if(game.isTimed)
		{
			[self updateTimer];
		}
	}
	
	//GAME OVER
	//did they choose to go back to the menu from the game over screen?
	if([keyPath isEqualToString:@"menuPressed"])
	{
		[self showMenu];
		[self removeGameOver];
	}
	
}

#pragma mark other game controls and labels
-(void)loadOtherControls
{
	//options control
	optionControl = [[OptionsButton alloc]initWithFrame:CGRectMake(skView.frame.size.width-padPadding-(padSide/3), padPadding, padSide/3, padSide/3)];
	[self.view addSubview:optionControl];
	//button to open options menu
	[optionControl addObserver:self forKeyPath:@"optionsPressed" options:NSKeyValueObservingOptionNew context:nil];
	
	[self setUpOptions];
	
	//sets up the game UI (score, timers, frames)
	gameUI = [[GameUI alloc]initWithFrame:skView.frame isTimed:game.isTimed];
	gameUI.userInteractionEnabled = NO;
	[self.view addSubview:gameUI];
	
	[self updateScore];
	
	//key value observer for score
	[game addObserver:self forKeyPath:@"score" options:NSKeyValueObservingOptionNew context:nil];
	
	//key value observer for game over
	[game addObserver:self forKeyPath:@"gameOver" options:NSKeyValueObservingOptionNew context:nil];
	
	//key value observer for timer
	[game addObserver:self forKeyPath:@"gameTime" options:NSKeyValueObservingOptionNew context:nil];
}

-(void)setUpOptions
{
	//set the optionsOffYPosition to be off the screen
	optionsOffYPosition = -skView.frame.size.height;
	options = [[OptionsMenu alloc] initWithFrame:CGRectMake(optionsXPosition, optionsOffYPosition,skView.frame.size.width-(padPadding*6) , skView.frame.size.height-(padPadding*6))];
	options.hidden = YES;
	[options setBackgroundColor:[UIColor clearColor]];
	[self.view addSubview:options];
	
	//button to close the options menu
	[options addObserver:self forKeyPath:@"donePressed" options:NSKeyValueObservingOptionNew context:nil];
}

//brings down the options menu
-(void)showOptions:(BOOL)show
{
	if(show)
	{
		[optionControl setUserInteractionEnabled:NO];
		[game pauseGame];
		[game setUserInteractionEnabled:NO];
		options.hidden = NO;
		//_options.frame = CGRectMake(optionsXPosition, optionsOffYPosition, _options.frame.size.width , _options.frame.size.height);
		[UIView animateWithDuration:0.25f
							  delay:0.0f
							options:UIViewAnimationOptionCurveEaseOut
						 animations:^{
							 options.frame = CGRectMake(optionsXPosition, optionsOnYPosition+75, options.frame.size.width , options.frame.size.height);
							 
						 }
						 completion:^(BOOL finished) {
							 //NSLog(@"finished1");
						 }];
		[UIView animateWithDuration:0.35f
							  delay:0.25f
							options:UIViewAnimationOptionCurveEaseInOut
						 animations:^{
							 options.frame = CGRectMake(optionsXPosition, optionsOnYPosition, options.frame.size.width , options.frame.size.height);
							 
						 }
						 completion:^(BOOL finished) {
							 [self showAd];
							 //NSLog(@"finished2");
						 }];
	}
	else
	{
		//clear iAd
		[self removeAd];
		
		
		//NOTE: Make sure to enable the _optionControl on completion, otherwise if pressed before completion the screen won't come back
		//clear options screen
		[UIView animateWithDuration:0.5f
							  delay:0.0f
							options:UIViewAnimationOptionTransitionNone
						 animations:^{
							 options.frame = CGRectMake(optionsXPosition, optionsOffYPosition, options.frame.size.width , options.frame.size.height);
							 
						 }
						 completion:^(BOOL finished) {
							 [optionControl setUserInteractionEnabled:YES];
							 [game setUserInteractionEnabled:YES];
							 [game playGame];
							 options.hidden = YES;
						 }];
	}
}
//updates the label
-(void)updateScore
{
	float score = [game score];
	float maxScore = [game maxScore];
	
	[gameUI updateScoreLabel:score];
	[gameUI updateMaxScoreLabel:maxScore];
}
//updates the label
-(void)updateTimer
{
	float time = game.gameTime;
	[gameUI updateTimerLabel:time];
}

#pragma mark ADBannerView methods
//create the ADBannerView
-(void)showAd
{
	//creates a short and wide Ad
	_iAd = [[ADBannerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 100)];
	_iAd.delegate = self;
}

//removes the Ad from view and then removes it entirely
-(void)removeAd
{
	[UIView animateWithDuration:0.2f
						  delay:0.0f
						options:UIViewAnimationOptionTransitionNone
					 animations:^{
						 _iAd.frame = CGRectOffset(_iAd.frame, 0, _iAd.frame.size.height);
					 }
					 completion:^(BOOL finished) {
						 // Assumes the banner view is placed at the bottom of the screen.
						 _iAd.frame = CGRectOffset(_iAd.frame, 0, _iAd.frame.size.height);
						 [_iAd removeFromSuperview];
						 _iAd.delegate = nil;
						 _iAd = nil;
						 _bannerIsVisible = NO;
					 }];
}

//if the Ad was loaded show it (with an animation)
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
	if (!_bannerIsVisible)
	{
		if(game != nil)
		{
			//move the options menu up a tad
			[UIView animateWithDuration:0.1f
								delay:0.0f
								options:UIViewAnimationOptionTransitionNone
							animations:^{
								//used if the tall iAd is used
								//_options.frame = CGRectOffset(_options.frame, 0, -padPadding*1.5);
							 
							}
							completion:^(BOOL finished) {
							 
							}];
		}
		// If banner isn't part of view hierarchy, add it
		if (_iAd.superview == nil)
		{
			[self.view addSubview:_iAd];
		}
		
		
		//animates the banner ad
		[UIView beginAnimations:@"animateAdBannerOn" context:NULL];
		
		// Assumes the banner view is just off the bottom of the screen.
		banner.frame = CGRectOffset(banner.frame, 0, -banner.frame.size.height);
		
		[UIView commitAnimations];
		
		_bannerIsVisible = YES;
	}
}

//undo setup if banner failed to show
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
	NSLog(@"Failed to retrieve ad");
	
	if (_bannerIsVisible)
	{
		if(game != nil)
		{
			//move the options menu down a tad
			[UIView animateWithDuration:0.1f
								  delay:0.0f
								options:UIViewAnimationOptionTransitionNone
							 animations:^{
								 //used if the tall iAd is used
								 //_options.frame = CGRectOffset(_options.frame, 0, padPadding*1.5);
							 
							 }
							 completion:^(BOOL finished) {
							 
							 }];
		}
		
		//animates the banner add
		[UIView beginAnimations:@"animateAdBannerOff" context:NULL];
		
		// Assumes the banner view is placed at the bottom of the screen.
		_iAd.frame = CGRectOffset(_iAd.frame, 0, _iAd.frame.size.height);
		
		[UIView commitAnimations];
		
		_bannerIsVisible = NO;
	}
}

#pragma mark cleanup methods
-(void)removeMainMenu
{
	[menu removeObserver:self forKeyPath:@"timedGamePressed"];
	[menu removeObserver:self forKeyPath:@"endlessGamePressed"];
	[menu removeObserver:self forKeyPath:@"optionsScreenPressed"];
	[menu removeObserver:self forKeyPath:@"highScoresPressed"];
	
	[self removeAd];
	menu = nil;
}
-(void)removeGame
{
	//clearKeyValueObservers
	[game removeObserver:self forKeyPath:@"score"];
	[game removeObserver:self forKeyPath:@"gameOver"];
	[game removeObserver:self forKeyPath:@"gameTime"];
	
	//remove the options button
	[optionControl removeFromSuperview];
	[optionControl removeObserver:self forKeyPath:@"optionsPressed"];
	optionControl = nil;
	
	//remove the score text and decoration
	[gameUI removeFromSuperview];
	gameUI = nil;
	
	//remove the options menu
	[options removeObserver:self forKeyPath:@"donePressed"];
	[options removeFromSuperview];
	options = nil;
}
-(void)removeGameOver
{
	[endGame removeObserver:self forKeyPath:@"menuPressed"];
	endGame = nil;
}

#pragma mark other methods
- (BOOL)shouldAutorotate
{
    return YES;
}

/*- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
#warning remove before submiting
	NSLog(@"MEMORY WARNING");
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark Handle pauses
-(void)viewDidAppear:(BOOL)animated{
	//allows us to pause when the notification menu is opened
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
	// Remove notifications
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
	
	[super viewWillDisappear:animated];
}

- (void)appWillResignActive:(NSNotification *)notification
{
	// Handle notification
	if(options.hidden)
	{
		[game pauseGame];
	}
}

- (void)appDidBecomeActive:(NSNotification *)notification
{
	// Handle notification
	if(options.hidden)
	{
		[game playGame];
	}
	else
	{
		[game pauseGame];
	}
}

//we need to remove the observers that were created so the scene could see the UI elements
-(void)dealloc
{
	if(game)
	{
		if(menu)
		{
			[menu removeObserver:self forKeyPath:@"timedGamePressed"];
			[menu removeObserver:self forKeyPath:@"endlessGamePressed"];
			[menu removeObserver:self forKeyPath:@"optionsScreenPressed"];
			[menu removeObserver:self forKeyPath:@"highScoresPressed"];
		}
		if(optionControl)
		{
			[optionControl removeObserver:self forKeyPath:@"optionsPressed"];
		}
		if(options)
		{
			[options removeObserver:self forKeyPath:@"donePressed"];
		}
		if(game)
		{
			[game removeObserver:self forKeyPath:@"score"];
			[game removeObserver:self forKeyPath:@"gameOver"];
			[game removeObserver:self forKeyPath:@"gameTime"];
		}
		if(endGame)
		{
			[endGame removeObserver:self forKeyPath:@"menuPressed"];
		}
	}
}

@end
