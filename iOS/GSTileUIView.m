//
//  GSTileUIView.m
//  GShisen (iOS)
//
//  Created by James Dessart on 2021-01-24.
//

#import "GSTileUIView.h"
#import "GSTile.h"
#import "GSBoard.h"

@interface GSTileUIView ()
{
    GSBoard *board;
    CGSize suggestedSize;
    NSSet<UITouch*> *touchesDown;
}
@end

@implementation GSTileUIView

@synthesize tile;

- (id)initOnBoard:(GSBoard *)aboard iconRef:(NSString *)ref group:(int)grp rndpos:(int)rnd isBorderTile:(BOOL)btile
{
    self = [super initWithFrame:CGRectZero];
    if (self)
    {
        self.userInteractionEnabled = YES;
        board = aboard;
        tile = [[GSTile alloc] initOnBoard:board iconRef:ref group:grp rndpos:rnd isBorderTile:btile delegate:self];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        self.gestureRecognizers = @[tap];
    }
    return self;
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
    
    self.userInteractionEnabled = tile.active;
    [self setNeedsDisplay];
}

- (void)setPositionX:(int)x y:(int)y
{
//    [tile setPositionOnBoard:x posy:y];
    [self refresh];
}

- (void)setSuggestedContentSize:(CGSize)size
{
    suggestedSize = size;
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, suggestedSize.width, suggestedSize.height)];
}

- (IBAction)tapped:(id)sender
{
    if (board.waitingOnHint)
    {
        return;
    }
    
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

//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    touchesDown = touches;
//}
//
//- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    if(board.gameState == GSGameStateRunning && touchesDown != nil)
//    {
//        for (UITouch *touch in touches)
//        {
//            if ([touchesDown containsObject:touch])
//            {
//                if(!tile.active)
//                {
//                    return;
//                }
//                
//                if(tile.selected)
//                {
//                    [tile deselect];
//                }
//                else
//                {
//                    [tile select];
//                }
//                break;
//            }
//        }
//    }
//    
//    touchesDown = nil;
//}

@end
