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
	
//now do all searching in allnotes, so switch tabbar to notestableviewcontroller	
 	[VariableStore sharedInstance].focusSearchBar = TRUE;
	NSLog(@"categorytable view set focus to true");
	//to actually switch the controller
	[self.parentViewController.tabBarController setSelectedIndex:1];
/*	ck: the following line of code is confusing, in essence it will
	 send didSelectViewController to the tabBarController delegate
	although the search button on categoryview sometimes works without it
	it doesn't trigger didselectviewcontroller... the delegate doesn't know that we switched
	the issue being that we want to 'pop' the view, but this is done in didselectviewcontroller
	thus, without this line of code, pressing search may goto the notetableviewcontroller which is still on some note page...
	... not the listview. ie. pressing search sometimes won't search
 fixed here:
 */
 [self.parentViewController.tabBarController.delegate tabBarController:self.tabBarController didSelectViewController:[self.tabBarController.viewControllers objectAtIndex:1]];  
 //
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

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
	//delete cache 'nil' specifies deletes all cache files
	[NSFetchedResultsController deleteCacheWithName:nil];  
	
	NSLog(@"cache deleted");
	
}

@end
