//
//  SettingsLayer.h
//  totem
//
//  Created by Matt Ripston on 9/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//


#import "cocos2d.h"
#import "chipmunk.h"
#import "totemAppDelegate.h"
@interface SettingsLayer : Layer {
	Sprite *button,*button_Touched;
	//database info for level
	totemAppDelegate *appDelegate;
	int touchTimer;
	BOOL buttontouched;
}
-(void) addBackground;
-(void) addMenu;
-(void) resumeCallback:(id) sender;
-(void) closeSettings:(id) sender;
-(void)resetSettings:(id) sender ;
@end
