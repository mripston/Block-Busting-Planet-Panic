//
//  TotemWorldScene.m
//  totem
//
//  Created by Matt Ripston on 9/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TotemWorldScene.h"
#import "MenuLayer.h"

#import "BlockType.h"
#import "SettingsLayer.h"
#import	"CreditsLayer.h"
#import "AchievementsLayer.h"
#import "totemAppDelegate.h"
int block_size = 5;
//time after clicking
const int touchDelay = 15;
const int waitDelay = 120;
const int startDelay = 30;
//number of levels
const int numofLevel = 50;
const int kTagNextLevel = 200;
const int kTagTutorial = 201;
const int kTagCheckWin = 202;
const int kTagWinner = 203;
const int kTagWinnerLabel = 209;
const int kTagStopWatch = 204;
const int kTagGameOver = 205;
const int kTagStartingLevel = 206;
const int kTagAchievmentLevel = 207;
const int kTagPrevLevel = 208;
const int kTagCracks = 210;
const int kTagSaying = 211;


const float kShutterDelay = 0.5f;
void *mainLayer;

// collision types
enum {
	kTag_Idol =0,
	kTag_Block,
	kTag_ImmovableBlock,
	kTag_SpringyBlock,
	kTag_Ground
};


static void
eachShape(void *ptr, void* unused)
{
	cpShape *shape = (cpShape*) ptr;
	Sprite *sprite = shape->data;
	if( sprite ) {
		cpBody *body = shape->body;
		
		// TIP: cocos2d and chipmunk uses the same struct to store it's position
		// chipmunk uses: cpVect, and cocos2d uses CGPoint but in reality the are the same
		// since v0.7.1 you can mix them if you want.
		
		// before v0.7.1
		//		[sprite setPosition: ccp( body->p.x, body->p.y)];
		
		// since v0.7.1 (eaier)
		[sprite setPosition: body->p];
		
		[sprite setRotation: (float) CC_RADIANS_TO_DEGREES( -body->a )];
		//iff offscreen to left
		if((sprite.position.x< -sprite.contentSize.width/2)||(sprite.position.x > 320+sprite.contentSize.width/2)) {
			TotemWorld *gameLayer = (TotemWorld *) mainLayer;
	
			[gameLayer removeOffscreenBlock:shape];
				
		}
	}
}
static void
deleteEachShape(void *ptr, void* unused)
{
	cpShape *shape = (cpShape*) ptr;
	TotemWorld *gameLayer = (TotemWorld *) mainLayer;
	[gameLayer deleteShape:shape];
	
}


static int idolTouchesGround(cpShape *a, cpShape *b, cpContact *contacts, int numContacts, cpFloat normal_coef, void *data){
	TotemWorld *gameLayer = (TotemWorld *) mainLayer;
	[gameLayer idolTouchesGround];
	return 1;
}
static void  pickingFunc(cpShape *shape, void *data) {
	TotemWorld *gameLayer = (TotemWorld *) mainLayer;
	[gameLayer pickingFunc:shape];

	
}
@implementation TotemWorld

@synthesize level;
//add a sprite with a position, type and rotation.  Type is the collision information, block, springy block, iddol, etc
//adds a body, shape and sprite and links them shape -> body -> sprite  can be found by tags
-(void) addSpriteNamed: (NSString *)name x: (float)x y:(float)y type:(int) type rotation:(int)rot {
	
	UIImage *image = [UIImage imageNamed:name];  
	Sprite *sprite = [[Sprite spriteWithFile:name] retain];
	[self addChild: sprite z:2];
	//sprite position set by body
//	sprite.position = cpv(x,y);
	
	int num_vertices = 4;
	cpVect verts[] = {
		cpv([image size].width/2 * -1,[image size].height/2 * -1),
		cpv([image size].width/2 * -1, [image size].height/2),
		cpv([image size].width/2, [image size].height/2),
		cpv([image size].width/2, [image size].height/2 * -1)
	};
	
	// all objects need a body
	cpBody *body = cpBodyNew(1.0, cpMomentForPoly(1.0, num_vertices, verts, CGPointMake(0,0)));
	
	if(type == kTag_SpringyBlock) {
		cpBodySetMass(body, .5);
	} else 
	if(type == kTag_Idol) {
		cpBodySetMass(body, .9);
	} else {
		cpBodySetMass(body, 1);
	}
	
	body->p = cpv(x, y);

	cpSpaceAddBody(space, body);
	// as well as a shape to represent their collision box
	cpShape* shape = cpPolyShapeNew(body, num_vertices, verts,cpvzero);
	shape->data = sprite;
	cpSpaceAddShape(space, shape);

	shape -> collision_type = type;
	

	if(type == kTag_Ground) {
		shape->e = 0.5f; // elasticity
		shape->u = 1.0f; // friction
	}else 
	if(type == kTag_SpringyBlock) {
		shape->e = 0.9f; // elasticity
		shape->u = 0.2f; // friction
	} else 
	if(type == kTag_Idol) {
		shape->e = 0.6f; // elasticity
		shape->u = 0.8f; // friction
			
	} else {
		shape->e = 0.2f; // elasticity
		shape->u = 1.0f; // friction
	}
	//if idol, add a collision function so when the idol hits the ground, idoltouchesground runs, which loses the game and resets
	if(type == kTag_Idol) {
		cpSpaceAddCollisionPairFunc(space, kTag_Idol, kTag_Ground, &idolTouchesGround, self);	
	}

	sprite.tag = type;
	//if sprite is rotated, we have to move the center so our map files still work.
	if(rot){
		cpBodySetAngle(body, (3* M_PI)/2);
		body->p = CGPointMake(body->p.x - [image size].height, body->p.y+ [image size].width/2-[image size].height/2);
	}
	//return sprite;
}

-(void) deleteShape:(cpShape*) shape{
	Sprite *b = shape->data;
	if( b ) {
		cpBody *body = shape->body;
		
		if(b.tag == kTag_Block || b.tag == kTag_SpringyBlock || b.tag == kTag_Idol || b.tag == kTag_ImmovableBlock) {
			cpSpaceRemoveShape(space,shape);
			
			cpSpaceRemoveBody(space, body);	
			//HACK - need to find a better way to get rid of sprite
			[self removeChild:b cleanup:NO];
		}
	}
}

//initialize our layer.  set up background and chipmunk, but don't load any info

-(id) init
{
	if( (self=[super init])) {
		
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = NO;
		mainLayer = self;
		numBlocksLeft = 0;
		levelName =@"";
		waitingForNextTouch= 0;
		//see if we are winning.
		checkingForWin =winnerTimer=waitingForNextTouch=startingLevel= 0;		
		
		//pick the music choice
		musicchoice = arc4random()%2;
		//add testing label
		label1 = [Label labelWithString:@"Blocks left:" dimensions:CGSizeMake(80,20) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:16];
		[self addChild: label1 z:100];
		[label1 setPosition: ccp(50,460)];
		
	/*	label1s = [Label labelWithString:@"Blocks left:" dimensions:CGSizeMake(80,20) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:17];
		[self addChild: label1s z:99];
		[label1s setPosition: ccp(50,460)];	
		[label1s setColor:ccc3( 192,0,255)];*/
		
		//add testing label
		label2 = [Label labelWithString:@"0" dimensions:CGSizeMake(80,20) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:16];
		[self addChild: label2 z:100];
		[label2 setPosition: ccp(50,440)];
		//add testing label
/*		label2s = [Label labelWithString:@"0" dimensions:CGSizeMake(80,20) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:17];
		[self addChild: label2s z:99];
		[label2s setPosition: ccp(50,440)];
		[label2s setColor:ccc3( 192,0,255)];*/
		
		
		label3 = [Label labelWithString:@"Time:" dimensions:CGSizeMake(80,20) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:16];
		[self addChild: label3 z:100];
		[label3 setPosition: ccp(270,460)];
	/*	label3s = [Label labelWithString:@"Time:" dimensions:CGSizeMake(80,20) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:17];
		[self addChild: label3s z:99];
		[label3s setPosition: ccp(270,460)];
		[label3s setColor:ccc3( 192,0,255)];
		*/
		//add testing label
		timerLabel = [Label labelWithString:@"00:00" dimensions:CGSizeMake(80,20) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:16];
		[self addChild: timerLabel z:100];
		[timerLabel setPosition: ccp(270,440)];
	/*	timerLabels = [Label labelWithString:@"00:00" dimensions:CGSizeMake(80,20) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:17];
		[self addChild: timerLabels z:99];
		[timerLabels setPosition: ccp(270,440)];
		[timerLabels setColor:ccc3( 192,0,255)];
		*/
		nameLabel = [Label labelWithString:@"" dimensions:CGSizeMake(300,32) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:24 ];
		[self addChild: nameLabel z:100];
		[nameLabel setPosition: ccp(160,15)];
		
		[nameLabel setColor:ccWHITE];
	
		nameLabel2 = [Label labelWithString:@"" dimensions:CGSizeMake(300,32) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:26 ];
		[self addChild: nameLabel2 z:99];
		[nameLabel2 setPosition: ccp(160,15)];
		
		[nameLabel2 setColor:ccc3( 192,0,255)];
		
		cpInitChipmunk();
		
		
		space = cpSpaceNew();
		cpSpaceResizeStaticHash(space, 200.0f, 1000);
		cpSpaceResizeActiveHash(space, 200, 1000);
		
		[self addBackground];
		[self addMenu];
		[self createBoundingBox];	
		
		//space->gravity = cpv(0, -300);
		clouddirection = arc4random()%2; //0 = left 1  = right
		space->elasticIterations = space->iterations;
		//link in appdelegate so we can use the database functions, like levels
		appDelegate = (totemAppDelegate *)[[UIApplication sharedApplication] delegate];
		
		//start tint cycle
		//start "day night cycle"
	
			
	}
	
	return self;
}

//updated once per tick to update the time taken to complete the level
-(void)changeTime: (ccTime) dt{
	//update timer lable, but only when not changing levels, resetting, or displaying win aniamtion
	if(startingLevel == 0 && !resetting && checkingForWin == 0 && winnerTimer == 0) {
		timerInt++;
	//	int hours = timerInt / 3600;
		int minutes = (int)(timerInt / 60) % 60;
		int seconds = (int)timerInt % 60;
		
		[timerLabel setString:[NSString stringWithFormat:@"%02i:%02i",minutes,seconds]];
		//[timerLabels setString:[NSString stringWithFormat:@"%02i:%02i",minutes,seconds]];
	}
	//check to see if we got any achievemnets
	if(!resetting) {
		g_totalTimePlayed++;
		[self checkAchievementsTime];
	}
	
}

//if the idol touches the ground.  needs to be worked on.
- (void)idolTouchesGround
{
	
	cpSpaceRemoveCollisionPairFunc(space, kTag_Idol, kTag_Ground);	
	Sprite *idol = (Sprite *)[self getChildByTag:kTag_Idol];
	
	Sprite* cracks = [Sprite spriteWithFile:@"cracks.png"];
	cracks.tag = kTagCracks;
	[cracks setPosition:cpv(idol.contentSize.width/2,idol.contentSize.height/2)];
//	[cracks setRotation:idol.rotation];
	[idol addChild:cracks z:3];
	
	[appDelegate playSound:@"fall.caf"];
	[self removeChildByTag:kTagCheckWin cleanup:NO];
	[self removeChildByTag:kTagStopWatch cleanup:NO];
	[self removeChildByTag:kTagSaying cleanup:NO];

	resetting = TRUE;
	//AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
	gameOverBG = [Sprite spriteWithFile:@"gameover.png"];
	gameOverBG.tag = kTagGameOver;
	[gameOverBG setPosition:cpv(160,240)];
	[self addChild:gameOverBG z:10];

	g_timesLost++;
	//show achievement here
	[self checkAchievementsWonLost];
	
//	[self performSelector:@selector(fadeOut:) withObject:nil afterDelay:1.0];
	[self performSelector:@selector(resetGame:) withObject:nil afterDelay:2.0];

}
//start timer, then go to next level
-(void)startLevel:(id)object
{
	[self removeChildByTag:kTagStartingLevel cleanup:NO];
	startingLevel=0;
	timerInt = 0;
	[timerLabel setString:@"00:00"];
	space->gravity = cpv(0, -300);
	

}
//delete sprites, fade out, load next level
-(void)nextLevel:(id)object {
	//slide shutters open
	[self slideShuttersOpen];
	//renalbed logo and menu
	item1.isEnabled=YES;
	[logo setVisible:YES];
	//get rid of next button, and sprite
	
	[self removeChildByTag:kTagTutorial cleanup:NO];
	[self removeChildByTag:kTagNextLevel cleanup:NO];
	[self removeChildByTag:kTagPrevLevel cleanup:NO];
	[self removeChildByTag:kTagWinner cleanup:NO];
	[self removeChildByTag:kTagWinnerLabel cleanup:NO];
	[self removeChildByTag:kTagStopWatch cleanup:NO];
	[self removeChildByTag:kTagSaying cleanup:NO];
	
	
	cpSpaceHashEach(space->activeShapes, &deleteEachShape, nil);
	cpSpaceHashEach(space->staticShapes, &deleteEachShape, nil);
	
	g_CurrentLevel++;

	
	//update level to next levle, update locked
	level = (Level *)[appDelegate.levels objectAtIndex:g_CurrentLevel-1];
	
	//[self.level updateLocked:FALSE];
	
	
	[self extLoadLevel:[NSString stringWithFormat:@"%02i",g_CurrentLevel ]];
	
	
	[nameLabel setString:[NSString stringWithFormat:@"%i: %@",level.lvl_num,level.lvl_name]];
	[nameLabel2 setString:[NSString stringWithFormat:@"%i: %@",level.lvl_num,level.lvl_name]];
	
	checkingForWin =winnerTimer=waitingForNextTouch= 0;	
	
	resetting = FALSE;
	
}
-(void)shuttersClosed {
	id actionToLeft = [MoveTo actionWithDuration: 0 position:ccp(82.5, 240)];
	id actionToRight = [MoveTo actionWithDuration: 0 position:ccp(320-87.5, 240)];
	
	
	[leftShutter runAction: actionToLeft];
	[rightShutter runAction: actionToRight];
}
-(void)slideShuttersOpen {
	
	id actionToLeft = [MoveTo actionWithDuration: kShutterDelay position:ccp(-82.5, 240)];
	id actionToRight = [MoveTo actionWithDuration: kShutterDelay position:ccp(320+87.5, 240)];
	
	
	[leftShutter runAction: actionToLeft];
	[rightShutter runAction: actionToRight];
}
-(void)slideShuttersClosed {
	
	id actionToLeft = [MoveTo actionWithDuration: kShutterDelay position:ccp(82.5, 240)];
	id actionToRight = [MoveTo actionWithDuration: kShutterDelay position:ccp(320-87.5, 240)];
	
	
	[leftShutter runAction: actionToLeft];
	[rightShutter runAction: actionToRight];
}
//start timer, then go to next level
-(void)wonLevel:(id)object
{
	if(self.level.fastest_time == -1 || timerInt < self.level.fastest_time){
		[self.level updateTime:timerInt];
	}
	
	[appDelegate updateLockedLevelSets];
	NSString *text = @"";
	int levelBlock =(level.lvl_num-1)/10;
	if(g_lockedLevelSets[levelBlock] < 8) {
		text = [NSString stringWithFormat:@"Completed: %i/10\nFinish %i more to unlock next set",g_lockedLevelSets[levelBlock],8-g_lockedLevelSets[levelBlock]];
	}
	else {
		text = @"Next set unlocked";
	}
	//on last set of level
	if(levelBlock == 4) {
		text = [NSString stringWithFormat:@"Completed: %i/10",g_lockedLevelSets[levelBlock]];

	}
	Label *completeLabel = [Label labelWithString:text dimensions:CGSizeMake(300,50) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:24 ];
	[self addChild: completeLabel z:204];
	[completeLabel setPosition: ccp(160,30)];
	completeLabel.tag = kTagWinnerLabel;
	
	[completeLabel setColor:ccWHITE];
	int i = 0;
	int j = 0;
	//if unlocked 8 or more levels, unlock next set of level
	for(i=0;i<4;i++){
		if(g_lockedLevelSets[i]>=8) {
			for(j=0;j<10;j++) {
				//update level to next levle, update locked
				level = (Level *)[appDelegate.levels objectAtIndex:(i+1)*10+j];
				[level updateLocked:FALSE];
			}
			
		}
	}
	g_highestLevel=0;
	for(i=0;i<50;i++){
		//update level to next levle, update locked
		level = (Level *)[appDelegate.levels objectAtIndex:i];
	
		if(level.fastest_time > -1) {
			g_highestLevel++;
		}
			
		
	}
	
	//beat all level
	if(g_highestLevel == numofLevel && g_achievements[5] == 0){ 
		[FlurryAPI logEvent:@"Completed Game"];
		g_achievements[5] =1;
		//add a label saying unlocked
		achievementLabel = [Label labelWithString:@"Achievement Unlocked!:\nComplete Game" dimensions:CGSizeMake(240,80) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:24];
		achievementLabel.tag = kTagAchievmentLevel;
		[self addChild: achievementLabel z:300];
		[achievementLabel setPosition: ccp(160,360)];
		[self performSelector:@selector(removeAchievementLabel:) withObject:nil afterDelay:4.0];
	}
/*	if(g_CurrentLevel+1> g_highestLevel) {
		g_highestLevel=g_CurrentLevel+1;
	};
	*/
	//took 10 min to beat level
	if(timerInt > 600 && g_achievements[6] == 0){ 
			[FlurryAPI logEvent:@"Take 10 min to beat a level"];
		g_achievements[6] =1;
		//add a label saying unlocked
		achievementLabel = [Label labelWithString:@"Achievement Unlocked!:\nTake 10min to beat a level" dimensions:CGSizeMake(240,80) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:24];
		achievementLabel.tag = kTagAchievmentLevel;
		[self addChild: achievementLabel z:210];
		[achievementLabel setPosition: ccp(160,360)];
		[self performSelector:@selector(removeAchievementLabel:) withObject:nil afterDelay:4.0];
		
	}
	g_timesWon++;
	//test here to show achievemenet
	[self checkAchievementsWonLost];
	[appDelegate playSound:@"win2.caf"];
	
	[self removeChildByTag:kTagCheckWin cleanup:NO];
	[self removeChildByTag:kTagSaying cleanup:NO];
	
	winnerTimer = 1;
	item1.isEnabled=FALSE;
	[logo setVisible:NO];
	// menu for next level
	MenuItem *restartitem = [MenuItemImage itemFromNormalImage:@"back.png" selectedImage:@"back_selected.png" target:self selector:@selector(resetGame:)];
	
	Menu *restartmenu = [Menu menuWithItems: restartitem, nil];
	//[menu alignItemsVertically];
	restartmenu.position = CGPointMake(35,50);
	
	restartmenu.tag = kTagPrevLevel;
	[self addChild: restartmenu z:204];
	//test to see if we're on the last level possible
	if(g_CurrentLevel == numofLevel) {
		winnerSpr = [Sprite spriteWithFile:@"wingame.png"];
		winnerSpr.tag = kTagWinner;
		[winnerSpr setPosition:cpv(160,240)];
		[self addChild:winnerSpr z:203];
		
		
	} else {
		winnerSpr = [Sprite spriteWithFile:@"winner.png"];
		winnerSpr.tag = kTagWinner;
		[winnerSpr setPosition:cpv(160,240)];
		[self addChild:winnerSpr z:203];
		
		Level *nextlevel = (Level *)[appDelegate.levels objectAtIndex:g_CurrentLevel];
		if(!nextlevel.locked){
		// menu for next level
		MenuItem *item = [MenuItemImage itemFromNormalImage:@"next.png" selectedImage:@"next_selected.png" target:self selector:@selector(nextLevel:)];
	
		Menu *menu = [Menu menuWithItems: item, nil];
		//[menu alignItemsVertically];
		menu.position = CGPointMake(285,50);
	
		menu.tag = kTagNextLevel;
		[self addChild: menu z:204];
		}
	}
	

//	[self performSelector:@selector(fadeOut:) withObject:nil afterDelay:1.0];
//	[self performSelector:@selector(nextLevel:) withObject:nil afterDelay:2.0];
	
}
//add a layer and fade in/out
-(void)fadeOut:(id)object {
	ColorLayer* layer2 = [ColorLayer layerWithColor: ccc4(0, 0, 0, 0)
											  width: 320 
											 height: 480];
	layer2.position = ccp(160, 240);
	layer2.relativeAnchorPoint = YES;
	[self addChild: layer2 z:100];
	
	id actionFade = [FadeIn actionWithDuration:1.0f];
	id actionFadeBack = [actionFade reverse];
	id seq2 = [Sequence actions:actionFade, actionFadeBack, nil];		
	[layer2 runAction:seq2];	
}
- (void)resetGame:(id)object
{
	
	[self slideShuttersOpen];
	item1.isEnabled=YES;
	[logo setVisible:YES];
	[self removeChildByTag:kTagGameOver cleanup:NO];
	
	[self removeChildByTag:kTagNextLevel cleanup:NO];
	[self removeChildByTag:kTagPrevLevel cleanup:NO];
	[self removeChildByTag:kTagWinner cleanup:NO];
	[self removeChildByTag:kTagWinnerLabel cleanup:NO];
	[self removeChildByTag:kTagStopWatch cleanup:NO];
	[self removeChildByTag:kTagSaying cleanup:NO];
	
	cpSpaceHashEach(space->activeShapes, &deleteEachShape, nil);
	cpSpaceHashEach(space->staticShapes, &deleteEachShape, nil);
	
	timerInt = 0;
	[timerLabel setString:@"00:00"];
	//[timerLabels setString:@"00:00"];
	
	[self extLoadLevel:[NSString stringWithFormat:@"%02i",g_CurrentLevel ]];
	checkingForWin = 0;
	waitingForNextTouch = 0;
	winnerTimer = 0;
	resetting = FALSE;
}

//dealy for a second while level loads.  prevents everything jumping around
-(void)extLoadLevel:(NSString *)lev {
	space->gravity = cpv(0, 0);
	//set cloud direction
	clouddirection = arc4random()%3; //0 = left 1  = right 2 = no clouds
	int i  = arc4random()%50;
	
	
	//NSLog(@"ufo? %d", i); 	
	if (i == 17) {
		ufoOn = TRUE;
	}
	else
		ufoOn = FALSE;
	[self setupClouds];
	[self loadLevel:[NSString stringWithFormat:@"lvl%@.txt", lev]];
	startingLevel = 1;
	
	startingLevelSpr = [Sprite spriteWithFile:@"startinglevel.png"];
	startingLevelSpr.tag = kTagStartingLevel;
	[startingLevelSpr setPosition:cpv(160,240)];
	[self addChild:startingLevelSpr z:10];
	
	tutorialOn=FALSE;
	if(g_CurrentLevel == 1) {
		[self removeChildByTag:kTagTutorial cleanup:NO];
		tutorialOn =TRUE;
		
		tutorial0 = [[Sprite spriteWithFile:@"tutorial0.png"] retain];
		[tutorial0 setPosition:cpv(192,354)];
		tutorial0.tag = kTagTutorial;
		tutorial0.opacity = 200;
		[self addChild: tutorial0 z:2];
		
		tutorial = [[Sprite spriteWithFile:@"tutorial1.png"] retain];
		[tutorial setPosition:cpv(240,200)];
		tutorial.tag = kTagTutorial;
		tutorial.opacity = 200;
		[self addChild: tutorial z:2];
		
		tutorial2 = [[Sprite spriteWithFile:@"tutorial2.png"] retain];
		[tutorial2 setPosition:cpv(220,80)];
		tutorial2.tag = kTagTutorial;
		tutorial2.opacity = 200;
		[self addChild: tutorial2 z:2];
	}else if(g_CurrentLevel == 2) {
		[self removeChildByTag:kTagTutorial cleanup:NO];
		[self removeChildByTag:kTagTutorial cleanup:NO];
		
		[self removeChildByTag:kTagTutorial cleanup:NO];
		tutorialOn =TRUE;
		tutorial4 = [[Sprite spriteWithFile:@"tutorial4.png"] retain];
		[tutorial4 setPosition:cpv(100,350)];
		tutorial4.tag = kTagTutorial;
		tutorial4.opacity = 200;
		[self addChild: tutorial4 z:2];
		
	}else if(g_CurrentLevel == 3) {
		
		[self removeChildByTag:kTagTutorial cleanup:NO];
		tutorialOn =TRUE;
		
		tutorial5 = [[Sprite spriteWithFile:@"tutorial5.png"] retain];
		[tutorial5 setPosition:cpv(240,350)];
		tutorial5.tag = kTagTutorial;
		tutorial5.opacity = 200;
		[self addChild: tutorial5 z:2];
	}else if(g_CurrentLevel == 5) {
		
		[self removeChildByTag:kTagTutorial cleanup:NO];
			tutorialOn =TRUE;
			tutorial3 = [[Sprite spriteWithFile:@"tutorial3.png"] retain];
			[tutorial3 setPosition:cpv(240,200)];
			tutorial3.tag = kTagTutorial;
			tutorial3.opacity = 200;
			[self addChild: tutorial3 z:2];
			
	}else{	
		[self removeChildByTag:kTagTutorial cleanup:NO];
	}
	
	[timerLabel setString:@"00:00"];
	//[timerLabels setString:@"00:00"];
	
	//[self startLevel];	
	
	[self performSelector:@selector(startLevel:) withObject:nil afterDelay:1];
}
//add sprites for grond and background
- (void)addBackground
{
	bg = [[Sprite spriteWithFile:@"sky.png"] retain];
	[bg setPosition:cpv(160,240)];
	[self addChild: bg z:0];
	
	Sprite *ground = [[Sprite spriteWithFile:@"ground.png"] retain];
	[ground setPosition:cpv(160,25)];
	[self addChild: ground z:0];
	
	logo = [[Sprite spriteWithFile:@"SmallLogo2.png"] retain];
	[logo setPosition:cpv(160,440)];
	logo.opacity = 150;
	[self addChild: logo z:200];
	
	leftShutter = [[Sprite spriteWithFile:@"leftshutter.png"] retain];
	[leftShutter setPosition:CGPointMake(81.5,240)];
	[self addChild: leftShutter z:198];
	
	rightShutter = [[Sprite spriteWithFile:@"rightshutter.png"] retain];
	[rightShutter setPosition:CGPointMake(232.5,240)];
	[self addChild: rightShutter z:199];
	
	int i = 0;
	for(i=0;i<3;i++){
		
		cloud[i] = [[Sprite spriteWithFile:[NSString stringWithFormat:@"cloud%i.png",i+1 ]] retain];
		[cloud[i] setPosition:CGPointMake(232.5,240)];
		[self addChild: cloud[i] z:i];	
	}
	
	ufo = [[Sprite spriteWithFile:@"ufo.png"] retain];
	[ufo setPosition:CGPointMake(-20,240)];
	[self addChild: ufo z:1];
	//	[self slideShuttersOpen];
	
	id actionTint = [TintBy actionWithDuration:30 red:-127 green:-255 blue:-127];
	
	id actionLoop = [RepeatForever actionWithAction:
					 [Sequence actions: [[actionTint copy] autorelease], [actionTint reverse], nil]
					 ];
	[bg runAction:actionLoop];
}


-(void)setupClouds{
	int i = 0;
	
	int ufoy = 400 - (arc4random()%140);
	[ufo setPosition:CGPointMake(-60,ufoy)];
	
	for(i=0;i<3;i++){
		cloud[i].opacity =arc4random()%100+ 100;
		cloudspeed[i]= arc4random()%3 +.5; //give speed 1-3;
		int startx = 0;
		if(clouddirection == 0){
			startx = - 100 - arc4random()%60 ;
		}
		else {
			startx = 420 + arc4random()%60 ;
		}
		int starty = 460 - (arc4random()%200);
		[cloud[i] setPosition:CGPointMake(startx,starty)];
		
	}
}
-(void)updateClouds{
	int i = 0;
	//is 2, don't have clouds
	if(clouddirection < 2){
	for(i=0;i<3;i++){
		if(clouddirection == 0){
			[cloud[i] setPosition:CGPointMake(cloud[i].position.x + cloudspeed[i],cloud[i].position.y)];
			if(cloud[i].position.x > 480) {
				cloudspeed[i]= arc4random()%3 +1; //give speed 1-3;
				int startx = - 100 - arc4random()%60 ;
				int starty = 460 - (arc4random()%300);
				[cloud[i] setPosition:CGPointMake(startx,starty)];
			}
		}
		else {
			
			[cloud[i] setPosition:CGPointMake(cloud[i].position.x - cloudspeed[i],cloud[i].position.y)];
			if(cloud[i].position.x < -160) {
				cloudspeed[i]= arc4random()%3 +1; //give speed 1-3;
				int startx = 420 + arc4random()%60 ;
				int starty = 460 - (arc4random()%300);
				[cloud[i] setPosition:CGPointMake(startx,starty)];
			}
		}
	}
	}
	if(ufoOn) {
		if(ufo.position.x < 480) {
			[ufo setPosition:CGPointMake(ufo.position.x +2,ufo.position.y)];
		}
		if((ufo.position.x > 20) && g_achievements[7] == 0){ 	
			[FlurryAPI logEvent:@"Saw Alien Life"];
			g_achievements[7] =1;
			//add a label saying unlocked
			achievementLabel = [Label labelWithString:@"Achievement Unlocked!:\nSaw Alien Life" dimensions:CGSizeMake(240,80) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:24];
			achievementLabel.tag = kTagAchievmentLevel;
			[self addChild: achievementLabel z:100];
			[achievementLabel setPosition: ccp(160,360)];
			[self performSelector:@selector(removeAchievementLabel:) withObject:nil afterDelay:4.0];
		}
	}
}
//load our menu to change options and load new level
-(void) menuCallback: (id) sender
{
	[appDelegate playSound:@"select.caf"];
	
	[self slideShuttersClosed];
	
	[self performSelector:@selector(openMenu:) withObject:nil afterDelay:kShutterDelay];
}
-(void) openMenu:(id) sender
{
	
	[(MultiplexLayer*)parent switchTo:1];

}
-(void)addMenu{
	// Image Item
	item1 = [MenuItemImage itemFromNormalImage:@"menu1.png" selectedImage:@"menu1_selected.png" target:self selector:@selector(menuCallback:)];
	
	Menu *menu = [Menu menuWithItems: item1, nil];
	
//[menu alignItemsVertically];
	menu.position =CGPointMake(280,24);
	
	[self addChild: menu z:190];
}

-(bool)loadLevel:(NSString*) levelFilename  {
	NSString *fullpath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:levelFilename];
	NSData* filedata = [NSData dataWithContentsOfFile:fullpath];
		
	NSString* dush = [[NSString alloc] initWithData:filedata encoding:NSASCIIStringEncoding];
	
	//expcted format
	//level # 1
	//Level name
	// # of blocks to remove
	//# of blocks, ie 6
	//type - brown 1, black 2, green 3
	//x/y - tile coord, multiples of 30
	//sizex, sizey - dimensions of block
	//rotated90, 0,1
	//tile, x, y, sizex, sizey,rotated90
	//ie 1,3,0,30,30,0 (square brown block at (3,0)
	//last line, idol,x,y  (note x in screen coordinates
	//0,160,6
	
	
	//expected format:
	//widthxheight, ie 15x25.  whitespace is ok, 15 x 25.
	//[height] rows of [width] comma-separated tile indexes.
	//a blank row, for sanity's sake.
	//[height] rows of [width] comma-separated physics flags.
	
	NSArray* rows = [dush componentsSeparatedByString:@"\n"];
	int rowindex = 0;
	//NSArray* wh = [[rows objectAtIndex:rowindex] componentsSeparatedByString:@"x"];
	g_CurrentLevel = [[rows objectAtIndex:rowindex] intValue];
	rowindex++;
//	levelName= [[NSString stringWithString:[rows objectAtIndex:rowindex] ]retain];
	//levelName = (NSString*)[rows objectAtIndex:rowindex] ;
	rowindex++;
	numBlocksLeft= [[rows objectAtIndex:rowindex] intValue];
	rowindex++;
	int numblocks = [[rows objectAtIndex:rowindex] intValue];
	rowindex++;
	
//	NSLog(@"loadlevel %d blocks: %d", g_CurrentLevel, numblocks); 
	
	for(int y=0;y<numblocks;y++){
		NSArray* row = [[rows objectAtIndex:rowindex] componentsSeparatedByString:@","];
		int type = [[row objectAtIndex:0] intValue]; //get type
		int x =  [[row objectAtIndex:1] intValue]; //get x
		int y =  [[row objectAtIndex:2] intValue]; //get y
		int sizex =  [[row objectAtIndex:3] intValue]; //get sizex
		int sizey =  [[row objectAtIndex:4] intValue]; //get sizey
		int rot =  [[row objectAtIndex:5] intValue]; //get rotation
		//create block here:
		NSString *blockType = @"";
		if(type == 1) {blockType = @"rusted";}
		if(type == 2) {blockType = @"unbreakable";}
		if(type == 3) {blockType = @"goo";}
				
		[self addSpriteNamed:[NSString stringWithFormat:@"%@_%dx%d.png",blockType,sizex,sizey] x:(x*block_size) + sizex/2 y:50 + (y*block_size) + sizey/2 type:type rotation:rot];
			
	//	NSLog(@"block#:%d type:%d x:%d y:%d sizex:%d sizey:%d", y,type,x,y,sizex,sizey); 
		rowindex++;
	}
	//got all blocks, now get idol
	NSArray* row = [[rows objectAtIndex:rowindex] componentsSeparatedByString:@","];
	int idoltype = [[row objectAtIndex:0] intValue]; //get idoltype
	int idolx =[[row objectAtIndex:1] intValue]; //get idol x
	int idoly = [[row objectAtIndex:2] intValue]; //get idol y
	//int idolsizex = 58;//[[row objectAtIndex:3] intValue]; //get idol sizex
	int idolsizey = 65;//[[row objectAtIndex:4] intValue]; //get idol sizey

	[self addSpriteNamed:@"idol.png" x:idolx y:50 + (idoly*block_size) + idolsizey/2 type:idoltype rotation:FALSE]; 
	
//	NSLog(@"idol#:%d x:%d y:%d sizex:%d sizey:%d", idoltype,idolx,idoly,idolsizex,idolsizey); 
	[dush release];
	
	return TRUE;
}

- (void)createBoundingBox
{
	CGSize wins = [[Director sharedDirector] winSize];
	
	staticBody = cpBodyNew(INFINITY, INFINITY);	
	//bounding box for entire level
	cpShape *shape;
	
	// bottom
	shape = cpSegmentShapeNew(staticBody, ccp(-160,50), ccp(480,50), 0.0f);
	shape->e = 1.0f; shape->u = 1.0f;
	shape -> collision_type = kTag_Ground;
	cpSpaceAddStaticShape(space, shape);
	
	// top
	shape = cpSegmentShapeNew(staticBody, ccp(-160,wins.height), ccp(480,wins.height), 0.0f);
	shape->e = 1.0f; shape->u = 1.0f;
	cpSpaceAddStaticShape(space, shape);
	
	// left
	shape = cpSegmentShapeNew(staticBody, ccp(-160,50), ccp(-160,wins.height), 0.0f);
	shape->e = 1.0f; shape->u = 1.0f;
	cpSpaceAddStaticShape(space, shape);
	
	// right
	shape = cpSegmentShapeNew(staticBody, ccp(480,50), ccp(480,wins.height), 0.0f);
	shape->e = 1.0f; shape->u = 1.0f;
	cpSpaceAddStaticShape(space, shape);
	
}

-(void) onExit {
	[super onExit];
	[appDelegate stopMusic];
	[appDelegate purgeSounds];
}

-(void) onEnter
{
	[super onEnter];
	
	//need to restart scheduler
	[self schedule: @selector(step:)interval:1.0/60];
	
	[self schedule: @selector(changeTime:) interval:1.0];
	
	//load level
	level = (Level *)[appDelegate.levels objectAtIndex:g_CurrentLevel-1];
	
	//set name of level
	[nameLabel setString:[NSString stringWithFormat:@"%i: %@",level.lvl_num,level.lvl_name]];
	[nameLabel2 setString:[NSString stringWithFormat:@"%i: %@",level.lvl_num,level.lvl_name]];
		
	[self slideShuttersOpen];
	
	//play music
	if(musicchoice == 0) {
		[appDelegate playMusic:@"mission.mp3"];
	}else {
		[appDelegate playMusic:@"future.mp3"];
		
	}

}
-(void)checkAchievementsTime {
	
	if(g_totalTimePlayed > 3600 && g_achievements[0] == 0){ 
			[FlurryAPI logEvent:@"Play 1 hour"];
			g_achievements[0] =1;
			//add a label saying unlocked
			achievementLabel = [Label labelWithString:@"Achievement Unlocked!:\nPlay for 1 hour" dimensions:CGSizeMake(240,80) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:24];
			achievementLabel.tag = kTagAchievmentLevel;
			[self addChild: achievementLabel z:100];
			[achievementLabel setPosition: ccp(160,360)];
			[self performSelector:@selector(removeAchievementLabel:) withObject:nil afterDelay:4.0];
	}
	//played 2 hours
	if(g_totalTimePlayed > 7200 && g_achievements[1] == 0){ 
			[FlurryAPI logEvent:@"Play 2 hours"];
			g_achievements[1] =1;
			//add a label saying unlocked
			achievementLabel = [Label labelWithString:@"Achievement Unlocked!:\nPlay for 2 hours" dimensions:CGSizeMake(240,80) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:24];
			achievementLabel.tag = kTagAchievmentLevel;
			[self addChild: achievementLabel z:100];
			[achievementLabel setPosition: ccp(160,360)];
			[self performSelector:@selector(removeAchievementLabel:) withObject:nil afterDelay:4.0];
			
	}

}

-(void)checkAchievementsWonLost {
	//win 50 times
	if(g_timesWon >= 150 && g_achievements[2] == 0){ 
			[FlurryAPI logEvent:@"Win 150 times"];
			g_achievements[2] =1;
			//add a label saying unlocked
			achievementLabel = [Label labelWithString:@"Achievement Unlocked!:\nWin 150 times" dimensions:CGSizeMake(240,80) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:24];
			achievementLabel.tag = kTagAchievmentLevel;
			[self addChild: achievementLabel z:100];
			[achievementLabel setPosition: ccp(160,360)];
			[self performSelector:@selector(removeAchievementLabel:) withObject:nil afterDelay:4.0];
				
	}
	//lose 50 times
	if(g_timesLost >= 150 && g_achievements[3] == 0){ 
			[FlurryAPI logEvent:@"Lose 150 times"];
			g_achievements[3] =1;
			//add a label saying unlocked
			achievementLabel = [Label labelWithString:@"Achievement Unlocked!:\nLose 150 times" dimensions:CGSizeMake(240,80) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:24];
			achievementLabel.tag = kTagAchievmentLevel;
			[self addChild: achievementLabel z:100];
			[achievementLabel setPosition: ccp(160,360)];
			[self performSelector:@selector(removeAchievementLabel:) withObject:nil afterDelay:4.0];
				
	}
}
- (void)removeAchievementLabel:(id)object
{
	[achievementLabel setString:@""];
}
-(void) step: (ccTime) delta
{
	int steps = 2;
	CGFloat dt = delta/(CGFloat)steps;
	[self updateClouds];
	if(!resetting) {
	
	
		if(waitingForNextTouch > 0) {
			waitingForNextTouch--;
			if(waitingForNextTouch == 0) {
				[self removeChild:stopWatch cleanup:NO];	
			}
		}
		if(checkingForWin > 0) {
			checkingForWin--;
			
			Sprite *idol = (Sprite *)[self getChildByTag:kTag_Idol];
			Sprite *say = (Sprite *)[self getChildByTag:kTagSaying];
			//make it follow idol
			if(say) {
				[say setPosition:cpv(idol.position.x+idol.contentSize.width/2-20,idol.position.y+idol.contentSize.height/2+20)];
			}
			
			if(checkingForWin == ( waitDelay-20)) {
				checkingWinSpr = [Sprite spriteWithFile:@"checkingwin.png"];
				checkingWinSpr.tag = kTagCheckWin;
				[checkingWinSpr setPosition:cpv(160,240)];
				[self addChild:checkingWinSpr z:10];
				
				int sayingNum = arc4random()%21;
				
				//add rover saying when winning
				saying = [Sprite spriteWithFile:[NSString stringWithFormat:@"saying%i.png",sayingNum]];
				saying.tag = kTagSaying;
				saying.opacity =200;
				[saying setPosition:cpv(idol.position.x+idol.contentSize.width/2-20,idol.position.y+idol.contentSize.height/2+20)];
				//[saying setPosition:cpv(idol.contentSize.width/2+10,idol.contentSize.height/2+60)];
				[self addChild:saying z:11];	
			}
			if(checkingForWin == 0) {
				
				item1.isEnabled=FALSE;
				[self removeChildByTag:kTagCheckWin cleanup:NO];
				[self removeChildByTag:kTagSaying cleanup:NO];
				[self slideShuttersClosed];				
				[self performSelector:@selector(wonLevel:) withObject:nil afterDelay:kShutterDelay+.2];
			}
		}

		

	//	[label2 setString:[NSString stringWithFormat:@"time: %i", waitingForNextTouch]];
		[label2 setString:[NSString stringWithFormat:@"%i", numBlocksLeft]];
	}
	for(int i=0; i<steps; i++){
		cpSpaceStep(space, dt);
	}
	cpSpaceHashEach(space->activeShapes, &eachShape, nil);
	cpSpaceHashEach(space->staticShapes, &eachShape, nil);
	
}
-(void) removeOffscreenBlock:(cpShape *)shape {
	//cpSpace *space= (cpSpace*)data;
	//	NSLog(@"shape e %d u: %d", shape->e, shape->u); 
	Sprite *b = shape->data;
	cpBody *body = shape->body;
	
	if(b.tag == kTag_Block || b.tag == kTag_SpringyBlock) {
		[appDelegate playSound:@"destroyblock.caf"];
		cpSpaceRemoveShape(space,shape);
		
		cpSpaceRemoveBody(space, body);	
		[self removeChild:b cleanup:NO];
		//remove 1 block from total
		numBlocksLeft--;
		if(numBlocksLeft == 0){
			checkingForWin= waitDelay;
			
		}
	}
	//just remove immovable blocks
	if(b.tag == kTag_ImmovableBlock) {
		cpSpaceRemoveShape(space,shape);
		
		cpSpaceRemoveBody(space, body);	
		[self removeChild:b cleanup:NO];
	}
}


-(void)  pickingFunc:(cpShape *)shape
{
	//cpSpace *space= (cpSpace*)data;
//	NSLog(@"shape e %d u: %d", shape->e, shape->u); 
	Sprite *b = shape->data;
	cpBody *body = shape->body;
	
	if(b.tag == kTag_Block || b.tag == kTag_SpringyBlock) {
		[appDelegate playSound:@"destroyblock.caf"];
		cpSpaceRemoveShape(space,shape);
		
		cpSpaceRemoveBody(space, body);	
		//HACK - need to find a better way to get rid of sprite
		//move behind other sprites
		CGFloat delay = .5;
	//	[b setZOrder:1];
		int dir = arc4random()%2;
		if(dir == 0) {		dir = -1;}
		[self reorderChild:b z:1];
		id actionTo = [RotateTo actionWithDuration: delay angle:dir*45];
		id actionFade = [FadeOut actionWithDuration:delay];
		id actionScale = [ScaleBy actionWithDuration:delay scale:0.5f];
		[b runAction: actionTo];
		[b runAction: actionFade];
		[b runAction:actionScale];

		
	//	[self removeChild:b cleanup:NO];
		//have delay so we can't keep touching
		waitingForNextTouch = touchDelay;
		stopWatch = [Sprite spriteWithFile:@"stopwatch.png"];
		stopWatch.tag = kTagStopWatch;
		[stopWatch setPosition:cpv(160,380)];
		[self addChild:stopWatch z:10];
		//remove 1 block from total
		numBlocksLeft--;
		if(numBlocksLeft == 0){
			checkingForWin= waitDelay;

		}
	}

	
}


- (BOOL)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	for( UITouch *touch in touches ) {
	//	[label1 setString:@"touched!"];
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[Director sharedDirector] convertCoordinate: location];
		//make sure we're not waiting for next touch, or checking to see if win conditions hit
		if(waitingForNextTouch == 0 && checkingForWin == 0 && startingLevel ==0 && winnerTimer==0) {
			//if tutorial on, get rid of sprites
			if(tutorialOn) {
				id action0 = [FadeOut actionWithDuration:1.0f];
				id action1 = [FadeOut actionWithDuration:1.0f];
				id action2 = [FadeOut actionWithDuration:1.0f];
				id action3 = [FadeOut actionWithDuration:1.0f];
				id action4 = [FadeOut actionWithDuration:1.0f];
				id action5 = [FadeOut actionWithDuration:1.0f];
				[tutorial0 runAction: action0];
				[tutorial runAction: action1];
				[tutorial2 runAction: action2];
				[tutorial3 runAction: action3];
				[tutorial4 runAction: action4];
				[tutorial5 runAction: action5];
				tutorialOn=FALSE;
			}
		
			//see if any shapes are in this touch
			cpSpaceShapePointQuery(space, location, pickingFunc, space);
		}
			
	}
	return kEventHandled;
}
- (void) dealloc
{
	[super dealloc];
}

@end
