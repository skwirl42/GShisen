//
//  boardview.m
//  GShisen
//
//  Created by James Dessart on 2021-01-24.
//

#import "GSBoardView.h"

@implementation GSBoardView

@synthesize shisenBoard;

- (void)awakeFromNib
{
    defaults = [NSUserDefaults standardUserDefaults];
    
    self.shisenBoard = [[GSBoard alloc] initialize:self];
    
    [self newGameActions];
}

- (void)dealloc
{
    [self.shisenBoard release];
    [super dealloc];
}

- (void)endOfGameActions
{
    if (timer && [timer isValid])
    {
        [timer invalidate];
        timer = nil;
    }
}

- (void)newGameActions
{
    if(timer && !self.shisenBoard.hadEndOfGame) {
        if([timer isValid])
        {
            [timer invalidate];
            timer = nil;
        }
    }
    if(timeField) {
        [timeField removeFromSuperview];
        [timeField release];
    }

    timeField = [[NSTextField alloc] initWithFrame:NSMakeRect(10, 5, 60, 15)];
    [timeField setFont: [NSFont systemFontOfSize: 10]];
    [timeField setAlignment:NSTextAlignmentCenter];
    [timeField setBezeled:NO];
    [timeField setEditable:NO];
    [timeField setSelectable:NO];
    [timeField setStringValue:@"00:00"];
    [self addSubview: timeField];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self
                   selector:@selector(timestep:) userInfo:nil repeats:YES];
    
    [self resizeWithOldSuperviewSize: self.bounds.size];
}

- (void)timestep:(NSTimer *)t
{
    NSString *timeStr;

    if(self.shisenBoard.gameState == GSGameStateRunning)
    {
        self.shisenBoard.seconds++;
        if(self.shisenBoard.seconds == 60) {
            self.shisenBoard.seconds = 0;
            self.shisenBoard.minutes++;
        }
    }
    timeStr = [NSString stringWithFormat:@"%02i:%02i", self.shisenBoard.minutes, self.shisenBoard.seconds];
    [timeField setStringValue: timeStr];
    [timeField setNeedsDisplay: YES];
}

- (IBAction)showHallOfFameWindow:(id)sender
{
    if (hallOfFameWindow)
    {
        [hallOfFameWindow updateScores];
        [hallOfFameWindow makeKeyAndOrderFront:self];
    }
}

- (IBAction)simulateWin:(id)sender
{
    [self.shisenBoard endOfGame];
    [self setNeedsDisplay:YES];
}

- (IBAction)clearScores:(id)sender
{
    NSAlert *confirmationAlert = [NSAlert new];
    
    confirmationAlert.alertStyle = NSAlertStyleWarning;
    confirmationAlert.messageText = NSLocalizedString(@"GSClearScoresConfirmation", "Alert text for clearing the high scores");
    confirmationAlert.informativeText = NSLocalizedString(@"GSClearScoresConfirmationInfoText", "Additional information when prompting for score deletion");
    [confirmationAlert addButtonWithTitle:NSLocalizedString(@"GSGeneralAlertOK", "The text on an OK button in an alert")];
    [confirmationAlert addButtonWithTitle:NSLocalizedString(@"GSGeneralAlertCancel", "The text on a Cancel button in an alert")];
    
    [confirmationAlert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn)
        {
            [self.shisenBoard clearScores];
        }
    }];
}

- (void)resizeWithOldSuperviewSize:(NSSize)oldFrameSize
{
    GSTile *tile;
    int hcount = 0;
    int vcount = 0;
    int hpos = -30;
    int vpos = [self frame].size.height -10;

    for(int i = 0; i < [self.shisenBoard.tiles count]; i++)
    {
        tile = [self.shisenBoard.tiles objectAtIndex: i];
        [tile setPositionOnBoard: hcount posy: vcount];
        [tile setFrame: NSMakeRect(hpos, vpos, 40, 56)];
        [self setNeedsDisplayInRect: [tile frame]];
        hpos += 40;
        hcount++;
        if(hcount == 20)
        {
            hcount = 0;
            vcount++;
            hpos = -30;
            vpos -= 56;
        }
    }
}

#if !defined(__APPLE__)
// on macOS this is all handled by connections in the nib
- (BOOL)performKeyEquivalent:(NSEvent *)theEvent
{
    NSString *commchar = [theEvent charactersIgnoringModifiers];

    if([commchar isEqualToString: @"n"])
    {
        [self.shisenBoard newGame];
        return YES;
    }
    if([commchar isEqualToString: @"g"] && !shisenBoard.hadEndOfGame)
    {
        [self.shisenBoard getHint];
        return YES;
    }
    if([commchar isEqualToString: @"z"] && !shisenBoard.hadEndOfGame)
    {
        [self.shisenBoard undo];
        return YES;
    }
#if defined(DEBUG) && DEBUG
    // end game without saving score
    if([commchar isEqualToString: @"0"] && !shisenBoard.hadEndOfGame)
    {
        shisenBoard.ignoreScore = YES;
        [self.shisenBoard endOfGame];
        return YES;
    }
    
    // end game, setting minutes and seconds to 4:30
    if([commchar isEqualToString: @"`"] && !shisenBoard.hadEndOfGame)
    {
        shisenBoard.minutes = 4;
        shisenBoard.seconds = 30;
        [self.shisenBoard endOfGame];
        return YES;
    }
    
    // end game, setting minutes and seconds to 10:00
    if([commchar isEqualToString: @"\\"] && !shisenBoard.hadEndOfGame)
    {
        shisenBoard.minutes = 10;
        shisenBoard.seconds = 0;
        [self.shisenBoard endOfGame];
        return YES;
    }
#endif // DEBUG

    return NO;
}
#endif // !defined(__APPLE__)

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
    if(self.shisenBoard.gameState == GSGameStatePaused && !self.shisenBoard.hadEndOfGame) {
        [pauseString drawAtPoint:drawLocation withAttributes:fontDict1];
        [pauseString drawAtPoint:drawLocation2 withAttributes:fontDict2];
    }
    else if(self.shisenBoard.hadEndOfGame) {
        [gameOverString drawAtPoint:drawLocation withAttributes:fontDict1];
        [gameOverString drawAtPoint:drawLocation2 withAttributes:fontDict2];
    }
}

- (void)newGame
{
    [self.shisenBoard newGame];
    [self newGameActions];
}

- (void)pause
{
    if (!self.shisenBoard.hadEndOfGame)
    {
        [self.shisenBoard pause];
        [self setNeedsDisplay:YES];
    }
}

- (void)undo
{
    [self.shisenBoard undo];
    [self setNeedsDisplay:YES];
}

- (void)getHint
{
    [self.shisenBoard getHint];
    [self setNeedsDisplay:YES];
}

- (void)addTile:(GSTile*)tile
{
    [self addSubview:tile];
}

- (void)displayNoMovesDialog
{
#ifdef __APPLE__
    NSAlert *alert = [NSAlert new];
    NSArray<NSString*> *buttonNames =
    @[
        NSLocalizedString(@"GSButtonTextNewGame", "Text for buttons that will start a new game"),
        NSLocalizedString(@"GSButtonTextQuit", "Text for buttons that will exit the application"),
        NSLocalizedString(@"GSButtonTextContinue", "Text for buttons that leave the game running (as opposed to a new game, or a quit action)")
    ];
    for (NSString *name in buttonNames)
    {
        [alert addButtonWithTitle:name];
        
    }
    alert.messageText = NSLocalizedString(@"GSAlertMessageTextNoMoreMoves", "Message text for an alert notifying the user that no more moves are possible");
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

- (NSString *)getUsername
{
    GSUserNameDialog *dlog = [[GSUserNameDialog alloc] initWithTitle: NSLocalizedString(@"GSWindowTitleHallOfFame", "Text to be used as a window title for windows involved in Hall of Fame operations")];
    [dlog center];

    NSString *lastUser = [defaults valueForKey:@"lastUser"];
    if (lastUser)
    {
        [dlog setEditFieldText:lastUser];
    }
    
    [dlog runModal];
    NSString *username = [dlog getEditFieldText];
    [dlog release];
    return username;
}

- (void)refresh
{
    [self setNeedsDisplay:YES];
}

- (void)showHallOfFameWithScores:(NSArray *)scores latestScore:(NSDictionary *)gameData
{
    if (gameData)
    {
#ifdef __APPLE__
        [hallOfFameWindow updateScoresWithRecentScore:gameData];
#else
        hallOfFameWindow = [[GSHallOfFameWin alloc] initWithScoreArray: scores recentScore: gameData];
#endif
    }
    else
    {
#ifdef __APPLE__
        [hallOfFameWindow updateScores];
#else
        hallOfFameWindow = [[GSHallOfFameWin alloc] initWithScoreArray: scores];
#endif
    }
    
    [hallOfFameWindow center];
    [hallOfFameWindow display];
    [hallOfFameWindow makeKeyAndOrderFront:self];
}

- (void)updateScores
{
    [hallOfFameWindow updateScores];
}

@end
