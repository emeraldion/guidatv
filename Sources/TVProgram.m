//
//  TVProgram.m
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

#import "TVProgram.h"

int TVProgramNoChannel = -1;
int TVProgramMaxTitleLength = 0;
NSString *TVProgramNoGenre = @"NO_GENRE";
NSString *TVProgramNoProgID = @"0";
NSString *TVProgramNoIMDBURL = @"NO_IMDB_URL";

static NSString *RESULTS_START = @"<div id=\"scheda-testo\">";
static NSString *RESULTS_END = @"<br><br>";

@implementation TVProgram

#pragma mark === Static Initializers ===

+ (id)programWithTitle:(NSString *)title
				progid:(NSString *)progid
				 genre:(NSString *)genre
			   channel:(int) channel
			 startDate:(NSCalendarDate *)startDate
{
	TVProgram *program = [[TVProgram alloc] initWithTitle:title
												   progid:progid
													genre:genre
												  channel:channel
												startDate:startDate];
	return [program autorelease];
}

#pragma mark === Initializers ===

- (id)initWithTitle:(NSString *)aTitle
			 progid:(NSString *)pid
			  genre:(NSString *)aGenre
			channel:(int)aChannel
		  startDate:(NSCalendarDate *)aDate
{
	if (self = [super init])
	{
		[self setTitle:aTitle];
		[self setGenre:aGenre];
		[self setChannel:aChannel];
		[self setStartDate:aDate];
		[self setIMDBURLString:TVProgramNoIMDBURL];
		[self setProgid:pid];
	}
	return self;
}

- (id)init
{
	return [self initWithTitle:@""
						 genre:TVProgramNoGenre
						progid:TVProgramNoProgID
					   channel:TVProgramNoChannel
					 startDate:[NSCalendarDate calendarDate]];
}

- (id)initWithCoder:(NSCoder *)coder
{
	if (self = [super init])
	{
		if ([coder containsValueForKey:@"title"])
		{
			[self setTitle:[coder decodeObjectForKey:@"title"]];
		}
		if ([coder containsValueForKey:@"genre"])
		{
			[self setGenre:[coder decodeObjectForKey:@"genre"]];
		}
		if ([coder containsValueForKey:@"channel"])
		{
			[self setChannel:[coder decodeIntForKey:@"channel"]];
		}
		if ([coder containsValueForKey:@"startDate"])
		{
			[self setStartDate:[coder decodeObjectForKey:@"startDate"]];
		}
		if ([coder containsValueForKey:@"endDate"])
		{
			[self setEndDate:[coder decodeObjectForKey:@"endDate"]];
		}
		if ([coder containsValueForKey:@"review"])
		{
			[self setReview:[coder decodeObjectForKey:@"review"]];
		}
		if ([coder containsValueForKey:@"IMDBURLstring"])
		{
			[self setIMDBURLString:[coder decodeObjectForKey:@"IMDBURLstring"]];
		}
		if ([coder containsValueForKey:@"progid"])
		{
			[self setProgid:[coder decodeObjectForKey:@"progid"]];
		}
		if ([coder containsValueForKey:@"userComments"])
		{
			[self setUserComments:[coder decodeObjectForKey:@"userComments"]];
		}
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:title forKey:@"title"];
	[coder encodeObject:genre forKey:@"genre"];
	[coder encodeInt:channel forKey:@"channel"];
	[coder encodeObject:startDate forKey:@"startDate"];
	[coder encodeObject:endDate forKey:@"endDate"];
	[coder encodeObject:review forKey:@"review"];
	[coder encodeObject:IMDBURLString forKey:@"IMDBURLstring"];
	[coder encodeObject:progid forKey:@"progid"];
	[coder encodeObject:userComments forKey:@"userComments"];
}

#pragma mark === Overridden from NSObject ===

- (BOOL)isEqual:(id)object
{
	return [[(TVProgram *)object progid] isEqual:progid];
}

#pragma mark === Setter Methods ===

- (void)setProgid:(NSString *)pid
{
	[pid retain];
	[progid release];
	progid = pid;
}

- (void)setTitle:(NSString *)aTitle
{
	int len = [aTitle length];
	TVProgramMaxTitleLength = (len > TVProgramMaxTitleLength) ? len : TVProgramMaxTitleLength;
	[aTitle retain];
	[title release];
	title = aTitle;
}

- (void)setChannel:(int)aChannel
{
	[channelName release];
	channelName = [[TVGuide sharedInstance] nameForChannel:aChannel];
	[channelName retain];
	channel = aChannel;
}

- (void)setGenre:(NSString *)aGenre
{
	[aGenre retain];
	[genre release];
	genre = aGenre;
}

- (void)setReview:(NSString *)aReview
{
	[aReview retain];
	[review release];
	review = aReview;
}

- (void)setStartDate:(NSCalendarDate *)aDate
{
	[aDate retain];
	[startDate release];
	startDate = aDate;
}

- (void)setEndDate:(NSCalendarDate *)aDate
{
	[aDate retain];
	[endDate release];
	endDate = aDate;
}

- (void)setIMDBURLString:(NSString *)urlString
{
	[urlString retain];
	[IMDBURLString release];
	IMDBURLString = urlString;
}

- (void)setUserComments:(NSString *)comments
{
	[comments retain];
	[userComments release];
	userComments = comments;
}

#pragma mark === Getter Methods ===

- (NSString *)title
{
	return title;
}

- (NSString *)genre
{
	return genre;
}

- (int)channel
{
	return channel;
}

- (NSString *)channelName
{
	return channelName;
}

- (NSCalendarDate *)startDate
{
	return startDate;
}

- (NSCalendarDate *)endDate
{
	return endDate;
}

- (NSString *)IMDBURLString
{

	if ([IMDBURLString isEqual:TVProgramNoIMDBURL] && NSClassFromString(@"CURLHandle"))
	{
		if ([genre isEqual:@"Film"] ||
			[genre isEqual:@"Serial"]) // FIXME
		{
			IMDBClient *client = [IMDBClient client];
			[client setConsumer:self];
			[client requestOverviewOfMovie:[self title]];
		}
		[self setIMDBURLString:nil];
	}

	return IMDBURLString;
}

- (NSString *)review
{

	if (!review && NSClassFromString(@"CURLHandle"))
	{
		NSURL *url;
		NSString *urlString = @"http://spettacolo.alice.it/guidatv/cgi/index.cgi";
		NSString *referrerString = @"http://spettacolo.alice.it/guidatv/cgi/index.cgi";
		
		NSDictionary *oPostDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
			@"1", @"tipo",
			progid, @"qs",
			nil];
		
		if (![urlString hasPrefix:@"http://"] && ![urlString hasPrefix:@"https://"] && ![urlString hasPrefix:@"ftp://"])
		{
			urlString = [NSString stringWithFormat:@"http://%@",urlString];
		}
		
		urlString =  [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		url = [NSURL URLWithString:urlString];
		
		if (nil != url)
		{
			CURLHandle *urlHandle = (CURLHandle *)[url URLHandleUsingCache:NO];
			
			[urlHandle setFailsOnError:NO];
			[urlHandle setUserAgent:
				@"Mozilla/5.0 (Macintosh; U; PPC Mac OS X; en-US)"];
			[urlHandle setReferer:referrerString];		
			if (oPostDictionary != nil)
			{
				[urlHandle setPostDictionary:oPostDictionary];
			}
			
			[urlHandle addClient:self];
			[urlHandle loadInBackground];
		}
		
	}

	return review;
}

- (NSString *)userComments
{
	return userComments;
}

- (NSString *)progid
{
	return progid;
}


#pragma mark === URLHandle protocol methods ===

- (void)URLHandle:(NSURLHandle *)sender resourceDataDidBecomeAvailable:(NSData *)newBytes
{	
}
- (void)URLHandleResourceDidBeginLoading:(NSURLHandle *)sender
{
}

- (void)URLHandleResourceDidFinishLoading:(NSURLHandle *)sender
{
	NSData *data = [sender resourceData];
	NSString *contentType = [sender propertyForKeyIfAvailable:@"content-type"];
	
	[sender removeClient:self];
	
	if (nil != data)
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
		
		int start = [bodyString rangeOfString:RESULTS_START].location + [RESULTS_START length];
		int end = [bodyString rangeOfString:RESULTS_END options:NSBackwardsSearch].location;
		[self setReview:[bodyString substringWithRange:NSMakeRange(start, end - start)]];
		[[TVGuide sharedInstance] saveProgram:self];
	}
}

- (void)URLHandleResourceDidCancelLoading:(NSURLHandle *)sender
{
}

- (void)URLHandle:(NSURLHandle *)sender resourceDidFailLoadingWithReason:(NSString *)reason
{
}

#pragma mark === IMDBConsumer protocol methods ===

- (void)movieOverviewDidBecomeAvailable:(NSString *)urlString
{
	[self setIMDBURLString:urlString];
	[[TVGuide sharedInstance] saveProgram:self];
}


#pragma mark === Other ===

- (BOOL)onair
{
	NSCalendarDate *now = [NSCalendarDate calendarDate];
	BOOL isOnair = NO;
	isOnair = ([now compare:startDate] != NSOrderedAscending &&
			   [now compare:endDate] != NSOrderedDescending);
	return isOnair;
}

- (NSString *)debugInfo
{
	return [NSString stringWithFormat:@"[%@] %@ (%@) on %@ from %@ to %@, onair:%i",
		progid,
		title,
		genre,
		[[NSNumber numberWithInt:channel] stringValue],
		startDate,
		endDate,
		[self onair]];
}

- (NSString *)description
{
	TVGuide *guide = [TVGuide sharedInstance];
	return [NSString stringWithFormat:@"%@  %@  %@  %@",
		startDate,
		[[guide nameForChannel:channel] stringByPaddingToLength:20
													 withString:@" "
												startingAtIndex:0],
		[title stringByPaddingToLength:TVProgramMaxTitleLength
							withString:@" "
					   startingAtIndex:0],
		genre];
}

- (NSString *)onairImg
{
	return ([self onair]) ? @"onair.tiff" : nil;
}

- (NSImage *)channelImg
{
	return [NSImage imageNamed:[[NSNumber numberWithInt:channel] stringValue]];
}

@end
