#include "GSTilePair.h"
#include "GSTile.h"

@implementation GSTilePair

@synthesize firstTile = fTile1;
@synthesize secondTile = fTile2;

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

#if TARGET_OS_MACOS && !TARGET_OS_IOS
- (void)dealloc
{
    fTile1 = nil;
    fTile2 = nil;
    
    [super dealloc];
}
#endif // TARGET_OS_MACOS && !TARGET_OS_IOS

@end
