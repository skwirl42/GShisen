#ifndef DIALOGS_H
#define DIALOGS_H

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface GSDlogView : NSView
@end

@interface GSUserNameDialog : NSWindow
{
	GSDlogView *dialogView;
    NSTextField *editfield;
	int result;
}

- (id)initWithTitle:(NSString *)title;
- (int)runModal;
- (NSString *)getEditFieldText;
- (void)setEditFieldText:(NSString*)text;
- (void)buttonAction:(id)sender;

@end

@interface GSHallOfFameWin : NSWindow<NSTableViewDataSource,NSTableViewDelegate>
{
    IBOutlet NSTableView *scoreTableView;
	NSView *myView;
  	NSScrollView *scoresScroll;
  	NSMatrix *scoresMatrix;	
  	NSTextFieldCell *textCell;
    NSMutableArray *scores;
    NSMutableArray<NSDictionary*> *scoreFieldData;
    NSDictionary *recentScore;
}

- (id)initWithScoreArray:(NSArray *)scores;
- (id)initWithScoreArray:(NSArray *)scores recentScore:(NSDictionary *)score;

- (void)updateScores;
- (void)updateScoresWithRecentScore:(NSDictionary*)score;

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;

- (NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;

@end

#endif // DIALOGS_H
