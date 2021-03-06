//
//  TVTuner.m
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

#define TUNE_IN_BACKGROUND 1

#import "TVTuner.h"
#import "TVProgram.h"
#import "NSString+TVUtils.h"
#import <CURLHandle/CURLHandle.h>
#import <CURLHandle/CURLHandle+extras.h>
#import <AGRegex/AGRegex.h>

static NSString *RESULTS_START = @"<!-- RISULTATO -->";
static NSString *RESULTS_END = @"<!-- /RISULTATO -->";
//static NSString *RESULTS_SEPARATOR = @"<!-- /RISULTATO -->\n\n\t\t\t\t  \n\t\t\n\t\t\t\t   \t\n\t\t\n\t\t\t\t   \t\n\n\n<!-- RISULTATO -->";
static NSString *ONAIR_MARKER = @"-in-onda";

NSString *TVTunerTerrestrial = @"1";
NSString *TVTunerSatellite = @"2";

extern NSString *TVSourcesKey;

extern int TVTerrestrialSource;
extern int TVSatelliteSource;

@protocol TVConsumer;

@implementation TVTuner

- (void)dealloc
{
	[super dealloc];
}

- (void) awakeFromNib
{
	_wait = NO;
	[progress setIndeterminate:YES];
}

- (NSString *)status
{
	return status;
}

- (void)setPrograms:(NSMutableArray *)progs
{
	[progs retain];
	[programs release];
	programs = progs;
}

- (void)setStatus:(NSString *)s
{
	[s retain];
	[status release];
	status = s;
}

- (void)setDay:(NSString *)d
{
	[d retain];
	[day release];
	day = d;
}
- (NSString *)day
{
	return day;
}

- (NSString *)label
{
	return label;
}
- (NSImage *)icon
{
	return icon;
}

#pragma mark === TVTuner methods ===

- (void)fetchPrograms
{
	[self fetchProgramsForDay:[[NSCalendarDate calendarDate] descriptionWithCalendarFormat:@"%e/%m/%Y"]
						 hour:[[NSCalendarDate calendarDate] descriptionWithCalendarFormat:@"%H:00"]];
}

- (void)fetchProgramsForDay:(NSString *)d hour:(NSString *)h
{
	int sources = [[NSUserDefaults standardUserDefaults] integerForKey:TVSourcesKey];
	if ((sources & TVTerrestrialSource) && (sources & TVSatelliteSource))
	{
		_wait = YES;
	}
	if (sources & TVTerrestrialSource)
	{
		[self fetchProgramsForDay:d
							 hour:h
						   source:TVTunerTerrestrial];
	}
	if (sources & TVSatelliteSource)
	{
		[self fetchProgramsForDay:d
							 hour:h
						   source:TVTunerSatellite];
	}
}

- (void)fetchProgramsForDay:(NSString *)d hour:(NSString *)h source:(NSString *)source
{
	[self setDay:d];
	[self setStatus:NSLocalizedString(@"Fetching Programs", @"Fetching Programs")];
	NSURL *url;
	NSString *urlString = @"http://spettacolo.alice.it/guidatv/cgi/index.cgi";
	NSString *referrerString = @"http://spettacolo.alice.it/guidatv/cgi/index.cgi";
	
	NSDictionary *oPostDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
		@"2", @"tipo",
		source, @"chtype",
		d, @"day",
		@"0", @"channel",
		[h substringWithRange:NSMakeRange(0,2)], @"hour",
		@"0", @"type",
		nil];
	
	// Add "http://" if missing
	if (![urlString hasPrefix:@"http://"] && ![urlString hasPrefix:@"https://"] && ![urlString hasPrefix:@"ftp://"])
	{
		urlString = [NSString stringWithFormat:@"http://%@",urlString];
	}
	
	urlString =  [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	url = [NSURL URLWithString:urlString];
	
	if (nil != url)	// ignore if no URL
	{
		// set some options based on user input
		CURLHandle *urlHandle = (CURLHandle *)[url URLHandleUsingCache:NO];
		
		[urlHandle setFailsOnError:NO];		// don't fail on >= 300 code; I want to see real results.
		[urlHandle setUserAgent:
			@"Mozilla/5.0 (Macintosh; U; PPC Mac OS X; en-US)"];
		[urlHandle setReferer:referrerString];		
		if (oPostDictionary != nil)
		{
			[urlHandle setPostDictionary:oPostDictionary];
		}
		
		[urlHandle setProgressIndicator:progress];
		
		mBytesRetrievedSoFar = 0;
		[urlHandle addClient:self];
		
		// launch in background
		[urlHandle loadInBackground];
	}
}

#pragma mark === URLHandle delegate methods ===

- (void)URLHandle:(NSURLHandle *)sender resourceDataDidBecomeAvailable:(NSData *)newBytes
{
	if (nil != progress)
	{
		id contentLength = [sender propertyForKeyIfAvailable:@"content-length"];
		
		mBytesRetrievedSoFar += [newBytes length];
		
		if (nil != contentLength)
		{
			double total = [contentLength doubleValue];
			[progress setIndeterminate:NO];
			[progress setMaxValue:total];
			[progress setDoubleValue:mBytesRetrievedSoFar];
		}
	}
	
}
- (void)URLHandleResourceDidBeginLoading:(NSURLHandle *)sender
{
	[self setStatus:NSLocalizedString(@"Begin Loading", @"Begin Loading")];
	[progress startAnimation:self];
}

- (void)URLHandleResourceDidFinishLoading:(NSURLHandle *)sender
{
	[self setStatus:NSLocalizedString(@"Finished Loading", @"Finished Loading")];
	
	NSData *data = [sender resourceData];	// if foreground, this will block 'til loaded.
	NSString *contentType = [sender propertyForKeyIfAvailable:@"content-type"];
	
	if (nil != progress)
	{
		[progress stopAnimation:self];
		[progress setIndeterminate:YES];
	}
	
	[sender removeClient:self];	// disconnect this from the URL handle	
	
	// Process Body
	if (nil != data)	// it might be nil if failed in the foreground thread, for instance
	{
		NSString *bodyString = nil;
		
		if ([contentType hasPrefix:@"text/"])
		{
			bodyString = [[[[NSString alloc] initWithData:data
												 encoding:NSASCIIStringEncoding] escapedString] autorelease];
		}
		else
		{
			bodyString = [NSString stringWithFormat:@"There were %d bytes of type %@",
				[data length], contentType];
		}
		NSLog(@"bodyString:%@", bodyString);
		
		AGRegex *reg = [AGRegex regexWithPattern:@"<!--\\s+RISULTATO\\s+-->\\s+<tr\\s+valign=\"top\">\\s+<td\\s+id=\"col-canale(-end)?\">\\s+<a\\s+href=\"\\?tipo=3&channel=([\\d]+)\">([^<]*)<\\/a><\\/td>\\s+<td\\s+id=\"col-orario(-end)?\"\\s+bgcolor=\"#(ECE7C9|E1D8AD)\">\\s+<div\\s+id=\"testo-orario(-chiaro)?\">\\s+([^<]+)<\\/div><\\/td>\\s+<td\\s+id=\"col-programma(-chiaro)?(-end)?\"\\s+bgcolor=\"#(E4E4E2|D1D1D1)\">\\s+<div\\s+id=\"bg-programma(-in-onda)?(-chiaro)?\">\\s*(<img\\s+src=\"http:\\/\\/images.alice.it\\/n_canali\\/cinema\\/guida_tv\\/freccia_in_onda.gif\"\\s+alt=\"ora\\s+in\\s+onda\"\\/>)?\\s*<a\\s+href=\"\\?tipo=1&qs=([^\"]+)\">([^<]+)\\s+<\\/div><\\/td>\\s+<td\\s+id=\"col-genere(-chiaro)?(-end)?\"\\s+bgcolor=\"#?(ECECEE|DFDFE1)\">\\s+<div\\s+id=\"testo-genere(-chiaro)?\">\\s+([^<]+)\\s+<\\/div>\\s+<\\/td>\\s+<\\/tr>\\s+<!--\\s+\\/RISULTATO\\s+-->"
										 options: AGRegexCaseInsensitive | AGRegexMultiline];
		if (reg == nil)
		{
			NSLog(@"Invalid regex");
			return;
		}
		NSArray *matches = [reg findAllInString:bodyString];
		int len = [matches count];
		NSMutableArray *progs = [NSMutableArray arrayWithCapacity:len];
		int k;
		for (k = 0; k < len; k++)
		{
			AGRegexMatch *match = (AGRegexMatch *)[matches objectAtIndex:k];
			NSCalendarDate *date = [NSCalendarDate dateWithString:[day stringByAppendingString:[@" " stringByAppendingString:[match groupAtIndex:7]]]
												   calendarFormat:@"%d/%m/%Y %H:%M"];
			
			// Create program object
			TVProgram *prog = [TVProgram programWithTitle:[match groupAtIndex:15]
												   progid:[match groupAtIndex:14]
													genre:[[match groupAtIndex:20] capitalizedString]
												  channel:[[match groupAtIndex:2] intValue]
												startDate:date];
			[progs insertObject:prog
						atIndex:k];
			NSLog(@"prog:%@", prog);
		}
		
		// Adjust dates to fill the schedule
		TVProgram *prev, *next;
		for (k = 0; k < len - 1; k++)
		{
			prev = [progs objectAtIndex:k];
			next = [progs objectAtIndex:k + 1];
			[prev setEndDate:[next startDate]];
		}
		
		if (_wait)
		{
			// We're waiting for a second response, so we store the programs in the instance variable
			[self setPrograms:progs];
			_wait = NO;
		}
		else
		{
			if (consumer)
			{
				if (programs)
				{
					progs = [programs arrayByAddingObjectsFromArray:progs];
				}
				[consumer programsDidBecomeAvailable:progs];
				[self setPrograms:nil];
			}
		}
	}
}

- (void)URLHandleResourceDidCancelLoading:(NSURLHandle *)sender
{
	if (nil != progress)
	{
		[progress stopAnimation:nil];
		[progress setIndeterminate:YES];
	}	
	[self setStatus:NSLocalizedString(@"Cancelled", @"Cancelled")];
}

- (void)URLHandle:(NSURLHandle *)sender resourceDidFailLoadingWithReason:(NSString *)reason
{
	if (nil != progress)
	{
		[progress stopAnimation:nil];
		[progress setIndeterminate:YES];
	}
	[self setStatus:NSLocalizedString(@"Failed",@"Failed")];
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

@end
