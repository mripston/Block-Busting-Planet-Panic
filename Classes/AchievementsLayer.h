//
//  AchievementsLayer.h
//  totem
//
//  Created by Matt Ripston on 9/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "chipmunk.h"
#import "totemAppDelegate.h"

@interface AchievementsLayer : Layer {
	Sprite *achiSpr[8];
	Sprite *achiDisabledSpr[8];
	Label *achiLabel[8];
	//database info for level
	totemAppDelegate *appDelegate;
}
-(void) addBackground;
-(void) addMenu;
-(void) resumeCallback:(id) sender;
-(void) closeAchievements:(id) sender;
-(void) addAchievements;
@end
