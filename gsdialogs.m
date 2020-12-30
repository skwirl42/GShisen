#include "gsdialogs.h"
#include "gshisen.h"

#import <AppKit/NSFont.h>

@implementation GSDlogView

- (void)drawRect:(NSRect)rect
{
#ifndef __APPLE__
  	[[NSColor darkGrayColor] set];
  	PSmoveto(0, 91);
 	PSlineto(240, 91);
	PSstroke();
  	[[NSColor whiteColor] set];
  	PSmoveto(0, 90);
 	PSlineto(240, 90);
	PSstroke();
	
  	[[NSColor darkGrayColor] set];
  	PSmoveto(0, 45);
 	PSlineto(240, 45);
	PSstroke();
  	[[NSColor whiteColor] set];
  	PSmoveto(0, 44);
 	PSlineto(240, 44);
	PSstroke();
#endif
}

@end

@implementation GSUserNameDialog

- (id)initWithTitle:(NSString *)title;
{
  	NSFont *font;

    self = [super initWithContentRect:NSMakeRect(0, 0, 240, 120) styleMask:NSWindowStyleMaskTitled
#ifndef __APPLE__
                                                                       backing:NSBackingStoreRetained 
                                                                         defer:NO];
#else
                                                                       backing:NSBackingStoreBuffered 
                                                                         defer:YES];
#endif

  	if(self) {
#ifndef __APPLE__
  		dialogView = [[[GSDlogView alloc] initWithFrame: _frame] autorelease];
#else
  		dialogView = [self contentView];
#endif
		font = [NSFont systemFontOfSize: 18];
		
		titlefield = [[NSTextField alloc] initWithFrame: NSMakeRect(10, 95, 200, 20)];
		//[titlefield setBackgroundColor:[NSColor lightGrayColor]];

		[titlefield setBezeled:NO];
		[titlefield setEditable:NO];
		[titlefield setSelectable:NO];
		[titlefield setFont: font];
		[titlefield setStringValue: title];
		[dialogView addSubview: titlefield]; 

		editfield = [[NSTextField alloc] initWithFrame: NSMakeRect(30, 56, 180, 22)];
		[editfield setEditable:YES];
		[editfield setSelectable:YES];
                [editfield setEnabled:YES];
		[dialogView addSubview: editfield];

	  	okbutt = [[NSButton alloc] initWithFrame: NSMakeRect(170, 10, 60, 25)];
#ifndef __APPLE__
	  	[okbutt setButtonType: NSMomentaryLight];
#else
                // these are the new constants for the Aqua push button.
        [okbutt setButtonType: NSButtonTypeMomentaryPushIn];
        [okbutt setBezelStyle: NSBezelStyleRounded];
#endif
                // make the button the default button
                [okbutt setKeyEquivalent:@"\r"];
	  	[okbutt setTitle:[NSBundle.mainBundle localizedStringForKey:@"GSGeneralAlertOK" value:@"" table:nil]];
	  	[okbutt setTarget:self];
	  	[okbutt setAction:@selector(buttonAction:)];		
                [okbutt setEnabled:YES];
		[dialogView addSubview: okbutt]; 
                [self makeFirstResponder: editfield];

#ifndef __APPLE__
		[self setContentView: dialogView];
		[self setTitle: @""];
#endif
	}

	return self;
}

- (void)dealloc
{
	[titlefield release];
	[editfield release];
	[okbutt release];	
  	[super dealloc];
}

- (int)runModal
{
  	NSApplication *app;

  	app = [NSApplication sharedApplication];
        // this removes the need to use makeKeyWindow
  	[app runModalForWindow: self];
  	return result;
}

- (NSString *)getEditFieldText
{
	return [editfield stringValue];
}

- (void)setEditFieldText:(NSString*)text
{
    editfield.stringValue = text;
}

- (void)buttonAction:(id)sender
{
	result = NSAlertFirstButtonReturn;
		
  	[self orderOut: self];
  	[[NSApplication sharedApplication] stopModal];
}

@end

@implementation GSHallOfFameWin

- (id)initWithScoreArray:(NSArray *)scores recentScore:(NSDictionary *)score
{
    self->scores = [scores mutableCopy];
    
	NSDictionary *scoresEntry, *attributes;
	NSString *userName, *minutes, *seconds, *totTime;
	NSAttributedString *italicsUserName, *italicsTime;
	NSRect myRect = {{0, 0}, {150, 300}};
	NSRect matrixRect = {{0, 0}, {150, 300}};
    unsigned int style = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable;
	int i;
	int foundScore = 0;
	
#ifndef __APPLE__
	self = [super initWithContentRect:myRect styleMask:style backing:NSBackingStoreRetained
										 defer:NO];
#else
	self = [super initWithContentRect:myRect styleMask:style backing:NSBackingStoreBuffered
										 defer:YES];
#endif
  	if(self)
	{
        if (!scoreFieldData)
        {
            scoreFieldData = [NSMutableArray<NSDictionary*> new];
        }
        
		[self setTitle:@"Hall Of Fame"];
		[self setFrameAutosaveName:@"Hall Of Fame"]; 
		
		myView = [[NSView alloc] initWithFrame: self.frame];
		[self setContentView: myView];

  		textCell = [NSTextFieldCell new];
		[textCell setBordered:NO];
        [textCell setAlignment:NSTextAlignmentLeft];
		[textCell setEditable:NO];

  		scoresMatrix = [[NSMatrix alloc] initWithFrame:matrixRect mode:NSListModeMatrix
                        prototype:textCell numberOfRows:0 numberOfColumns:2];

		[scoresMatrix setAutoresizingMask: NSViewWidthSizable];
											
 		scoresScroll = [[NSScrollView alloc] initWithFrame: matrixRect];
		[scoresScroll setAutoresizingMask: NSViewHeightSizable | NSViewWidthSizable];
  		[scoresScroll setHasVerticalScroller: YES];
  		[scoresScroll setHasHorizontalScroller: NO];
		
		for(i = 0; i < [scores count]; i++)
		{
			scoresEntry = [scores objectAtIndex: i];
			userName = [scoresEntry objectForKey: @"username"];
			minutes = [scoresEntry objectForKey: @"minutes"];
			seconds = [scoresEntry objectForKey: @"seconds"];
			totTime = [NSString stringWithFormat:@"%@:%@", minutes, seconds];
            
            [scoreFieldData addObject:[NSDictionary dictionaryWithObject:userName forKey:@"Name"]];
            [scoreFieldData addObject:[NSDictionary dictionaryWithObject:totTime forKey:@"Time"]];

 			[scoresMatrix addRow];
			
			if( [scoresEntry isEqualToDictionary:score] && !foundScore )
			{
				// This is the user's score, so let's italicize it!
				attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:0.5],
											NSObliquenessAttributeName, nil];
				italicsUserName 
					= [[NSAttributedString alloc] initWithString:userName attributes:attributes];
				italicsTime 
					= [[NSAttributedString alloc] initWithString:totTime attributes:attributes];
				
				NSCell *nameCell = [scoresMatrix cellAtRow:i column:0];
				[nameCell setAttributedStringValue: italicsUserName];
				[scoresMatrix updateCell: nameCell];

				NSCell *timeCell = [scoresMatrix cellAtRow:i column:1];
				[timeCell setAttributedStringValue: italicsTime];
				[scoresMatrix updateCell: timeCell];
				
				foundScore = 1;
			}
			else
			{
				[[scoresMatrix cellAtRow:i column:0] setStringValue: userName];
				[[scoresMatrix cellAtRow:i column:1] setStringValue: totTime];
			}
		}
		
		[scoresMatrix sizeToFit];
		
  		[scoresScroll setDocumentView: scoresMatrix];
  		[myView addSubview: scoresScroll];
	}
	return self;
}

- (id)initWithScoreArray:(NSArray *)scores
{
	return [self initWithScoreArray:scores recentScore:nil];
}

- (void) dealloc
{
	[myView release];
  	[super dealloc];
}

- (void)awakeFromNib
{
    if (!scores)
    {
        [self updateScores];
    }
}

- (void)updateScores
{
    recentScore = nil;
    [self updateScoresWithRecentScore:nil];
}

- (void)updateScoresWithRecentScore:(NSDictionary *)score
{
    recentScore = score;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    scores = [[defaults arrayForKey:@"scores"] mutableCopy];
    
    if (scoreFieldData)
    {
        [scoreFieldData removeAllObjects];
    }
    else
    {
        scoreFieldData = [NSMutableArray<NSDictionary*> new];
    }
    
    for(int i = 0; i < [scores count]; i++)
    {
        NSDictionary *scoresEntry = [scores objectAtIndex: i];
        NSString *userName = [scoresEntry objectForKey: @"username"];
        NSString *minutes = [scoresEntry objectForKey: @"minutes"];
        NSString *seconds = [scoresEntry objectForKey: @"seconds"];
        NSString *totTime = [NSString stringWithFormat:@"%@:%@", minutes, seconds];
        
        NSDictionary *itemDictionary = [NSDictionary dictionaryWithObjects:@[userName, totTime] forKeys:@[@"Name", @"Time"]];
        [scoreFieldData addObject:itemDictionary];
    }
    
    [scoreTableView reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    if (self->scores == nil || self->scores.count == 0)
    {
        return 0;
    }
    return self->scores.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if (self->scores == nil || self->scores.count == 0)
    {
        return nil;
    }
    
    NSDictionary *item = [scoreFieldData objectAtIndex:row];
    NSString *cellString = [item objectForKey:tableColumn.identifier];
    
    return cellString;
}

- (NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSTableCellView *view = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    
    NSDictionary *scoreItem = [scores objectAtIndex:row];
    NSString *scoreFieldString = [self tableView:tableView objectValueForTableColumn:tableColumn row:row];

    if (recentScore && [scoreItem isEqualToDictionary:recentScore])
    {
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:0.25],
                                                 NSObliquenessAttributeName, nil];
        NSAttributedString *stringValue = [[NSAttributedString alloc] initWithString:scoreFieldString attributes:attributes];
        view.textField.attributedStringValue = stringValue;
    }
    else
    {
        view.textField.stringValue = scoreFieldString;
    }
    return view;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    // Not editable, so we'll just do nothing
}

@end
