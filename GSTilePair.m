#include "GSTilePair.h"
#include "GSTile.h"

@implementation GSTilePair

- (GSTilePair *)initWithTile:(GSTile *)tileOne andTile:(GSTile *)tileTwo
{
    fTile1 = tileOne;
    fTile2 = tileTwo;
    return self;
}

- (void)activateTiles
{
    [fTile1 deselect];
    [fTile1 activate];
    [fTile2 deselect];
    [fTile2 activate];
}

- (void)dealloc
{
    fTile1 = nil;
    fTile2 = nil;
    [super dealloc];
}


@end
