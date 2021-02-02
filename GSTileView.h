//
//  GSTileView.h
//  GShisen
//
//  Created by James Dessart on 2021-01-24.
//

#import <Cocoa/Cocoa.h>
#import "GSTileDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class GSTile;
@class GSBoard;

@interface GSTileView : NSImageView<GSTileDelegate>
@property (strong) GSTile *tile;

- (id)initOnBoard:(GSBoard *)aboard iconRef:(NSString *)ref group:(int)grp rndpos:(int)rnd isBorderTile:(BOOL)btile;

@end

NS_ASSUME_NONNULL_END
