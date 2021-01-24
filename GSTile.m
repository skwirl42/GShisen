#include "GSTile.h"
#include "GSBoard.h"

@implementation GSTile

@synthesize selected = isSelect;
@synthesize active = isActive;
@synthesize group = group;
@synthesize randomPosition = rndpos;
@synthesize x = px;
@synthesize y = py;

- (id)initOnBoard:(GSBoard *)aboard 
          iconRef:(NSString *)ref 
            group:(int)grp
           rndpos:(int)rnd
     isBorderTile:(BOOL)isBorderTile
{
    self = [super init];
    if(self) {
        [self setFrame: NSMakeRect(0, 0, 40, 56)];
        if(!isBorderTile) {
            theBoard = aboard;
            iconName = [[NSString alloc] initWithFormat:@"%@.tiff", ref];
            iconSelName = [[NSString alloc] initWithFormat:@"%@-h.tiff", ref];
            icon = [NSImage imageNamed: iconName];
            group = grp;
            rndpos = [[NSNumber alloc] initWithInt: rnd];
            isSelect = NO;
            isActive = YES;
        } else {
            theBoard = nil;
            iconName = nil;
            iconSelName = nil;
            icon = nil;
            rndpos = nil;
            isActive = NO;
        }
    }
    return self;
}

- (void)dealloc
{
    if (iconName){
        [iconName release];
    }
    
    if (iconSelName) {
        [iconSelName release];
    }
    
    if (rndpos) {
        [rndpos release];
    }

    [super dealloc];
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

- (void)setPositionOnBoard:(int)x posy:(int)y
{
    px = x;
    py = y;
}

- (void)select
{
    int result = [theBoard prepareTilesToRemove: self];
    if(!result) {
        return;
    } else {
        isSelect = YES;
        icon = [NSImage imageNamed: iconSelName];
        [self setNeedsDisplay: YES];
    }
    
    if(result == 2) {
        [theBoard removeCurrentTiles];
    }
}

- (void)deselect
{
    isSelect = NO;
    icon = [NSImage imageNamed: iconName];
    [self setNeedsDisplay: YES];
    [theBoard unSetCurrentTiles];
}

- (void)highlight
{
    icon = [NSImage imageNamed: iconSelName];
    [self setNeedsDisplay: YES];
}

- (void)deactivate
{
    isActive = NO;
    [self setNeedsDisplay: YES];
}

- (void)activate
{
    isActive = YES;
    [self setNeedsDisplay: YES];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    if(theBoard.gameState == GSGameStateRunning) {
        if(!isActive) {
            return;
        }
        
        if(self.selected)
        {
            [self deselect];
        }
        else
        {
            [self select];
        }
    }
}

- (void)drawRect:(NSRect)rect
{
    if(self.active && theBoard.gameState == GSGameStateRunning) {
        [icon drawInRect:rect];
    }
}

@end


