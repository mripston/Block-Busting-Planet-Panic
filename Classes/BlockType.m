//
//  BlockType.m
//  totem
//
//  Created by Matt Ripston on 9/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "chipmunk.h"
#import "BlockType.h"


@implementation BlockType
@synthesize type;
@synthesize  ready;

-(void) resetPosition
{
	cpBody *body = self.userData;
	

	body->p = cpv(200,300);
	body->v = cpv(0,0);
	
}


@end
