//
//  FlatColorView.m
//  GuidaTV
//
//  Created by delphine on 26-11-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//  http://www.emeraldion.it
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// Bug fixes, suggestions and comments should be sent to:
// claudio@emeraldion.it
//


#import "FlatColorView.h"


@implementation FlatColorView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBgColor:[NSColor whiteColor]];
    }
    return self;
}

- (void)awakeFromNib
{
	[self setBgColor:[NSColor whiteColor]];
}

- (void)drawRect:(NSRect)rect {

	[bgColor set];
	NSRectFill(rect);
}

- (NSColor *)bgColor
{
	return bgColor;
}
- (void)setBgColor:(NSColor *)col
{
	[col retain];
	[bgColor release];
	bgColor = col;
}

@end
