//
//  AppDelegate.m
//  GShisen (iOS)
//
//  Created by James Dessart on 2021-01-29.
//

#import "AppDelegate.h"
#import "GSUIPageController.h"

@implementation AppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    pageController = (GSUIPageController*)((UIPageViewController*)window.rootViewController).delegate;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [pageController gainedActive];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [pageController lostActive];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [pageController gainedActive];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [pageController lostActive];
}

- (IBAction)newGame:(id)sender
{
    
}

- (IBAction)pause:(id)sender
{
    
}

- (IBAction)getHint:(id)sender
{
    
}

- (IBAction)undo:(id)sender
{
    
}

- (IBAction)runInfoPanel:(id)sender
{
    
}

@end
