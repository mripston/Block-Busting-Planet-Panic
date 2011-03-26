//
//  TotemWorldScene.h
//  totem
//
//  Created by Matt Ripston on 9/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "chipmunk.h"
#import "Level.h"
#import "totemAppDelegate.h"

@class BlockType;
@interface TotemWorld : Layer {
	cpSpace *space;
	cpBody *staticBody;
	//BlockType *blocks[32];
	int numBlocksLeft;
	NSString *levelName;
	Sprite *gameOverBG;
	Sprite *stopWatch;
	Sprite *checkingWinSpr;
	Sprite *startingLevelSpr;
	Sprite *winnerSpr;
	Sprite *leftShutter, *rightShutter;
	Sprite *bg;
	Sprite *cloud[3];
	Sprite *ufo;
	BOOL ufoOn;
	Sprite *tutorial0, *tutorial, *tutorial2,*tutorial3,*tutorial4,*tutorial5;
	Sprite *saying;
	Sprite *logo;
	CGFloat cloudspeed[3];
	int clouddirection;
	Label* label1, *label2, *timerLabel,*label3, *nameLabel, *nameLabel2;
	int musicchoice;
	Label* achievementLabel;
	cpShape* selectedshape;
	bool resetting;
	int waitingForNextTouch;
	int checkingForWin;
	int startingLevel;
	int winnerTimer;
	int timerInt;
	int tutorialOn;
	MenuItem *item1;
	//database info for level
	totemAppDelegate *appDelegate;
	Level						*level;
}

@property(nonatomic,retain) Level						*level;
-(void)updateClouds;
-(void)slideShuttersOpen;
-(void)slideShuttersClosed;
-(void)shuttersClosed;
-(void) setupClouds;
-(void) wonLevel: (id) sender;
-(void)startLevel:(id)object;
-(void) deleteShape:(cpShape*) shape;
-(void)idolTouchesGround;
-(void)  pickingFunc:(cpShape *)shape;
- (void)addBackground;
- (void) menuCallback: (id) sender;
- (void)addMenu;
- (void)createBoundingBox;
-(void) step: (ccTime) dt;
-(bool)loadLevel:(NSString*) levelFilename;
-(void)extLoadLevel:(NSString *)lev;
-(void)checkAchievementsTime ;
-(void)checkAchievementsWonLost ;
- (void)removeAchievementLabel:(id)object;
-(void) removeOffscreenBlock:(cpShape *)shape ;
@end
