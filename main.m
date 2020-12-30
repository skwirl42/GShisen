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
	[theApp setDelegate: [GShisen sharedshisen]]; 
#ifdef __APPLE__
	[NSBundle loadNibNamed:@"gshisen" owner:theApp];
#endif // __APPLE__
	createMenu();
	[theApp run];
	[pool release];
	return 0;
}

void createMenu()
{
	NSMenu *game;
#ifdef __APPLE__
	NSMenu *mainMenu;
	mainMenu = [[NSApplication sharedApplication] mainMenu];
#else
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
#endif // __APPLE__

	game = [[NSMenu new] initWithTitle:@"Game"];
	[game addItemWithTitle:@"New Game" action:@selector(newGame:) keyEquivalent:@"n"];
	[game addItemWithTitle:@"Pause" action:@selector(pause:) keyEquivalent:@"p"];
	[game addItemWithTitle:@"Get hint" action:@selector(getHint:) keyEquivalent:@"g"];
	[game addItemWithTitle:@"Undo" action:@selector(undo:) keyEquivalent:@"z"];
        
	[game addItemWithTitle:@"Hall of Fame" action: NULL keyEquivalent:@""];

#ifdef __APPLE__
	[mainMenu addItemWithTitle:@"Game" action: NULL keyEquivalent: @""];
	[mainMenu update];
	[mainMenu setSubmenu:game forItem:[mainMenu itemWithTitle:@"Game"]];
	[[mainMenu itemWithTitle:@"Game"] setEnabled:YES];
#else
	[menu setSubmenu:game forItem:[menu itemWithTitle:@"Game"]];
	[[NSApplication sharedApplication] setMainMenu: menu];		
	[menu update];
#endif // __APPLE__
}
