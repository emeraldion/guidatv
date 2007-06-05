//
//  TVController.m
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

#import "TVController.h"
#import "TVGuide.h"
#import "TVTuner.h"
#import "NSArray+TVUtils.h"
#import <CURLHandle/CURLHandle.h>
#import <CURLHandle/CURLHandle+extras.h>

#define DONATION_REMINDER_MAXCOUNT 10
#define DAYS_AHEAD 5

static int TVReloadDelay = 300;
static BOOL TVAutoReload = YES;

static NSString *MyDocumentToolbarIdentifier = @"MyDocument Toolbar";
static NSString *DetailsToolbarItemIdentifier = @"Details ToolbarItem";
static NSString *TuneToolbarItemIdentifier = @"Tune ToolbarItem";
static NSString *iCalToolbarItemIdentifier = @"iCal ToolbarItem";
static NSString *primeTimeToolbarItemIdentifier = @"PrimeTime ToolbarItem";
static NSString *nowOnAirToolbarItemIdentifier = @"Now On Air ToolbarItem";
static NSString *SearchToolbarItemIdentifier = @"Search ToolbarItem";

static NSString *EME_URL = @"http://www.emeraldion.it/";
static NSString *GUIDATV_URL = @"http://www.emeraldion.it/software/macosx/guidatv/";
static NSString *DONATE_URL = @"http://www.emeraldion.it/software/macosx/guidatv/donate/";
static NSString *PRIMETIME_HOUR = @"21:00";

static int TVCancelReminder = 0;
static int TVSetReminder = 1;

@class MyPathTransformer;
@class TimeTransformer;
@class ProgramsPrintView;
@class CPVerticalAlignedCell;

@implementation TVController

#pragma mark === Common methods ===

- (id) init
{
	self = [super init];
	controlsVisible = NO;
	return self;
}

+ (void) initialize
{
	NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
	
	[defaults setObject:[NSNumber numberWithInt:TVTerrestrialSource]
				 forKey:TVSourcesKey];
	[defaults setObject:[NSNumber numberWithInt:TVReloadDelay]
				 forKey:TVReloadDelayKey];
	[defaults setObject:[NSNumber numberWithBool:TVAutoReload]
				 forKey:TVAutoReloadKey];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (void) dealloc
{
	[preferencesController release];
	[toolbar release];
	[timer release];
	[super dealloc];
}

- (void) awakeFromNib
{
    [self initializeToolbar];
	
	[table setTarget:self];

	[table setDoubleAction:@selector(openDocument:)];

	[[sourcestable tableColumnWithIdentifier:@"sourcename"] setDataCell:[[CPVerticalAlignedCell alloc] init]];
	[sourcestable setUsesGradientSelection:YES];

	if (!NSClassFromString(@"NSViewAnimation"))
	{
		// Give some ol'Aqua look
		[controlsBg setImage:nil];
	}
	
	NSArray *sources = [NSArray arrayWithObjects:
		[NSDictionary dictionaryWithObjectsAndKeys:
			[NSImage imageNamed:@"terrestrial-small"],
			@"icon",
			NSLocalizedString(@"Terrestrial TV", @"Terrestrial TV"),
			@"label",
			TVTunerTerrestrial,
			@"source",
			nil],
		[NSDictionary dictionaryWithObjectsAndKeys:
			[NSImage imageNamed:@"satellite-small"],
			@"icon",
			NSLocalizedString(@"Satellite TV", @"Satellite TV"),
			@"label",
			TVTunerSatellite,
			@"source",
			nil],		
		nil];
	/*
	NSArray *sources = [NSArray arrayWithObjects:[[[VirgilioSpettacoliTVTuner alloc] initWithMode:VSTerrestrialMode] autorelease],
		[[[VirgilioSpettacoliTVTuner alloc] initWithMode:VSSatelliteMode] autorelease],
		[[[MediasetPremiumTVTuner alloc] init] autorelease],
		nil];
	*/
	[sourcesController setContent:sources];
	
	int h;
	NSMutableArray *hArr = [NSMutableArray arrayWithCapacity:24];
	for (h = 0; h < 24; h++)
	{
		[hArr insertObject:[NSString stringWithFormat:@"%.2d:00", h]
				   atIndex:h];
	}
	[hoursController setContent:[hArr retain]];
	
	[daysController setContent:[[NSArray arrayCenteredInDate:[NSCalendarDate calendarDate] 
													   range:DAYS_AHEAD] retain]];	
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleSourceChange:)
												 name:NSTableViewSelectionDidChangeNotification
											   object:nil];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	BOOL autoReload = [defaults boolForKey:TVAutoReloadKey];
	if (autoReload)
	{
		float delay = (float)[defaults integerForKey:TVReloadDelayKey];
		timer = [[NSTimer scheduledTimerWithTimeInterval:delay
												  target:self
												selector:@selector(tune:)
												userInfo:NULL
												 repeats:YES] retain];
	}
}

#pragma mark === Common Actions ===

- (IBAction) showPreferencesPanel:(id)sender
{
	if (!preferencesController)
	{
		preferencesController = [[PreferencesController alloc] init];
	}
	[preferencesController showWindow:self];
}

- (IBAction)programEditorFor:(id)sender
{
	TVProgramDocument *programDocument = [[TVProgramDocument alloc] init];
	id program = [[[sender dataSource] selectedObjects] objectAtIndex:0];
	[programDocument makeWindowControllers];
	[programDocument setProgram:program];
	[programDocument showWindows];
	[self setNextResponder:programDocument];
	//	[[[[programDocument windowControllers] objectAtIndex:0] window] makeKeyAndOrderFront:nil];
	
}

- (IBAction)tune:(id)sender
{
	[guide setConsumer:self];
	[guide fetchProgramsForDay:[dayMenu titleOfSelectedItem]
						  hour:[hourMenu titleOfSelectedItem]
						source:[[[sourcesController selectedObjects] objectAtIndex:0] valueForKey:@"source"]];
}

- (IBAction)forceTune:(id)sender
{
	[guide setConsumer:self];
	[guide fetchProgramsForDay:[dayMenu titleOfSelectedItem]
						  hour:[hourMenu titleOfSelectedItem]
						source:[[[sourcesController selectedObjects] objectAtIndex:0] valueForKey:@"source"]
				   forceReload:YES];
}

- (void)updateDayMenu
{
	NSString *title = [dayMenu titleOfSelectedItem];
	[daysController setContent:[[NSArray arrayCenteredInDate:[NSCalendarDate dateWithString:title
																			 calendarFormat:@"%d/%m/%Y"]
													   range:DAYS_AHEAD] retain]];
	[daysController setSelectionIndex:DAYS_AHEAD];
	[dayMenu selectItemWithTitle:title];
}

- (void)updateDayMenuWithDate:(NSCalendarDate *)date
{
	[daysController setContent:[[NSArray arrayCenteredInDate:date
													   range:DAYS_AHEAD] retain]];
	[daysController setSelectionIndex:DAYS_AHEAD];
	[dayMenu selectItemWithTitle:[date descriptionWithCalendarFormat:@"%d/%m/%Y"]];
}

- (IBAction) updateDayThenTune:(id)sender
{
	[self updateDayMenu];
	[self tune:sender];
}

- (IBAction) previousDay:(id)sender
{
	int index = [dayMenu indexOfSelectedItem];
	if (index > 0)
	{
		[dayMenu selectItemAtIndex:index - 1];
		[self updateDayMenu];
		[self tune:sender];
	}
}

- (IBAction) nextDay:(id)sender
{
	int index = [dayMenu indexOfSelectedItem];
	int len = [dayMenu numberOfItems];
	if (index < len - 1)
	{
		[dayMenu selectItemAtIndex:index + 1];
		[self updateDayMenu];
		[self tune:sender];
	}
}

- (IBAction) previousTimeslot:(id)sender
{
	int index = [hourMenu indexOfSelectedItem];
	int len = [hourMenu numberOfItems];
	int newIndex = (index > 0) ? index - 1 : len - 1;
	[hourMenu selectItemAtIndex:newIndex];
	[self tune:sender];
}

- (IBAction) nextTimeslot:(id)sender
{
	int index = [hourMenu indexOfSelectedItem];
	int len = [hourMenu numberOfItems];
	int newIndex = (index < len - 1) ? index + 1 : 0;
	[hourMenu selectItemAtIndex:newIndex];
	[self tune:sender];
}

- (IBAction)primeTime:(id)sender
{
	[self updateDayMenuWithDate:[NSCalendarDate calendarDate]];
	[hourMenu selectItemWithTitle:PRIMETIME_HOUR];	
	[self tune:nil];
}

- (IBAction)nowOnAir:(id)sender
{
	[self updateDayMenuWithDate:[NSCalendarDate calendarDate]];
	[hourMenu selectItemWithTitle:[[NSCalendarDate calendarDate] descriptionWithCalendarFormat:@"%H:00"]];
	[self tune:nil];
}

- (IBAction) toggleControls:(id)sender
{ 
	NSView *firstView = [[[table superview] superview] superview];

	if (NSClassFromString(@"NSViewAnimation"))
	{
		// Tiger and above
		
		NSViewAnimation *theAnim; 
		NSRect firstViewFrame; 
		NSRect newViewFrame; 
		NSMutableDictionary* firstViewDict; 
		if (controlsVisible)
		{
			// Create the attributes dictionary for the first view. 
			firstViewDict = [NSMutableDictionary dictionaryWithCapacity:3]; 
			firstViewFrame = [firstView frame]; 
			// Specify which view to modify. 
			[firstViewDict setObject:firstView forKey:NSViewAnimationTargetKey]; 
			// Specify the starting position of the view. 
			[firstViewDict setObject:[NSValue valueWithRect:firstViewFrame] 
							  forKey:NSViewAnimationStartFrameKey]; 
			// Change the ending position of the view. 
			newViewFrame = firstViewFrame; 
			newViewFrame.size.height += 40;
			[firstViewDict setObject:[NSValue valueWithRect:newViewFrame] 
							  forKey:NSViewAnimationEndFrameKey]; 
		}
		else
		{ 
			// Create the attributes dictionary for the first view. 
			firstViewDict = [NSMutableDictionary dictionaryWithCapacity:3]; 
			firstViewFrame = [firstView frame]; 
			// Specify which view to modify. 
			[firstViewDict setObject:firstView forKey:NSViewAnimationTargetKey]; 
			// Specify the starting position of the view. 
			[firstViewDict setObject:[NSValue valueWithRect:firstViewFrame] 
							  forKey:NSViewAnimationStartFrameKey]; 
			// Change the ending position of the view. 
			newViewFrame = firstViewFrame; 
			newViewFrame.size.height -= 40;
			[firstViewDict setObject:[NSValue valueWithRect:newViewFrame] 
							  forKey:NSViewAnimationEndFrameKey]; 
		}
		// Create the view animation object. 
		theAnim = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray 
						arrayWithObjects:firstViewDict, nil]]; 
		// Set some additional attributes for the animation. 
		[theAnim setFrameRate:40.0];
		[theAnim setDuration:0.2];
		[theAnim setAnimationCurve:NSAnimationEaseIn];
		// Run the animation. 
		[theAnim startAnimation]; 
		// The animation has finished, so go ahead and release it. 
		[theAnim release];
	}
	else
	{
		if (controlsVisible)
		{
			NSRect _frame = [firstView frame];
			_frame.size.height += 40;
			[firstView setFrame:_frame];
			[[firstView superview] setNeedsDisplay:YES];
		}
		else
		{
			NSRect _frame = [firstView frame];
			_frame.size.height -= 40;
			[firstView setFrame:_frame];
			[[firstView superview] setNeedsDisplay:YES];
		}
	}
	controlsVisible = !controlsVisible;
} 

- (IBAction) openDocument:(id)sender
{
	TVProgram *pr = [[programsController selectedObjects] objectAtIndex:0];
	TVProgramDocument *doc = [[TVProgramDocument alloc] init];
	//[doc setFileURL:[NSURL URLWithString:[@"file:///" stringByAppendingString:[[TVGuide sharedInstance] pathForProgram:pr]]]];
	[doc makeWindowControllers];
	[doc setProgram:pr];
	[doc setFileName:[[TVGuide sharedInstance] pathForProgram:pr]];
	[doc showWindows];
}

- (IBAction)print:(id)sender
{
	NSPrintInfo *pInfo = [NSPrintInfo sharedPrintInfo];
	NSPrintOperation *pOp;
	
	ProgramsPrintView *programsView;
	[programsController commitEditing];
	programsView = [[ProgramsPrintView alloc] initWithPrograms:[programsController arrangedObjects]
													 printInfo:pInfo];
	pOp = [NSPrintOperation printOperationWithView:programsView
										 printInfo:pInfo];
	[pOp setShowPanels:YES];
	[pOp runOperation];
}

- (IBAction) export:(id)sender
{
	NSSavePanel *sPanel = [NSSavePanel savePanel];
	[sPanel setTitle:NSLocalizedString(@"Export", @"Export")];
	[sPanel setRequiredFileType:@"txt"];
	[sPanel setCanSelectHiddenExtension:YES];
	if ([sPanel runModalForDirectory:NSHomeDirectory() 
								file:NSLocalizedString(@"GuidaTV programs", @"GuidaTV programs")] == NSFileHandlingPanelOKButton)
	{
		NSString *filePath =  [sPanel filename];
		[programsController commitEditing];
		NSArray *content = (NSArray *)[programsController content];
		NSString *lines = [content stringByFormattingAsProgramsList];
		
		// Here we deal with a Tiger-only API. Test for compliance.
		BOOL success = NO;
		if ([lines respondsToSelector:@selector(writeToFile:atomically:encoding:error:)])
		{
			success = [lines writeToFile:filePath
								atomically:YES
								  encoding:NSMacOSRomanStringEncoding
									 error:NULL];
		}
		else
		{
			success = [lines writeToFile:filePath
								atomically:YES];
		}
		
		if (!success)
		{
			NSRunCriticalAlertPanel(NSLocalizedString(@"Error writing to file",@"Error writing to file"),
									[NSString stringWithFormat:NSLocalizedString(@"Could not write to file %@",@"Could not write to file %@"),
										filePath],
									NSLocalizedString(@"OK",@"OK"),
									nil,
									nil);
		}
	}
}

#pragma mark === Setters/Getters ===
/*
 - (void)setDays:(NSArray *)d
 {
	 [d retain];
	 [days release];
	 days = d;
 }
 
 - (NSArray *)days
 {
	 return days;
 }
 */

#pragma mark === NSToolbar delegate methods ===

- (void)initializeToolbar
{
    toolbar = [[NSToolbar alloc] initWithIdentifier:MyDocumentToolbarIdentifier];
    [toolbar setAllowsUserCustomization:YES];
    [toolbar setAutosavesConfiguration:YES];
    [toolbar setDisplayMode:NSToolbarDisplayModeIconOnly];
    [toolbar setDelegate:self];
    [window setToolbar:toolbar];
    [toolbar release];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar
     itemForItemIdentifier:(NSString *)itemIdent
 willBeInsertedIntoToolbar:(BOOL)willBeInserted
{
    NSToolbarItem *toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdent];
	
    [toolbarItem autorelease];
	if ([itemIdent isEqual:TuneToolbarItemIdentifier]) { // a basic button item
        [toolbarItem setLabel: NSLocalizedString(@"Fetch Programs", @"Fetch Programs")];
        [toolbarItem setPaletteLabel: NSLocalizedString(@"Fetch Programs", @"Fetch Programs")];
        [toolbarItem setToolTip:NSLocalizedString(@"Fetch Programs", @"Fetch Programs")];
        [toolbarItem setImage:[NSImage imageNamed: @"reload"]];
        [toolbarItem setTarget: self];
        [toolbarItem setAction: @selector(tune:)];
    }
    else if ([itemIdent isEqual:iCalToolbarItemIdentifier]) { // a basic button item
        [toolbarItem setLabel: NSLocalizedString(@"Reminder", @"Reminder")];
        [toolbarItem setPaletteLabel: NSLocalizedString(@"Reminder", @"Reminder")];
        [toolbarItem setToolTip:NSLocalizedString(@"Add Reminder", @"Add Reminder")];
        [toolbarItem setImage:[NSImage imageNamed: @"icaltoolbar"]];
        [toolbarItem setTarget: self];
        [toolbarItem setAction: @selector(addReminder:)];
	}
    else if ([itemIdent isEqual:primeTimeToolbarItemIdentifier]) { // a basic button item
        [toolbarItem setLabel: NSLocalizedString(@"Prime Time", @"Prime Time")];
        [toolbarItem setPaletteLabel: NSLocalizedString(@"Prime Time", @"Prime Time")];
        [toolbarItem setToolTip:NSLocalizedString(@"Prime Time", @"Prime Time")];
        [toolbarItem setImage:[NSImage imageNamed: @"primaserata"]];
        [toolbarItem setTarget: self];
        [toolbarItem setAction: @selector(primeTime:)];
	}
    else if ([itemIdent isEqual:nowOnAirToolbarItemIdentifier]) { // a basic button item
        [toolbarItem setLabel: NSLocalizedString(@"Now On Air", @"Now On Air")];
        [toolbarItem setPaletteLabel: NSLocalizedString(@"Now On Air", @"Now On Air")];
        [toolbarItem setToolTip:NSLocalizedString(@"Now On Air", @"Now On Air")];
        [toolbarItem setImage:[NSImage imageNamed: @"popcorntub"]];
        [toolbarItem setTarget: self];
        [toolbarItem setAction: @selector(nowOnAir:)];
	}
	else if ([itemIdent isEqual:SearchToolbarItemIdentifier]) { // a basic button item
		[toolbarItem setLabel: NSLocalizedString(@"Search", @"Search")];
		[toolbarItem setPaletteLabel: NSLocalizedString(@"Search", @"Search")];
		[toolbarItem setToolTip:NSLocalizedString(@"Search", @"Search")];
		[toolbarItem setImage:[NSImage imageNamed: @"search"]];
		[toolbarItem setTarget: self];
		[toolbarItem setAction: @selector(toggleControls:)];
	}
	
	
    return toolbarItem;
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{ // return an array of the items found in the default toolbar
    return [NSArray arrayWithObjects:
		TuneToolbarItemIdentifier,
		iCalToolbarItemIdentifier, primeTimeToolbarItemIdentifier,
		nowOnAirToolbarItemIdentifier,
		SearchToolbarItemIdentifier,
        NSToolbarFlexibleSpaceItemIdentifier,
        NSToolbarPrintItemIdentifier, nil];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{ // return an array of all the items that can be put in the toolbar
    return [NSArray arrayWithObjects:
		TuneToolbarItemIdentifier,
		iCalToolbarItemIdentifier, primeTimeToolbarItemIdentifier,
		nowOnAirToolbarItemIdentifier, SearchToolbarItemIdentifier,
        NSToolbarPrintItemIdentifier, NSToolbarShowColorsItemIdentifier,
        NSToolbarShowFontsItemIdentifier, NSToolbarCustomizeToolbarItemIdentifier,
        NSToolbarFlexibleSpaceItemIdentifier, NSToolbarSpaceItemIdentifier,
        NSToolbarSeparatorItemIdentifier, nil];
}

- (void)toolbarWillAddItem:(NSNotification *)notification
{ // lets us modify items (target, action, tool tip, etc.) as they are added to toolbar
    NSToolbarItem *addedItem = [[notification userInfo] objectForKey: @"item"];
    if ([[addedItem itemIdentifier] isEqual:NSToolbarPrintItemIdentifier]) {
        [addedItem setToolTip: NSLocalizedString(@"Print Document", @"Print Document")];
        [addedItem setTarget:self];
		[addedItem setAction:@selector(print:)];
    }
}

- (void)toolbarDidRemoveItem:(NSNotification *)notification
{
	// handle removal of items.  We have an item that could be a target, so that needs to be reset
    //NSToolbarItem *removedItem = [[notification userInfo] objectForKey: @"item"];
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem
{ // works just like menu item validation, but for the toolbar.
    BOOL ret = NO;
	if ([[toolbarItem itemIdentifier] isEqual:NSToolbarPrintItemIdentifier] ||
		[[toolbarItem itemIdentifier] isEqual:primeTimeToolbarItemIdentifier] ||
		[[toolbarItem itemIdentifier] isEqual:nowOnAirToolbarItemIdentifier] ||
		[[toolbarItem itemIdentifier] isEqual:SearchToolbarItemIdentifier] ||
		[[toolbarItem itemIdentifier] isEqual:TuneToolbarItemIdentifier]) {
        ret = YES;
    }
	else if (//[[toolbarItem itemIdentifier] isEqual:DetailsToolbarItemIdentifier] ||
			 [[toolbarItem itemIdentifier] isEqual:iCalToolbarItemIdentifier]) {
		ret = ([[programsController selectedObjects] count] > 0);
	}
    return ret;
}

#pragma mark === NSApplication delegate methods ===

- (void) applicationDidFinishLaunching:(NSNotification *) notif
{
	[CURLHandle curlHelloSignature:@"XxXx" acceptAll:YES];	// to get CURLHandle registered for handling URLs
	
	/* Registering Value Transformers */
	id pathTransformer = [[[MyPathTransformer alloc] init] autorelease];
	[NSValueTransformer setValueTransformer:pathTransformer forName:@"MyPathTransformer"];
	
	id timeTransformer = [[[TimeTransformer alloc] init] autorelease];
	[NSValueTransformer setValueTransformer:timeTransformer forName:@"TimeTransformer"];
	
	/* Donation handling */
	
	// If user didn't tell she donated...
	if (![self hasDonated] &&
		[self shouldDisplayDonationReminder])
	{
		[NSApp beginSheet:donateSheet
		   modalForWindow:window
			modalDelegate:self 
		   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
			  contextInfo:NULL];		
	}
	
	[NSApp setApplicationIconImage:[NSImage imageNamed:@"GuidaTV-on"]];
	[self nowOnAir:nil];
}

- (void) applicationWillTerminate:(NSNotification *) notif
{
	[CURLHandle curlGoodbye];	// to clean up
	[timer invalidate];
	[timer release]; //NSSearchField
	[NSApp setApplicationIconImage:[NSImage imageNamed:@"GuidaTV"]];	
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender;
{
	return YES;
}

- (IBAction)addReminder:(id)sender
{
	[NSApp beginSheet:icalsheet
	   modalForWindow:window
		modalDelegate:self 
	   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
		  contextInfo:NULL];
}

- (IBAction)cancelDonationReminder:(id)sender
{
	[donateSheet orderOut:sender];
	[NSApp endSheet:donateSheet returnCode:TVCancelReminder];
}

- (IBAction) dismissDonationReminderThenDonate:(id)sender
{
	[self cancelDonationReminder:sender];
	[self donate:nil];
}

- (IBAction) toggleAlreadyDonated:(id)sender
{
	NSUserDefaults *defaults;
	defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:[sender state] forKey:TVHasDonatedKey];
	[defaults synchronize];
}

- (IBAction)cancelReminder:(id)sender
{
	[icalsheet orderOut:sender];
	[NSApp endSheet:icalsheet returnCode:TVCancelReminder];
}

- (IBAction)setReminder:(id)sender
{
	[icalsheet orderOut:sender];
	[NSApp endSheet:icalsheet returnCode:TVSetReminder];
}

- (void)sheetDidEnd:(NSWindow *)sheet
		 returnCode:(int)retCode
		contextInfo:(void *)cInfo
{
	
}

#pragma mark === Web links ===

- (IBAction)webSite:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:GUIDATV_URL]];
}

- (IBAction)emeLodge:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:EME_URL]];
}

- (IBAction)donate:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:DONATE_URL]];
}

#pragma mark === TVConsumer protocol methods ===

- (void)programsDidBecomeAvailable:(NSArray *)programs
{
	[programsController setContent:programs];
	[table reloadData];	
	//	[[TVGuide sharedInstance] saveDataToDisk];
	
}

#pragma mark === NSTableView delegate methods ===

- (IBAction) copy:(id)sender
{
	NSPasteboard *pb = [NSPasteboard generalPasteboard];
	[self copySelectedProgramToPasteboard:pb];
}

/* Not implemented
- (IBAction) cut:(id)sender
{
	NSLog(@"cut:");
}

- (IBAction) paste:(id)sender
{
	NSLog(@"paste:");
}
*/

/* Support methods */

- (void) copySelectedProgramToPasteboard:(NSPasteboard *)pb
{
	// Get user selection
	[programsController commitEditing];
	id selectedObjects = [programsController selectedObjects];
	
	// Is there something selected??
	if ([selectedObjects count] > 0)
	{
		// Declare pasteboard types
		[pb declareTypes:[NSArray arrayWithObject:NSStringPboardType]
				   owner:self];
		
		// Copy data
		[pb setString:[[selectedObjects objectAtIndex:0] description]
			  forType:NSStringPboardType];
	}
}

/*
 - (unsigned int)draggingSourceOperationMaskForLocal:(BOOL)isLocal
 {
	 NSLog(@"draggingSourceOperationMaskForLocal:");
	 return YES;
 }
 
 - (void)mouseDragged:(NSEvent *)event
 {
	 NSLog(@"mouseDragged:");
 }
 */

- (BOOL)hasDonated
{
	NSUserDefaults *defaults;
	defaults = [NSUserDefaults standardUserDefaults];
	return [defaults boolForKey:TVHasDonatedKey];	
}

- (BOOL)shouldDisplayDonationReminder
{
	NSUserDefaults *defaults;
	defaults = [NSUserDefaults standardUserDefaults];
	// Get current counter...
	int counter = [defaults integerForKey:TVDonationReminderCounterKey];
	// Increment the counter...
	[defaults setInteger:((counter + 1) % (DONATION_REMINDER_MAXCOUNT + 1)) forKey:TVDonationReminderCounterKey];
	[defaults synchronize];
	// Return the counter
	return (counter == DONATION_REMINDER_MAXCOUNT);
}

- (void)handleSourceChange:(NSNotification *)note
{
	if ([note object] == sourcestable)
	{
		[self tune:nil];
	}
}

@end

@implementation TVController (NSSplitViewDelegate)

/*
- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize
{
}
*/

- (float)splitView:(NSSplitView *)sender constrainMinCoordinate:(float)proposedCoord ofSubviewAt:(int)offset
{
	if (sender == hrzSplit)
	{
		switch (offset)
		{
			case 0:
				return 112;
		}
	}
	return proposedCoord;
}

- (float)splitView:(NSSplitView *)sender constrainMaxCoordinate:(float)proposedCoord ofSubviewAt:(int)offset
{
	if (sender == hrzSplit)
	{
		switch (offset)
		{
			case 0:
				return [hrzSplit bounds].size.height - [hrzSplit dividerThickness] - 224;
		}
	}
	return proposedCoord;
}

/*
- (void)splitViewWillResizeSubviews:(NSNotification *)notification
{
}
- (void)splitViewDidResizeSubviews:(NSNotification *)notification
{
}
*/

- (BOOL)splitView:(NSSplitView *)sender canCollapseSubview:(NSView *)subview
{
	if (sender == hrzSplit)
	{
		if (subview == [[hrzSplit subviews] objectAtIndex:1])
		{
			return YES;
		}
	}
	return NO;
}

- (float)splitView:(NSSplitView *)splitView constrainSplitPosition:(float)proposedPosition ofSubviewAt:(int)index
{
	return proposedPosition;
}

@end