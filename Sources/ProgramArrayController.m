//
//  ProgramArrayController.m
//  GuidaTV
//
//  Created by delphine on 17-06-2006.
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

#import "ProgramArrayController.h"

@implementation ProgramArrayController

- (NSArray *)arrangeObjects:(NSArray *)objects {
    
    if (searchString == nil ||
		searchString == @"") {
        return [super arrangeObjects:objects];   
    }
    
    NSMutableArray *filteredObjects = [NSMutableArray arrayWithCapacity:[objects count]];
    NSEnumerator *objectsEnumerator = [objects objectEnumerator];
    id item;
    
    while (item = [objectsEnumerator nextObject]) {
        if ([[item valueForKeyPath:@"title"] rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [filteredObjects addObject:item];
        }
    }
    return [super arrangeObjects:filteredObjects];
}

- (NSString *)searchString
{
	return searchString;
}

- (void)setSearchString:(NSString *)sString
{
    [searchString release];
	
    if ([sString length] == 0)
	{
        searchString = nil;
    }
	else
	{
        searchString = [sString copy];
    }
}

- (IBAction)filter:(id)sender
{
	[self setSearchString: [sender stringValue]];
    [self rearrangeObjects];
}


@end
