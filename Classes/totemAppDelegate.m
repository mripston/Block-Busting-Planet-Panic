//
//  totemAppDelegate.m
//  totem
//
//  Created by Matt Ripston on 9/2/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "totemAppDelegate.h"
#import "cocos2d.h"
#import "TotemWorldScene.h"
#import "MenuLayer.h"
#import "MainMenuLayer.h"
#import "SettingsLayer.h"
#import "LevelSelectViewController.h"
#import "Level.h"
#import "SoundEngine.h"
#import "AchievementsLayer.h"
#import	"CreditsLayer.h"


//sound stuff leaks memory in the simulator, which is distracting when looking for real leaks.  use this to hack out SoundEngine calls.
#define DEBUG_SOUND_ENABLED true

@implementation totemAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize levels;

+ (void)initialize {
	
    if ([self class] == [totemAppDelegate class]) {
		NSArray *defValues, *defKeys;
		
		//unlock first level, but have zero time for everything else
		defValues = [NSArray arrayWithObjects:[NSNumber numberWithInt:1],[NSNumber numberWithInt:1],
					 [NSNumber numberWithInt:1], [NSNumber numberWithInt:1],
					 [NSNumber numberWithInt:0],
					 //achievements
					 [NSNumber numberWithInt:0],[NSNumber numberWithInt:0], [NSNumber numberWithInt:0],[NSNumber numberWithInt:0],
					 [NSNumber numberWithInt:0],[NSNumber numberWithInt:0], [NSNumber numberWithInt:0],[NSNumber numberWithInt:0],
					 //times won/lost
					 [NSNumber numberWithInt:0], [NSNumber numberWithInt:0],
					 
					 nil];
		defKeys = [NSArray arrayWithObjects:@"currentLevel",@"g_highestLevel",
				   @"SoundEnabled",@"g_musicOn",
				   @"g_totalTimePlayed",
				   //achievements
				   @"g_achievements0",@"g_achievements1",@"g_achievements2",@"g_achievements3",
				   @"g_achievements4",@"g_achievements5",@"g_achievements6",@"g_achievements7",
				    //times won/lost
				   @"g_timesWon",@"g_timesLost",
				   nil];
		
        NSDictionary *resourceDict = [NSDictionary dictionaryWithObjects:defValues forKeys:defKeys];
        [[NSUserDefaults standardUserDefaults] registerDefaults:resourceDict];
	
		
    }
}

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	//start pinch anaytics
	NSString *applicationCode = @"7f91a2dcb569d9fddc22d163d8cf36ba";
	[FlurryAPI startSession:applicationCode];

	//for now set current level as 1.  later we'll have it laoded from memory
	g_CurrentLevel = [[NSUserDefaults standardUserDefaults] integerForKey:@"currentLevel"];
	
	
	g_highestLevel = [[NSUserDefaults standardUserDefaults] integerForKey:@"g_highestLevel"];
	g_soundOn = [[NSUserDefaults standardUserDefaults] integerForKey:@"SoundEnabled"];;
	g_musicOn = [[NSUserDefaults standardUserDefaults] integerForKey:@"g_musicOn"];
	g_totalTimePlayed = [[NSUserDefaults standardUserDefaults] integerForKey:@"g_totalTimePlayed"];
	
	int i=0;
	for(i=0;i<8;i++) {
		g_achievements[i] = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"g_achievements%i", i]];
	}
	g_timesWon = [[NSUserDefaults standardUserDefaults] integerForKey:@"g_timesWon"];
	g_timesLost = [[NSUserDefaults standardUserDefaults] integerForKey:@"g_timesLost"];
	
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// cocos2d will inherit these values
	[window setUserInteractionEnabled:YES];	
	[window setMultipleTouchEnabled:NO];
	
	// must be called before any othe call to the director
	// WARNING: FastDirector doesn't interact well with UIKit controls
	//	[Director useFastDirector];
	
	// before creating any layer, set the landscape mode
	//[[Director sharedDirector] setDeviceOrientation:CCDeviceOrientationPortrait];
	[[Director sharedDirector] setAnimationInterval:1.0/60];
	[[Director sharedDirector] setDisplayFPS:NO];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
	
	// create an openGL view inside a window
	[[Director sharedDirector] attachInView:window];	
	
		
	// 'layer' is an autorelease object.
	//	TotemWorld *layer = [TotemWorld node];
	[self createEditableCopyOfDatabaseIfNeeded];
	[self initializeDatabase];
	
	//setup Sound
	[self setupSound];
	//Layer *layer = [MenuLayer node];

	[self updateLockedLevelSets];
	//automatically load first level
	[self changeLevel];

}
//database functions

-(void)updateLockedLevelSets {

	Level *level;
	int i = 0;
	for(i=0;i<5;i++) {
		g_lockedLevelSets[i]=0;
	}
	//for(j=0;j<5;j++) {
		for(i=0;i<levels.count;i++) {
			level = (Level *)[levels  objectAtIndex:i];
			if(level.fastest_time > -1) {
				g_lockedLevelSets[(int)(i/10)]++;
			}
		}
//	}
	
}
// Creates a writable copy of the bundled default database in the application Documents directory.
- (void)createEditableCopyOfDatabaseIfNeeded {
    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"levels.sqlite"];
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success) return;
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"levels.sqlite"];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}

// Open the database connection and retrieve minimal information for all objects.
- (void)initializeDatabase {
    NSMutableArray *levelArray = [[NSMutableArray alloc] init];
    self.levels = levelArray;
    [levelArray release];
    // The database is stored in the application bundle. 
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"levels.sqlite"];
    // Open the database. The database was prepared outside the application.
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        // Get the primary key for all books.
        const char *sql = "SELECT pk FROM levels";
        sqlite3_stmt *statement;
        // Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
        // The third parameter is either the length of the SQL string or -1 to read up to the first null terminator. 
		if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
            // We "step" through the results - once for each row.
            while (sqlite3_step(statement) == SQLITE_ROW) {
                // The second parameter indicates the column index into the result set.
                int primaryKey = sqlite3_column_int(statement, 0);
                // We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
                // autorelease is slightly more expensive than release. This design choice has nothing to do with
                // actual memory management - at the end of this block of code, all the book objects allocated
                // here will be in memory regardless of whether we use autorelease or release, because they are
                // retained by the books array.
                Level *td = [[Level alloc] initWithPrimaryKey:primaryKey database:database];
                [levels addObject:td];
                [td release];
            }
        }
        // "Finalize" the statement - releases the resources associated with the statement.
        sqlite3_finalize(statement);
    } else {
        // Even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
        // Additional error handling, as appropriate...
    }
	
}
-(int)totalTime {
	int time=0;
	int i=0;
	Level *level;
	for(i=0;i<levels.count;i++) {
		level = (Level *)[levels  objectAtIndex:i];
		if(level.fastest_time > -1) {
			time+=level.fastest_time;
		}
	}
	return time;
}
-(void)resetData {
	g_CurrentLevel = 1;
	g_totalTimePlayed = 0;
	g_highestLevel=1;
	g_timesWon = g_timesLost = 0;
	
	int i;
	for(i=0;i<8;i++){
		g_achievements[i] = 0;
	}
	Level *level;
	for(i=0;i<levels.count;i++) {
		level = (Level *)[levels  objectAtIndex:i];
		
		level.locked = 1;
		level.fastest_time = -1;
	}
	for(i=0;i<10;i++) {
		//make sure to unlock first level
		level = (Level *)[levels  objectAtIndex:i];
		level.locked =0;
	}
	
}
-(void)unlockAll {
	
	Level *level;
	int i=0;
	for(i=0;i<levels.count;i++) {
		level = (Level *)[levels  objectAtIndex:i];
		
		level.locked = 0;
		level.fastest_time = 10;
	}
	
}
-(void)changeLevel {
	Scene *s2 = [Scene node];
	TotemWorld *node = [TotemWorld node];
	[node extLoadLevel:[NSString stringWithFormat:@"%02i",g_CurrentLevel]];
	
	//create multiplex layer with main game, menu, settings
	MultiplexLayer *layer = [MultiplexLayer layerWithLayers: node,[MenuLayer node],[SettingsLayer node],[AchievementsLayer node], [CreditsLayer node],   nil];
	[s2 addChild: layer];
	
	[window makeKeyAndVisible];	
	//[[Director sharedDirector] runWithScene: [FadeTransition transitionWithDuration:1.0f scene:s2]];
	
	[[Director sharedDirector] runWithScene: s2];
	
}
- (void)applicationWillResignActive:(UIApplication *)application {
	[[Director sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[Director sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[TextureMgr sharedTextureMgr] removeAllTextures];
}
- (void)applicationWillTerminate:(UIApplication *)application {

	// Save data if appropriate
	[levels makeObjectsPerformSelector:@selector(dehydrate)];
	//save current level
	[[NSUserDefaults standardUserDefaults] setInteger:g_CurrentLevel	forKey:@"currentLevel"];
	[[NSUserDefaults standardUserDefaults] setInteger:g_highestLevel	forKey:@"g_highestLevel"];
	[[NSUserDefaults standardUserDefaults] setInteger:g_soundOn	forKey:@"SoundEnabled"];
	[[NSUserDefaults standardUserDefaults] setInteger:g_musicOn	forKey:@"g_musicOn"];
	
	[[NSUserDefaults standardUserDefaults] setInteger:g_totalTimePlayed	forKey:@"g_totalTimePlayed"];
	
	int i=0;
	for(i=0;i<8;i++) {
		
		[[NSUserDefaults standardUserDefaults] setInteger:g_achievements[i]	forKey:[NSString stringWithFormat:@"g_achievements%i", i]];
	}
	[[NSUserDefaults standardUserDefaults] setInteger:g_timesWon	forKey:@"g_timesWon"];
	[[NSUserDefaults standardUserDefaults] setInteger:g_timesLost	forKey:@"g_timesLost"];

	
	[[Director sharedDirector] end];
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[Director sharedDirector] setNextDeltaTimeZero:YES];
}



#pragma mark sound code

//load and buffer the specified sound.  File should preferably be in core-audio format (.caf).  Not sure if other formats work, todo: test.
-(UInt32) getSound:(NSString*)filename{
	NSNumber* retval = [sounds valueForKey:filename];
	if(retval != nil)
		return [retval intValue];
	NSString *fullpath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:filename];
	UInt32 loadedsound;
	SoundEngine_LoadEffect([fullpath UTF8String], &loadedsound);
	[sounds setValue:[NSNumber numberWithInt:loadedsound] forKey:filename];
	NSLog(@"loaded %@", filename);
	return loadedsound;
}

- (void) purgeSounds
{
	NSEnumerator* e = [sounds objectEnumerator];
	NSNumber* snd;
	while((snd = [e nextObject])){
		SoundEngine_UnloadEffect([snd intValue]);
	}
	[sounds removeAllObjects];
}

//play specified file.  File is loaded and buffered as necessary.
-(void) playSound:(NSString*)filename{
	if(!g_soundOn)return;
	if(DEBUG_SOUND_ENABLED)
		SoundEngine_StartEffect([self getSound:filename]);
}

//works with mp3 files.
//works with caf files.
//works with wav files.
//does not work with midi files.
-(void) playMusic:(NSString*)filename{	
	if(!g_musicOn)return;
	NSString *fullpath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:filename];
	SoundEngine_StopBackgroundMusic(FALSE);
	SoundEngine_UnloadBackgroundMusicTrack();
	SoundEngine_LoadBackgroundMusicTrack([fullpath UTF8String], false, false);
	SoundEngine_SetBackgroundMusicVolume(.25);
	SoundEngine_StartBackgroundMusic();
}
-(void) vibrate {
	SoundEngine_Vibrate();
}
-(void) stopMusic {
	SoundEngine_StopBackgroundMusic(FALSE);
	SoundEngine_UnloadBackgroundMusicTrack();
}

-(void) setupSound{
	if(DEBUG_SOUND_ENABLED){
		SoundEngine_Initialize(44100);
		SoundEngine_SetListenerPosition(0.0, 0.0, 1.0);	
	}
}
- (void)dealloc {
	[self purgeSounds];
	[[Director sharedDirector] release];
	[window release];
	[super dealloc];
}

@end
