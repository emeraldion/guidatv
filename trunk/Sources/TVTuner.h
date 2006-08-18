//
//  TVTuner.h
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

extern NSString *TVTunerTerrestrial;
extern NSString *TVTunerSatellite;

@class CURLHandle;

@interface TVTuner : NSObject <NSURLHandleClient>
{
	CURLHandle *mURLHandle;
	NSMutableArray *programs;
	IBOutlet NSProgressIndicator *progress;
	IBOutlet NSTextField *statusbar;
	int mBytesRetrievedSoFar;
	NSString *status;
	NSString *day;
	id consumer;
	BOOL _wait;
}

#pragma mark === TVTuner methods ===
- (void)fetchPrograms;
- (void)fetchProgramsForDay:(NSString *)day hour:(NSString *)hour;
- (void)fetchProgramsForDay:(NSString *)day hour:(NSString *)hour source:(NSString *)source;

#pragma mark === Setters and getters ===

- (void)setStatus:(NSString *)status;
- (NSString *)status;

- (void)setDay:(NSString *)day;
- (NSString *)day;

#pragma mark === TVConsumer provider methods ===

- (void)setConsumer:(id)sender;

@end
