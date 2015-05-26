//
//  GameUI.h
//  Cold Catcher
//
//  Created by Carl Milazzo on 5/25/15.
//  Copyright (c) 2015 Carl Milazzo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameUI : UIView


//initializes the UI for the game
//isTimed is used for timed vs endless game
-(id)initWithFrame:(CGRect)frame isTimed:(BOOL)isTimed;

//used to update each of the labels used
-(void)updateMaxScoreLabel:(float)maxScore;
-(void)updateScoreLabel:(float)score;
-(void)updateTimerLabel:(float)time;


//used to pass correct number and ending for scores
typedef struct
{
	float number;
	__unsafe_unretained NSString *character;
}scoreModifier;

//changes the score to the correct modifier (cm, mm, m)
+(scoreModifier)scoreFixer:(float)score;
@end
