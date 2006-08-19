//
//  SourcesTableDelegate.m
//  GuidaTV
//
//  Created by delphine on 19-08-2006.
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

#import "SourcesTableDelegate.h"


@implementation SourcesTableDelegate

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
	NSColor *fontColor;
	NSColor *shadowColor;
	if ([[tableView selectedRowIndexes] containsIndex:row] && ([tableView editedRow] != row))
	{
		
		fontColor = [NSColor whiteColor];
		shadowColor = [NSColor colorWithDeviceRed:(127.0/255.0) green:(140.0/255.0) blue:(160.0/255.0) alpha:1.0];
	}
	else
	{
		fontColor = [NSColor blackColor];
		shadowColor = nil;
	}
	[cell setTextColor:fontColor];
	NSShadow *shadow = [[NSShadow alloc] init];
	NSSize shadowOffset = { width: 1.0, height: -1.5};
	[shadow setShadowOffset:shadowOffset];
	[shadow setShadowColor:shadowColor];
	[shadow set];	
}

@end
