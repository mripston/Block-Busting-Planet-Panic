//
//  BlockType.h
//  totem
//
//  Created by Matt Ripston on 9/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BlockType : Sprite {
	int type;
	bool ready;

}
@property (readwrite) int type;
@property(readwrite) bool ready;
-(void) resetPosition;

@end
