//
//  MenuLayer.h
//  totem
//
//  Created by Matt Ripston on 9/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//


#import "cocos2d.h"
#import "chipmunk.h"

#import "totemAppDelegate.h"
@interface MenuLayer : Layer {
	int new_level;
	UINavigationController *navigationController;
	totemAppDelegate *appDelegate;
	Sprite *bg;
	Label *totalTime,*totalTime2;
	BOOL level_select_open;
	int timerInt;
}

-(void)addBackground;
-(void)addMenu;
-(void)closeLevelSelect:(id)sender;
-(void) restartLevelCallback:(id) sender;
-(void) levelSelectCallback:(id) sender;
-(void) settingsCallback:(id) sender;
-(void) resumeCallback:(id) sender;
-(void) creditsCallback:(id) sender;
-(void) achievementsCallback:(id) sender;
@end
