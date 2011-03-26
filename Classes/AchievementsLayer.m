//
//  AchievementsLayer.m
//  totem
//
//  Created by Matt Ripston on 9/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AchievementsLayer.h"

#import "SettingsLayer.h"
#import "totemAppDelegate.h"
#import "TotemWorldScene.h"
#import "MenuLayer.h"
#import "CreditsLayer.h"

const int kBackMenu3 = 103;
@implementation AchievementsLayer
-(id) init
{
	if( (self=[super init])) {
		
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = NO;
		
		
		//link in appdelegate so we can use the database functions, like levels
		appDelegate = (totemAppDelegate *)[[UIApplication sharedApplication] delegate];
		
		[self addBackground];
		[self addMenu];
		[self addAchievements];
	}
	
	return self;
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
	MenuItem *itemnew = [MenuItemImage itemFromNormalImage:@"back.png" selectedImage:@"back_selected.png" target:self selector:@selector(closeAchievements:)];
	
	Menu *menu3 = [Menu menuWithItems: itemnew, nil];
	//[menu alignItemsVertically];
	menu3.position = CGPointMake(35,450);
	menu3.tag = kBackMenu3;
	[self addChild: menu3  z:200];

}
-(void)onEnter {
	//update values
	[super onEnter];
	[FlurryAPI logEvent:@"Achievements"];
	int temptime = g_totalTimePlayed;
	int hours = temptime / 3600;
	int minutes = (int)(temptime / 60) % 60;
	int seconds = (int)temptime % 60;
	//add achievement icons
	if(g_achievements[0] == 0) {
		[achiSpr[0] setVisible:NO];
		[achiDisabledSpr[0] setVisible:YES];
		[achiLabel[0] setString:[NSString stringWithFormat:@"%02i:%02i:%02i",hours,minutes,seconds]];
	}
	else if(g_achievements[0] == 1) {
		
		[achiSpr[0] setVisible:YES];
		[achiDisabledSpr[0] setVisible:NO];
		[achiLabel[0] setString:@""];
	}
	if(g_achievements[1] == 0) {
		[achiSpr[1] setVisible:NO];
		[achiDisabledSpr[1] setVisible:YES];
		[achiLabel[1] setString:[NSString stringWithFormat:@"%02i:%02i:%02i",hours,minutes,seconds]];
	}
	else if(g_achievements[1] == 1) {
		[achiSpr[1] setVisible:YES];
		[achiDisabledSpr[1] setVisible:NO];
		[achiLabel[1] setString:@""];
	}
	
	//3&4
	if(g_achievements[2] == 0) {
		[achiSpr[2] setVisible:NO];
		[achiDisabledSpr[2] setVisible:YES];
		[achiLabel[2] setString:[NSString stringWithFormat:@"%02i/150",g_timesWon]];
	}
	else if(g_achievements[2] == 1) {
		
		[achiSpr[2] setVisible:YES];
		[achiDisabledSpr[2] setVisible:NO];
		[achiLabel[2] setString:@""];
	}
	if(g_achievements[3] == 0) {
		[achiSpr[3] setVisible:NO];
		[achiDisabledSpr[3] setVisible:YES];
		[achiLabel[3] setString:[NSString stringWithFormat:@"%02i/150",g_timesLost]];
	}
	else if(g_achievements[3] == 1) {
		[achiSpr[3] setVisible:YES];
		[achiDisabledSpr[3] setVisible:NO];
		[achiLabel[3] setString:@""];
	}
	
	//5&6
	if(g_achievements[4] == 0) {
		[achiSpr[4] setVisible:NO];
		[achiDisabledSpr[4] setVisible:YES];
		[achiLabel[4] setString:@""];
	}
	else if(g_achievements[4] == 1) {
		
		[achiSpr[4] setVisible:YES];
		[achiDisabledSpr[4] setVisible:NO];
		[achiLabel[4] setString:@""];
	}
	if(g_achievements[5] == 0) {
		[achiSpr[5] setVisible:NO];
		[achiDisabledSpr[5] setVisible:YES];
		[achiLabel[5] setString:[NSString stringWithFormat:@"%02i/50",g_highestLevel]];
	}
	else if(g_achievements[5] == 1) {
		[achiSpr[5] setVisible:YES];
		[achiDisabledSpr[5] setVisible:NO];
		[achiLabel[5] setString:@""];
	}
	
	//7&8
	if(g_achievements[6] == 0) {
		[achiSpr[6] setVisible:NO];
		[achiDisabledSpr[6] setVisible:YES];
		[achiLabel[6] setString:[NSString stringWithFormat:@""]];
	}
	else if(g_achievements[6] == 1) {
		
		[achiSpr[6] setVisible:YES];
		[achiDisabledSpr[6] setVisible:NO];
		[achiLabel[6] setString:@""];
	}
	if(g_achievements[7] == 0) {
		[achiSpr[7] setVisible:NO];
		[achiDisabledSpr[7] setVisible:YES];
		[achiLabel[7] setString:@""];
	}
	else if(g_achievements[7] == 1) {
		[achiSpr[7] setVisible:YES];
		[achiDisabledSpr[7] setVisible:NO];
		[achiLabel[7] setString:@""];
	}
	
}
-(void) addAchievements
{
	int hours = g_totalTimePlayed / 3600;
	int minutes = (int)(g_totalTimePlayed / 60) % 60;
	int seconds = (int)g_totalTimePlayed % 60;
	
	//Achievement 1
	//add achievement icons
	achiSpr[0] = [Sprite spriteWithFile:@"achievement1.png"];
	[achiSpr[0] setPosition:cpv(90,370)];
	[self addChild: achiSpr[0] z:200];
	//add achievement icons
	achiDisabledSpr[0] = [Sprite spriteWithFile:@"achievement1a.png"];
	[achiDisabledSpr[0] setPosition:cpv(90,370)];
	[self addChild: achiDisabledSpr[0] z:200];
	//add testing label
	achiLabel[0] = [Label labelWithString:[NSString stringWithFormat:@"%02i:%02i:%02i",hours,minutes,seconds] dimensions:CGSizeMake(120,20) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:16];
	[self addChild: achiLabel[0] z:200];
	[achiLabel[0] setPosition: ccp(90,328)];
	
	//Achievement 2
	//add achievement icons
	achiSpr[1] = [Sprite spriteWithFile:@"achievement2.png"] ;
	[achiSpr[1] setPosition:cpv(230,370)];
	[self addChild: achiSpr[1] z:200];
	achiDisabledSpr[1] = [Sprite spriteWithFile:@"achievement2a.png"];
	[achiDisabledSpr[1] setPosition:cpv(230,370)];
	[self addChild: achiDisabledSpr[1] z:200];
	//add testing label
	achiLabel[1] = [Label labelWithString:[NSString stringWithFormat:@"%02i:%02i:%02i",hours,minutes,seconds] dimensions:CGSizeMake(120,20) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:16];
	[self addChild: achiLabel[1] z:200];
	[achiLabel[1] setPosition: ccp(230,328)];
	
	//Achievement 3
	//add achievement icons
	achiSpr[2] = [Sprite spriteWithFile:@"achievement3.png"];
	[achiSpr[2] setPosition:cpv(90,290)];
	[self addChild: achiSpr[2] z:200];
	//add achievement icons
	achiDisabledSpr[2] = [Sprite spriteWithFile:@"achievement3a.png"];
	[achiDisabledSpr[2] setPosition:cpv(90,290)];
	[self addChild: achiDisabledSpr[2] z:200];
	//add testing label
	achiLabel[2] = [Label labelWithString:[NSString stringWithFormat:@"%02i/50",g_timesWon] dimensions:CGSizeMake(120,20) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:16];
	[self addChild: achiLabel[2] z:200];
	[achiLabel[2] setPosition: ccp(90,248)];
	
	//Achievement 4
	//add achievement icons
	achiSpr[3] = [Sprite spriteWithFile:@"achievement4.png"] ;
	[achiSpr[3] setPosition:cpv(230,290)];
	[self addChild: achiSpr[3] z:200];
	achiDisabledSpr[3] = [Sprite spriteWithFile:@"achievement4a.png"];
	[achiDisabledSpr[3] setPosition:cpv(230,290)];
	[self addChild: achiDisabledSpr[3] z:200];
	//add testing label
	achiLabel[3] = [Label labelWithString:[NSString stringWithFormat:@"%02i/50",g_timesLost] dimensions:CGSizeMake(120,20) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:16];
	[self addChild: achiLabel[3] z:200];
	[achiLabel[3] setPosition: ccp(230,248)];
	
	//Achievement 5
	//add achievement icons
	achiSpr[4] = [Sprite spriteWithFile:@"achievement5.png"];
	[achiSpr[4] setPosition:cpv(90,210)];
	[self addChild: achiSpr[4] z:200];
	//add achievement icons
	achiDisabledSpr[4] = [Sprite spriteWithFile:@"achievement5a.png"];
	[achiDisabledSpr[4] setPosition:cpv(90,210)];
	[self addChild: achiDisabledSpr[4] z:200];
	//add testing label
	achiLabel[4] = [Label labelWithString:[NSString stringWithFormat:@"%02i:%02i:%02i",hours,minutes,seconds] dimensions:CGSizeMake(120,20) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:16];
	[self addChild: achiLabel[4] z:200];
	[achiLabel[4] setPosition: ccp(90,168)];
	
	//Achievement 6
	//add achievement icons
	achiSpr[5] = [Sprite spriteWithFile:@"achievement6.png"] ;
	[achiSpr[5] setPosition:cpv(230,210)];
	[self addChild: achiSpr[5] z:200];
	achiDisabledSpr[5] = [Sprite spriteWithFile:@"achievement6a.png"];
	[achiDisabledSpr[5] setPosition:cpv(230,210)];
	[self addChild: achiDisabledSpr[5] z:200];
	//add testing label
	achiLabel[5] = [Label labelWithString:[NSString stringWithFormat:@"%02i:%02i:%02i",hours,minutes,seconds] dimensions:CGSizeMake(120,20) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:16];
	[self addChild: achiLabel[5] z:200];
	[achiLabel[5] setPosition: ccp(230,168)];
	
	//Achievement 7
	//add achievement icons
	achiSpr[6] = [Sprite spriteWithFile:@"achievement7.png"];
	[achiSpr[6] setPosition:cpv(90,130)];
	[self addChild: achiSpr[6] z:200];
	//add achievement icons
	achiDisabledSpr[6] = [Sprite spriteWithFile:@"achievement7a.png"];
	[achiDisabledSpr[6] setPosition:cpv(90,130)];
	[self addChild: achiDisabledSpr[6] z:200];
	//add testing label
	achiLabel[6] = [Label labelWithString:[NSString stringWithFormat:@"%02i/50",g_timesWon] dimensions:CGSizeMake(120,20) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:16];
	[self addChild: achiLabel[6] z:200];
	[achiLabel[6] setPosition: ccp(90,88)];
	
	//Achievement 8
	//add achievement icons
	achiSpr[7] = [Sprite spriteWithFile:@"achievement8.png"] ;
	[achiSpr[7] setPosition:cpv(230,130)];
	[self addChild: achiSpr[7] z:200];
	achiDisabledSpr[7] = [Sprite spriteWithFile:@"achievement8a.png"];
	[achiDisabledSpr[7] setPosition:cpv(230,130)];
	[self addChild: achiDisabledSpr[7] z:200];
	//add testing label
	achiLabel[7] = [Label labelWithString:@"" dimensions:CGSizeMake(120,20) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:16];
	[self addChild: achiLabel[7] z:200];
	[achiLabel[7] setPosition: ccp(230,88)];
	
}
-(void) menuCallback: (id) sender
{
	NSLog(@"selected item: %@ index:%d", [sender selectedItem], [sender selectedIndex] );
}
-(void) closeAchievements:(id) sender
{	
	
	[appDelegate playSound:@"select.caf"];
	[(MultiplexLayer*)parent switchTo:1];
	
}
-(void) resumeCallback:(id) sender
{	
	
	[appDelegate playSound:@"select.caf"];
	[(MultiplexLayer*)parent switchTo:0];
	
}
- (void) dealloc
{
	[super dealloc];
}
@end
