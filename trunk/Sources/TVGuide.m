//
//  TVGuide.m
//  GuidaTV
//
//  Created by delphine on 9-06-2006.
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


#import "TVGuide.h"

TVGuide *tvGuideSharedInstance;

@class TVProgram;

@implementation TVGuide

+ (id)sharedInstance
{
	if (tvGuideSharedInstance == nil)
	{
		tvGuideSharedInstance = [[TVGuide alloc] init];
	}
	return tvGuideSharedInstance;
}

- (id)init
{
	[super init];
	if (self != nil)
	{
		// Init genres dictionary
		NSString *genresPath = [[NSBundle mainBundle] pathForResource:@"Genres" ofType:@"plist"];
		genresList = [[NSDictionary dictionaryWithContentsOfFile:genresPath] retain];

		// Init channels dictionary
		NSString *channelsPath = [[NSBundle mainBundle] pathForResource:@"Channels" ofType:@"plist"];
		channelsList = [[NSDictionary dictionaryWithContentsOfFile:channelsPath] retain];
	}
	return self;
}

- (void)awakeFromNib
{
	if (!tvGuideSharedInstance)
	{
		tvGuideSharedInstance = self;
	}
	[self loadDataFromDisk];
}

-(void)dealloc
{
	[self setGuide:nil];
	[self setDay:nil hour:nil source:nil];
	[self setPrograms:nil];
	[channelsList release];
	[genresList release];
	[super dealloc];
}

#pragma mark === Accessor Methods ===

- (void)setGuide:(NSArray *)g
{
	[g retain];
	[guide release];
	guide = g;
}

- (NSArray *)guide
{
	return guide;
}

- (void)setPrograms:(NSArray *)p
{
	[p retain];
	[programs release];
	programs = p;
}

- (NSArray *)programs
{
	return programs;
}

#pragma mark === Lookup Methods ===

- (NSString *)nameForGenre:(int)genre
{
	return [genresList objectForKey:[[NSNumber numberWithInt:genre] stringValue]];
}

- (NSString *)nameForChannel:(int)channel
{
	return [channelsList objectForKey:[[NSNumber numberWithInt:channel] stringValue]];
}

- (NSDictionary *)channelsList
{
	return channelsList;
}

- (NSDictionary *)genresList
{
	return genresList;
}

- (void)setDay:(NSString *)d hour:(NSString *)h source:(NSString *)s
{
	[d retain];
	[day release];
	day = d;

	[h retain];
	[hour release];
	hour = h;

	[s retain];
	[source release];
	source = s;
}

#pragma mark === Persistence Methods ===

- (void)loadDataFromDisk
{
	NSString *guidepath = [self pathForDataFile];
	NSMutableDictionary *g = [NSKeyedUnarchiver unarchiveObjectWithFile:guidepath];
	if (g != nil)
	{
		[self setGuide:g];
	}
	else
	{
		[self setGuide:[NSMutableDictionary dictionary]];
	}
}

- (void)saveDataToDisk
{
	int i;
	BOOL result;
	TVProgram *program;
	NSString *programPath;
	NSMutableArray *paths = [NSMutableArray arrayWithCapacity:[programs count]];
	for (i = 0; i < [programs count]; i++)
	{
		program = [programs objectAtIndex:i];
		programPath = [self pathForProgram:program];

		[paths addObject:programPath];

		result = [NSKeyedArchiver archiveRootObject:program
											 toFile:programPath];
	}

	[guide setValue:paths
			 forKey:[NSString stringWithFormat:@"%@-%@-%@", day, hour, source]];

	[NSKeyedArchiver archiveRootObject:guide
								toFile:[self pathForDataFile]];
}

- (void)saveProgram:(TVProgram *)prog
{
	NSString *programPath = [self pathForProgram:prog];

	BOOL result = [NSKeyedArchiver archiveRootObject:prog
											  toFile:programPath];
}

- (NSString *)pathForProgram:(TVProgram *)prog
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
    
	NSString *folder = [@"~/Library/Application Support/Guida TV" stringByExpandingTildeInPath];

	NSCalendarDate *date = [prog startDate];
	NSArray *path = [NSArray arrayWithObjects:@"Archive",
		[date descriptionWithCalendarFormat:@"%Y"],
		[date descriptionWithCalendarFormat:@"%m"],
		[date descriptionWithCalendarFormat:@"%d"],
		nil];
	
	int i;
	for (i = 0; i < [path count]; i++)
	{
		folder = [folder stringByAppendingPathComponent:[path objectAtIndex:i]];
		if ([fileManager fileExistsAtPath: folder] == NO)
		{
			[fileManager createDirectoryAtPath: folder attributes: nil];
		}
	}
	
	NSString *fileName = [NSString stringWithFormat:@"%@.tvprogram",
		[prog progid]];
	return [folder stringByAppendingPathComponent: fileName];
}

- (NSString *) pathForDataFile
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
    
	NSString *folder = @"~/Library/Application Support/Guida TV/";
	folder = [folder stringByExpandingTildeInPath];
	
	if ([fileManager fileExistsAtPath: folder] == NO)
	{
		[fileManager createDirectoryAtPath: folder attributes: nil];
	}
    
	NSString *fileName = @"Guide.tvguide";
	return [folder stringByAppendingPathComponent: fileName];
}

- (NSArray *)programsForSource:(NSString *)source timeslot:(NSCalendarDate *)timeslot
{
	return nil;
}

#pragma mark === TVConsumer protocol ===

- (void)programsDidBecomeAvailable:(NSArray *)programs
{
	// Store programs
	[self setPrograms:programs];
	// Save guide & program to disk
	[self saveDataToDisk];
	// Dispatch programs to the next consumer
	if (consumer != nil)
	{
		[consumer programsDidBecomeAvailable:programs];		
	}
}

- (void)setConsumer:(id)sender
{
	if ([sender conformsToProtocol:@protocol(TVConsumer)])
	{
		if (sender != consumer)
		{
			[consumer release];
			consumer = sender;
		}
	}
}

- (void)fetchProgramsForDay:(NSString *)d hour:(NSString *)h source:(NSString *)s
{
	[self fetchProgramsForDay:d
						 hour:h
					   source:s
				  forceReload:NO];
}

- (void)fetchProgramsForDay:(NSString *)d hour:(NSString *)h source:(NSString *)s forceReload:(BOOL)force
{
	[self setDay:d hour:h source:s];
	NSArray *paths = [guide valueForKey:[NSString stringWithFormat:@"%@-%@-%@", d, h, s]];
	if ((paths == nil) || force)
	{
		[tuner setConsumer:self];
		[tuner fetchProgramsForDay:d
							  hour:h
							source:s];
	}
	else
	{
		// Recupero i programmi dal disco
		int i, len = [paths count];
		NSMutableArray *p = [NSMutableArray arrayWithCapacity:len];
		for (i = 0; i < len; i++)
		{
			TVProgram *pr = [NSKeyedUnarchiver unarchiveObjectWithFile:[paths objectAtIndex:i]];
			[p insertObject:pr
					atIndex:i];
		}
		if (consumer != nil)
		{
			[consumer programsDidBecomeAvailable:p];
		}		
	}	
}

- (void)fetchProgramsForDate:(NSCalendarDate *)date source:(TVTuner *)tuner
{
	[self fetchProgramsForDate:date
						source:tuner
				   forceReload:NO];
}

- (void)fetchProgramsForDate:(NSCalendarDate *)date source:(TVTuner *)tuner forceReload:(BOOL)force
{
	// Not implemented
}

@end
