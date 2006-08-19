//
//  TVProgram.h
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

#import <Cocoa/Cocoa.h>
#import <CURLHandle/CURLHandle.h>
#import "IMDBClient.h"
#import "TVGuide.h"

extern int TVProgramNoChannel;
extern NSString *TVProgramNoGenre;
extern int TVProgramMaxTitleLength;

@interface TVProgram : NSObject <NSCoding, NSURLHandleClient, IMDBConsumer>
{

	NSString *title;
	NSString *genre;
	int channel;
	NSString *channelName;
	NSCalendarDate *startDate;
	NSCalendarDate *endDate;
	NSString *review;
	NSString *progid;
	NSString *IMDBURLString;
	NSString *userComments;
}

#pragma mark === Static Initializers ===

+ (id)programWithTitle:(NSString *)aTitle progid:(NSString *)progid genre:(NSString *)aGenre channel:(int)aChannel startDate:(NSCalendarDate *)aDate onair:(BOOL)aOnair;

#pragma mark === Initializers ===

- (id)initWithTitle:(NSString *)aTitle progid:(NSString *)progid genre:(NSString *)aGenre channel:(int)aChannel startDate:(NSCalendarDate *)aDate onair:(BOOL)aOnair;
- (id)init;

#pragma mark === Setter Methods ===

- (void)setTitle:(NSString *)aTitle;
- (void)setChannel:(int)aChannel;
- (void)setGenre:(NSString *)aGenre;
- (void)setEndDate:(NSCalendarDate *)aDate;
- (void)setStartDate:(NSCalendarDate *)aDate;
- (void)setIMDBURLString:(NSString *)urlString;
- (void)setUserComments:(NSString *)comments;
- (void)setProgid:(NSString *)progid;

#pragma mark === Getter Methods ===

- (NSString *)title;
- (int)channel;
- (NSString *)channelName;
- (NSString *)genre;
- (NSCalendarDate *)endDate;
- (NSCalendarDate *)startDate;
- (NSString *)review;
- (NSString *)IMDBURLString;
- (NSString *)userComments;
- (NSString *)progid;

#pragma mark === Other ===

- (BOOL)onair;
- (NSString *)description;


@end
