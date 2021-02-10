//
//  GSHallOfFameViewController.m
//  GShisen (iOS)
//
//  Created by James Dessart on 2021-02-02.
//

#import "GSHallOfFameViewController.h"
#import "GSHoFTableViewCell.h"

@interface GSHallOfFameViewController ()
{
    NSUserDefaults *defaults;
    NSArray *scores;
    NSDictionary *userData;
}
@end

@implementation GSHallOfFameViewController

@synthesize onNewGame;

- (void)viewDidLoad
{
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];
    [self updateScores];
}

- (void)gameStateUpdated:(GSGameState)newState
{
    newGameButton.hidden = newState != GSGameStateFinished;
}

- (IBAction)newGame:(id)sender
{
    if (onNewGame)
    {
        onNewGame();
    }
}

- (void)updateScores
{
    userData = nil;
    if ([defaults valueForKey:@"scores"])
    {
        scores = [defaults valueForKey:@"scores"];
    }
    else
    {
        scores = [NSArray array];
    }
    [scoreTable reloadData];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    GSHoFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"hofTableCell" forIndexPath:indexPath];
    
    NSDictionary *score = scores[indexPath.row];
    NSString *timeString = [NSString stringWithFormat:@"%@:%@", [score objectForKey:@"minutes"], [score objectForKey:@"seconds"]];
    
    BOOL highlight = NO;
    if (userData && [score isEqualToDictionary:userData])
    {
        highlight = YES;
    }
    [cell setName:[score objectForKey:@"username"] andTime:timeString withHighlight:highlight];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section != 0)
    {
        return 0;
    }
    
    return scores.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)updateScores:(NSArray*)scores withUserData:(NSDictionary*)userData
{
    self->scores = [defaults objectForKey:@"scores"];
    self->userData = userData;
    [scoreTable reloadData];
}

@end
