//
//  MenuLayer.m
//  totem
//
//  Created by Matt Ripston on 9/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MenuLayer.h"
#import "TotemWorldScene.h"
#import "MainMenuLayer.h"
#import "totemAppDelegate.h"
#import "LevelSelectViewController.h"
#import "SettingsLayer.h"
#import "AchievementsLayer.h"
#import	"CreditsLayer.h"

const int kTagLevelSelect = 100;
const int kBackMenu = 101;
@implementation MenuLayer
-(id) init
{
	if( (self=[super init])) {
		
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = NO;
		level_select_open = FALSE;
		
		//link in appdelegate so we can use the database functions, like levels
		appDelegate = (totemAppDelegate *)[[UIApplication sharedApplication] delegate];
		
		timerInt=appDelegate.totalTime;
		
		[self addBackground];
		[self addMenu];
	}
	
	return self;
}
-(void)onEnter {
	
	[super onEnter];
	timerInt=appDelegate.totalTime;
}
- (void)addBackground
{
	/*Sprite *bkg = [[Sprite spriteWithFile:@"sky.png"] retain];
	[bkg setPosition:cpv(160,240)];
	[self addChild: bkg z:0];
	
	Sprite *ground = [[Sprite spriteWithFile:@"ground.png"] retain];
	[ground setPosition:cpv(160,25)];
	[self addChild: ground z:0];
	*/
	Sprite *logo = [[Sprite spriteWithFile:@"SmallLogo2.png"] retain];
	[logo setPosition:cpv(160,440)];
	[self addChild: logo z:200];
	Sprite *leftShutter = [[Sprite spriteWithFile:@"leftshutter.png"] retain];
	[leftShutter setPosition:CGPointMake(81.5,240)];
	[self addChild: leftShutter z:199];
	
	Sprite *rightShutter = [[Sprite spriteWithFile:@"rightshutter.png"] retain];
	[rightShutter setPosition:CGPointMake(232.5,240)];
	[self addChild: rightShutter z:198];
}


-(void)addMenu{
	// menu for close icon
	MenuItem *item1 = [MenuItemImage itemFromNormalImage:@"close.png" selectedImage:@"close_selected.png" target:self selector:@selector(resumeCallback:)];
	
	Menu *menu = [Menu menuWithItems: item1, nil];
	//[menu alignItemsVertically];
	menu.position = CGPointMake(280,24);
	
	[self addChild: menu z:200];
	
	//add level select
//	[MenuItemFont setFontSize:20];
	
/*	MenuItemFont *restartLevelItem = [MenuItemFont itemFromString: @"Restart Level" target:self selector:@selector(restartLevelCallback:) ];
	MenuItemFont *levelSelectItem = [MenuItemFont itemFromString: @"Level Select" target:self selector:@selector(levelSelectCallback:) ];
	MenuItemFont *settingsItem = [MenuItemFont itemFromString: @"Settings" target:self selector:@selector(settingsCallback:) ];
	
	MenuItemFont *achievementsItem = [MenuItemFont itemFromString: @"Achievements" target:self selector:@selector(achievementsCallback:) ];
	
	MenuItemFont *creditsItem = [MenuItemFont itemFromString: @"Credits" target:self selector:@selector(creditsCallback:) ];
		*/
	MenuItem *restartLevelItem = [MenuItemImage itemFromNormalImage:@"restartlevel.png" selectedImage:@"restartlevel_selected.png" target:self selector:@selector(restartLevelCallback:)];
	MenuItem *levelSelectItem = [MenuItemImage itemFromNormalImage:@"levelselectbutton.png" selectedImage:@"levelselectbutton_selected.png" target:self selector:@selector(levelSelectCallback:)];
	MenuItem *settingsItem = [MenuItemImage itemFromNormalImage:@"settings.png" selectedImage:@"settings_selected.png" target:self selector:@selector(settingsCallback:)];
	MenuItem *achievementsItem = [MenuItemImage itemFromNormalImage:@"achievements.png" selectedImage:@"achievements_selected.png" target:self selector:@selector(achievementsCallback:)];
	MenuItem *creditsItem = [MenuItemImage itemFromNormalImage:@"credits.png" selectedImage:@"credits_selected.png" target:self selector:@selector(creditsCallback:)];
	
	Menu *menu2 = [Menu menuWithItems: restartLevelItem,levelSelectItem,settingsItem,achievementsItem,creditsItem, nil];
	[menu2 alignItemsVertically];
	[self addChild: menu2 z:200];
}

-(void) restartLevelCallback:(id) sender
{
	[(totemAppDelegate *)[[UIApplication sharedApplication] delegate] playSound:@"select.caf"];
	Scene *s2 = [Scene node];
	TotemWorld *node = [TotemWorld node];
	[node extLoadLevel:[NSString stringWithFormat:@"%02i",g_CurrentLevel]];
	
		
	MultiplexLayer *layer = [MultiplexLayer layerWithLayers: node,[MenuLayer node],[SettingsLayer node],[AchievementsLayer node], [CreditsLayer node],  nil];
	[s2 addChild: layer];
	
	[[Director sharedDirector] replaceScene:s2];
	
}
-(void) levelSelectCallback:(id) sender
{
	[(totemAppDelegate *)[[UIApplication sharedApplication] delegate] playSound:@"select.caf"];
	// menu for back icon
	MenuItem *item1 = [MenuItemImage itemFromNormalImage:@"back.png" selectedImage:@"back_selected.png" target:self selector:@selector(closeLevelSelect:)];
	
	Menu *menu = [Menu menuWithItems: item1, nil];
	//[menu alignItemsVertically];
	menu.position = CGPointMake(35,450);
	menu.tag = kBackMenu;
	[self addChild: menu z:200];
	
	//add backdrop
	
	bg = [[Sprite spriteWithFile:@"menubkg.png"] retain];
	[bg setPosition:cpv(160,240)];
	[self addChild: bg z:201];
	
	totalTime = [Label labelWithString:@"00:00" dimensions:CGSizeMake(300,32) alignment:UITextAlignmentLeft fontName:@"Marker Felt" fontSize:16 ];
	[totalTime setPosition: ccp(242,40)];
	
	[totalTime setColor:ccc3( 192,0,255)];

	
	totalTime2 = [Label labelWithString:@"00:00" dimensions:CGSizeMake(300,32) alignment:UITextAlignmentLeft fontName:@"Marker Felt" fontSize:17 ];
	[totalTime2 setPosition: ccp(240,40)];
	
	[totalTime2 setColor:ccWHITE];
	
	int hours = (int)timerInt / 3600;
	int minutes = (int)(timerInt / 60) % 60;
	int seconds = (int)timerInt % 60;
	
	[totalTime setString:[NSString stringWithFormat:@"%02i:%02i:%02i",hours,minutes,seconds]];
	[totalTime2 setString:[NSString stringWithFormat:@"%02i:%02i:%02i",hours,minutes,seconds]];
	
	
	//[self addChild: totalTime z:202];

	[self addChild: totalTime2 z:201];
	navigationController = [[LevelSelectViewController alloc] initWithNibName:@"LevelSelectViewController" bundle:nil];
	
	
	[navigationController.view setTag:kTagLevelSelect];
	navigationController.view.center = CGPointMake(160,240);
	
	[[[Director sharedDirector] openGLView]  addSubview:navigationController.view]; 
	level_select_open= TRUE;
	
}
-(void)closeLevelSelect:(id)sender {
	if(level_select_open){
		
		[(totemAppDelegate *)[[UIApplication sharedApplication] delegate] playSound:@"select.caf"];
		[[[[UIApplication sharedApplication] keyWindow] viewWithTag:kTagLevelSelect] removeFromSuperview]; 
		
		[self removeChild:bg cleanup:NO];
		[self removeChild:totalTime cleanup:NO];
		[self removeChild:totalTime2 cleanup:NO];
		level_select_open = FALSE;
		//remove menu for back icon
		[self removeChildByTag:kBackMenu cleanup:NO];
	}
}
-(void) settingsCallback:(id) sender
{
	
	[(totemAppDelegate *)[[UIApplication sharedApplication] delegate] playSound:@"select.caf"];
	[(MultiplexLayer*)parent switchTo:2];
	
}
-(void) resumeCallback:(id) sender
{	
	[(totemAppDelegate *)[[UIApplication sharedApplication] delegate] playSound:@"select.caf"];
	if(level_select_open){
		
		[[[[UIApplication sharedApplication] keyWindow] viewWithTag:kTagLevelSelect] removeFromSuperview]; 
		
		[self removeChild:bg cleanup:NO];
		[self removeChild:totalTime cleanup:NO];
		[self removeChild:totalTime2 cleanup:NO];

		level_select_open = FALSE;
		//remove menu for back icon
		[self removeChildByTag:kBackMenu cleanup:NO];
	}
	[(MultiplexLayer*)parent switchTo:0];
	
}
-(void) achievementsCallback:(id) sender
{
	
	[(totemAppDelegate *)[[UIApplication sharedApplication] delegate] playSound:@"select.caf"];
	[(MultiplexLayer*)parent switchTo:3];
	
}
-(void) creditsCallback:(id) sender
{
	
	[(totemAppDelegate *)[[UIApplication sharedApplication] delegate] playSound:@"select.caf"];
	[(MultiplexLayer*)parent switchTo:4];
	
}
- (void) dealloc
{
	[super dealloc];
}

@end
