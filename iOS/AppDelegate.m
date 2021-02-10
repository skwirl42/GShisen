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
    [pageController gainedActive:YES];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [pageController lostActive:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [pageController gainedActive:NO];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [pageController lostActive:NO];
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
