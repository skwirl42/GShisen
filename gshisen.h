#ifndef GSHISEN_H
#define GSHISEN_H

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#include "GSBoardView.h"

@interface GShisen : NSObject<NSApplicationDelegate>
{
#if !defined(__APPLE__)
	NSWindow *win;
#endif // !defined(__APPLE__)
    
	IBOutlet GSBoardView *board;
}

@property BOOL isDebug;

+ (GShisen *)sharedshisen;

- (IBAction)newGame:(id)sender;
- (IBAction)pause:(id)sender;
- (IBAction)getHint:(id)sender;
- (IBAction)undo:(id)sender;
- (IBAction)runInfoPanel:(id)sender;

@end

#endif // GSHISEN_H
