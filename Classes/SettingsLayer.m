//
//  SettingsLayer.m
//  totem
//
//  Created by Matt Ripston on 9/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SettingsLayer.h"
#import "totemAppDelegate.h"
#import "TotemWorldScene.h"
#import "MenuLayer.h"
#import "AchievementsLayer.h"
#import	"CreditsLayer.h"
const int kBackMenu2 = 101;
@implementation SettingsLayer
-(id) init
{
	if( (self=[super init])) {
		
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = NO;
		
		
		//link in appdelegate so we can use the database functions, like levels
		appDelegate = (totemAppDelegate *)[[UIApplication sharedApplication] delegate];
		
		[self addBackground];
		[self addMenu];
		touchTimer =0;
		buttontouched=FALSE;
		
	}
	
	return self;
}

-(void)onEnter {
	
	[super onEnter];
	[self schedule: @selector(changeTime:) interval:1.0];
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
	
	//add level select


//	[label1s setColor:ccc3( 192,0,255)];
	

    MenuItemToggle *item1 = [MenuItemToggle itemWithTarget:self selector:@selector(menuCallback:) items:
                             [MenuItemImage itemFromNormalImage:@"Soundoff.png" selectedImage:@"Soundoff.png"],
                             [MenuItemImage itemFromNormalImage:@"Soundon.png" selectedImage:@"Soundon.png"],
                             nil];
	item1.selectedIndex = g_soundOn;
    
    MenuItemToggle *item2 = [MenuItemToggle itemWithTarget:self selector:@selector(musicmenuCallback:) items:
                             [MenuItemImage itemFromNormalImage:@"Musicoff.png" selectedImage:@"Musicoff.png"],
                             [MenuItemImage itemFromNormalImage:@"Musicon.png" selectedImage:@"Musicon.png"],
							 
                             nil];

	item2.selectedIndex = g_musicOn;
	
//	item1.position =  CGPointMake(0,300);
//	item2.position =  CGPointMake(270,300);

	Menu *menu2 = [Menu menuWithItems:
                  item1, item2, nil]; // 9 items.
	[menu2 alignItemsHorizontally];
    menu2.position  =  CGPointMake(160,300);
	[self addChild: menu2 z:200];
	
	// menu for back icon
	MenuItem *itemnew = [MenuItemImage itemFromNormalImage:@"back.png" selectedImage:@"back_selected.png" target:self selector:@selector(closeSettings:)];
	
	Menu *menu3 = [Menu menuWithItems: itemnew, nil];
	//[menu alignItemsVertically];
	menu3.position =  CGPointMake(35,450);
	menu3.tag = kBackMenu2;
	[self addChild: menu3  z:200];
	
	// menu for back icon
	/*MenuItem *itemreset = [MenuItemImage itemFromNormalImage:@"reset.png" selectedImage:@"reset_selected.png" target:self selector:@selector(resetSettings:)];
	
	Menu *menureset = [Menu menuWithItems: itemreset, nil];
	//[menu alignItemsVertically];
	menureset.position = CGPointMake(160,100);
	[self addChild: menureset  z:200];*/
	
	button = [Sprite spriteWithFile:@"button.png"];

	[button setPosition:cpv(160,100)];
	[self addChild:button z:200];	
	
	button_Touched = [Sprite spriteWithFile:@"buttonpressed.png"];
	
	[button_Touched setPosition:cpv(160,100)];
	[self addChild:button_Touched z:201];
	[button_Touched setVisible:NO];
	
}
-(void) menuCallback: (id) sender
{
	
	[(totemAppDelegate *)[[UIApplication sharedApplication] delegate] playSound:@"select.caf"];
	if(	g_soundOn ==1)
		g_soundOn=0;
	else
		g_soundOn=1;
	NSLog(@"selected item: %@ index:%d", [sender selectedItem], [sender selectedIndex] );
}

- (BOOL)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	for( UITouch *touch in touches ) {
		//	[label1 setString:@"touched!"];
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[Director sharedDirector] convertCoordinate: location];
		float w = [button contentSize].width;
		float h = [button contentSize].height;

		CGPoint point = CGPointMake([button position].x - (w/2), [button position].y
									- (h/2));
		//point = [[Director sharedDirector] convertCoordinate:point];
		CGRect rect =  CGRectMake(point.x, point.y, w, h);
			
        if (CGRectContainsPoint(rect, location)) {
			[button setVisible:NO];
			[button_Touched setVisible:YES];
            // code here is only executed if obj has been touched
			buttontouched=TRUE;
			
			
        }
		
	}
	return kEventHandled;
}

- (BOOL)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	for( UITouch *touch in touches ) {
		//	[label1 setString:@"touched!"];
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[Director sharedDirector] convertCoordinate: location];
		float w = [button contentSize].width;
		float h = [button contentSize].height;
		
		CGPoint point = CGPointMake([button position].x - (w/2), [button position].y
									- (h/2));
		//point = [[Director sharedDirector] convertCoordinate:point];
		CGRect rect =  CGRectMake(point.x, point.y, w, h);
		
        if (CGRectContainsPoint(rect, location)) {
			[button setVisible:NO];
			[button_Touched setVisible:YES];
            // code here is only executed if obj has been touched
			buttontouched=TRUE;
        }
		else 
		{
			buttontouched=FALSE;
			[button setVisible:YES];
			[button_Touched setVisible:NO];
			touchTimer=0;
		}
		
	}
	return kEventHandled;
}
- (BOOL)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	for( UITouch *touch in touches ) {
		buttontouched=FALSE;
		[button setVisible:YES];
		[button_Touched setVisible:NO];
		touchTimer=0;
	}
	return kEventHandled;
}
-(void)changeTime: (ccTime) dt{
	if(buttontouched){
	touchTimer++;
	if(touchTimer > 3) {
		[self resetSettings:(id)1];
	}}
}

-(void) musicmenuCallback: (id) sender

{
	
	[(totemAppDelegate *)[[UIApplication sharedApplication] delegate] playSound:@"select.caf"];
	if(	g_musicOn ==1) {
		g_musicOn=0;
	}
	else {
		g_musicOn=1;
	}
	NSLog(@"selected item: %@ index:%d", [sender selectedItem], [sender selectedIndex] );
}
-(void) closeSettings:(id) sender
{	
	[appDelegate playSound:@"select.caf"];
	
	[(MultiplexLayer*)parent switchTo:1];
	
}
-(void) resumeCallback:(id) sender
{	
	
	[appDelegate playSound:@"select.caf"];
	[(MultiplexLayer*)parent switchTo:0];
	
}
-(void)resetSettings:(id) sender {
		[FlurryAPI logEvent:@"Reset Settings"];
	buttontouched= FALSE;
	[appDelegate vibrate];
	//[(totemAppDelegate *)[[UIApplication sharedApplication] delegate] resetData];
	[appDelegate resetData];
	Scene *s2 = [Scene node];
	TotemWorld *node = [TotemWorld node];
	[node extLoadLevel:[NSString stringWithFormat:@"%02i",g_CurrentLevel]];
	
	//create multiplex layer with main game, menu, settings
	MultiplexLayer *layer = [MultiplexLayer layerWithLayers: node,[MenuLayer node],[SettingsLayer node] ,[AchievementsLayer node], [CreditsLayer node],  nil];
	[s2 addChild: layer];
//	[//appDelegate vibrate];

	[[Director sharedDirector] replaceScene: [FadeTransition transitionWithDuration:0.0f scene:s2]];
}
- (void) dealloc
{
	[super dealloc];
}
@end
