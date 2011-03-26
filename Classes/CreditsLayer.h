//
//  CreditsLayer.h
//  totem
//
//  Created by Matt Ripston on 9/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
#import "cocos2d.h"
#import "chipmunk.h"


@interface CreditsLayer : Layer {
	Label *achievementLabel;
}
-(void) addBackground;
-(void) addMenu;
-(void) resumeCallback:(id) sender;
-(void) closeCredits:(id) sender;
-(void) checkAchievements;
@end
