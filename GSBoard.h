#ifndef BOARD_H
#define BOARD_H

#import <Foundation/Foundation.h>
//#import <AppKit/AppKit.h>
#include "GSTile.h"
#include "GSTilePair.h"
#include "GSBoardDelegate.h"

typedef NS_ENUM(NSInteger, GSGameState) {
    GSGameStatePaused = 0,
    GSGameStateRunning = 1,
};

#define MAX_SCORES			15

@interface GSBoard : NSObject
{
    id<GSBoardDelegate> delegate;
	NSUserDefaults *defaults;
	NSMutableArray *scores;
	NSArray<NSString*> *iconsNamesRefs;
	NSMutableArray<GSTile*> *tiles;
    GSTile *firstTile;
    GSTile *secondTile;
    NSMutableArray<GSTilePair*> *undoArray;
    GSGameState gameState;
    int seconds;
    int minutes;
    BOOL hadEndOfGame;
    BOOL ignoreScore;
}

@property (readonly) GSGameState gameState;
@property (strong) NSMutableArray<GSTile*> *tiles;
@property int minutes;
@property int seconds;
@property BOOL ignoreScore;
@property BOOL hadEndOfGame;
@property BOOL waitingOnHint;
@property dispatch_block_t endOfGameBlock;

- (id)initialize:(id<GSBoardDelegate>)delegate;
- (void)newGame;
- (void)undo;
- (int)prepareTilesToRemove:(GSTile *)clickedTile;
- (void)removeCurrentTiles;
- (BOOL)findPathBetweenTiles;
- (BOOL)findSimplePathFromX1:(int)x1 y1:(int)y1 toX2:(int)x2 y2:(int)y2;
- (BOOL)canMakeLineFromX1:(int)x1 y1:(int)y1 toX2:(int)x2 y2:(int)y2;
- (void)unSetCurrentTiles;
- (void)pause;
- (void)setPause:(BOOL)doPause;
- (void)getHint;
- (void)verifyEndOfGame;
- (void)endOfGame;
- (NSArray *)tilesAtX:(int)xpos;
- (NSArray *)tilesAtY:(int)ypos;
- (GSTile *)tileAtX:(int)xpos y:(int)ypos;
- (BOOL)canUndo;

- (void)clearScores;

@end

#endif // BOARD_H
