//
//  LevelSelectViewController.m
//  level
//
//  Created by Matt Ripston on 9/11/09.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "LevelSelectViewController.h"
#import "totemAppDelegate.h"
#import "Level.h"
#import "LevelCell.h"
#import "TotemWorldScene.h"
#import "MenuLayer.h"
#import "SettingsLayer.h"
#import "AchievementsLayer.h"
#import	"CreditsLayer.h"

#define SectionHeaderHeight 40

@implementation LevelSelectViewController


- (void)viewDidLoad {
	self.view.backgroundColor = [UIColor clearColor];
	totemAppDelegate *appDelegate = (totemAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate updateLockedLevelSets];
	// Add the following line if you want the list to be editable
	// self.navigationItem.leftBarButtonItem = self.editButtonItem;
	//CGRect sectionRect = [self.tableView rectForSection:(g_CurrentLevel-1)/10];
	//[self. tableView scrollRectToVisible:sectionRect animated:YES];

	//	[self.tableView selectRowAtIndexPath:(NSIndexPath *)g_CurrentLevel-1 animated:NO	scrollPosition:UITableViewScrollPositionMiddle];
}


/*- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
 
 return 1;
 }
 */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	//	totemAppDelegate *appDelegate = (totemAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (section == 0) return 10;
	if (section == 1) return 10;
	if (section == 2) return 10;
	if (section == 3) return 10;
	if (section == 4) return 10;
	
	else return 0;
	
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *MyIdentifier = @"MyIdentifier";
	
	LevelCell *cell = (LevelCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		cell = [[[LevelCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
	}
	
	totemAppDelegate *appDelegate = (totemAppDelegate *)[[UIApplication sharedApplication] delegate];
	Level *td = [appDelegate.levels objectAtIndex:indexPath.section *10 +indexPath.row];
	
	[cell setLevel:td];
	
	//set background to transparent image
	cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"lvlselectbkg.png"]];
//	cell.backgroundColor = [UIColor blueColor];
	if(td.locked) {
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	// Set up the cell
	return cell;
}

-(void)changeLevel:(NSString *)lev {
	Scene *s2 = [Scene node];
	TotemWorld *node = [TotemWorld node];
	[node extLoadLevel:lev];
	
	//node.level =   newlevel;
	MultiplexLayer *layer = [MultiplexLayer layerWithLayers: node,[MenuLayer node],[SettingsLayer node] ,[AchievementsLayer node], [CreditsLayer node], nil];
	
	[s2 addChild: layer];
	
	[[Director sharedDirector] replaceScene: [FadeTransition transitionWithDuration:0.0f scene:s2]];
	
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// Navigation logic
	totemAppDelegate *appDelegate = (totemAppDelegate *)[[UIApplication sharedApplication] delegate];
	Level *level = (Level *)[appDelegate.levels objectAtIndex:indexPath.section *10 +indexPath.row];
	 if(!level.locked){
		 [tableView deselectRowAtIndexPath:indexPath animated:YES];
	
		 [self changeLevel:[NSString stringWithFormat:@"%02i",level.lvl_num]];
	
	//[self release];
//	[self removeChildByTag:101 cleanup:NO];
	//[self.navigationController popToRootViewControllerAnimated:TRUE];
	//[self release];
	
		 [[[[UIApplication sharedApplication] keyWindow] viewWithTag:100] removeFromSuperview]; 
	 }
	
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 5;
}
- (NSString *)tableView:(UITableView *)tv titleForHeaderInSection:(NSInteger)section {
	NSString *text = @"";
	if(g_lockedLevelSets[section] < 8) {
		text = [NSString stringWithFormat:@"Finish %i more to unlock next set",8-g_lockedLevelSets[section]];
	}
	/*if(g_lockedLevelSets[section] == 0 ) {
	 
	 text = @"Set locked";	
	 }*/
	else {
		
		text = [NSString stringWithFormat:@"Finished %i/10",g_lockedLevelSets[section]];
	}
	if(section==4) {
		text = [NSString stringWithFormat:@"Finished %i/10",g_lockedLevelSets[section]];
	}
	return text;
}

/*
 Override if you support editing the list
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
 }	
 if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }	
 }
 */


/*
 Override if you support conditional editing of the list
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 Override if you support rearranging the list
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 Override if you support conditional rearranging of the list
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */ 


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self tableView:tableView titleForHeaderInSection:section] != nil) {
        return SectionHeaderHeight;
    }
    else {
        // If no section header title, no section header needed
        return 0;
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
	
    // Create label with section title
    UILabel *label = [[[UILabel alloc] init] autorelease];
    label.frame = CGRectMake(20, 6, 300, 30);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.shadowColor = [UIColor colorWithRed:(192.0/255.0) green:0 blue:1 alpha:1];
    label.shadowOffset = CGSizeMake(2.0, 2.0);
    label.font = [UIFont boldSystemFontOfSize:16];
    label.text = sectionTitle;
	//ccc3( 192,0,255)
    // Create header view and add label as a subview
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, SectionHeaderHeight)];
    [view autorelease];
    [view addSubview:label];
	
    return view;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	int section = (g_CurrentLevel-1)/10;
	int row = (g_CurrentLevel-1)%10;
	NSIndexPath *rowPath = [NSIndexPath indexPathForRow:row inSection:section];
	[self.tableView scrollToRowAtIndexPath:rowPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
	
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
}

- (void)viewDidDisappear:(BOOL)animated {
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[super dealloc];
}


@end

