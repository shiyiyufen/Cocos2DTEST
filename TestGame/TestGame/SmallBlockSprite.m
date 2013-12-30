//
//  SmallBlockSprite.m
//  CatNap
//
//  Created by Ray Wenderlich on 4/8/11.
//  Copyright 2011 Ray Wenderlich. All rights reserved.
//

#import "SmallBlockSprite.h"

@implementation SmallBlockSprite

- (id)initWithSpace:(cpSpace *)theSpace location:(CGPoint)location {
    if ((self = [super initWithSpace:theSpace location:location spriteFrameName:@"00.png"])) {
    }
    return self;
}

@end