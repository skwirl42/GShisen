//
//  boardview.h
//  GShisen
//
//  Created by James Dessart on 2021-01-24.
//

#import <Cocoa/Cocoa.h>
#import "GSBoardDelegate.h"
#import "GSBoard.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSBoardView : NSView <GSBoardDelegate>
{
    IBOutlet GSHallOfFameWin *hallOfFameWindow;
    NSTextField *timeField;
    NSTimer *timer;
    NSUserDefaults *defaults;
}
@property (strong) GSBoard *shisenBoard;

- (IBAction)showHallOfFameWindow:(id)sender;
- (IBAction)simulateWin:(id)sender;
- (IBAction)clearScores:(id)sender;

- (void)newGame;
- (void)pause;
- (void)getHint;
- (void)undo;

@end

NS_ASSUME_NONNULL_END
