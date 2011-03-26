//
//  Level.m
//  level
//
//  Created by Matt Ripston on 9/11/09.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Level.h"

static sqlite3_stmt *init_statement = nil;
static sqlite3_stmt *dehydrate_statment = nil;

@implementation Level
@synthesize primaryKey,lvl_num,lvl_locked,lvl_unlocked,locked,fastest_time,lvl_name;

- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db {
	
	if ((self = [super init])) {
        primaryKey = pk;
        database = db;
        // Compile the query for retrieving book data. See insertNewBookIntoDatabase: for more detail.
        if (init_statement == nil) {
            // Note the '?' at the end of the query. This is a parameter which can be replaced by a bound variable.
            // This is a great way to optimize because frequently used queries can be compiled once, then with each
            // use new variable values can be bound to placeholders.
            const char *sql = "SELECT level_num,locked,lvl_locked,lvl_unlocked,fastest_time,name FROM levels WHERE pk=?";
            if (sqlite3_prepare_v2(database, sql, -1, &init_statement, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            }
        }
        // For this query, we bind the primary key to the first (and only) placeholder in the statement.
        // Note that the parameters are numbered from 1, not from 0.
        sqlite3_bind_int(init_statement, 1, primaryKey);
        if (sqlite3_step(init_statement) == SQLITE_ROW) {
			self.lvl_num = sqlite3_column_int(init_statement,0);
			self.locked = sqlite3_column_int(init_statement,1);			
            self.lvl_locked = [NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 2)];
            self.lvl_unlocked = [NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 3)];
			self.fastest_time = sqlite3_column_int(init_statement,4);
            self.lvl_name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 5)];
        } else {
            self.lvl_locked = @"Nothing";
			self.lvl_num = 0;
        }
        // Reset the statement for future reuse.
        sqlite3_reset(init_statement);
    }
    return self;
}


- (void)updateLocked:(NSInteger)newLocked {
	self.locked	= newLocked;
	dirty = YES;
}

- (void)updateTime:(NSInteger)newTime {
	self.fastest_time	= newTime;
	dirty = YES;
}

- (void) dehydrate {
	//if(dirty) {
		
		if (dehydrate_statment == nil) {
			const char *sql = "UPDATE levels SET locked = ?,fastest_time = ? WHERE pk=?";
			if (sqlite3_prepare_v2(database, sql, -1, &dehydrate_statment, NULL) != SQLITE_OK) {
				NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
			}
		}
		
		sqlite3_bind_int(dehydrate_statment, 3, self.primaryKey);
		sqlite3_bind_int(dehydrate_statment, 2, self.fastest_time);
		sqlite3_bind_int(dehydrate_statment, 1, self.locked);
		int success = sqlite3_step(dehydrate_statment);
		
		if (success != SQLITE_DONE) {
			NSAssert1(0, @"Error: failed to save priority with message '%s'.", sqlite3_errmsg(database));
		}
		
		sqlite3_reset(dehydrate_statment);
		dirty = NO;
//	}
	
}

@end
