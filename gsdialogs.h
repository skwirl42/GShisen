#ifndef DIALOGS_H
#define DIALOGS_H

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface GSDlogView : NSView
@end

@interface GSUserNameDialog : NSWindow
{
	GSDlogView *dialogView;
	NSTextField *titlefield, *editfield;	
	NSButton *okbutt;
	int result;
}

- (id)initWithTitle:(NSString *)title;
- (int)runModal;
- (NSString *)getEditFieldText;
- (void)buttonAction:(id)sender;

@end

@interface GSHallOfFameWin : NSWindow
{
	NSView *myView;
  	NSScrollView *scoresScroll;
  	NSMatrix *scoresMatrix;	
  	NSTextFieldCell *textCell;
}

- (id)initWithScoreArray:(NSArray *)scores;
- (id)initWithScoreArray:(NSArray *)scores recentScore:(NSDictionary *)score;

@end

#endif // DIALOGS_H
