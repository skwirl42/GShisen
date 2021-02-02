//
//  GSBoardUIView.m
//  GShisen (iOS)
//
//  Created by James Dessart on 2021-01-24.
//

#import "GSBoardUIViewController.h"
#import "GSBoard.h"
#import "GSTileUIView.h"

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface GSBoardUIViewController ()
{
    NSMutableArray<GSTileUIView*> *tileViews;
}
@end

@implementation GSBoardUIViewController

@synthesize board;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
//    [self.view setFrame:self.view.window.frame];
    
    defaults = [NSUserDefaults standardUserDefaults];
    tileViews = [[NSMutableArray<GSTileUIView*> alloc] init];
    
    self.board = [[GSBoard alloc] initialize:self];
    
    [self newGame:self];
    
    [self addObserver:self forKeyPath:@"canUndo" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"hadEndOfGame" options:NSKeyValueObservingOptionNew context:nil];
    undoButton.enabled = NO;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"canUndo"])
    {
        undoButton.enabled = board.canUndo;
    }
    else if ([keyPath isEqualToString:@"hadEndOfGame"])
    {
        
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
    // TODO
}

- (void)endOfGameActions
{
    // TODO
}

- (NSString *)getUsername
{
    // TODO
    return @"user";
}

- (void)refresh
{
    [self.view setNeedsDisplay];
}

- (void)showHallOfFameWithScores:(NSArray *)scores latestScore:(NSDictionary *)gameData
{
    // TODO
}

- (void)updateScores
{
    // TODO
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
