#ifndef TILEPAIR_H
#define TILEPAIR_H

#include "tile.h"

@interface GSTilePair : NSObject
{
    GSTile *fTile1;
    GSTile *fTile2;
    
}

- (GSTilePair *)initWithTile:(GSTile *)tileOne andTile:(GSTile *)tileTwo;
- (void)activateTiles;

@end

#endif // TILEPAIR_H
