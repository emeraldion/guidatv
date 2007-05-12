//
//  IMDBClient.m
//  GuidaTV
//
//  Created by delphine on 18-06-2006.
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

#import "IMDBClient.h"
#import <CURLHandle/CURLHandle.h>
#import <CURLHandle/CURLHandle+extras.h>

static NSString *IMDBAPIFormatString = @"http://imdb.com/find?q=%@;s=tt;site=aka";
static NSString *IMDBHome = @"http://imdb.com/";
static NSString *IMDBTitleAvailableMarker = @"http://imdb.com/title/";

@implementation IMDBClient

- (id)init
{
	self = [super init];
	// custom initialization here
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

+ (IMDBClient *)client
{
	return [[[IMDBClient alloc] init] autorelease];
}

- (void)setConsumer:(id <IMDBConsumer>)consumer
{
	[consumer retain];
	[mConsumer release];
	mConsumer = consumer;
}
- (void)removeConsumer:(id <IMDBConsumer>)consumer
{
	if (mConsumer == consumer)
		[self setConsumer:nil];
}

- (void)requestOverviewOfMovie:(NSString *)movie
{
	// Retrieve informations and then dispatch the consumer
	
	NSURL *url;
	NSString *urlString = [NSString stringWithFormat:IMDBAPIFormatString,
		[movie stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	NSString *referrerString = IMDBHome;

	url = [NSURL URLWithString:urlString];
	
	if (nil != url)	// ignore if no URL
	{
		// set some options based on user input
		CURLHandle *urlHandle = (CURLHandle *)[url URLHandleUsingCache:NO];
		
		[urlHandle setFailsOnError:NO];		// don't fail on >= 300 code; I want to see real results.
		[urlHandle setUserAgent:
			@"Mozilla/5.0 (Macintosh; U; PPC Mac OS X; en-US)"];
		[urlHandle setReferer:referrerString];		
		[urlHandle addClient:self];
		
		// launch in background
		[urlHandle loadInBackground];
	}	
}

#pragma mark === URLHandle delegate methods ===

- (void)URLHandle:(NSURLHandle *)sender resourceDataDidBecomeAvailable:(NSData *)newBytes
{
}
- (void)URLHandleResourceDidBeginLoading:(NSURLHandle *)sender
{
}

- (void)URLHandleResourceDidFinishLoading:(NSURLHandle *)sender
{
	NSString *movieURLString = [sender propertyForKeyIfAvailable:@"location"];
	
	[sender removeClient:self];	// disconnect this from the URL handle	
	if (mConsumer && movieURLString)
	{
		if ([movieURLString rangeOfString:IMDBTitleAvailableMarker].length > 0)
		{
			NSRange qRange = [movieURLString rangeOfString:@"?"];
			if (qRange.length > 0)
			{
				movieURLString = [movieURLString substringWithRange:NSMakeRange(0,qRange.location)];
			}
			[mConsumer movieOverviewDidBecomeAvailable:movieURLString];
		}
	}
}

- (void)URLHandleResourceDidCancelLoading:(NSURLHandle *)sender
{
	if (mConsumer)
	{
		//[mConsumer movieOverviewDidBecomeAvailable:nil];
	}
}

- (void)URLHandle:(NSURLHandle *)sender resourceDidFailLoadingWithReason:(NSString *)reason
{
	if (mConsumer)
	{
		//[mConsumer movieOverviewDidBecomeAvailable:nil];
	}
}

@end
