//
//  CreditsLayer.m
//  totem
//
//  Created by Matt Ripston on 9/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CreditsLayer.h"
#import "AchievementsLayer.h"

#import "SettingsLayer.h"
#import "totemAppDelegate.h"
#import "TotemWorldScene.h"
#import "MenuLayer.h"
#import "CreditsLayer.h"

const int kBackMenu4 = 104;
@implementation CreditsLayer
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
-(void)onEnter {
	[super onEnter];
	[self checkAchievements];
	
}
-(void)checkAchievements {
	//win 50 times
	if( g_achievements[4] == 0){ 
		g_achievements[4] =1;
		//add a label saying unlocked
		achievementLabel = [Label labelWithString:@"Achievement Unlocked!:\nView Credits" dimensions:CGSizeMake(240,80) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:24];

		[self addChild: achievementLabel z:100];
		[achievementLabel setPosition: ccp(160,360)];
		[self performSelector:@selector(removeAchievementLabel:) withObject:nil afterDelay:4.0];
		
	}
}
- (void)removeAchievementLabel:(id)object
{
	[achievementLabel setString:@""];
}

- (void)addBackground
{
	/*	Sprite *bg = [[Sprite spriteWithFile:@"sky.png"] retain];
	 [bg setPosition:cpv(160,240)];
	 [self addChild: bg z:0];
	 
	 Sprite *ground = [[Sprite spriteWithFile:@"ground.png"] retain];
	 [ground setPosition:cpv(160,25)];
	 [self addChild: ground z:0];*/
	Sprite *logo = [[Sprite spriteWithFile:@"SmallLogo2.png"] retain];
	[logo setPosition:cpv(160,440)];
	[self addChild: logo z:200];
	
	Sprite *leftShutter = [[Sprite spriteWithFile:@"leftshutter.png"] retain];
	[leftShutter setPosition:CGPointMake(81.5,240)];
	[self addChild: leftShutter z:1];
	
	Sprite *rightShutter = [[Sprite spriteWithFile:@"rightshutter.png"] retain];
	[rightShutter setPosition:CGPointMake(232.5,240)];
	[self addChild: rightShutter z:0];
}

-(void)addMenu{
	// menu for close icon
	MenuItem *item = [MenuItemImage itemFromNormalImage:@"close.png" selectedImage:@"close_selected.png" target:self selector:@selector(resumeCallback:)];
	
	Menu *menu = [Menu menuWithItems: item, nil];
	//[menu alignItemsVertically];
	menu.position = CGPointMake(280,24);
	
	[self addChild: menu z:200];
	
	
	// menu for back icon
	MenuItem *itemnew = [MenuItemImage itemFromNormalImage:@"back.png" selectedImage:@"back_selected.png" target:self selector:@selector(closeCredits:)];
	
	Menu *menu3 = [Menu menuWithItems: itemnew, nil];
	//[menu alignItemsVertically];
	menu3.position = CGPointMake(35,450);
	menu3.tag = kBackMenu4;
	[self addChild: menu3  z:200];
	
	//add credits
	//add testing label
	NSString* creditString = @"Design\nProgramming\nTesting:\nMatt Ripston\n\n\nArt by:Eric Nault\n\n\nVisit my website at:\nwww.mattripston.com";
	Label *label1 = [Label labelWithString:creditString dimensions:CGSizeMake(300,340) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:24];
	[self addChild: label1 z:100];
	[label1 setPosition: ccp(160,180)];
	
	Label *label1s = [Label labelWithString:creditString dimensions:CGSizeMake(300,340) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:25];
	[self addChild: label1s z:99];
	[label1s setPosition: ccp(160,185)];
	[label1s setColor:ccc3( 192,0,255)];
	
	
}
-(void) menuCallback: (id) sender
{
	NSLog(@"selected item: %@ index:%d", [sender selectedItem], [sender selectedIndex] );
}
-(void) closeCredits:(id) sender
{	
	
	[(totemAppDelegate *)[[UIApplication sharedApplication] delegate] playSound:@"select.caf"];
	[(MultiplexLayer*)parent switchTo:1];
	
}
-(void) resumeCallback:(id) sender
{	
	
	[(totemAppDelegate *)[[UIApplication sharedApplication] delegate] playSound:@"select.caf"];
	[(MultiplexLayer*)parent switchTo:0];
	
}
- (void) dealloc
{
	[super dealloc];
}
@end
