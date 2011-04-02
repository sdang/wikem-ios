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
    [tabBarItem dealloc];
    [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style inManagedContext:(NSManagedObjectContext *)context withCategory:(Category *)category
{
    if ((self = [self initWithStyle:style])) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        request.entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:context];
        request.sortDescriptors = [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES]];
        NSString *cacheName;
        if (category) {
            request.predicate = [NSPredicate predicateWithFormat:@"%@ in categories", category];
            self.title = category.title;
            NSLog(@"Opening Category: %@", category);
             cacheName = [NSString stringWithString:category.title];
        } else {
            cacheName = @"notes";
            request.predicate = nil;
        }
        
        request.fetchBatchSize = 20;
        
        NSFetchedResultsController *frc = [[NSFetchedResultsController alloc]
                                           initWithFetchRequest:request
                                           managedObjectContext:context
                                           sectionNameKeyPath:nil 
                                           cacheName:cacheName];
        
        self.fetchedResultsController = frc;
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
