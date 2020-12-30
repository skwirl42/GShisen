#ifndef TILE_H
#define TILE_H

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@class GSBoard;

@interface GSTile : NSView
{	
	NSImage *icon;
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

- (id)initOnBoard:(GSBoard *)aboard 
			 iconRef:(NSString *)ref 
			 	group:(int)grp
			  rndpos:(int)rnd
	  isBorderTile:(BOOL)btile;
- (void)setPositionOnBoard:(int)x posy:(int)y;	
- (void)select;
- (void)highlight;
- (void)unselect;
- (void)deactivate;
- (void)activate;

@property (readonly) BOOL selected;
@property (readonly) BOOL active;
@property (readonly) int group;
@property (readonly) NSNumber *randomPosition;
@property (readonly) int x;
@property (readonly) int y;

@end

#endif // TILE_H

