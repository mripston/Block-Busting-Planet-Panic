//
//  main.m
//  totem
//
//  Created by Matt Ripston on 9/2/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	int retVal = UIApplicationMain(argc, argv, nil, @"totemAppDelegate");
	[pool release];
	return retVal;
}
