#ifndef GSHISEN_H
#define GSHISEN_H

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#include "board.h"

@interface GShisen : NSObject<NSApplicationDelegate>
{
	NSWindow *win;
	IBOutlet GSBoard *board;
}

+ (GShisen *)sharedshisen;

- (IBAction)newGame:(id)sender;
- (IBAction)pause:(id)sender;
- (IBAction)getHint:(id)sender;
- (IBAction)undo:(id)sender;
- (IBAction)runInfoPanel:(id)sender;

@end

#endif // GSHISEN_H
