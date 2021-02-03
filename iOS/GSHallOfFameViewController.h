//
//  GSHallOfFameViewController.h
//  GShisen (iOS)
//
//  Created by James Dessart on 2021-02-02.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GSHallOfFameViewController : UIViewController<UITableViewDataSource>
{
    IBOutlet UITableView *scoreTable;
}

- (void)updateScores:(NSArray*)scores withUserData:(NSDictionary*)userData;
- (void)updateScores;
@end

NS_ASSUME_NONNULL_END
