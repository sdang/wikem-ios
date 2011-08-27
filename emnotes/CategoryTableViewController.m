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
#import "VariableStore.h"

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
        UIBarButtonItem *sButton = 
		    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(gotoSearch)];
        self.navigationItem.rightBarButtonItem = sButton;
        [sButton release];
        
    }
    return self;
}
- (void)gotoSearch
{ 
//First do some maintenance. check if needs a new cache
	if ([VariableStore sharedInstance].categoryViewNeedsCacheReset==YES){
		//delete cache 'nil' specifies deletes all cache files
		[NSFetchedResultsController deleteCacheWithName:nil];  
		//reset the bool to NO
		[VariableStore sharedInstance].categoryViewNeedsCacheReset=NO;
		NSLog(@"cache deleted");
		}
	
//now start a new notetableviewcontroller	
	
    NotesTableViewController *noteTableViewController = [[NotesTableViewController alloc] initWithStyle:UITableViewStylePlain 
														inManagedContext:[self.fetchedResultsController managedObjectContext] 
														         withCategory:nil];
    //set the noteTableView to focus
	noteTableViewController.focusSearchBar = TRUE;
	self.notesTableViewController = noteTableViewController;
    [self.navigationController pushViewController:noteTableViewController animated:NO];
	//[self.navigationController pushViewController:noteTableViewController animated:YES];

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
                                     //      cacheName:@"categories"]; 
										   cacheName:nil];
        
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
  //  [self.navigationController pushViewController:noteTableViewController animated:YES];
	[self.navigationController pushViewController:noteTableViewController animated:NO];

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

		NSString *wikem = @"WikEM ";
		NSString *titlestring = self.tabBarItem.title;
		
        self.title = [NSString stringWithFormat:@"%@%@", wikem, titlestring];
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

/* don't need. put in the parent tabbar class
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
	return YES;
}*/

@end
