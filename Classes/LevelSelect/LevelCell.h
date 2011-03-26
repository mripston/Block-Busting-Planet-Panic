//
//  LevelCell.h
//  level
//
//  Created by Matt Ripston on 9/11/09.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Level.h"

@interface LevelCell : UITableViewCell {
	Level        *level;
    UILabel     *levelTextLabel;
    UILabel     *levelTimeLabel;
    UILabel     *levelNameLabel;
    UIImageView *levelImageView;
}

@property (nonatomic, retain) UILabel     *levelTextLabel;
@property (nonatomic, retain) UILabel     *levelTimeLabel;
@property (nonatomic, retain) UILabel     *levelNameLabel;
@property (nonatomic, retain) UIImageView *levelImageView;

- (UIImage *)imageForPriority:(NSInteger)priority;

- (Level *)level;
- (void)setLevel:(Level *)newLevel;

@end
