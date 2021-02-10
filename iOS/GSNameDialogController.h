//
//  GSNameDialogController.h
//  GShisen (iOS)
//
//  Created by James Dessart on 2021-02-02.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GSNameDialogController : UIViewController
{
    IBOutlet UITextField *nameField;
}

@property NSString *name;
@property BOOL acceptedName;
@property (copy) void (^completionHandler)(GSNameDialogController*);

- (IBAction)hitOk:(id)sender;
- (IBAction)hitCancel:(id)sender;

@end

NS_ASSUME_NONNULL_END
