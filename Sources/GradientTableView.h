//
//  GradientTableView.m
//  GuidaTV
//
//  Created by delphine on 26-11-2006.
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


@interface GradientTableView : NSTableView {

	NSIndexSet *draggedRows;
	
	BOOL usesGradientSelection;
	BOOL selectionGradientIsContiguous;
	BOOL usesDisabledGradientSelectionOnly;
	BOOL hasBreakBetweenGradientSelectedRows;
	
	//NSMutableDictionary *regionList;
}

/* Useful for delegate when deciding how to colour text */
- (NSIndexSet *)draggedRows;

	// Gradient selection methods
	/* Sets whether the outline view should use gradient selection bars. */
- (void)setUsesGradientSelection:(BOOL)flag;
- (BOOL)usesGradientSelection;

	/* Sets whether gradient selections should be contiguous across multiple
	rows. (iTunes and Mail don't have this, but I think it looks better.) */
- (void)setSelectionGradientIsContiguous:(BOOL)flag;
- (BOOL)selectionGradientIsContiguous;

	/* Sets whether the selection should always look disabled (grey), even
	when the outline view has the focus (like in Mail) */
- (void)setUsesDisabledGradientSelectionOnly:(BOOL)flag;
- (BOOL)usesDisabledGradientSelectionOnly;

	/* Sets whether selected rows have a pixel gap between them that is the
	background colour rather than the selection colour */
- (void)setHasBreakBetweenGradientSelectedRows:(BOOL)flag;
- (BOOL)hasBreakBetweenGradientSelectedRows;

@end
