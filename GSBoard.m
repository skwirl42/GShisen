#include "GSBoard.h"
#include <sys/times.h>

#ifndef DEBUG
#define DEBUG   0
#endif

int min(int a, int b) {
    if(a < b)
    	return a;
    else
    	return b;
}

int max(int a, int b) {
    if(a > b)
    	return a;
    else
    	return b;
}

static NSInteger randomizeTiles(id o1, id o2, void *context)
{
    GSTile *t1 = o1;
    GSTile *t2 = o2;
    return [t1.randomPosition compare: t2.randomPosition];
}

static NSComparisonResult sortScores(id o1, id o2, void *context)
{
    NSDictionary *d1 = o1;
    NSDictionary *d2 = o2;
    int min1, min2, sec1, sec2;
	
    min1 = [[d1 objectForKey: @"minutes"] intValue];
    sec1 = [[d1 objectForKey: @"seconds"] intValue];
    sec1 += min1 * 60;
    min2 = [[d2 objectForKey: @"minutes"] intValue];
    sec2 = [[d2 objectForKey: @"seconds"] intValue];
    sec2 += min2 * 60;

    return [[NSNumber numberWithInt: sec1] compare: [NSNumber numberWithInt: sec2]];
}

@interface GSBoard (Private)
- (BOOL)findPathBetweenTile:(GSTile*)firstTile andTile:(GSTile*)secondTile;
- (BOOL)findSimplePathFromX1:(int)x1 y1:(int)y1 toX2:(int)x2 y2:(int)y2;
- (BOOL)canMakeLineFromX1:(int)x1 y1:(int)y1 toX2:(int)x2 y2:(int)y2;
@end

@implementation GSBoard

@synthesize gameState = gameState;
@synthesize tiles = tiles;
@synthesize ignoreScore = ignoreScore;
@synthesize hadEndOfGame;
@synthesize minutes = minutes;
@synthesize seconds = seconds;
@synthesize endOfGameBlock;
@synthesize waitingOnHint;
@synthesize scores = scores;

- (id)initialize:(id<GSBoardDelegate>)delegate
{
    self->delegate = delegate;
    seconds = 0;
    minutes = 0;
    tiles = nil;
    gameState = GSGameStatePaused;
    iconsNamesRefs = [[NSArray<NSString*> alloc] initWithObjects:@"1-1", @"1-2", @"1-3", @"1-4", @"2-1", @"2-2", @"2-3", @"2-4",
                                                                  @"3-1", @"3-2", @"3-3", @"3-4", @"4-1", @"4-2", @"4-3", @"4-4",
                                                                  @"5-1", @"5-2", @"5-3", @"5-4", @"6-1", @"6-2", @"6-3", @"6-4",
                                                                  @"7-1", @"7-2", @"7-3", @"7-4", @"8-1", @"8-2", @"8-3", @"8-4",
                                                                  @"9-1", @"9-2", @"9-3", @"9-4", nil];

    defaults = [NSUserDefaults standardUserDefaults];
    NSArray *tempArray = [[defaults arrayForKey:@"scores"] mutableCopy];
    if(!tempArray) {
        scores = [NSMutableArray arrayWithCapacity:1];
        [defaults setObject:scores forKey:@"scores"];
    }
    else {
        scores = [NSMutableArray arrayWithCapacity:1];
        [scores setArray:tempArray];
        [defaults setObject:scores forKey:@"scores"];
    }
    [defaults synchronize];
    
#if TARGET_OS_MACOS && !TARGET_OS_IOS
    [scores retain];
#endif
            
    hadEndOfGame = NO;
    ignoreScore = NO;
    undoArray = nil;
    
    return self;
}

#if TARGET_OS_MACOS && !TARGET_OS_IOS
- (void)dealloc
{
    [tiles release];
    [iconsNamesRefs release];
    [scores release];
    [undoArray release];
    [super dealloc];
}
#endif

- (BOOL)canUndo
{
    return undoArray.count > 0 && !hadEndOfGame;
}

- (void)undo
{
    GSTilePair *pairToUndo;
    if( [undoArray count] > 0 )
    {
        [self willChangeValueForKey:@"canUndo"];
        pairToUndo = [undoArray lastObject];
        [pairToUndo activateTiles];
        [undoArray removeObject:pairToUndo];
        [self didChangeValueForKey:@"canUndo"];
    }
    else
    {
#if TARGET_OS_MACOS && !TARGET_OS_IOS
        NSBeep();
#endif
    }
}

- (void)newGame
{
    int borderPositions[56] =
    {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
     20,                                                                39,
     40,                                                                59,
     60,                                                                79,
     80,                                                                99,
     100,                                                              119,
     120,                                                              139,
     140,                                                              159,
     160,                                                              179,
     180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 
     194, 195, 196, 197, 198, 199};

    clock_t t;
    struct tms dummy;
    t = times(&dummy);
    srand((int)t);

    if(undoArray != nil)
    {
        [undoArray removeAllObjects];
    }
    else
    {
        undoArray = [[NSMutableArray alloc] initWithCapacity: 72];
    }
    
    NSMutableArray *tmptiles = [NSMutableArray arrayWithCapacity: 144];
    for (int i = 0; i < iconsNamesRefs.count; i++)
    {
        for(int j = 0; j < 4; j++)
        {
            NSString *iconName = [iconsNamesRefs objectAtIndex:i];
            GSTile *tile = [delegate createTileWithIcon:iconName group: i rndpos: rand() isBorderTile:NO];
            [tmptiles addObject: tile];
        }
    }
    tmptiles = (NSMutableArray *)[tmptiles sortedArrayUsingFunction:randomizeTiles context:nil];

    if(tiles)
    {
        for (GSTile *tile in tiles)
        {
            [delegate removeTile:tile];
        }
            
        [tiles removeAllObjects];
    }
    else
    {
        tiles = [[NSMutableArray alloc] initWithCapacity: 200];
    }
    
    int p = 0;
    BOOL isBorderTile;
    for(int i = 0; i < 200; i++)
    {
        isBorderTile = NO;
        for(int j = 0; j < 56; j++)
        {
            if(i == borderPositions[j])
            {
                isBorderTile = YES;
                GSTile *tile = [delegate createTileWithIcon:nil group:-1 rndpos:-1 isBorderTile:isBorderTile];
                [tiles addObject: tile];
            }
        }
        if(!isBorderTile)
        {
            [tiles addObject: [tmptiles objectAtIndex: p]];
            p++;
        }
    }

    for (GSTile *tile in tiles)
    {
        [delegate addTile: tile];
    }
		
    firstTile = nil;
    secondTile = nil;	
	
    seconds = 0;
    minutes = 0;

    [self willChangeValueForKey:@"hadEndOfGame"];
    hadEndOfGame = NO;
    [self didChangeValueForKey:@"hadEndOfGame"];
    [self willChangeValueForKey:@"canUndo"];
    [self didChangeValueForKey:@"canUndo"];
    gameState = GSGameStateRunning;
}

- (int)prepareTilesToRemove:(GSTile *)clickedTile
{
    if(!firstTile) {
        firstTile = clickedTile;
        return 1;
    }
    secondTile = clickedTile;
	
    if([firstTile group] == [secondTile group])
    {
        if([self findPathBetweenTile:firstTile andTile:secondTile])	{
            return 2;
        }
        else {
            [firstTile deselect];
            firstTile = clickedTile;
            secondTile = nil;
            return 1;
        }
    }
    else
    {
        [firstTile deselect];
        firstTile = clickedTile;
        secondTile = nil;
        return 1;
    }

    return 0;
}

- (BOOL)findPathBetweenTile:(GSTile*)tileA andTile:(GSTile*)tileB
{
    int x1 = tileA.x;
    int y1 = tileA.y;
    int x2 = tileB.x;
    int y2 = tileB.y;
    int dx[4] = {1, 0, -1, 0};
    int dy[4] = {0, 1, 0, -1};
    int newx, newy, i;

    if([self findSimplePathFromX1:x1 y1:y1 toX2:x2 y2:y2])
        return YES;
		
    for(i = 0; i < 4; i++) {
        newx = x1 + dx[i];
        newy = y1 + dy[i];

        while(![self tileAtX:newx y:newy].active
              && newx >= 0 && newx < 20 && newy >= 0 && newy < 10) {

            if([self findSimplePathFromX1:newx y1:newy toX2:x2 y2:y2])
                return YES;

            newx += dx[i];
            newy += dy[i];
        }
    }
		
    return NO;		
}

- (BOOL)findSimplePathFromX1:(int)x1 y1:(int)y1 toX2:(int)x2 y2:(int)y2
{
    GSTile *tile;
    BOOL r = NO;

    if([self canMakeLineFromX1:x1 y1:y1 toX2:x2 y2:y2]) {
        r = YES;
    } else {
        if(!(x1 == x2 || y1 == y2)) {
            tile = [self tileAtX:x2 y:y1];
            if(!tile.active
               && [self canMakeLineFromX1:x1 y1:y1 toX2:x2 y2:y1]
               && [self canMakeLineFromX1:x2 y1:y1 toX2:x2 y2:y2]) {
                r = YES;
            } else {
                tile = [self tileAtX:x1 y:y2];
                if(!tile.active
                   && [self canMakeLineFromX1:x1 y1:y1 toX2:x1 y2:y2]
                   && [self canMakeLineFromX1:x1 y1:y2 toX2:x2 y2:y2]) {
                    r = YES;
                }
            }
        }
    }
	
    return r;
}

- (BOOL)canMakeLineFromX1:(int)x1 y1:(int)y1 toX2:(int)x2 y2:(int)y2
{
    NSArray *lineOfTiles;
    GSTile *tile;
    int i;
	
    if(x1 == x2) {
        lineOfTiles = [self tilesAtX: x1];
    	for(i = min(y1, y2)+1; i < max(y1, y2); i++) {
            tile = [lineOfTiles objectAtIndex: i];
            if(tile.active)
                return NO;
        }
        return YES;
    }
	
    if(y1 == y2) {
        lineOfTiles = [self tilesAtY: y1];
    	for(i = min(x1, x2)+1; i < max(x1, x2); i++) {
            tile = [lineOfTiles objectAtIndex: i];
            if(tile.active)
                return NO;
        }
        return YES;
    }	
	
    return NO;
}

- (void)removeCurrentTiles
{
    GSTilePair *removedPair;
    
    [firstTile deactivate];
    [secondTile deactivate];

    removedPair = [[GSTilePair alloc] initWithTile:firstTile andTile:secondTile];
    
    [self willChangeValueForKey:@"canUndo"];
    [undoArray addObject:removedPair];
    [self didChangeValueForKey:@"canUndo"];
    
    [self verifyEndOfGame];
    [self unSetCurrentTiles];
    
    // Check if a move can be made each time a move is made,
    // so we can notify the user that they're chasing ghosts
    if (![self getHintPair])
    {
        [self->delegate displayNoMovesDialog];
    }
}

- (void)unSetCurrentTiles
{
    firstTile = nil;
    secondTile = nil;		
}

- (void)verifyEndOfGame
{
    int i;
    BOOL found = NO;

    for(i = 0; i < [tiles count]; i++) {
        firstTile = [tiles objectAtIndex: i];
        if(firstTile.active) {
            found = YES;
            firstTile = nil;
            break;
        }
    }
    if(!found) {
        [self endOfGame];
        return;
    }
}

- (void)getHint
{
    for(int i = 0; i < [tiles count]; i++)
    {
        GSTile *tile = [tiles objectAtIndex: i];
        if(tile.active && tile.selected)
        {
            [tile deselect];
        }
    }

    GSTilePair *hintPair = [self getHintPair];
    if (hintPair)
    {
        firstTile = hintPair.firstTile;
        secondTile = hintPair.secondTile;
        [firstTile highlight];
        [secondTile highlight];
        self.waitingOnHint = YES;
        [[NSRunLoop currentRunLoop] runUntilDate:
                                        [NSDate dateWithTimeIntervalSinceNow: 2]];
        GSTile *tile = secondTile;
        [firstTile deselect];
        [tile deselect];
        self.waitingOnHint = NO;
    }
    else
    {
        [delegate displayNoMovesDialog];
    }
}

- (GSTilePair*)getHintPair
{
    GSTile *tileA;
    GSTile *tileB;
    for(int i = 0; i < [tiles count]; i++)
    {
        for(int j = (i + 1); j < [tiles count]; j++)
        {
            tileA = [tiles objectAtIndex: i];
            tileB = [tiles objectAtIndex: j];
            if(tileA.active && tileB.active && tileA.group == tileB.group && [self findPathBetweenTile:tileA andTile:tileB])
            {
                return [[GSTilePair alloc] initWithTile:tileA andTile:tileB];
            }
        }
    }
    
    return nil;
}

- (void)setPause:(BOOL)doPause
{
    if (hadEndOfGame)
    {
        return;
    }
    
    if (doPause && gameState == GSGameStateRunning)
    {
        gameState = GSGameStatePaused;
    }
    else if (!doPause && gameState == GSGameStatePaused)
    {
        gameState = GSGameStateRunning;
    }
}

- (void)pause
{
    if(gameState == GSGameStatePaused) {
        gameState = GSGameStateRunning;
    } else if(gameState == GSGameStateRunning) {
        gameState = GSGameStatePaused;
    }
    [delegate refresh];
}

- (void)showScoresPostGame:(NSDictionary*)gameData
{
    [delegate showHallOfFameWithScores:scores latestScore:gameData];
    
    seconds = 0;
    minutes = 0;

    ignoreScore = NO;
    
    [delegate refresh];
}

- (void)endOfGame
{
    NSRange topScoreRange = {0, MAX_SCORES};

    [self willChangeValueForKey:@"hadEndOfGame"];
    hadEndOfGame = YES;
    [self didChangeValueForKey:@"hadEndOfGame"];
    [self willChangeValueForKey:@"canUndo"];
    [self didChangeValueForKey:@"canUndo"];

    [delegate endOfGameActions];
    
	// First, create a dummy scores entry for checking
    NSMutableDictionary *dummyData = [NSMutableDictionary dictionaryWithCapacity: 3];
	[dummyData setObject: @"dummy" forKey: @"username"];
	__block NSString *entry = [NSString stringWithFormat: @"%i", minutes];
	[dummyData setObject: entry forKey: @"minutes"];
	entry = [NSString stringWithFormat: @"%02i", seconds];
	[dummyData setObject: entry forKey: @"seconds"];
	
    scores = [[defaults objectForKey:@"scores"] mutableCopy];
    
	// create a copy of the scores, adding the dummy entry
	NSMutableArray *tempScores = [scores mutableCopy];
	[tempScores addObject: dummyData];
	
	// Sort the scores, and only take the top ten
    [tempScores sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return sortScores(obj1, obj2, nil);
    }];
	
    __block NSArray *finalScores;
	if( [tempScores count] < MAX_SCORES )
	{
		finalScores = [tempScores copy];
	}
	else
	{
		finalScores = [tempScores subarrayWithRange: topScoreRange];
	}
	
    gameState = GSGameStatePaused;
	
	// Are we in the top ten?
    __block NSMutableDictionary *gameData = nil;
	if( [finalScores containsObject: dummyData] && !ignoreScore )
	{
        [delegate getUsername:^(NSString *username) {
            if (username != nil)
            {
                [self->defaults setValue:username forKey:@"lastUser"];
                [self->defaults synchronize];
                
                if( !self->ignoreScore )
                {
                    // Create a scores entry
                    gameData = [NSMutableDictionary dictionaryWithCapacity: 3];
                    [gameData setObject: username forKey: @"username"];
                    entry = [NSString stringWithFormat: @"%i", self->minutes];
                    [gameData setObject: entry forKey: @"minutes"];
                    entry = [NSString stringWithFormat: @"%02i", self->seconds];
                    [gameData setObject: entry forKey: @"seconds"];
                    
                    // Make the new top 10 by taking the old top ten, adding
                    // our score (with proper user name), then taking the top
                    // of that array
                    [self->scores addObject: gameData];
                    
                    [self->scores sortUsingFunction:sortScores context:nil];
                    
                    if( [self->scores count] >= MAX_SCORES )
                    {
        #if TARGET_OS_MACOS && !TARGET_OS_IOS
                        NSArray *oldScores = scores;
        #endif
                        finalScores = [self->scores subarrayWithRange: topScoreRange];
                        self->scores = [finalScores mutableCopy];
                        
        #if TARGET_OS_MACOS && !TARGET_OS_IOS
                        [oldScores release];
                        [scores retain];
        #endif
                    }
                    
                    [self->defaults setObject: self->scores forKey: @"scores"];
                    [self->defaults synchronize];
                }
            }
            
            [self showScoresPostGame:gameData];
        }];
	}
    else
    {
        [self showScoresPostGame:gameData];
    }
}

- (void)clearScores
{
    if (scores)
    {
#if TARGET_OS_MACOS && !TARGET_OS_IOS
        [scores autorelease];
#endif
        scores = nil;
    }

    scores = [NSMutableArray arrayWithCapacity:1];
    [defaults setObject:scores forKey:@"scores"];
    [defaults synchronize];
    
    [delegate updateScores];
    
#if TARGET_OS_MACOS && !TARGET_OS_IOS
    [scores retain]
#endif
}

- (NSArray *)tilesAtX:(int)xpos
{
    NSMutableArray *tls = [NSMutableArray arrayWithCapacity: 1];
    for(int i = 0; i < [tiles count]; i++) {
        GSTile *tile = [tiles objectAtIndex: i];
        if(tile.x == xpos)
            [tls addObject: tile];
    }
    return tls;
}

- (NSArray *)tilesAtY:(int)ypos
{
    NSMutableArray *tls = [NSMutableArray arrayWithCapacity: 1];
    for(int i = 0; i < [tiles count]; i++) {
        GSTile *tile = [tiles objectAtIndex: i];
        if(tile.y == ypos)
            [tls addObject: tile];
    }
    return tls;
}

- (GSTile *)tileAtX:(int)xpos y:(int)ypos
{
    for(int i = 0; i < [tiles count]; i++) {
        GSTile *tile = [tiles objectAtIndex: i];
        if((tile.x == xpos) && (tile.y == ypos))
            return tile;
    }
    return nil;
}

@end




