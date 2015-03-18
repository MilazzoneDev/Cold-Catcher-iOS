//
//  Utils.h
//  Cold Catcher
//
//  Created by Carl Milazzo on 12/29/14.
//

//#import <CoreGraphics/CoreGraphics.h>
#import <SpriteKit/SpriteKit.h>
#import <GLKit/GLKMath.h>


#define ARC4RANDOM_MAX      0xFFFFFFFFu

#define DegreesToRadians(d) (M_PI * (d) / 180.0f)
#define RadiansToDegrees(r) ((r) * 180.0f / M_PI)

#pragma mark Random Functions

//random float between 1 and 0 (not including 1)
static __inline__ CGFloat RandomFloat(void) {
	return (CGFloat)arc4random()/ARC4RANDOM_MAX;
}

//random float between min and max (not including max)
static __inline__ CGFloat RandomFloatRange(CGFloat min, CGFloat max) {
	return ((double)arc4random() / ARC4RANDOM_MAX) * (max - min) + min;
}

//random +1 or -1
static __inline__ CGFloat RandomSign(void) {
	return arc4random_uniform(2) == 0 ? 1.0f : -1.0f;
}
#pragma mark Points and angles

//vector to point
static __inline__ CGPoint CGPointFromGLKVector2(GLKVector2 vector)
{
	return CGPointMake(vector.x, vector.y);
}

//point to vector
static __inline__ GLKVector2 GLKVector2FromCGPoint(CGPoint point)
{
	return GLKVector2Make(point.x, point.y);
}

//adding points together
static __inline__ CGPoint CGPointAdd(CGPoint point1, CGPoint point2)
{
	return CGPointMake(point1.x + point2.x, point1.y + point2.y);
}

//subtracting points
static __inline__ CGPoint CGPointSubtract(CGPoint point1, CGPoint point2)
{
	return CGPointMake(point1.x - point2.x, point1.y - point2.y);
}

//multiplying points
static __inline__ CGPoint CGPointMultiply(CGPoint point1, CGPoint point2)
{
	return CGPointMake(point1.x * point2.x, point1.y * point2.y);
}

//dividing points
static __inline__ CGPoint CGPointDivide(CGPoint point1, CGPoint point2)
{
	return CGPointMake(point1.x / point2.x, point1.y / point2.y);
}

//multiply a point by a scalar
static __inline__ CGPoint CGPointMultiplyScalar(CGPoint point, CGFloat value)
{
	return CGPointFromGLKVector2(GLKVector2MultiplyScalar(GLKVector2FromCGPoint(point), value));
}

//length of vector (from a point)
static __inline__ CGFloat CGPointLength(CGPoint point)
{
	return GLKVector2Length(GLKVector2FromCGPoint(point));
}

//normalize a point
static __inline__ CGPoint CGPointNormalize(CGPoint point)
{
	return CGPointFromGLKVector2(GLKVector2Normalize(GLKVector2FromCGPoint(point)));
}

//distance between points
static __inline__ CGFloat CGPointDistance(CGPoint point1, CGPoint point2)
{
	return CGPointLength(CGPointSubtract(point1, point2));
}

//point to angle
static __inline__ CGFloat CGPointToAngle(CGPoint point)
{
	return atan2f(point.y, point.x);
}

//angle to normalized point
static __inline__ CGPoint CGPointForAngle(CGFloat value)
{
	return CGPointMake(cosf(value), sinf(value));
}

//lerp between 2 points at time t
static __inline__ CGPoint CGPointLerp(CGPoint startPoint, CGPoint endPoint, float t)
{
	return CGPointMake(startPoint.x + (endPoint.x - startPoint.x) * t,
					   startPoint.y + (endPoint.y - startPoint.y) * t);
}

static __inline__ CGFloat ScalarSign(CGFloat value)
{
	return value >= 0 ? 1 : -1;
}

// Returns shortest angle between two angles, between -M_PI and M_PI
static __inline__ CGFloat ScalarShortestAngleBetween(CGFloat value1, CGFloat value2)
{
	CGFloat difference = value2 - value1;
	CGFloat angle = fmodf(difference, M_PI * 2);
	if (angle >= M_PI) {
		angle -= M_PI * 2;
	}
	if (angle <= -M_PI) {
		angle += M_PI * 2;
	}
	return angle;
}

#pragma mark Other math
//clamp float
static __inline__ CGFloat Clamp(CGFloat value, CGFloat min, CGFloat max) {
	return value < min ? min : value > max ? max : value;
}

#pragma mark Color
//SkColor from RGB
static __inline__ SKColor *SKColorWithRGB(int r, int g, int b) {
	return [SKColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f];
}
//SkColor from RGBA
static __inline__ SKColor *SKColorWithRGBA(int r, int g, int b, int a) {
	return [SKColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a/255.0f];
}
