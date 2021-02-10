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
    GSGameStateFinished = 2,
};

#define MAX_SCORES			10

@interface GSBoard : NSObject
{
    id<GSBoardDelegate> delegate;
	NSUserDefaults *defaults;
	NSMutableArray* scores;
	NSArray<NSString*> *iconsNamesRefs;
	NSMutableArray<GSTile*> *tiles;
    GSTile *firstTile;
    GSTile *secondTile;
    NSMutableArray<GSTilePair*> *undoArray;
    GSGameState gameState;
    int seconds;
    int minutes;
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
@property (strong) NSArray *scores;

- (id)initialize:(id<GSBoardDelegate>)delegate;
- (void)newGame;
- (void)undo;
- (void)pause;
- (void)setPause:(BOOL)doPause;
- (void)getHint;
- (GSTilePair*)getHintPair;
- (void)verifyEndOfGame;
- (void)endOfGame;
- (NSArray *)tilesAtX:(int)xpos;
- (NSArray *)tilesAtY:(int)ypos;
- (GSTile *)tileAtX:(int)xpos y:(int)ypos;
- (BOOL)canUndo;

- (int)prepareTilesToRemove:(GSTile *)clickedTile;
- (void)removeCurrentTiles;
- (void)unSetCurrentTiles;

- (void)clearScores;

@end

#endif // BOARD_H
