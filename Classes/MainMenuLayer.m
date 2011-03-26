//
//  MenuLayer.m
//  totem
//
//  Created by Matt Ripston on 9/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MainMenuLayer.h"
#import "TotemWorldScene.h"
#import "totemAppDelegate.h"
#import "MenuLayer.h"
#import "LevelSelectViewController.h"

@implementation MainMenuLayer
-(id) init
{
	if( (self=[super init])) {
		
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = NO;
		

		[self addBackground];
		[self addMenu];
	}
	
	return self;
}

- (void)addBackground
{
	Sprite *bg = [[Sprite spriteWithFile:@"sky.png"] retain];
	[bg setPosition:cpv(160,240)];
	[self addChild: bg z:0];
	
	Sprite *ground = [[Sprite spriteWithFile:@"ground.png"] retain];
	[ground setPosition:cpv(160,25)];
	[self addChild: ground z:0];
	
	Sprite *logo = [[Sprite spriteWithFile:@"logo.png"] retain];
	[logo setPosition:cpv(160,400)];
	[self addChild: logo z:1];
	
	Sprite *totem = [[Sprite spriteWithFile:@"totem.png"] retain];
	[totem setPosition:cpv(260,144)];
	[self addChild: totem z:1];
}

-(void) menuCallback: (id) sender
{
	Scene *s2 = [Scene node];
	[s2 addChild: [TotemWorld node]];
	[[Director sharedDirector] replaceScene: [FadeTransition transitionWithDuration:0.5f scene:s2]];
	
	//[(MultiplexLayer*)parent switchToAndReleaseMe:0];
}
-(void)addMenu{
	// Image Item
	//MenuItem *item1 = [MenuItemImage itemFromNormalImage:@"menu1.png" selectedImage:@"menu1_selected.png" target:self selector:@selector(menuCallback:)];
	
	//	Menu *menu = [Menu menuWithItems: item1, nil];
	//[menu alignItemsVertically];
	//	menu.position = CGPointMake(305,465);
	
	//	[self addChild: menu z:200];
	
	//add level select
	[MenuItemFont setFontSize:20];
	//[MenuItemFont setFontName: @"Courier New"];
	// Font Item
	//[CallFuncND actionWithTarget:self selector:@selector(callback3:data:) data:(void*)0xbebabeba],
	//nil];
	MenuItemFont *playGameItem = [MenuItemFont itemFromString: @"Play Game" target:self selector:@selector(playGameCallback:) ];
	MenuItemFont *levelSelectItem = [MenuItemFont itemFromString: @"Level Select" target:self selector:@selector(levelSelectCallback:) ];
	MenuItemFont *otherGamesItem = [MenuItemFont itemFromString: @"Other Games" target:self selector:@selector(otherGamesCallback:) ];
	
	Menu *menu2 = [Menu menuWithItems: playGameItem,levelSelectItem,otherGamesItem, nil];
	[menu2 alignItemsVertically];
	[self addChild: menu2 z:200];
}

-(void) playGameCallback:(id) sender
{

	//load tutorial if level 1
	if(g_CurrentLevel > 1){
		Scene *s2 = [Scene node];
	TotemWorld *node = [TotemWorld node];
	[node extLoadLevel:[NSString stringWithFormat:@"%02i",g_CurrentLevel]];
	
	
	MultiplexLayer *layer = [MultiplexLayer layerWithLayers: node,[MenuLayer node],  nil];
	[s2 addChild: layer];
	
	[[Director sharedDirector] replaceScene: [FadeTransition transitionWithDuration:1.0f scene:s2]];
	 }
	else {
//	Scene *s2 = [Scene node];
	//TutorialLayer *node = [TutorialLayer node];
	
//[s2 addChild: node];
	
//	[[Director sharedDirector] replaceScene: [FadeTransition transitionWithDuration:1.0f scene:s2]];
	}
	
}
-(void) levelSelectCallback:(id) sender
{
	//[(RootViewController*) 	 [(totemAppDelegate*)[[UIApplication sharedApplication] delegate] 	  rootViewController] showMainMenu]; 
	
	
	//[(totemAppDelegate *)[[UIApplication sharedApplication] delegate] loadLevelSelect]; 
	
	//add backdrop
	Sprite *bg = [[Sprite spriteWithFile:@"backdrop.png"] retain];
	[bg setPosition:cpv(160,240)];
	[self addChild: bg z:300];
	
	UINavigationController *navigationController = [[LevelSelectViewController alloc] initWithNibName:@"LevelSelectViewController" bundle:nil];
	
	navigationController.view.center = CGPointMake(160,240);
//	[[Director sharedDirector] attachInWindow:navigationController.view.window];
	[[[Director sharedDirector] openGLView]  addSubview:navigationController.view]; 

	
//	navigationController = [[LevelSelectViewController alloc] initWithNibName:@"LevelSelectViewController" bundle:nil];
	
	
	// Configure and show the window
///	[window addSubview:[navigationController view]];
//	[window makeKeyAndVisible];
	
	/*Scene *s2 = [Scene node];
	LevelSelectLayer *node = [LevelSelectLayer node];
	[s2 addChild: node];
	[[Director sharedDirector] replaceScene: [FadeTransition transitionWithDuration:0.0f scene:s2]];*/
	
}
-(void) otherGamesCallback:(id) sender
{
	Scene *s2 = [Scene node];
	TotemWorld *node = [TotemWorld node];
	[node extLoadLevel:@"01"];
	[s2 addChild: node];
	[[Director sharedDirector] replaceScene: [FadeTransition transitionWithDuration:0.0f scene:s2]];
	
}
- (void)dealloc {
	[super dealloc];
}

@end
