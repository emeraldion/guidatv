//
//  TVController.h
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
#import "NSArray+TVUtils.h"

extern NSString *TVReloadDelayKey;
extern NSString *TVAutoReloadKey;
extern NSString *TVSourcesKey;
extern NSString *TVHasDonatedKey;
extern NSString *TVDonationReminderCounterKey;

extern int TVTerrestrialSource;
extern int TVSatelliteSource;

extern NSString *TVTunerTerrestrial;
extern NSString *TVTunerSatellite;

@class TVTuner;
@class TVGuide;
@class ProgramArrayController;
@class PreferencesController;
@class TVProgramDocument;

@interface TVController : NSObject <TVConsumer>
{
	IBOutlet id drawer;
	IBOutlet id table;
	IBOutlet id sourcestable;
	IBOutlet id window;
	IBOutlet TVTuner *tuner;
	IBOutlet TVGuide *guide;
	IBOutlet ProgramArrayController *programsController;
	IBOutlet NSArrayController *sourcesController;
	IBOutlet NSArrayController *daysController;
	IBOutlet NSArrayController *hoursController;
	IBOutlet NSWindow *icalsheet;
	IBOutlet NSWindow *donateSheet;
	IBOutlet NSPopUpButton *hourMenu;
	IBOutlet NSPopUpButton *dayMenu;
	IBOutlet NSButton *alreadyDonated;
	IBOutlet NSImageView *controlsBg;
	PreferencesController *preferencesController;
	NSToolbar *toolbar;
	NSTimer *timer;
	BOOL controlsVisible;
//	NSArray *days;
//	NSArray *hours;
}

- (IBAction) showPreferencesPanel:(id)sender;
- (IBAction) toggleDrawer:(id)sender;
- (IBAction) updateDayThenTune:(id)sender;
- (IBAction) tune:(id)sender;
- (IBAction) forceTune:(id)sender;
- (IBAction) addReminder:(id)sender;
- (IBAction) cancelReminder:(id)sender;
- (IBAction) cancelDonationReminder:(id)sender;
- (IBAction) dismissDonationReminderThenDonate:(id)sender;
- (IBAction) toggleAlreadyDonated:(id)sender;
- (IBAction) setReminder:(id)sender;
- (IBAction) primeTime:(id)sender;
- (IBAction) nowOnAir:(id)sender;
- (IBAction) toggleControls:(id)sender;

// Data export

- (IBAction) print:(id)sender;
- (IBAction) export:(id)sender;

// Time shifting

- (IBAction) previousDay:(id)sender;
- (IBAction) nextDay:(id)sender;
- (IBAction) previousTimeslot:(id)sender;
- (IBAction) nextTimeslot:(id)sender;

#pragma mark === Setters/Getters ===

//- (void)setDays:(NSArray *)d;
//- (NSArray *)days;

#pragma mark === NSToolbar delegate methods ===

- (void)initializeToolbar;
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar
     itemForItemIdentifier:(NSString *)itemIdent
 willBeInsertedIntoToolbar:(BOOL)willBeInserted;
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar;
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar;
- (void)toolbarWillAddItem:(NSNotification *)notification;
- (void)toolbarDidRemoveItem:(NSNotification *)notification;
- (BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem;

#pragma mark === Web links ===

- (IBAction)webSite:(id)sender;
- (IBAction)emeLodge:(id)sender;
- (IBAction)donate:(id)sender;
@end
