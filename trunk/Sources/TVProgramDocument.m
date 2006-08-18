//
//  TVProgramDocument.m
//  GuidaTV
//
//  Created by delphine on 13-08-2006.
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

#import "TVProgramDocument.h"


@implementation TVProgramDocument

- (id)init
{
    self = [super init];
    if (self) {
		
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
		
    }
    return self;
}

- (void)dealloc
{
	[self setProgram:nil];
	[super dealloc];
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
	NSLog(@"windowControllerDidLoadNib:");

	[super windowControllerDidLoadNib:aController];
}

- (NSString *)windowNibName {
	NSLog(@"TVProgramDocument");
    // Implement this to return a nib to load OR implement -makeWindowControllers to manually create your controllers.
    return @"TVProgramDocument";
}

- (NSData *)dataRepresentationOfType:(NSString *)type {
    // Implement to provide a persistent data representation of your document OR remove this and implement the file-wrapper or file path based save methods.

	// Commit editing
	[programController commitEditing];
	// Archive data
	return [NSKeyedArchiver archivedDataWithRootObject:program];
}

- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)type {
    // Implement to load a persistent data representation of your document OR remove this and implement the file-wrapper or file path based load methods.
	TVProgram *pr = [NSKeyedUnarchiver unarchiveObjectWithData:data];

	if (pr == nil)
	{
		return NO;
	}
	else
	{
		[self setProgram:pr];
		return YES;
	}
}

#pragma mark === Accessors ===

- (void)setProgram:(TVProgram *)pr
{
	[pr retain];
	[program release];
	program = pr;
}

- (TVProgram *)program
{
	return program;
}

@end
