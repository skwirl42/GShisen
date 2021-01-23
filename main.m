#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
#include "gshisen.h"

void createMenu(void);

int main(int argc, char** argv) 
{
	id pool;
	NSApplication *theApp;

	pool = [NSAutoreleasePool new];

#if LIB_FOUNDATION_LIBRARY
  	[NSProcessInfo initializeWithArguments:argv count:argc environment:env];
#endif

	theApp = [NSApplication sharedApplication];
#ifdef __APPLE__
    NSArray *topLevelObjects = nil;
    if ([[NSBundle mainBundle] loadNibNamed:@"gshisen" owner:theApp topLevelObjects:&topLevelObjects])
    {
        [topLevelObjects retain];
    }
    else
    {
        NSLog(@"Couldn't load the main nib.");
        return -1;
    }
#else
    [theApp setDelegate: [GShisen sharedshisen]];
    createMenu();
#endif // __APPLE__
	[theApp run];
    
#ifdef __APPLE__
    [topLevelObjects release];
#endif // __APPLE__
    
	[pool release];
	return 0;
}

void createMenu()
{
	NSMenu *game;
	NSMenu *menu;
	NSMenu *infoMenu;

	menu = [[NSMenu alloc] initWithTitle:@"GShisen"];
	[[NSApplication sharedApplication] setMainMenu: menu];		

	[menu addItemWithTitle: @"Info" action: NULL keyEquivalent: @""];
	[menu addItemWithTitle:@"Game" action: NULL keyEquivalent:@""];
	[menu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@"q"];

	infoMenu = [NSMenu new];
	[infoMenu addItemWithTitle:@"Info Panel..." action:@selector(runInfoPanel:) keyEquivalent:@"i"];
	[menu setSubmenu:infoMenu forItem:[menu itemWithTitle:@"Info"]];

	game = [[NSMenu new] initWithTitle:@"Game"];
	[game addItemWithTitle:@"New Game" action:@selector(newGame:) keyEquivalent:@"n"];
	[game addItemWithTitle:@"Pause" action:@selector(pause:) keyEquivalent:@"p"];
	[game addItemWithTitle:@"Get hint" action:@selector(getHint:) keyEquivalent:@"g"];
	[game addItemWithTitle:@"Undo" action:@selector(undo:) keyEquivalent:@"z"];
        
	[game addItemWithTitle:@"Hall of Fame" action: NULL keyEquivalent:@""];

	[menu setSubmenu:game forItem:[menu itemWithTitle:@"Game"]];
	[[NSApplication sharedApplication] setMainMenu: menu];		
	[menu update];
}
