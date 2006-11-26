//
//  ELSplitView.m
//  GuidaTV
//
//  Created by delphine on 08-10-2006.
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


#import "ELSplitView.h"

@implementation ELSplitView

- (void)awakeFromNib
{
	grip = [[NSImage imageNamed:@"splitview-grip"] retain];
	[grip setFlipped:YES];
	bar = [[NSImage imageNamed:@"splitview-bar"] retain];
	[bar setFlipped:YES];
}

- (void)dealloc
{
	[grip release];
	[bar release];
	[super dealloc];
}

- (float)dividerThickness
{
	return 9.0;
}

- (void)drawDividerInRect:(NSRect)aRect
{
	// Draw background
	[[NSColor controlShadowColor] set];
	[NSBezierPath fillRect:aRect];

	// Draw bar and grip onto the canvas
	NSRect canvasRect = NSMakeRect(0,
								   0,
								   aRect.size.width,
								   aRect.size.height - 1);
	NSRect targetRect = NSMakeRect(aRect.origin.x,
								   aRect.origin.y,
								   aRect.size.width,
								   aRect.size.height - 1);
	
	// Create a canvas
	NSImage *canvas = [[[NSImage alloc] initWithSize:canvasRect.size] autorelease];

	NSRect gripRect = canvasRect;
	gripRect.origin.x = (NSMidX(canvasRect) - ([grip size].width/2));
	[canvas lockFocus];
	[bar setSize:canvasRect.size];
	[bar drawInRect:canvasRect fromRect:canvasRect operation:NSCompositeSourceOver fraction:1.0];
	[grip drawInRect:gripRect fromRect:canvasRect operation:NSCompositeSourceOver fraction:1.0];
	[canvas unlockFocus];
	
	// Draw canvas to divider bar
	[self lockFocus];
	[canvas drawInRect:targetRect fromRect:canvasRect operation:NSCompositeSourceOver fraction:1.0];
	[self unlockFocus];
	
}

@end
