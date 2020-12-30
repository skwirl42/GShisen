#include "board.h"
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
    return [[t1 rndpos] compare: [t2 rndpos]];
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

- (id)initWithFrame:(NSRect)frameRect
{
    NSArray *tempArray;
    self = [super initWithFrame:frameRect];
    if(self) {
        seconds = 0;
        minutes = 0;
        tiles = nil;
        timeField = nil;
        tmr = nil;
        gameState = GAME_STATE_PAUSED;
        iconsNamesRefs = [[NSArray alloc] initWithObjects:
                                          @"1-1", @"1-2", @"1-3", @"1-4", @"2-1", @"2-2", @"2-3", @"2-4",
                                          @"3-1", @"3-2", @"3-3", @"3-4", @"4-1", @"4-2", @"4-3", @"4-4",
                                          @"5-1", @"5-2", @"5-3", @"5-4", @"6-1", @"6-2", @"6-3", @"6-4",
                                          @"7-1", @"7-2", @"7-3", @"7-4", @"8-1", @"8-2", @"8-3", @"8-4",
                                          @"9-1", @"9-2", @"9-3", @"9-4", nil]; 

        defaults = [NSUserDefaults standardUserDefaults];
        tempArray = (NSMutableArray *)[[defaults arrayForKey:@"scores"] retain];
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
    }
    return self;
}

- (void)dealloc
{
    [tiles release];
    [iconsNamesRefs release];
    [timeField release];
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
    NSMutableArray *tmptiles;
    GSTile *tile;
    NSString *ref;
    clock_t t;
    struct tms dummy;
    int i, j, p;
    BOOL bordt;
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
    t = times(&dummy); 
    srand((int)t);

    if(undoArray != nil)
    {
        [undoArray removeAllObjects];
        [undoArray release];
        undoArray = nil;
    }
    undoArray = [[NSMutableArray alloc] initWithCapacity: 72];
    
    tmptiles = [NSMutableArray arrayWithCapacity: 144];
    for(i = 0; i < [iconsNamesRefs count]; i++) {
        for(j = 0; j < 4; j++) {
            ref = [iconsNamesRefs objectAtIndex: i];
            tile = [[GSTile alloc] initOnBoard: self 
                                   iconRef: ref group: i rndpos: rand() isBorderTile:NO];
            [tmptiles addObject: tile];
            [tile release];
        }
    }
    tmptiles = (NSMutableArray *)[tmptiles sortedArrayUsingFunction:randomizeTiles context:self];

    if(tmr && !hadEndOfGame) {
        if([tmr isValid])
            [tmr invalidate];
    }
    if(timeField) {
        [timeField removeFromSuperview];
        [timeField release];
    }	

    if(tiles) {
        for(i = 0; i < [tiles count]; i++)
            [[tiles objectAtIndex: i] removeFromSuperview];
        [tiles release];
        tiles = nil;
    }
    tiles = [[NSMutableArray alloc] initWithCapacity: 200];
	
    p = 0;
    for(i = 0; i < 200; i++) {
        bordt = NO;
        for(j = 0; j < 56; j++) {
            if(i == borderPositions[j]) {
                tile = [[GSTile alloc] initOnBoard: self 
                                       iconRef: nil group: -1 rndpos: -1 isBorderTile: YES];
                [tiles addObject: tile];
                [tile release];
                bordt = YES;
            }
        }
        if(!bordt) {
            [tiles addObject: [tmptiles objectAtIndex: p]];
            p++;
        }
    }

    for(i = 0; i < [tiles count]; i++) 
        [self addSubview: [tiles objectAtIndex:i]];
		
    firstTile = nil;
    secondTile = nil;	
	
    timeField = [[NSTextField alloc] initWithFrame:NSMakeRect(10, 5, 60, 15)];
    [timeField setFont: [NSFont systemFontOfSize: 10]];
    [timeField setAlignment:NSTextAlignmentCenter];
    [timeField setBezeled:NO];
    [timeField setEditable:NO];
    [timeField setSelectable:NO];
    [timeField setStringValue:@"00:00"];
    [self addSubview: timeField];
		
    [self resizeWithOldSuperviewSize: [self frame].size];
	
    seconds = 0;
    minutes = 0;

    tmr = [NSTimer scheduledTimerWithTimeInterval:1 target:self 
                   selector:@selector(timestep:) userInfo:nil repeats:YES];
    hadEndOfGame = NO;
    gameState = GAME_STATE_RUNNING;
}

- (void)timestep:(NSTimer *)t
{
    NSString *timeStr;

    if(gameState == GAME_STATE_RUNNING)
    {
        seconds++;
        if(seconds == 60) {
            seconds = 0;
            minutes++;
        }
    }
    timeStr = [NSString stringWithFormat:@"%02i:%02i", minutes, seconds];
    [timeField setStringValue: timeStr];
    [timeField setNeedsDisplay: YES];
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
        if([self findPathBetweenTiles])	
            return 2;
        else
        {
            [firstTile unselect];
            firstTile = clickedTile;
            secondTile = nil;
            return 1;
        }
    }
    else
    {
        [firstTile unselect];
        firstTile = clickedTile;
        secondTile = nil;
        return 1;
    }

    return 0;
}

- (BOOL)findPathBetweenTiles
{
    int x1 = [firstTile px];
    int y1 = [firstTile py];
    int x2 = [secondTile px];
    int y2 = [secondTile py];
    int dx[4] = {1, 0, -1, 0};
    int dy[4] = {0, 1, 0, -1};
    int newx, newy, i;

    if([self findSimplePathFromX1:x1 y1:y1 toX2:x2 y2:y2])
        return YES;
		
    for(i = 0; i < 4; i++) {
        newx = x1 + dx[i];
        newy = y1 + dy[i];

        while(![[self tileAtxPosition:newx yPosition:newy] isActive] 		
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
            tile = [self tileAtxPosition:x2 yPosition:y1];
            if(![tile isActive] 
               && [self canMakeLineFromX1:x1 y1:y1 toX2:x2 y2:y1]
               && [self canMakeLineFromX1:x2 y1:y1 toX2:x2 y2:y2]) {
                r = YES;
            } else {
                tile = [self tileAtxPosition:x1 yPosition:y2];
                if(![tile isActive] 
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
        lineOfTiles = [self tilesAtXPosition: x1];
    	for(i = min(y1, y2)+1; i < max(y1, y2); i++) {
            tile = [lineOfTiles objectAtIndex: i];
            if([tile isActive])
                return NO;
        }
        return YES;
    }
	
    if(y1 == y2) {
        lineOfTiles = [self tilesAtYPosition: y1];
    	for(i = min(x1, x2)+1; i < max(x1, x2); i++) {
            tile = [lineOfTiles objectAtIndex: i];
            if([tile isActive])
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
        if([firstTile isActive]) {
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
        if([tile isActive] && [tile isSelect])
            [tile unselect];
    }
	
    for(i = 0; i < [tiles count]; i++) {
        if(found)
            break;
        for(j = (i + 1); j < [tiles count]; j++) {
			firstTile = [tiles objectAtIndex: i];
			secondTile = [tiles objectAtIndex: j];
			if([firstTile isActive] && [secondTile isActive]) {
				if([firstTile group] == [secondTile group]) {
					if([self findPathBetweenTiles]) {
						found = YES;
						break;
					}
				}
			}
        }
    }
    if(found) {
        [firstTile hightlight];
        [secondTile hightlight];
        [[NSRunLoop currentRunLoop] runUntilDate: 
                                        [NSDate dateWithTimeIntervalSinceNow: 2]];
        tile = secondTile;
        [firstTile unselect];
        [tile unselect];									
    } else {
#ifdef __APPLE__
        NSAlert *alert = [NSAlert new];
        NSArray<NSString*> *buttonNames = @[@"New Game", @"Quit", @"Continue"];
        for (NSString *name in buttonNames)
        {
            [alert addButtonWithTitle:name];
            
        }
        alert.messageText = @"No more moves possible!";
        [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
            switch (returnCode)
            {
                case NSAlertFirstButtonReturn:
                    [self newGame];
                    break;
                    
                case NSAlertSecondButtonReturn:
                    [NSApp terminate:self];
                    break;
            }
        }];
#else
        NSInteger result = NSRunAlertPanel(nil, @"No more moves possible!", @"New Game", @"Quit", @"Continue");
        if(result == NSAlertDefaultReturn)
            [self newGame];
        else if (result == NSAlertAlternateReturn)
            [NSApp terminate:self];
#endif
     }
}

- (void)pause
{
    if(gameState == GAME_STATE_PAUSED) {
        gameState = GAME_STATE_RUNNING;
    } else if(gameState == GAME_STATE_RUNNING) {
        gameState = GAME_STATE_PAUSED;
    }
    [self setNeedsDisplay:YES];
}

- (void)endOfGame
{
    GSUserNameDialog *dlog;
    GSHallOfFameWin *hofWin;
    NSString *username;
    NSMutableDictionary *gameData = nil;
    NSMutableDictionary *dummyData = nil;;
	NSMutableArray *tempScores;
	NSArray *finalScores;
    NSString *entry;
	NSRange topScoreRange;

	topScoreRange.location = 0;
	topScoreRange.length = MAX_SCORES;

    hadEndOfGame = YES;
        
    if([tmr isValid])
        [tmr invalidate];
    
	// First, create a dummy scores entry for checking
	dummyData = [NSMutableDictionary dictionaryWithCapacity: 3];
	[dummyData setObject: @"dummy" forKey: @"username"];
	entry = [NSString stringWithFormat: @"%i", minutes];
	[dummyData setObject: entry forKey: @"minutes"];
	entry = [NSString stringWithFormat: @"%02i", seconds];
	[dummyData setObject: entry forKey: @"seconds"];
	
	// create a copy of the scores, adding the dummy entry
	tempScores = [scores mutableCopy];
	[tempScores addObject: dummyData];
	
	// Sort the scores, and only take the top ten
	[tempScores sortUsingFunction:sortScores context:self];
	
	if( [tempScores count] < MAX_SCORES )
	{
		finalScores = [tempScores copy];
	}
	else
	{
		finalScores = [tempScores subarrayWithRange: topScoreRange];
	}
	
    gameState = GAME_STATE_PAUSED;
	
	// Are we in the top ten?
	if( [finalScores containsObject: dummyData] && !ignoreScore )
	{
		dlog = [[GSUserNameDialog alloc] initWithTitle: @"Hall Of Fame"];
		[dlog center];

		[dlog runModal];
		username = [dlog getEditFieldText];
		[dlog release];
		
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
		
		hofWin = [[GSHallOfFameWin alloc] initWithScoreArray: scores recentScore: gameData];
	}
	else
	{
		// We didn't make it into the high scores! :(
		hofWin = [[GSHallOfFameWin alloc] initWithScoreArray: scores];
	}
	
    [hofWin center];
    [hofWin display];
    //[hofWin orderFront:nil];
    [hofWin makeKeyAndOrderFront:self];

    seconds = 0;
    minutes = 0;

    ignoreScore = NO;

    [self setNeedsDisplay:YES];
}

- (NSArray *)tilesAtXPosition:(int)xpos
{
    NSMutableArray *tls;
    GSTile *tile;
    int i;

    tls = [NSMutableArray arrayWithCapacity: 1];
    for(i = 0; i < [tiles count]; i++) {
        tile = [tiles objectAtIndex: i];
        if([tile px] == xpos)
            [tls addObject: tile];
    }
    return tls;
}

- (NSArray *)tilesAtYPosition:(int)ypos
{
    NSMutableArray *tls;
    GSTile *tile;
    int i;

    tls = [NSMutableArray arrayWithCapacity: 1];
    for(i = 0; i < [tiles count]; i++) {
        tile = [tiles objectAtIndex: i];
        if([tile py] == ypos)
            [tls addObject: tile];
    }
    return tls;
}

- (GSTile *)tileAtxPosition:(int)xpos yPosition:(int)ypos
{
    GSTile *tile;
    int i;

    for(i = 0; i < [tiles count]; i++) {
        tile = [tiles objectAtIndex: i];
        if(([tile px] == xpos) && ([tile py] == ypos))
            return tile;
    }
    return nil;
}

- (void)resizeWithOldSuperviewSize:(NSSize)oldFrameSize
{
    GSTile *tile;
    int i, hcount, vcount, hpos, vpos;

    vpos = [self frame].size.height -10;
    hpos = -30;
    hcount = 0;
    vcount = 0;
    for(i = 0; i < [tiles count]; i++) {
        tile = [tiles objectAtIndex: i];
        [tile setPositionOnBoard: hcount posy: vcount];			  
        [tile setFrame: NSMakeRect(hpos, vpos, 40, 56)];
        [self setNeedsDisplayInRect: [tile frame]];
        hpos += 40;
        hcount++;
        if(hcount == 20) {
            hcount = 0;
            vcount++;
            hpos = -30;
            vpos -= 56;
        }
    }
}

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent
{
    NSString *commchar = [theEvent charactersIgnoringModifiers];

    if([commchar isEqualToString: @"n"])
	{
        [self newGame];
        return YES;
    }
    if([commchar isEqualToString: @"g"] && !hadEndOfGame)
	{
        [self getHint];
        return YES;
    }
    if([commchar isEqualToString: @"z"] && !hadEndOfGame)
	{
        [self undo];
        return YES;
    }
#if defined(DEBUG) && DEBUG
	// end game without saving score
    if([commchar isEqualToString: @"0"] && !hadEndOfGame)
	{
        ignoreScore = YES;
        [self endOfGame];
        return YES;
    }
	
	// end game, setting minutes and seconds to 4:30
	if([commchar isEqualToString: @"`"] && !hadEndOfGame)
	{
		minutes = 4;
		seconds = 30;
		[self endOfGame];
		return YES;
	}
	
	// end game, setting minutes and seconds to 10:00
	if([commchar isEqualToString: @"\\"] && !hadEndOfGame)
	{
		minutes = 10;
		seconds = 0;
		[self endOfGame];
		return YES;
	}
#endif // DEBUG

    return NO;
}

- (void)drawRect:(NSRect)rect
{
    id font = [NSFont boldSystemFontOfSize:48];
    NSString *pauseString = @"Paused";
    NSString *gameOverString = @"Game Over";
    
    // arrays for dictionaries
    NSArray *keyArray = [NSArray arrayWithObjects:NSFontAttributeName, 
                            NSForegroundColorAttributeName, nil];
    NSArray *valueArray1 = [NSArray arrayWithObjects:font,
                            [NSColor colorWithCalibratedRed: 0.09 green: 0.3 blue: 0 alpha: 1], nil];
    NSArray *valueArray2 = [NSArray arrayWithObjects:font,
                            [NSColor colorWithCalibratedRed: 0.9 green: 0.9 blue: 1 alpha: 1], nil];
    
    // attribute dictionaries
    NSDictionary *fontDict1 = [NSDictionary dictionaryWithObjects:valueArray1 forKeys:keyArray];
    NSDictionary *fontDict2 = [NSDictionary dictionaryWithObjects:valueArray2 forKeys:keyArray];
    
    // drawing locations
    NSPoint drawLocation = { 260, 256 };
    NSPoint drawLocation2 = { 256, 260 };

    [[NSColor colorWithCalibratedRed: 0.1 green: 0.47 blue: 0 alpha: 1] set];
    NSRectFill(rect);
    if(gameState == GAME_STATE_PAUSED && !hadEndOfGame) {
        [pauseString drawAtPoint:drawLocation withAttributes:fontDict1];
        [pauseString drawAtPoint:drawLocation2 withAttributes:fontDict2];
    }
    else if(hadEndOfGame) {
        [gameOverString drawAtPoint:drawLocation withAttributes:fontDict1];
        [gameOverString drawAtPoint:drawLocation2 withAttributes:fontDict2];
    }
}

- (int)gameState
{
    return gameState;
}

@end




