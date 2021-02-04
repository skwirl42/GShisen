//
//  GSBoardUIView.m
//  GShisen (iOS)
//
//  Created by James Dessart on 2021-01-24.
//

#import "GSBoardUIViewController.h"
#import "GSBoard.h"
#import "GSTileUIView.h"
#import "GSNameDialogController.h"

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

#define HINT_GESTURE_MIN_TRANSLATION 100

@interface GSBoardUIViewController ()
{
    NSMutableArray<GSTileUIView*> *tileViews;
    GSTilePair *hintPair;
    BOOL isShowingAlert;
    BOOL inHintGesture;
}
@end

@implementation GSBoardUIViewController

@synthesize board;
@synthesize onScoreUpdateCallback;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
//    [self.view setFrame:self.view.window.frame];
    
    defaults = [NSUserDefaults standardUserDefaults];
    tileViews = [[NSMutableArray<GSTileUIView*> alloc] init];
    
    self.board = [[GSBoard alloc] initialize:self];
    
    [self newGame:self];
    
    [board addObserver:self forKeyPath:@"canUndo" options:NSKeyValueObservingOptionNew context:nil];
    [board addObserver:self forKeyPath:@"hadEndOfGame" options:NSKeyValueObservingOptionNew context:nil];
    undoButton.enabled = NO;
    undoButton.userInteractionEnabled = NO;
    gameOverField.hidden = YES;
    isShowingAlert = NO;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"canUndo"])
    {
        undoButton.enabled = board.canUndo;
        undoButton.userInteractionEnabled = board.canUndo;
    }
    else if ([keyPath isEqualToString:@"hadEndOfGame"])
    {
        gameOverField.hidden = NO;
        getHintButton.enabled = NO;
        getHintButton.userInteractionEnabled = NO;
    }
}

- (GSTileUIView*)viewForTile:(GSTile*)tile
{
    for (GSTileUIView *view in tileViews)
    {
        if (view.tile == tile)
        {
            return view;
        }
    }
    
    return nil;
}

- (IBAction)newGame:(id)sender
{
    [self.board newGame];
    
    if(timer && !self.board.hadEndOfGame)
    {
        if([timer isValid])
        {
            [timer invalidate];
            timer = nil;
        }
    }

    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self
                   selector:@selector(timestep:) userInfo:nil repeats:YES];
    [self resize];
    gameOverField.hidden = YES;
    getHintButton.enabled = YES;
    getHintButton.userInteractionEnabled = YES;
}

- (void)timestep:(NSTimer *)t
{
    NSString *timeStr;

    if(self.board.gameState == GSGameStateRunning)
    {
        self.board.seconds++;
        if(self.board.seconds == 60)
        {
            self.board.seconds = 0;
            self.board.minutes++;
        }
    }
    timeStr = [NSString stringWithFormat:@"%02i:%02i", self.board.minutes, self.board.seconds];
    timeField.text = timeStr;
    [timeField setNeedsDisplay];
}

- (IBAction)pause:(id)sender
{
    [self.board pause];
}
    
- (IBAction)getHint:(id)sender
{
    [self.board getHint];
}

- (IBAction)undo:(id)sender
{
    [self.board undo];
}

- (IBAction)scrollUpdate:(id)sender
{
    CGPoint translation = [panRecognizer translationInView:self.view];
    if (!inHintGesture && panRecognizer.state == UIGestureRecognizerStateBegan)
    {
        inHintGesture = YES;
        board.waitingOnHint = YES;
        for (GSTile *tile in [board tiles])
        {
            if (tile.active && tile.selected)
            {
                [tile deselect];
            }
        }
    }
    else if (inHintGesture && panRecognizer.state == UIGestureRecognizerStateChanged)
    {
        if (translation.y >= HINT_GESTURE_MIN_TRANSLATION)
        {
            hintPair = [board getHintPair];
            [hintPair.firstTile highlight];
            [hintPair.secondTile highlight];
        }
        else if (hintPair)
        {
            [hintPair.firstTile deselect];
            [hintPair.secondTile deselect];
        }
    }
    else if (panRecognizer.state == UIGestureRecognizerStateEnded || panRecognizer.state == UIGestureRecognizerStateCancelled || panRecognizer.state == UIGestureRecognizerStateFailed)
    {
        if (hintPair)
        {
            [hintPair.firstTile deselect];
            [hintPair.secondTile deselect];
        }
        board.waitingOnHint = NO;
        inHintGesture = NO;
        hintPair = nil;
    }
}

- (void)addTile:(GSTile *)tile
{
    GSTileUIView *view = [self viewForTile:tile];
    [self.view addSubview:view];
}

- (void)removeTile:(GSTile *)tile
{
    GSTileUIView *view = [self viewForTile:tile];
    [tileViews removeObject:view];
    [view removeFromSuperview];
}

- (void)displayNoMovesDialog
{
    if (isShowingAlert)
    {
        return;
    }
    isShowingAlert = YES;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"GSAlertMessageTextNoMoreMoves", "No moves are possible") message:NSLocalizedString(@"GSAlertMessageTextNoMoreMoves", "No moves are possible") preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"GSButtonTextNewGame", "Text for buttons that will start a new game") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self newGame:self];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"GSButtonTextContinue", "Text for buttons that leave the game running (as opposed to a new game, or a quit action)") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}]];
    [self presentViewController:alert animated:YES completion:^{ self->isShowingAlert = NO; }];
}

- (void)endOfGameActions
{
    // TODO
}

- (void)getUsername:(void (^)(NSString *))usernameCallback
{
    isShowingAlert = YES;
    GSNameDialogController *controller = (GSNameDialogController *)[self.storyboard instantiateViewControllerWithIdentifier:@"GetName"];
    
    NSString *lastUser = [defaults valueForKey:@"lastUser"];
    if (lastUser)
    {
        controller.name = lastUser;
    }
    
    controller.completionHandler =
        ^(GSNameDialogController * _Nonnull finishedDialog)
        {
            [self dismissViewControllerAnimated:YES completion:nil];
            self->isShowingAlert = NO;
            if (finishedDialog.acceptedName)
            {
                usernameCallback(finishedDialog.name);
            }
            
            usernameCallback(nil);
        };
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)refresh
{
    [self.view setNeedsDisplay];
}

- (void)showHallOfFameWithScores:(NSArray *)scores latestScore:(NSDictionary *)gameData
{
    if (onScoreUpdateCallback)
    {
        onScoreUpdateCallback(scores, gameData, YES);
    }
}

- (void)updateScores
{
    if (onScoreUpdateCallback)
    {
        onScoreUpdateCallback(board.scores, nil, NO);
    }
}

- (GSTile *)createTileWithIcon:(NSString *)icon group:(int)group rndpos:(int)randomPosition isBorderTile:(BOOL)isBorderTile
{
    GSTileUIView *view = [[GSTileUIView alloc] initOnBoard:board iconRef:icon group:group rndpos:randomPosition isBorderTile:isBorderTile];
    
    [tileViews addObject:view];
    
    return view.tile;
}

- (void)resize
{
    const float intendedTileAspectRatio = 40.f / 56.f;
    int frameWidth = (int)self.view.frame.size.width;
    int frameHeight = (int)self.view.frame.size.height;
    int tileWidth = frameWidth / 20;
    int tileHeight = frameHeight / 12;
    float resizedAspect = (float)frameWidth / (float)frameHeight;
    if (resizedAspect > intendedTileAspectRatio)
    {
        tileWidth = tileHeight * intendedTileAspectRatio;
    }
    else if (resizedAspect < intendedTileAspectRatio)
    {
        tileHeight = tileWidth / intendedTileAspectRatio;
    }
    
    int extraWidth = frameWidth - (20 * tileWidth);
    int extraHeight = frameHeight - (11 * tileHeight);
    
    int hposBegin = extraWidth / 2;
    int vposBegin = extraHeight / 2;
    
    int hcount = 0;
    int vcount = 0;
    int hpos = hposBegin;
    int vpos = self.view.frame.origin.y + vposBegin;//self.view.frame.size.height + vposBegin;

    for (GSTile *tile in board.tiles)
    {
        GSTileUIView *view = [self viewForTile:tile];
        [tile setPositionOnBoard: hcount posy: vcount];
        [view setFrame: CGRectMake(hpos, vpos, tileWidth, tileHeight)];
        [view refresh];
        hpos += tileWidth;
        hcount++;
        if(hcount == 20)
        {
            hcount = 0;
            vcount++;
            hpos = hposBegin;
            vpos += tileHeight;
        }
    }
    [self.view setNeedsDisplay];
}


@end
