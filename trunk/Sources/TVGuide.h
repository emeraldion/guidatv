//
//  TVGuide.h
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
#import "TVConsumer.h"

@class TVTuner;
@class TVProgram;

@interface TVGuide : NSObject <TVConsumer> {
	IBOutlet TVTuner *tuner;
	
	NSString *day;
	NSString *hour;
	NSString *source;
	
	NSDictionary *channelsList;
	NSDictionary *genresList;
	
	NSMutableDictionary *guide;
	NSArray *programs;
	id consumer;
}

+ (id)sharedInstance;

- (void)setGuide:(NSArray *)guide;
- (NSArray *)guide;

- (NSString *)nameForChannel:(int)channel;
- (NSString *)nameForGenre:(int)genre;

- (NSDictionary *)channelsList;
- (NSDictionary *)genresList;

- (void)setDay:(NSString *)day hour:(NSString *)hour;

- (void)loadDataFromDisk;
- (void)saveDataToDisk;
- (NSString *) pathForDataFile;

- (NSString *) pathForProgram:(TVProgram *)p;

- (NSArray *)programsForSource:(NSString *)source timeslot:(NSCalendarDate *)timeslot;

@end
