#ifndef TILEPAIR_H
#define TILEPAIR_H

#include <Foundation/Foundation.h>

@class GSTile;

@interface GSTilePair : NSObject
{
    GSTile __weak *fTile1;
    GSTile __weak *fTile2;
}

@property (weak) GSTile *firstTile;
@property (weak) GSTile *secondTile;

- (GSTilePair *)initWithTile:(GSTile *)tileOne andTile:(GSTile *)tileTwo;
- (void)activateTiles;

@end

#endif // TILEPAIR_H
