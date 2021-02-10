//
//  GSUIPageController.m
//  GShisen (iOS)
//
//  Created by James Dessart on 2021-01-24.
//

#import "GSUIPageController.h"
#import "GSBoardUIViewController.h"
#import "GSBoard.h"
#import "GSHallOfFameViewController.h"

@interface GSUIPageController ()
{
    GSHallOfFameViewController *hallOfFame;
    NSArray<NSString*> *pages;
    NSMutableDictionary<NSString*,UIViewController*> *pageViews;
    NSInteger index;
    NSInteger potentialIndex;
    NSArray *scores;
    NSDictionary *userData;
}
@end

@implementation GSUIPageController

@synthesize boardController;

- (void)awakeFromNib
{
    [super awakeFromNib];
    pages = @[@"Game", @"Pause", @"HallOfFame"];
    pageViews = [NSMutableDictionary<NSString*,UIViewController*> new];
    index = 0;
    
    [pageViewController setViewControllers:@[[self getControllerForIndex:0]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:^(BOOL finished) {}];
    
    boardController = (GSBoardUIViewController*)[self getControllerForIndex:0];
    boardController.onScoreUpdateCallback = ^(NSArray * scores, NSDictionary * userData, BOOL showHallOfFame) {
        [self updateScores:scores withUserData:userData];
        if (showHallOfFame)
        {
            self->index = [self->pages indexOfObject:@"HallOfFame"];
            [self->pageViewController setViewControllers:@[[self getControllerForIndex:self->index]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {}];
        }
    };
    index = 0;
    
    [boardController.board addObserver:self forKeyPath:@"gameState" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"gameState"] && hallOfFame)
    {
        [hallOfFame gameStateUpdated:boardController.board.gameState];
    }
}

- (void)lostActive:(BOOL)isIntoBackground
{
    if (isIntoBackground)
    {
        index = 1;
        [pageViewController setViewControllers:@[[self getControllerForIndex:index]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:^(BOOL finished) {}];
        [boardController.board setPause:YES];
    }
}

- (void)gainedActive:(BOOL)isIntoBackground
{
    
}

- (void)updateScores:(NSArray*)scores withUserData:(NSDictionary *)userData
{
    if (hallOfFame)
    {
        if (userData)
        {
            [hallOfFame updateScores:scores withUserData:userData];
        }
        else
        {
            [hallOfFame updateScores];
        }
    }
    else
    {
        self->scores = scores;
        self->userData = userData;
    }
}

- (UIViewController *)getControllerForIndex:(NSUInteger)index
{
    if ([pageViews objectForKey:pages[index]] != nil)
    {
        return [pageViews objectForKey:pages[index]];
    }
    
    UIStoryboard *storyboard = pageViewController.storyboard;
    UIViewController *newController = [storyboard instantiateViewControllerWithIdentifier:pages[index]];
    [pageViews setObject:newController forKey:pages[index]];
    
    if ([newController isKindOfClass:[GSHallOfFameViewController class]])
    {
        hallOfFame = (GSHallOfFameViewController*)newController;
        if (scores)
        {
            [hallOfFame updateScores:scores withUserData:userData];
        }
        [hallOfFame gameStateUpdated:boardController.board.gameState];
        
        __block GSBoardUIViewController *board = boardController;
        __block UIPageViewController *thePageViewController = pageViewController;
        hallOfFame.onNewGame = ^{
            [thePageViewController setViewControllers:@[board] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL finished)
            {
                [board newGame:nil];
            }];
        };
    }
    
    return newController;
}

- (nullable UIViewController *)pageViewController:(nonnull UIPageViewController *)pageViewController viewControllerAfterViewController:(nonnull UIViewController *)viewController
{
    NSUInteger pageIndex = [pages indexOfObject:viewController.restorationIdentifier];
    
    if (pageIndex != NSNotFound)
    {
        NSUInteger nextPage = pageIndex + 1;
        if (nextPage < pages.count)
        {
            return [self getControllerForIndex:nextPage];
        }
    }
    
    return nil;
}

- (nullable UIViewController *)pageViewController:(nonnull UIPageViewController *)pageViewController viewControllerBeforeViewController:(nonnull UIViewController *)viewController
{
    NSUInteger pageIndex = [pages indexOfObject:viewController.restorationIdentifier];
    
    if (pageIndex != NSNotFound && pageIndex > 0)
    {
        NSUInteger prevPage = pageIndex - 1;
        return [self getControllerForIndex:prevPage];
    }
    
    return nil;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return pages.count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return index;
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers
{
    NSArray *namesArray = [pendingViewControllers valueForKey:@"restorationIdentifier"];
    if (namesArray.count == 1)
    {
        potentialIndex = [pages indexOfObject:namesArray.firstObject];
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed
{
    NSArray *namesArray = [previousViewControllers valueForKey:@"restorationIdentifier"];
    if (namesArray.count == 1 && completed)
    {
        [boardController.board setPause:[namesArray.firstObject isEqualToString:pages.firstObject]];
        index = potentialIndex;
    }
}

@end
