//
//  PreferencesController.m
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

#import "PreferencesController.h"

NSString *TVReloadDelayKey = @"TVReloadDelay";
NSString *TVAutoReloadKey = @"TVAutoReload";
NSString *TVSourcesKey = @"TVSources";
NSString *TVHasDonatedKey = @"TVHasDonated";
NSString *TVDonationReminderCounterKey = @"TVDonationReminderCounter";

int TVTerrestrialSource = 1;
int TVSatelliteSource = 2;

@implementation PreferencesController

- (id) init
{
	self = [super initWithWindowNibName:@"Preferences"];
	return self;
}

- (void)windowDidLoad
{
	[delaySlider setIntValue:[self reloadDelay]];
	[autoReload setState:[self autoReload]];
	[sourceMatrix setState:[self sources] & TVTerrestrialSource
					 atRow:0
					column:0];
	[sourceMatrix setState:[self sources] & TVSatelliteSource
					 atRow:1
					column:0];
	[autoUpdate setState:[self autoUpdate]];
	[self _updateLabel:[self reloadDelay]];
}

#pragma mark === Getters ===

- (int)reloadDelay
{
	NSUserDefaults *defaults;
	defaults = [NSUserDefaults standardUserDefaults];
	return [defaults integerForKey:TVReloadDelayKey];
}

- (BOOL)autoReload
{
	NSUserDefaults *defaults;
	defaults = [NSUserDefaults standardUserDefaults];
	return [defaults boolForKey:TVAutoReloadKey];
}

- (int)sources
{
	NSUserDefaults *defaults;
	defaults = [NSUserDefaults standardUserDefaults];
	return [defaults integerForKey:TVSourcesKey];	
}

- (BOOL) autoUpdate
{
	NSUserDefaults *defaults;
	defaults = [NSUserDefaults standardUserDefaults];
	return [defaults boolForKey:@"SUCheckAtStartup"];
}

#pragma mark === Actions ===

- (IBAction)changeDelay:(id)sender
{
	int value = [sender intValue];
	[self _updateLabel:value];
	[[NSUserDefaults standardUserDefaults] setInteger:value
											   forKey:TVReloadDelayKey];
	
}

- (IBAction)changeAutoReload:(id)sender
{
	BOOL state = [sender state];
	[delaySlider setEnabled:state];
	[[NSUserDefaults standardUserDefaults] setBool:state
											forKey:TVAutoReloadKey];
}

- (IBAction)changeSource:(id)sender
{
	id cell = [sender selectedCell];
	int sources = [self sources];
	[[NSUserDefaults standardUserDefaults] setInteger:sources ^ [cell tag]
											   forKey:TVSourcesKey];
}

- (IBAction)changeAutoUpdate:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setBool:[sender state]
											forKey:@"SUCheckAtStartup"];
}

#pragma mark === Private Methods ===

- (void)_updateLabel:(int)value
{
	[delayLabel setObjectValue:[[NSValueTransformer valueTransformerForName:@"TimeTransformer"] transformedValue:[NSNumber numberWithInt:value]]];
}

@end
