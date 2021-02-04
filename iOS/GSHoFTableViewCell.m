//
//  GSHoFTableViewCell.m
//  GShisen (iOS)
//
//  Created by James Dessart on 2021-02-02.
//

#import "GSHoFTableViewCell.h"

@implementation GSHoFTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setName:(NSString*)name andTime:(NSString*)time withHighlight:(BOOL)highlight
{
    nameLabel.text = name;
    timeLabel.text = time;
    
    if (@available(iOS 13.0, *))
    {
        self.backgroundColor = highlight ? [UIColor lightGrayColor] : [UIColor systemBackgroundColor];
    }
    else
    {
        self.backgroundColor = highlight ? [UIColor lightGrayColor] : [UIColor whiteColor];
    }
}

@end
