//
//  NSArray+TVUtils.m
//  GuidaTV
//
//  Created by delphine on 28-06-2006.
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

#import "NSArray+TVUtils.h"
#import "TVProgram.h"

@implementation NSArray (TVUtils)

// Creates a string by collapsing all elements and prepending a custom header
- (NSString *)stringByFormattingAsProgramsList
{
	NSMutableString *list = [NSMutableString stringWithFormat:@"# Programs list exported on %@ by\n# GuidaTV <http://www.emeraldion.it/software/macosx/guidatv/>\n\n",
		[NSCalendarDate calendarDate]];
	
	[list appendFormat:@"%@  %@  %@  %@\n",
		[NSLocalizedString(@"Date",@"Date") stringByPaddingToLength:16
														 withString:@" "
													startingAtIndex:0],
		[NSLocalizedString(@"Channel",@"Channel") stringByPaddingToLength:20
															   withString:@" "
														  startingAtIndex:0],
		[NSLocalizedString(@"Title",@"Title") stringByPaddingToLength:TVProgramMaxTitleLength
														   withString:@" "
													  startingAtIndex:0],
		NSLocalizedString(@"Genre",@"Genre")];
	[list appendFormat:@"%@  %@  %@  %@\n",
		[@"" stringByPaddingToLength:16
						  withString:@"-"
					 startingAtIndex:0],
		[@"" stringByPaddingToLength:20
						  withString:@"-"
					 startingAtIndex:0],
		[@"" stringByPaddingToLength:TVProgramMaxTitleLength
						  withString:@"-"
					 startingAtIndex:0],
		[@"" stringByPaddingToLength:10
						  withString:@"-"
					 startingAtIndex:0]];
	[list appendString:[self componentsJoinedByString:@"\n"]];
	return list;
}

// Fills the receiver with a list of dates centered in date and length 2 * days + 1
+ (id)arrayCenteredInDate:(NSCalendarDate *)date range:(int)days
{
	int d;
	NSMutableArray *dArr = [NSMutableArray arrayWithCapacity:2 * days + 1];
	for (d = -days; d < days + 1; d++)
	{
		[dArr insertObject:[[date dateByAddingYears:0
											 months:0
											   days:d
											  hours:0
											minutes:0
											seconds:0] descriptionWithCalendarFormat:@"%d/%m/%Y"]
				   atIndex:(days + d)];
	}
	return [dArr autorelease];
}

@end
