#include "GSBoard.h"
#include "gshisen.h"
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

static NSInteger sortScores(id o1, id o2, void *context)
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

@implementation GSBoard

@synthesize gameState = gameState;
@synthesize tiles = tiles;
@synthesize ignoreScore = ignoreScore;
@synthesize hadEndOfGame = hadEndOfGame;
@synthesize minutes = minutes;
@synthesize seconds = seconds;
@synthesize endOfGameBlock;

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
    NSArray *tempArray = (NSMutableArray *)[[defaults arrayForKey:@"scores"] retain];
    if(!tempArray) {
        scores = [[NSMutableArray arrayWithCapacity:1] retain];
        [defaults setObject:scores forKey:@"scores"];
    }
    else {
        scores = [[NSMutableArray arrayWithCapacity:1] retain];
        [scores setArray:tempArray];
        [defaults setObject:scores forKey:@"scores"];
    }
    [defaults synchronize];
            
    hadEndOfGame = NO;
    ignoreScore = NO;
    undoArray = nil;
            
    [self newGame];
    
    return self;
}

- (void)dealloc
{
    [tiles release];
    [iconsNamesRefs release];
    [scores release];
    [undoArray release];
    [super dealloc];
}

- (void)undo
{
    GSTilePair *pairToUndo;
    if( [undoArray count] > 0 )
    {
        pairToUndo = [undoArray lastObject];
        [pairToUndo activateTiles];
        [undoArray removeObject:pairToUndo];
    }
    else
    {
        NSBeep();
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
    
    GSTile *tile;
    NSMutableArray *tmptiles = [NSMutableArray arrayWithCapacity: 144];
    for (int i = 0; i < iconsNamesRefs.count; i++) {
        for(int j = 0; j < 4; j++) {
            NSString *iconName = [iconsNamesRefs objectAtIndex:i];
            tile = [[GSTile alloc] initOnBoard: self
                                   iconRef: iconName group: i rndpos: rand() isBorderTile:NO];
            [tmptiles addObject: tile];
            [tile release];
        }
    }
    tmptiles = (NSMutableArray *)[tmptiles sortedArrayUsingFunction:randomizeTiles context:self];

    if(tiles) {
        for(int i = 0; i < [tiles count]; i++)
            [[tiles objectAtIndex: i] removeFromSuperview];
        [tiles release];
        tiles = nil;
    }
    tiles = [[NSMutableArray alloc] initWithCapacity: 200];
    int p = 0;
    BOOL isBorderTile;
    for(int i = 0; i < 200; i++) {
        isBorderTile = NO;
        for(int j = 0; j < 56; j++) {
            if(i == borderPositions[j]) {
                tile = [[GSTile alloc] initOnBoard: self 
                                       iconRef: nil group: -1 rndpos: -1 isBorderTile: YES];
                [tiles addObject: tile];
                [tile release];
                isBorderTile = YES;
            }
        }
        if(!isBorderTile) {
            [tiles addObject: [tmptiles objectAtIndex: p]];
            p++;
        }
    }

    for(int i = 0; i < [tiles count]; i++)
        [delegate addTile: [tiles objectAtIndex:i]];
		
    firstTile = nil;
    secondTile = nil;	
	
    seconds = 0;
    minutes = 0;

    hadEndOfGame = NO;
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
        if([self findPathBetweenTiles])	{
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

- (BOOL)findPathBetweenTiles
{
    int x1 = firstTile.x;
    int y1 = firstTile.y;
    int x2 = secondTile.x;
    int y2 = secondTile.y;
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
    
    [undoArray addObject:removedPair];
    
    [self verifyEndOfGame];
    [self unSetCurrentTiles];
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
    GSTile *tile;
    NSInteger i, j;
    BOOL found = NO;

    for(i = 0; i < [tiles count]; i++) {
        tile = [tiles objectAtIndex: i];
        if(tile.active && tile.selected)
            [tile deselect];
    }
	
    for(i = 0; i < [tiles count]; i++) {
        if(found)
            break;
        for(j = (i + 1); j < [tiles count]; j++) {
			firstTile = [tiles objectAtIndex: i];
			secondTile = [tiles objectAtIndex: j];
			if(firstTile.active && secondTile.active) {
				if(firstTile.group == secondTile.group) {
					if([self findPathBetweenTiles]) {
						found = YES;
						break;
					}
				}
			}
        }
    }
    if(found)
    {
        [firstTile highlight];
        [secondTile highlight];
        [[NSRunLoop currentRunLoop] runUntilDate: 
                                        [NSDate dateWithTimeIntervalSinceNow: 2]];
        tile = secondTile;
        [firstTile deselect];
        [tile deselect];									
    }
    else
    {
        [delegate displayNoMovesDialog];
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

- (void)endOfGame
{
    NSString *username;
    NSRange topScoreRange = {0, MAX_SCORES};

    hadEndOfGame = YES;
            
    [delegate endOfGameActions];
    
	// First, create a dummy scores entry for checking
    NSMutableDictionary *dummyData = [NSMutableDictionary dictionaryWithCapacity: 3];
	[dummyData setObject: @"dummy" forKey: @"username"];
	NSString *entry = [NSString stringWithFormat: @"%i", minutes];
	[dummyData setObject: entry forKey: @"minutes"];
	entry = [NSString stringWithFormat: @"%02i", seconds];
	[dummyData setObject: entry forKey: @"seconds"];
	
	// create a copy of the scores, adding the dummy entry
	NSMutableArray *tempScores = [scores mutableCopy];
	[tempScores addObject: dummyData];
	
	// Sort the scores, and only take the top ten
	[tempScores sortUsingFunction:sortScores context:self];
	
    NSArray *finalScores;
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
    NSMutableDictionary *gameData = nil;
	if( [finalScores containsObject: dummyData] && !ignoreScore )
	{
        username = [delegate getUsername];
        
        [defaults setValue:username forKey:@"lastUser"];
        [defaults synchronize];
		
		if( !ignoreScore )
		{
			// Create a scores entry
			gameData = [NSMutableDictionary dictionaryWithCapacity: 3];
			[gameData setObject: username forKey: @"username"];
			entry = [NSString stringWithFormat: @"%i", minutes];
			[gameData setObject: entry forKey: @"minutes"];
			entry = [NSString stringWithFormat: @"%02i", seconds];
			[gameData setObject: entry forKey: @"seconds"];
			
			// Make the new top 10 by taking the old top ten, adding
			// our score (with proper user name), then taking the top
			// of that array
			[scores addObject: gameData];
			
			[scores sortUsingFunction:sortScores context:self];
			
			if( [scores count] >= MAX_SCORES )
			{
				finalScores = [scores subarrayWithRange: topScoreRange];
				[scores release];
				scores = [finalScores mutableCopy];
				[scores retain];
			}
			
			[defaults setObject: scores forKey: @"scores"];
			[defaults synchronize];
		}
	}
    
    [delegate showHallOfFameWithScores:scores latestScore:gameData];
	
    seconds = 0;
    minutes = 0;

    ignoreScore = NO;
}

- (void)clearScores
{
    if (scores)
    {
        [scores autorelease];
    }
    scores = [[NSMutableArray arrayWithCapacity:1] retain];
    [defaults setObject:scores forKey:@"scores"];
    [defaults synchronize];
    
    [delegate updateScores];
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




