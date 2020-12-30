#ifndef BOARD_H
#define BOARD_H

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#include "tile.h"
#include "gsdialogs.h"
#include "tilepair.h"

typedef NS_ENUM(NSInteger, GSGameState) {
    GSGameStatePaused = 0,
    GSGameStateRunning = 1,
};

#define MAX_SCORES			15

@interface GSBoard : NSView
{
	NSUserDefaults *defaults;
	NSMutableArray *scores;
	NSArray<NSString*> *iconsNamesRefs;
	NSMutableArray<GSTile*> *tiles;
    GSTile *firstTile;
    GSTile *secondTile;
	NSTextField *timeField;
	NSTimer *tmr;
    NSMutableArray<GSTilePair*> *undoArray;
    GSGameState gameState;
    int seconds;
    int minutes;
    BOOL hadEndOfGame;
    BOOL ignoreScore;
}

- (id)initWithFrame:(NSRect)frameRect;
- (void)newGame;
- (void)undo;
- (void)timestep:(NSTimer *)t;
- (int)prepareTilesToRemove:(GSTile *)clickedTile;
- (void)removeCurrentTiles;
- (BOOL)findPathBetweenTiles;
- (BOOL)findSimplePathFromX1:(int)x1 y1:(int)y1 toX2:(int)x2 y2:(int)y2;
- (BOOL)canMakeLineFromX1:(int)x1 y1:(int)y1 toX2:(int)x2 y2:(int)y2;
- (void)unSetCurrentTiles;
- (void)pause;
- (void)getHint;
- (void)verifyEndOfGame;
- (void)endOfGame;
- (NSArray *)tilesAtX:(int)xpos;
- (NSArray *)tilesAtY:(int)ypos;
- (GSTile *)tileAtX:(int)xpos y:(int)ypos;
- (GSGameState)gameState;

@end

#endif // BOARD_H
