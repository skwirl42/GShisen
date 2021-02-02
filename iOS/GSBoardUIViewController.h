//
//  GSBoardUIView.h
//  GShisen (iOS)
//
//  Created by James Dessart on 2021-01-24.
//

#import <UIKit/UIKit.h>
#import "GSBoardDelegate.h"

@class GSBoard;

NS_ASSUME_NONNULL_BEGIN

@interface GSBoardUIViewController : UIViewController <GSBoardDelegate>
{
    IBOutlet UILabel *timeField;
    IBOutlet UIButton *undoButton;
    NSTimer *timer;
    NSUserDefaults *defaults;
}

@property (strong) GSBoard *board;

- (IBAction)newGame:(id)sender;
- (IBAction)pause:(id)sender;
- (IBAction)getHint:(id)sender;
- (IBAction)undo:(id)sender;

@end

NS_ASSUME_NONNULL_END
