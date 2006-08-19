//
//  PreferencesController.h
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

#import <Cocoa/Cocoa.h>

extern NSString *TVReloadDelayKey;
extern NSString *TVAutoReloadKey;
extern NSString *TVSourcesKey;

extern int TVTerrestrialSource;
extern int TVSatelliteSource;

@interface PreferencesController : NSWindowController {

	IBOutlet id delaySlider;
	IBOutlet id autoReload;
	IBOutlet id sourceMatrix;
	IBOutlet id autoUpdate;
	IBOutlet id delayLabel;
}

- (IBAction)changeDelay:(id)sender;
- (IBAction)changeAutoReload:(id)sender;
- (IBAction)changeSource:(id)sender;
- (IBAction)changeAutoUpdate:(id)sender;

- (BOOL)autoReload;
- (int)reloadDelay;
- (int)sources;
- (BOOL)autoUpdate;

@end
