#ifndef GSHISEN_H
#define GSHISEN_H

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#include "board.h"

@interface GShisen : NSObject<NSApplicationDelegate>
{
	NSWindow *win;
	GSBoard *board;
}

+ (GShisen *)sharedshisen;

- (void)method:menuCell;
- (void)newGame:(id)sender;
- (void)pause:(id)sender;
- (void)getHint:(id)sender;
- (void)undo:(id)sender;
- (void)runInfoPanel:(id)sender;

@end

#endif // GSHISEN_H
