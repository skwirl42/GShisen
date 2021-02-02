//
//  AppDelegate.h
//  GShisen (iOS)
//
//  Created by James Dessart on 2021-01-29.
//

#import <UIKit/UIKit.h>
@class GSBoardUIViewController;
@class GSUIPageController;

NS_ASSUME_NONNULL_BEGIN

@interface AppDelegate : NSObject<UIApplicationDelegate>
{
    GSBoardUIViewController *board;
    GSUIPageController *pageController;
}

@property (nullable, nonatomic, strong) UIWindow *window;

- (IBAction)newGame:(id)sender;
- (IBAction)pause:(id)sender;
- (IBAction)getHint:(id)sender;
- (IBAction)undo:(id)sender;
- (IBAction)runInfoPanel:(id)sender;

@end

NS_ASSUME_NONNULL_END
