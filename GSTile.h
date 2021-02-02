#ifndef TILE_H
#define TILE_H

#import <Foundation/Foundation.h>
#import "GSTileDelegate.h"

#if TARGET_OS_MAC && !TARGET_OS_IOS
#import <AppKit/AppKit.h>
typedef NSImage ImageType;
#elif TARGET_OS_IOS
#import <UIKit/UIKit.h>
typedef UIImage ImageType;
#endif

@class GSBoard;

@interface GSTile : NSObject
{	
	ImageType *icon;
    NSString *iconName;
    NSString *iconSelName;
	int group;
	NSNumber *rndpos;
	GSBoard *theBoard;
    BOOL isSelect;
    BOOL isActive;
    int px;
    int py;
}

@property (weak) id<GSTileDelegate> delegate;

- (id)initOnBoard:(GSBoard *)aboard iconRef:(NSString *)ref group:(int)grp rndpos:(int)rnd isBorderTile:(BOOL)btile delegate:(id<GSTileDelegate>)delegate;
- (void)setPositionOnBoard:(int)x posy:(int)y;	
- (void)select;
- (void)highlight;
- (void)deselect;
- (void)deactivate;
- (void)activate;

@property (readonly) BOOL selected;
@property (readonly) BOOL active;
@property (readonly) int group;
@property (readonly) NSNumber *randomPosition;
@property (readonly) int x;
@property (readonly) int y;
@property (readonly) ImageType *icon;

@end

#endif // TILE_H

