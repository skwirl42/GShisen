//
//  GSBoardDelegate.h
//  GShisen
//
//  Created by James Dessart on 2021-01-24.
//

#ifndef GSBoardDelegate_h
#define GSBoardDelegate_h

@class GSTile;

@protocol GSBoardDelegate <NSObject>

- (NSString*)getUsername;
- (void)showHallOfFameWithScores:(NSArray*)scores latestScore:(NSDictionary*)gameData;
- (void)addTile:(GSTile*)tile;
- (void)refresh;
- (void)displayNoMovesDialog;
- (void)updateScores;
- (void)endOfGameActions;

@end

#endif /* GSBoardDelegate_h */
