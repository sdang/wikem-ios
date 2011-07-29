//
//  CategoryTableViewController.m
//  TabViewTest
//
//  Created by Sabin Dang on 4/1/11.
//  Copyright 2011 sabindang.com. All rights reserved.
//

#import "CategoryTableViewController.h"
#import "NotesTableViewController.h"
#import "Category.h"
#import "CoreDataTableViewController.h"

@implementation CategoryTableViewController

@synthesize tabBarItem;
@synthesize managedObjectContext;
@synthesize notesTableViewController;


//ck...place this in init with sytle?
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UIBarButtonItem *sButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(gotoSearch)];
        self.navigationItem.rightBarButtonItem = sButton;
        [sButton release];
        
    }
    return self;
}
- (void)gotoSearch
{ 
	
	
    NotesTableViewController *noteTableViewController = [[NotesTableViewController alloc] initWithStyle:UITableViewStylePlain 
                                                                                       inManagedContext:[self.fetchedResultsController managedObjectContext] 
														         withCategory:nil];
    //set the noteTableView to focus
	noteTableViewController.focusSearchBar = TRUE;
	self.notesTableViewController = noteTableViewController;
    [self.navigationController pushViewController:noteTableViewController animated:YES];
    [noteTableViewController release];
 
}



- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    // Existing code
	self.searchKey = nil;

 }


- (id)initWithStyle:(UITableViewStyle)style inManagedContext:(NSManagedObjectContext *)context
{
    if ((self = [self initWithStyle:style])) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        request.entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:context];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
        request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        request.predicate = nil;
        request.fetchBatchSize = 20;
        
        NSFetchedResultsController *frc = [[NSFetchedResultsController alloc]
                                           initWithFetchRequest:request
                                           managedObjectContext:context
                                           sectionNameKeyPath:nil 
                                           cacheName:@"categories"]; 
									//	   cacheName:nil];
        
        self.fetchedResultsController = frc;
        [sortDescriptor release];
        [request release];
        [frc release];
    }
    return self;
}

- (void)managedObjectSelected:(NSManagedObject *)managedObject
{
    
    NotesTableViewController *noteTableViewController = [[NotesTableViewController alloc] initWithStyle:UITableViewStylePlain 
                                                                                       inManagedContext:[self.fetchedResultsController managedObjectContext] 
                                                                                           withCategory:(Category *)managedObject];
    self.notesTableViewController = noteTableViewController;
    [self.navigationController pushViewController:noteTableViewController animated:YES];
    [noteTableViewController release];
}

- (void)setupTabBarItem
{
    UITabBarItem *item = [[UITabBarItem alloc]
                          initWithTitle:@"Categories"
                          image:[UIImage imageNamed:@"33-cabinet.png"]
                          tag:0];
   // self.searchKey = @"title";
    self.tabBarItem = item;
    [item release];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [self setupTabBarItem];
        self.title = self.tabBarItem.title;
    }
    return self;
}

- (void)dealloc
{
    [self.notesTableViewController release];
    [tabBarItem release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.tabBarItem = nil;
    self.notesTableViewController = nil;
}

@end
