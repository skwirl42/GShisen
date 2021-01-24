#ifndef TILEPAIR_H
#define TILEPAIR_H

#include <Foundation/Foundation.h>

@class GSTile;

@interface GSTilePair : NSObject
{
    GSTile *fTile1;
    GSTile *fTile2;
}

- (GSTilePair *)initWithTile:(GSTile *)tileOne andTile:(GSTile *)tileTwo;
- (void)activateTiles;

@end

#endif // TILEPAIR_H
