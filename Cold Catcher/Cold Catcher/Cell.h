//
//  Cell.h
//  Cold Catcher
//
//  Created by Carl Milazzo on 12/29/14.
//  Copyright (c) 2014 Carl Milazzo. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Cell : SKNode

//adjusted variables are variables used for scaling
// visible radius
@property(nonatomic, assign)CGFloat radius;
@property(nonatomic, assign) UIColor* color;
@property(nonatomic, assign) CGPoint seekPoint;
@property(nonatomic, assign) CGFloat maxSpeed;
@property(nonatomic, assign) CGPoint curVelocity;
// adjustedRadius * playscale = radius
@property(nonatomic, assign) CGFloat adjustedRadius;
// adjustedPosition = original position (before scaling)
@property(nonatomic, assign) CGPoint adjustedPosition;
// adjustedSeekPoint = original seekPoint (before scaling)
@property(nonatomic, assign) CGPoint adjustedSeekPoint;

@property SKShapeNode *sprite;
@property SKEmitterNode *insideCell;

+(CGFloat)getAccel;

-(id)initPlayer:(CGFloat)startingRadius withSpeedOf:(CGFloat)MaxSpeed;
-(id)initEnemyCell:(CGFloat)startingRadius withSpeedOf:(CGFloat)MaxSpeed;

-(void)playerUpdate;
-(void)update;
-(void)MoveToSeekPoint:(CGFloat)dt;

-(void)changeRadius:(CGFloat)changeAmt;

@end
