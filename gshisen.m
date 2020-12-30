#include "gshisen.h"

static GShisen *sharedshisen = nil;

@implementation GShisen

+ (GShisen *)sharedshisen
{
    if(!sharedshisen) {
        NS_DURING
            {
                sharedshisen = [[self alloc] init];
            }
        NS_HANDLER
            {
                [localException raise];
            }
        NS_ENDHANDLER
            }
    return sharedshisen;
}

- (void)dealloc
{
    [board release];
    [win release];
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    unsigned int style = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable;

    win = [[NSWindow alloc] initWithContentRect: NSMakeRect(0, 0, 740, 490)
                            styleMask: style
                            backing: NSBackingStoreBuffered
                            defer: NO];
    [win setMaxSize: NSMakeSize(740, 520)];
    [win setMinSize: NSMakeSize(740, 490)];
    [win setTitle: @"GShisen"];
    board = [[GSBoard alloc] initWithFrame: NSMakeRect(0, 0, 740, 490)];
    [win setContentView: board];
    [win center];
    [win display];
    [win orderFront:nil];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)app 
{
    return NSTerminateNow;
}

- (void)newGame:(id)sender
{
    [board newGame];
}

- (void)pause:(id)sender
{
    [board pause];
}

- (void)undo:(id)sender
{
    [board undo];
}

- (void)getHint:(id)sender
{
    [board getHint];
}

- (void)method:menuCell
{

}

- (void)runInfoPanel:(id)sender
{
  NSMutableDictionary *d;

  d = [NSMutableDictionary new];
  [d setObject: @"GShisen" forKey: @"ApplicationName"];
  [d setObject: @"The first GNUstep Game!" 
     forKey: @"ApplicationDescription"];
  [d setObject: @"GShisen 1.1" forKey: @"ApplicationRelease"];
  [d setObject: @"Apr 2000" forKey: @"FullVersionID"];
  [d setObject: [NSArray arrayWithObjects: 
			   @"James Dessart <james@skwirl.ca>",
				@" Enrico Sersale <enrico@imago.ro>", nil]
     forKey: @"Authors"];
  [d setObject: @"See http://www.imago.ro/gshisen" forKey: @"URL"];
  [d setObject: @"Copyright (C) 1999, 2000 Free Software Foundation, Inc. - Portions (c) James Dessart"
     forKey: @"Copyright"];
  [d setObject: @"Released under the GNU General Public License 2.0"
     forKey: @"CopyrightDescription"];
  
  //[NSApp orderFrontStandardInfoPanelWithOptions:d];
}

@end

