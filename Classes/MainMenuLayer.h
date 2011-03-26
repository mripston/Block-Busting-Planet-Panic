//
//  MainMenuLayer.h
//  totem
//
//  Created by Matt Ripston on 9/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//




#import "cocos2d.h"
#import "chipmunk.h"

@interface MainMenuLayer : Layer {
	int new_level;

}
-(void) menuCallback: (id) sender;
-(void)addBackground;
-(void)addMenu;

-(void) playGameCallback:(id) sender;
-(void) levelSelectCallback:(id) sender;
-(void) otherGamesCallback:(id) sender;

@end

