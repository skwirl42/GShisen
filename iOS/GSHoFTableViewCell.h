//
//  GSHoFTableViewCell.h
//  GShisen (iOS)
//
//  Created by James Dessart on 2021-02-02.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GSHoFTableViewCell : UITableViewCell
{
    IBOutlet UILabel *nameLabel;
    IBOutlet UILabel *timeLabel;
}

- (void)setName:(NSString*)name andTime:(NSString*)time withHighlight:(BOOL)highlight;

@end

NS_ASSUME_NONNULL_END
