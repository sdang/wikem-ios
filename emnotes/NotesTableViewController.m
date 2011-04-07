//
//  NotesTableViewController.m
//  TabViewTest
//
//  Created by Sabin Dang on 4/1/11.
//  Copyright 2011 sabindang.com. All rights reserved.
//

#import "NotesTableViewController.h"
#import "NoteViewController.h"
#import "Note.h"

@implementation NotesTableViewController

@synthesize tabBarItem;

- (void)setupTabBarItem
{
    UITabBarItem *item = [[UITabBarItem alloc]
                          initWithTitle:@"All Notes"
                          image:[UIImage imageNamed:@"179-notepad.png"]
                          tag:0];
    self.tabBarItem = item;
    [item release];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self setupTabBarItem];
        self.searchKey = @"name";
        self.title = self.tabBarItem.title;
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [tabBarItem release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.tabBarItem = nil;
}

- (id)initWithStyle:(UITableViewStyle)style inManagedContext:(NSManagedObjectContext *)context withCategory:(Category *)category
{
    if ((self = [self initWithStyle:style])) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        request.entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:context];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        NSString *cacheName = nil;
        if (category) {
            request.predicate = [NSPredicate predicateWithFormat:@"%@ in categories", category];
            self.title = category.title;
             cacheName = [NSString stringWithString:category.title];
        } else {
            cacheName = @"notes";
            request.predicate = nil;
        }
        
        request.fetchBatchSize = 20;
        
        NSFetchedResultsController *frc = [[NSFetchedResultsController alloc]
                                           initWithFetchRequest:request
                                           managedObjectContext:context
                                           sectionNameKeyPath:@"getFirstLetter" 
                                           cacheName:cacheName];
        
        self.fetchedResultsController = frc;
        [sortDescriptor release];
        [request release];
        [frc release];
    }
    return self;
}

- (void)managedObjectSelected:(NSManagedObject *)managedObject
{
    NoteViewController *noteViewController = [[NoteViewController alloc] init];
    noteViewController.note = (Note *)managedObject;
    [self.navigationController pushViewController:noteViewController animated:YES];
    [noteViewController release];
}


@end
