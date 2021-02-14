//
//  GSTileView.m
//  GShisen
//
//  Created by James Dessart on 2021-01-24.
//

#import "GSTileView.h"
#import "GSTile.h"
#import "GSBoard.h"

@interface GSTileView ()
{
    CGSize suggestedSize;
    GSBoard *board;
}
@end

@implementation GSTileView

@synthesize tile;

- (id)initOnBoard:(GSBoard *)aboard iconRef:(NSString *)ref group:(int)grp rndpos:(int)rnd isBorderTile:(BOOL)btile
{
    self = [super init];
    if (self)
    {
        board = aboard;
        tile = [[GSTile alloc] initOnBoard:board iconRef:ref group:grp rndpos:rnd isBorderTile:btile delegate:self];
    }
    return self;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    if(board.gameState == GSGameStateRunning)
    {
        if(!tile.active)
        {
            return;
        }
        
        if(tile.selected)
        {
            [tile deselect];
        }
        else
        {
            [tile select];
        }
    }
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

- (void)refresh
{
    if (tile.active)
    {
        self.image = tile.icon;
    }
    else
    {
        self.image = nil;
    }
    [self setNeedsDisplay:YES];
}

- (void)setSuggestedContentSize:(CGSize)size
{
    suggestedSize = size;
    [self setFrame:NSMakeRect(self.frame.origin.x, self.frame.origin.y, suggestedSize.width, suggestedSize.height)];
}

- (void)setPositionX:(int)x y:(int)y
{
//    [tile setPositionOnBoard:x posy:y];
    [self refresh];
}

@end
