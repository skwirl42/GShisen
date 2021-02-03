//
//  GSNameDialogController.m
//  GShisen (iOS)
//
//  Created by James Dessart on 2021-02-02.
//

#import "GSNameDialogController.h"

@implementation GSNameDialogController

@synthesize name;
@synthesize acceptedName;
@synthesize completionHandler;

- (void)viewWillAppear:(BOOL)animated
{
    nameField.text = self.name;
}

- (IBAction)hitOk:(id)sender
{
    self.name = nameField.text;
    self.acceptedName = YES;
    
    if (completionHandler)
    {
        completionHandler(self);
    }
}

- (IBAction)hitCancel:(id)sender
{
    self.acceptedName = NO;
    
    if (completionHandler)
    {
        completionHandler(self);
    }
}

@end
