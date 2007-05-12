//
//  ProgramsPrintView.m
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


#import "ProgramsPrintView.h"
#import "TVProgram.h"

#define VSPACE 28.0
#define PADDING 2.0
#define HSPACE 10.0
#define GENRE_WIDTH 100.0
#define ICON_WIDTH 24.0

@implementation ProgramsPrintView

- (BOOL)knowsPageRange:(NSRange *)r
{
	int progsPerPage = [self programsPerPage];
	
	r->location = 1;
	r->length = ([programs count] / progsPerPage);
	if ([programs count] % progsPerPage > 0)
	{
		r->length++;
	}
	return YES;
}

- (NSRect)rectForPage:(int)page
{
	NSRect result;
	result.size = paperSize;
	result.origin.y = (page - 1) *  paperSize.height;
	result.origin.x = 0.0;
	return result;
}

- (void)drawRect:(NSRect)rect {
    int count, i;
	count = [programs count];
	for (i = 0; i < count; i++)
	{
		NSRect lineRect = [self rectForProgram:i];
		if (NSIntersectsRect(rect, lineRect))
		{
			// Fill alternate background of cell if needed
			if (i % 2 != 0)
			{
				NSRect altRect = lineRect;
				altRect.origin.x += ICON_WIDTH + PADDING;
				altRect.size.width -= ICON_WIDTH - PADDING;
			
				[[NSGraphicsContext currentContext] saveGraphicsState]; {
					[[NSColor colorWithDeviceWhite:0.95 alpha:1.0] set];
					[NSBezierPath fillRect:altRect];
				} [[NSGraphicsContext currentContext] restoreGraphicsState];
			}
			
			// Get current program to draw
			TVProgram *prog = [programs objectAtIndex:i];
			
			// Icon, on the left
			NSImage *chanImg = [[prog channelImg] copy];
			[chanImg setFlipped:YES];
			NSRect srcRect = NSMakeRect(0.0,
										0.0,
										[chanImg size].width,
										[chanImg size].height);
			NSRect iconRect = NSMakeRect(lineRect.origin.x + PADDING,
										 lineRect.origin.y + (lineRect.size.height - ICON_WIDTH) / 2,
										 ICON_WIDTH,
										 ICON_WIDTH);
			[chanImg drawInRect:iconRect
					   fromRect:srcRect
					  operation:NSCompositeSourceOver
					   fraction:1.0];
			
			// Title, on the upper left
			NSRect titleRect = NSMakeRect(lineRect.origin.x + ICON_WIDTH + PADDING + HSPACE,
										  lineRect.origin.y,
										  lineRect.size.width - ICON_WIDTH,
										  0.5 * lineRect.size.height);
			[[prog title] drawInRect:titleRect
					  withAttributes:titleAttributes];
			
			// Date, on the upper right
			NSRect dateRect = NSMakeRect(lineRect.origin.x + lineRect.size.width - GENRE_WIDTH,
										 lineRect.origin.y,
										 GENRE_WIDTH,
										 lineRect.size.height);
			/*			[[[prog date] descriptionWithCalendarFormat:@"%A %e %B %Y %H:%M"
locale:[NSLocale currentLocale]] drawInRect:dateRect
withAttributes:dateAttributes];		
*/
			[[[prog startDate] descriptionWithCalendarFormat:@"%d/%m/%Y %H:%M"] drawInRect:dateRect
																			withAttributes:dateAttributes];
			// Channel, on the lower left
			NSRect channelRect = NSMakeRect(lineRect.origin.x + ICON_WIDTH + PADDING + HSPACE,
											lineRect.origin.y + 0.5 * lineRect.size.height,
											lineRect.size.width - ICON_WIDTH,
											lineRect.size.height);
			[[prog channelName] drawInRect:channelRect
							withAttributes:genreAttributes];
			
			// Genre, on the lower right
			NSRect genreRect = NSMakeRect(lineRect.origin.x + lineRect.size.width - GENRE_WIDTH,
										  lineRect.origin.y + 0.5 * lineRect.size.height,
										  GENRE_WIDTH,
										  lineRect.size.height);
			[[prog genre] drawInRect:genreRect
					  withAttributes:genreAttributes];
			
			[chanImg release];
		}
	}
}

- (id)initWithPrograms:(NSArray *)progs printInfo:(NSPrintInfo *)pInfo
{
	NSRange pageRange;
	NSRect frame;
	
	paperSize = [pInfo paperSize];
	leftMargin = [pInfo leftMargin];
	topMargin = [pInfo topMargin];
	
	programs = [progs retain];
	
	//Get number of pages
	[self knowsPageRange:&pageRange];
	
	//Make the view big enough to hold first and last page
	frame = NSUnionRect([self rectForPage:pageRange.location],
						[self rectForPage:NSMaxRange(pageRange) - 1]);
	
	//Call superclass' designated initializer
	self = [super initWithFrame:frame];
	
	//Get attributes to be printed
	titleAttributes = [[NSMutableDictionary alloc] init];
	[titleAttributes setObject:[NSFont fontWithName:@"Lucida Grande"
											   size:11.0]
						forKey:NSFontAttributeName];
	dateAttributes = [[NSMutableDictionary alloc] init];
	[dateAttributes setObject:[NSFont fontWithName:@"Lucida Grande"
											  size:9.0]
					   forKey:NSFontAttributeName];
	genreAttributes = [[NSMutableDictionary alloc] init];
	[genreAttributes setObject:[NSFont fontWithName:@"Lucida Grande"
											   size:9.0]
						forKey:NSFontAttributeName];
	return self;
}
- (NSRect)rectForProgram:(int)i
{
	NSRect result;
	int programsPerPage = [self programsPerPage];
	result.size.height = VSPACE;
	result.size.width = paperSize.width - (2 * leftMargin);
	result.origin.x = leftMargin;
	int page = i / programsPerPage;
	int indexOnPage = i % programsPerPage;
	result.origin.y = (page * paperSize.height) + 
		topMargin + (indexOnPage * VSPACE);
	
	return result;
}
- (int)programsPerPage
{
	float ppp = (paperSize.height - (2.0 * topMargin)) / VSPACE;
	return (int)ppp;
}

- (BOOL)isFlipped
{
	// We want the origin to be in the upper left corner
	return YES;
}

- (void)dealloc
{
	[titleAttributes release];
	[dateAttributes release];
	[genreAttributes release];
	[programs release];
	[super dealloc];
}

@end
