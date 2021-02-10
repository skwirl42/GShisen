//
//  GSHallOfFameViewController.h
//  GShisen (iOS)
//
//  Created by James Dessart on 2021-02-02.
//

#import <UIKit/UIKit.h>
#import "GSBoard.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSHallOfFameViewController : UIViewController<UITableViewDataSource>
{
    IBOutlet UITableView *scoreTable;
    IBOutlet UIButton *newGameButton;
}

@property (copy) void(^onNewGame)(void);

- (void)gameStateUpdated:(GSGameState)newState;
- (IBAction)newGame:(id)sender;

- (void)updateScores:(NSArray*)scores withUserData:(NSDictionary*)userData;
- (void)updateScores;
@end

NS_ASSUME_NONNULL_END
