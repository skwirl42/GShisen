//
//  GSUIPageController.h
//  GShisen (iOS)
//
//  Created by James Dessart on 2021-01-24.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GSBoardUIViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSUIPageController : NSObject<UIPageViewControllerDelegate,UIPageViewControllerDataSource>
{
    IBOutlet UIPageViewController *pageViewController;
}

@property (weak) GSBoardUIViewController *boardController;

- (void)lostActive:(BOOL)isIntoBackground;
- (void)gainedActive:(BOOL)isIntoBackground;

@end

NS_ASSUME_NONNULL_END
