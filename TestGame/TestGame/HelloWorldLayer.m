//
//  HelloWorldLayer.m
//  TestGame
//
//  Created by ZhaoJuan on 13-12-26.
//  Copyright ZhaoJuan 2013年. All rights reserved.
//

#import "AppDelegate.h"
#import "cpMouse.h"
// Import the interfaces
#import "HelloWorldLayer.h"

#import "SmallBlockSprite.h"

enum {
	kTagParentNode = 1,
};


#pragma mark - HelloWorldLayer

@interface HelloWorldLayer ()
-(void) addNewSpriteAtPosition:(CGPoint)pos;
-(void) createMenu;
-(void) initPhysics;
@end


@implementation HelloWorldLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init
{
	if( (self=[super init])) {
		
		// enable events
#ifdef __CC_PLATFORM_IOS
		self.touchEnabled = YES;
		self.accelerometerEnabled = YES;
#elif defined(__CC_PLATFORM_MAC)
		self.mouseEnabled = YES;
#endif
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		// title
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Multi touch the screen" fontName:@"Marker Felt" fontSize:36];
		label.position = ccp( s.width / 2, s.height - 30);
//		[self addChild:label z:-1];
		
		// reset button
//		[self createMenu];
		
		
		// init physics
		[self initPhysics];
		
		
#if 1
		// Use batch node. Faster
		CCSpriteBatchNode *parent = [CCSpriteBatchNode batchNodeWithFile:@"grossini_dance_atlas.png" capacity:100];
		_spriteTexture = [parent texture];
#else
		// doesn't use batch node. Slower
		_spriteTexture = [[CCTextureCache sharedTextureCache] addImage:@"grossini_dance_atlas.png"];
		CCNode *parent = [CCNode node];
#endif
//		[self addChild:parent z:0 tag:kTagParentNode];
		
//		[self addNewSpriteAtPosition:ccp(100,100)];
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"catnap.plist"];
        CCSpriteBatchNode *batchNode = [CCSpriteBatchNode batchNodeWithFile:@"catnap.png"];
//        [self addChild:batchNode];
//        SmallBlockSprite *s1 = [[SmallBlockSprite alloc] initWithFile:@"00.png"];
//        s1.position = ccp(150, 50);
//        [self addChild:s1];
//        
//        SmallBlockSprite *s2 = [[SmallBlockSprite alloc] initWithFile:@"00.png"];
//        s2.position = ccp(450, 250);
//        [self addChild:s2];
        
        cpShape *shape0 = cpSegmentShapeNew( _space->staticBody, cpv(100,250), cpv(200,250), 0.0f);
        cpShapeSetElasticity( shape0, 1.0f );
		cpShapeSetFriction( shape0, 1.0f );
		cpSpaceAddStaticShape(_space, shape0 );
        
//        cpShape *shape1 = cpSegmentShapeNew( _space->staticBody, cpv(100,50), cpv(200,50), 0.0f);
//        cpShapeSetElasticity( shape1, 1.0f );
//		cpShapeSetFriction( shape1, 1.0f );
//		cpSpaceAddStaticShape(_space, shape1 );
        
//        cpShape *shape2 = cpSegmentShapeNew( _space->staticBody, cpv(400,250), cpv(500,250), 0.0f);
//        cpShapeSetElasticity( shape2, 1.0f );
//		cpShapeSetFriction( shape2, 1.0f );
//		cpSpaceAddStaticShape(_space, shape2 );
        
//        cpShape *shape2 = cpPolyShapeNew( _space->staticBody, cpv(400,250), cpv(500,250), 0.0f);
//        cpShapeSetElasticity( shape2, 1.0f );
//		cpShapeSetFriction( shape2, 1.0f );
//		cpSpaceAddStaticShape(_space, shape2 );
        
        cpShape *po = cpSegmentShapeNew(_space->staticBody, ccp(150, 10), ccp(450, 210), 0.0f);
        cpShapeSetElasticity( po, 1.0f );
		cpShapeSetFriction( po, 1.0f );
		cpSpaceAddStaticShape(_space, po );
        
        CCSprite *background = [CCSprite spriteWithFile:@"catnap_bg.png"];
        background.anchorPoint = CGPointZero;
        [self addChild:background z:-1];
        
        [self addNewEmeryAtPosition:ccp(150, 200)];
        
        [self addNewStoneAtPosition:ccp(150, 100)];
        [self addNewEmeryAtPosition:ccp(450, 300)];
        [self addNewStoneAtPosition:ccp(450, 250)];
//        [self addNewEmeryAtPosition:ccp(150, 250)];
        
        [self addNewEmeryAtPosition:ccp(150, 300)];
		[self scheduleUpdate];
	}
	
	return self;
}

- (void)registerWithTouchDispatcher {
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

-(void) initPhysics
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	_space = cpSpaceNew();
	
	cpSpaceSetGravity( _space, cpv(0, -200) );
	
	//
	// rogue shapes
	// We have to free them manually
	//
	// bottom
	_walls[0] = cpSegmentShapeNew( _space->staticBody, cpv(0,0), cpv(s.width,0), 0.0f);
	
	// top
	_walls[1] = cpSegmentShapeNew( _space->staticBody, cpv(0,s.height), cpv(s.width,s.height), 0.0f);
	
	// left
	_walls[2] = cpSegmentShapeNew( _space->staticBody, cpv(0,0), cpv(0,s.height), 0.0f);
	
	// right
	_walls[3] = cpSegmentShapeNew( _space->staticBody, cpv(s.width,0), cpv(s.width,s.height), 0.0f);
	
	for( int i=0;i<4;i++) {
		cpShapeSetElasticity( _walls[i], 1.0f );
		cpShapeSetFriction( _walls[i], 1.0f );
		cpSpaceAddStaticShape(_space, _walls[i] );
	}
	
	_debugLayer = [CCPhysicsDebugNode debugNodeForCPSpace:_space];
	_debugLayer.visible = NO;
	[self addChild:_debugLayer z:100];
}

- (void)dealloc
{
	// manually Free rogue shapes
	for( int i=0;i<4;i++) {
		cpShapeFree( _walls[i] );
	}
	
	cpSpaceFree( _space );
	
	[super dealloc];
	
}

-(void) update:(ccTime) delta
{
	// Should use a fixed size step based on the animation interval.
	int steps = 2;
	CGFloat dt = [[CCDirector sharedDirector] animationInterval]/(CGFloat)steps;
	
	for(int i=0; i<steps; i++){
		cpSpaceStep(_space, dt);
	}
}

-(void) createMenu
{
	// Default font size will be 22 points.
	[CCMenuItemFont setFontSize:22];
	
	// Reset Button
	CCMenuItemLabel *reset = [CCMenuItemFont itemWithString:@"Reset Me" block:^(id sender){
		[[CCDirector sharedDirector] replaceScene: [HelloWorldLayer scene]];
	}];
	
	// Debug Button
	CCMenuItemLabel *debug = [CCMenuItemFont itemWithString:@"Toggle Debug" block:^(id sender){
		[_debugLayer setVisible: !_debugLayer.visible];
	}];
	
	
	// to avoid a retain-cycle with the menuitem and blocks
	__block id copy_self = self;
	
	// Achievement Menu Item using blocks
	CCMenuItem *itemAchievement = [CCMenuItemFont itemWithString:@"Achievements" block:^(id sender) {
		
		
		GKAchievementViewController *achivementViewController = [[GKAchievementViewController alloc] init];
		achivementViewController.achievementDelegate = copy_self;
		
		AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
		
		[[app navController] presentModalViewController:achivementViewController animated:YES];
		
		[achivementViewController release];
	}];
	
	// Leaderboard Menu Item using blocks
	CCMenuItem *itemLeaderboard = [CCMenuItemFont itemWithString:@"Leaderboard" block:^(id sender) {
		
		
		GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
		leaderboardViewController.leaderboardDelegate = copy_self;
		
		AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
		
		[[app navController] presentModalViewController:leaderboardViewController animated:YES];
		
		[leaderboardViewController release];
	}];
    
    CCMenuItem *about = [CCMenuItemFont itemWithString:@"About" block:^(id sender) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"About" message:@"Info" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }];
	
	CCMenu *menu = [CCMenu menuWithItems:itemAchievement, itemLeaderboard, debug, reset,about, nil];
	
	[menu alignItemsVertically];
	
	CGSize size = [[CCDirector sharedDirector] winSize];
	[menu setPosition:ccp( size.width/2, size.height/2)];
	
	
	[self addChild: menu z:-1];
}

-(void) addNewSpriteAtPosition:(CGPoint)pos
{
	// physics body
	int num = 4;
	cpVect verts[] = {
		cpv(-24,-54),
		cpv(-24, 54),
		cpv( 24, 54),
		cpv( 24,-54),
	};
	
	cpBody *body = cpBodyNew(1.0f, cpMomentForPoly(1.0f, num, verts, CGPointZero));
	cpBodySetPos( body, pos );
	cpSpaceAddBody(_space, body);
    
	
	cpShape* shape = cpPolyShapeNew(body, num, verts, CGPointZero);
	cpShapeSetElasticity( shape, 0.5f );
	cpShapeSetFriction( shape, 0.5f );
	cpSpaceAddShape(_space, shape);
    
//    cpBody *b1 = cpBodyNewStatic()
	
	// sprite
	CCNode *parent = [self getChildByTag:kTagParentNode];
	int posx = CCRANDOM_0_1() * 200.0f;
	int posy = CCRANDOM_0_1() * 200.0f;
	posx = (posx % 4) * 85;
	posy = (posy % 3) * 121;
	
	CCPhysicsSprite *sprite = [CCPhysicsSprite spriteWithTexture:_spriteTexture rect:CGRectMake(posx, posy, 85, 121)];
	[parent addChild: sprite];
	[sprite setCPBody:body];
	[sprite setPosition: pos];
}

-(void) addNewStoneAtPosition:(CGPoint)pos
{
	int kTagEmeryNode = 21;
	
	
	int num = 4;
	CGPoint verts[] = {
		ccp(-25,-25),
		ccp(-25, 25),
		ccp(25, 25),
        ccp(25, -25)
	};
    CCPhysicsSprite *sprite = [CCPhysicsSprite spriteWithFile:@"00.png" rect:CGRectMake(0, 0, 50, 50)];
	cpBody *body = _space->staticBody;
    //	cpBody *b = cpBodyInitStatic(body);
	body->p = pos;
//	cpSpaceAddBody(_space, body);
	
	cpShape* shape = cpPolyShapeNew(body, num, verts, CGPointZero);
	shape->collision_type = kTagEmeryNode;
	shape->data = sprite;
	//shape->e = 0.5f; shape->u = 0.5f;
	cpSpaceAddShape(_space, shape);
	[sprite setCPBody:body];
    
    
	sprite.position = pos;
	sprite.tag = kTagEmeryNode;
	[self addChild:sprite];
}

-(void) addNewEmeryAtPosition:(CGPoint)pos
{
    int kTagEmeryNode = 20;
	
	
	int num = 4;
	CGPoint verts[] = {
		ccp(-25,-25),
		ccp(-25, 25),
		ccp(25, 25),
        ccp(25, -25)
	};
	 CCPhysicsSprite *sprite = [CCPhysicsSprite spriteWithFile:@"Icon.png" rect:CGRectMake(0, 0, 50, 50)];
	cpBody *body = cpBodyNew(1.0f, cpMomentForPoly(1.0f, num, verts, CGPointZero));
//	cpBody *b = cpBodyInitStatic(body);
	body->p = pos;
	cpSpaceAddBody(_space, body);
	
	cpShape* shape = cpPolyShapeNew(body, num, verts, CGPointZero);
	shape->collision_type = kTagEmeryNode;
	shape->data = sprite;
	//shape->e = 0.5f; shape->u = 0.5f;
	cpSpaceAddShape(_space, shape);
	[sprite setCPBody:body];
    
   
	sprite.position = pos;
	sprite.tag = kTagEmeryNode;
	[self addChild:sprite];
//	[sprite setPhysicsShape:shape space:_space];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    //cpMouseGrab(mouse, touchLocation, false);
    cpShape *shape = cpSpacePointQueryFirst(_space, touchLocation, GRABABLE_MASK_BIT, 0);
    if (shape) {
        CCPhysicsSprite *sprite = (CCPhysicsSprite *) shape->data;
        if (shape->collision_type != 21)
        {
            cpSpaceRemoveBody(_space, sprite.CPBody);
        }
        
        cpSpaceRemoveShape(_space, shape);
        [sprite removeFromParentAndCleanup:YES];
        
//        [[SimpleAudioEngine sharedEngine] playEffect:@"poof.wav"];
    }
    return YES;
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//	for( UITouch *touch in touches ) {
//		CGPoint location = [touch locationInView: [touch view]];
//		
//		location = [[CCDirector sharedDirector] convertToGL: location];
//		
////		[self addNewSpriteAtPosition: location];
//        [self addNewEmeryAtPosition:location];
//	}
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{
	static float prevX=0, prevY=0;
	
#define kFilterFactor 0.05f
	
	float accelX = (float) acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
	float accelY = (float) acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;
	
	prevX = accelX;
	prevY = accelY;
	
	cpVect v;
	if( [[CCDirector sharedDirector] interfaceOrientation] == UIInterfaceOrientationLandscapeRight )
		v = cpv( -accelY, accelX);
	else
		v = cpv( accelY, -accelX);
	
	cpSpaceSetGravity( _space, cpvmult(v, 200) );
}


#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

@end

