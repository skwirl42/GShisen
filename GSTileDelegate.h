//
//  GSTileDelegate.h
//  GShisen
//
//  Created by James Dessart on 2021-01-24.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@protocol GSTileDelegate <NSObject>

- (void)setSuggestedContentSize:(CGSize)size;
- (void)refresh;
- (void)setPositionX:(int)x y:(int)y;

@end
