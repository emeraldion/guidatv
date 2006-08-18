#import "HyperLinkTextField.h"

@implementation HyperLinkTextField

- (void)awakeFromNib
{
	[self setTextColor:[NSColor blueColor]];
}

- (void)mouseDown:(NSEvent *)theEvent
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[self stringValue]]];
}

@end
