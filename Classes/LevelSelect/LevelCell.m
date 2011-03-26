//
//  LevelCell.m
//  Level
//
//  Created by Matt Ripston on 9/11/09.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "LevelCell.h"

static UIImage *priority1Image = nil;
static UIImage *priority2Image = nil;
static UIImage *priority3Image = nil;

@interface LevelCell()
- (UILabel *)newLabelWithPrimaryColor:(UIColor *)primaryColor selectedColor:
(UIColor *)selectedColor fontSize:(CGFloat)fontSize bold:(BOOL)bold;
@end

@implementation LevelCell

@synthesize levelTextLabel,levelTimeLabel,levelImageView,levelNameLabel;

+ (void)initialize
{
    // The priority images are cached as part of the class, so they need to be
    // explicitly retained.
    priority1Image = [[UIImage imageNamed:@"red.png"] retain];
    priority2Image = [[UIImage imageNamed:@"yellow.png"] retain];
	priority3Image = [[UIImage imageNamed:@"green.png"] retain];
	
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier])) {
        UIView *myContentView = self.contentView;
        
		self.levelImageView = [[UIImageView alloc] initWithImage:priority1Image];
		[myContentView addSubview:self.levelImageView];
        [self.levelImageView release];
        
        self.levelTextLabel = [self newLabelWithPrimaryColor:[UIColor purpleColor] 
											   selectedColor:[UIColor purpleColor] fontSize:18.0 bold:YES]; 
		self.levelTextLabel.textAlignment = UITextAlignmentLeft; // default
		[myContentView addSubview:self.levelTextLabel];
		[self.levelTextLabel release];
		
        self.levelTimeLabel = [self newLabelWithPrimaryColor:[UIColor purpleColor] 
											   selectedColor:[UIColor purpleColor] fontSize:16.0 bold:YES];
		self.levelTimeLabel.textAlignment = UITextAlignmentLeft;
		[myContentView addSubview:self.levelTimeLabel];
		[self.levelTimeLabel release];
		
		self.levelNameLabel = [self newLabelWithPrimaryColor:[UIColor purpleColor] 
											   selectedColor:[UIColor purpleColor] fontSize:16.0 bold:YES];
		self.levelNameLabel.textAlignment = UITextAlignmentLeft;
		[myContentView addSubview:self.levelNameLabel];
		[self.levelNameLabel release];
        
        // Position the levelPriorityImageView above all of the other views so
        // it's not obscured. It's a transparent image, so any views
        // that overlap it will still be visible.
        [myContentView bringSubviewToFront:self.levelImageView];
    }
    return self;
}

- (Level *)level
{
    return self.level;
}

- (void)setLevel:(Level *)newLevel
{
	
    level = newLevel;
    
    self.levelTextLabel.text = [NSString stringWithFormat:@"%i", newLevel.lvl_num];
	if(level.fastest_time > -1) {
		self.levelTimeLabel.text = [NSString stringWithFormat:@"%02i:%02i",newLevel.fastest_time/60,newLevel.fastest_time%60];
	}else {
		self.levelTimeLabel.text =@"";	
	}
	
	NSString *imageName =  [NSString stringWithFormat:@"lvl%02i.png",level.lvl_num];
	if(level.locked) {
		imageName =  [NSString stringWithFormat:@"lvl%02i_locked.png",level.lvl_num];
	}
	self.levelImageView.image = [[UIImage imageNamed:imageName] retain];
	
	self.levelNameLabel.text = newLevel.lvl_name;
	
    [self setNeedsDisplay];
}



- (void)layoutSubviews {
    
#define FIRST_COLUMN_OFFSET 2
#define FIRST_COLUMN_WIDTH 50
	
#define SECOND_COLUMN_OFFSET 25
#define SECOND_COLUMN_WIDTH 25
	
	
#define THIRD_COLUMN_OFFSET 90
#define THIRD_COLUMN_WIDTH 180
	
#define FOURTH_COLUMN_OFFSET 250
#define FOURTH_COLUMN_WIDTH 40
	
#define UPPER_ROW_TOP 4
    
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
	
    if (!self.editing) {
		
        CGFloat boundsX = contentRect.origin.x;
		CGRect frame;
		/* original
		 
		 // Place the Text label.
		 frame = CGRectMake(boundsX +RIGHT_COLUMN_OFFSET  , UPPER_ROW_TOP, RIGHT_COLUMN_WIDTH, 13);
		 frame.origin.y = 15;
		 self.levelTextLabel.frame = frame;
		 
		 // Place the priority image.
		 UIImageView *imageView = self.levelImageView;
		 frame = [imageView frame];
		 frame.origin.x = boundsX + LEFT_COLUMN_OFFSET;
		 frame.origin.y = 10;
		 imageView.frame = frame;
		 
		 // Place the priority label.
		 CGSize prioritySize = [self.levelTimeLabel.text sizeWithFont:self.levelTimeLabel.font 
		 forWidth:RIGHT_COLUMN_WIDTH lineBreakMode:UILineBreakModeTailTruncation];
		 CGFloat priorityX = frame.origin.x + imageView.frame.size.width + 8.0;
		 frame = CGRectMake(priorityX, UPPER_ROW_TOP, prioritySize.width, prioritySize.height);
		 frame.origin.y = 15;
		 self.levelTimeLabel.frame = frame;
		 */
		
        // Place the Text label.
		frame = CGRectMake(boundsX +FIRST_COLUMN_OFFSET  , UPPER_ROW_TOP, FIRST_COLUMN_WIDTH, 13);
		frame.origin.y = 26;
		self.levelTextLabel.frame = frame;
        
        // Place the priority image.
        UIImageView *imageView = self.levelImageView;
        frame = [imageView frame];
		frame.origin.x = boundsX + SECOND_COLUMN_OFFSET;
		frame.origin.y = 1;
 		imageView.frame = frame;
        
		frame.origin.x = boundsX + THIRD_COLUMN_OFFSET;
		frame.origin.y = 26;
		frame.size.width = THIRD_COLUMN_WIDTH;
		frame.size.height = 20;
		self.levelNameLabel.frame = frame;
		
		frame.origin.x = boundsX + FOURTH_COLUMN_OFFSET;
		frame.origin.y = 25;
		frame.size.width = 100;
		frame.size.height = 13;
		self.levelTimeLabel.frame = frame;
		
        // Place the priority label.
		/*   CGSize timeSize = [self.levelTimeLabel.text sizeWithFont:self.levelTimeLabel.font 
		 forWidth:RIGHT_COLUMN_WIDTH lineBreakMode:UILineBreakModeTailTruncation];
		 CGFloat timeX = frame.origin.x + imageView.frame.size.width + 8.0;
		 frame = CGRectMake(timeX, UPPER_ROW_TOP, timeSize.width, timeSize.height);
		 frame.origin.y = 15;
		 self.levelTimeLabel.frame = frame;*/
		
		
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
	[super setSelected:selected animated:animated];
	
	UIColor *backgroundColor = nil;
	if (selected) {
	    backgroundColor = [UIColor clearColor];
	} else {
		backgroundColor = [UIColor clearColor];
	}
    
	self.levelTextLabel.backgroundColor = backgroundColor;
	self.levelTextLabel.highlighted = selected;
	self.levelTextLabel.opaque = !selected;
	
	self.levelTimeLabel.backgroundColor = backgroundColor;
	self.levelTimeLabel.highlighted = selected;
	self.levelTimeLabel.opaque = !selected;
	
	self.levelNameLabel.backgroundColor = backgroundColor;
	self.levelNameLabel.highlighted = selected;
	self.levelNameLabel.opaque = !selected;
}


- (UILabel *)newLabelWithPrimaryColor:(UIColor *)primaryColor 
						selectedColor:(UIColor *)selectedColor fontSize:(CGFloat)fontSize bold:(BOOL)bold
{
	
    UIFont *font;
    if (bold) {
        font = [UIFont boldSystemFontOfSize:fontSize];
    } else {
        font = [UIFont systemFontOfSize:fontSize];
    }
    
	UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	newLabel.backgroundColor = [UIColor clearColor];
	newLabel.opaque = YES;
	newLabel.textColor = primaryColor;
	newLabel.highlightedTextColor = selectedColor;
	newLabel.font = font;
	
	return newLabel;
}

- (UIImage *)imageForPriority:(NSInteger)priority
{
	switch (priority) {
		case 1:
			return priority1Image;
			break;
		default:
			return priority3Image;
			break;
	}
	return nil;
}


- (void)dealloc {
	[super dealloc];
}


@end
