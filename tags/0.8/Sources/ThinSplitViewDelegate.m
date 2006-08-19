//
//  ThinSplitViewDelegate.m
//  GuidaTV
//
//  Created by delphine on 15-08-2006.
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
// Based on RBSplitView by Rainer Brockerhoff
// <http://www.brockerhoff.net/src/rbs.html>
//

#import "ThinSplitViewDelegate.h"

@implementation ThinSplitViewDelegate

// This makes it possible to drag the first divider around by the dragView.
- (unsigned int)splitView:(RBSplitView*)sender dividerForPoint:(NSPoint)point inSubview:(RBSplitSubview*)subview {
	if (subview==firstSplit) {
		if ([dragView mouse:[dragView convertPoint:point fromView:sender] inRect:[dragView bounds]]) {
			return 0;	// [firstSplit position], which we assume to be zero
		}
	}
	return NSNotFound;
}

// This changes the cursor when it's over the dragView.
- (NSRect)splitView:(RBSplitView*)sender cursorRect:(NSRect)rect forDivider:(unsigned int)divider {
	if (divider==0) {
		[sender addCursorRect:[dragView convertRect:[dragView bounds] toView:sender] cursor:[RBSplitView cursor:RBSVVerticalCursor]];
	}
	return rect;
}

- (NSRect)splitView:(RBSplitView*)sender willDrawDividerInRect:(NSRect)dividerRect betweenView:(RBSplitSubview*)leading andView:(RBSplitSubview*)trailing withProposedRect:(NSRect)imageRect
{
	// Let's draw the background of the divider ourselves
	[sender lockFocus];
	[[NSColor controlShadowColor] set];
	[NSBezierPath fillRect:dividerRect];
	[sender unlockFocus];
}

@end
