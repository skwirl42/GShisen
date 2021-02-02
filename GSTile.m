#include "GSTile.h"
#include "GSBoard.h"

@implementation GSTile

@synthesize selected = isSelect;
@synthesize active = isActive;
@synthesize group = group;
@synthesize randomPosition = rndpos;
@synthesize x = px;
@synthesize y = py;
@synthesize delegate;
@synthesize icon = icon;

- (id)initOnBoard:(GSBoard *)aboard 
          iconRef:(NSString *)ref 
            group:(int)grp
           rndpos:(int)rnd
     isBorderTile:(BOOL)isBorderTile
         delegate:(id<GSTileDelegate>)delegate
{
    self = [super init];
    if(self) {
        self.delegate = delegate;
        [delegate setSuggestedContentSize:CGSizeMake(40, 56)];
        if(!isBorderTile) {
            theBoard = aboard;
            iconName = [[NSString alloc] initWithFormat:@"%@.tiff", ref];
            iconSelName = [[NSString alloc] initWithFormat:@"%@-h.tiff", ref];
            icon = [ImageType imageNamed: iconName];
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

#if TARGET_OS_MACOS && !TARGET_OS_IOS
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
#endif

- (void)setPositionOnBoard:(int)x posy:(int)y
{
    px = x;
    py = y;
    [delegate setPositionX:x y:y];
}

- (void)select
{
    int result = [theBoard prepareTilesToRemove: self];
    if(!result) {
        return;
    } else {
        isSelect = YES;
        icon = [ImageType imageNamed: iconSelName];
        [delegate refresh];
    }
    
    if(result == 2) {
        [theBoard removeCurrentTiles];
    }
}

- (void)deselect
{
    isSelect = NO;
    icon = [ImageType imageNamed: iconName];
    [delegate refresh];
    [theBoard unSetCurrentTiles];
}

- (void)highlight
{
    icon = [ImageType imageNamed: iconSelName];
    [delegate refresh];
}

- (void)deactivate
{
    isActive = NO;
    [delegate refresh];
}

- (void)activate
{
    isActive = YES;
    [delegate refresh];
}

@end


