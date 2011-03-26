//
//  Level.h
//  level
//
//  Created by Matt Ripston on 9/11/09.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface Level : NSObject {
	sqlite3   *database;
	NSString  *lvl_locked;
	NSString *lvl_unlocked;
	NSInteger fastest_time;
	NSInteger lvl_num;
	NSString *lvl_name;
	bool locked;
	NSInteger primaryKey;
	BOOL dirty;
}

@property (assign, nonatomic, readonly) NSInteger primaryKey;
@property (nonatomic, retain) NSString *lvl_locked;
@property (nonatomic, retain) NSString *lvl_unlocked;
@property (nonatomic, retain) NSString *lvl_name;
@property (nonatomic) NSInteger fastest_time;
@property (nonatomic) NSInteger lvl_num;
@property (nonatomic) bool locked;

- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db;
- (void)updateLocked:(NSInteger) newLocked;
- (void)updateTime:(NSInteger)newTime ;
- (void)dehydrate;


@end
