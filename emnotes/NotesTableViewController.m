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
//ck : makes default setters and getters..
@synthesize managedObjectContext;


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
        NSString *sectionName = nil;
        
        if (category) {
            request.predicate = [NSPredicate predicateWithFormat:@"%@ in categories", category];
            self.title = category.title;
            cacheName = [NSString stringWithString:category.title];
            sectionName = nil; 
        } else {
            sectionName = @"getFirstLetter";
            cacheName = @"notes";
            request.predicate = nil;
        }
        
        request.fetchBatchSize = 20;
        
        NSFetchedResultsController *frc = [[NSFetchedResultsController alloc]
                                           initWithFetchRequest:request
                                           managedObjectContext:context
                                           sectionNameKeyPath:sectionName
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
	noteViewController.managedObjectContext = self.managedObjectContext;
//i hope that passed the correct context along...
	noteViewController.note = (Note *)managedObject;
    [self.navigationController pushViewController:noteViewController animated:YES];
    [noteViewController release];
}

- (UITableViewCellAccessoryType)accessoryTypeForManagedObject:(NSManagedObject *)managedObject
{
	return UITableViewCellAccessoryNone;
}


@end
