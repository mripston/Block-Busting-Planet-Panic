//
//  totemAppDelegate.h
//  totem
//
//  Created by Matt Ripston on 9/2/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "FlurryAPI.h"
int g_CurrentLevel;
int g_highestLevel;
int g_soundOn;
int g_musicOn;
int g_timesWon;
int g_timesLost;
int g_lockedLevelSets[5];

BOOL g_achievements[8];
int64_t g_totalTimePlayed;
// layer types
enum {
	kLayer_TotemGame,
	kLayer_Menu
};
@interface totemAppDelegate : NSObject <UIApplicationDelegate> {
	IBOutlet UIWindow *window;
	IBOutlet UINavigationController *navigationController;
	
	sqlite3 *database;
	NSMutableArray *levels;
	//used to track sound allocations.  The actual sound data is buffered in SoundEngine; 'sounds' here only tracks the openAL ids of the loaded sounds.
	NSMutableDictionary*	sounds;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, retain) NSMutableArray *levels;
- (void)createEditableCopyOfDatabaseIfNeeded;
- (void)initializeDatabase;
-(void)resetData ;
-(void)unlockAll;
-(void)changeLevel;
-(void) vibrate;
-(int) totalTime;
-(void)updateLockedLevelSets;
- (void) setupSound; //intialize the sound device.  Takes a non-trivial amount of time, and should be called during initialization.
- (UInt32) getSound:(NSString*) filename; //useful for preloading sounds; called automatically by playSound.  Buffers sounds.
- (void) purgeSounds;
- (void) playSound:(NSString*) filename; //play a sound.  Loads and buffers the sound if needed.
-(void) playMusic:(NSString*)filename; //play and loop a music file in the background.  streams the file.
-(void) stopMusic; //stop the music.  unloads the currently playing music file.


@end
