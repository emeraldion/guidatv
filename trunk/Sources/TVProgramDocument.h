//
//  TVProgramDocument.h
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

#import <Cocoa/Cocoa.h>
#import "TVProgram.h"

@interface TVProgramDocument : NSDocument {

	IBOutlet NSObjectController *programController;
	TVProgram *program;
}

@end
