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
#import "CategoryTableViewController.h"
#import "VariableStore.h"

@implementation NotesTableViewController

@synthesize tabBarItem;
//ck : makes default setters and getters..
@synthesize managedObjectContext;

@synthesize focusSearchBar;

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
		//
		
        self.title = self.tabBarItem.title;
        // Custom initialization
		//NSLog(@"initwstle no params");
		//focusSearchBar = FALSE;
    }
    return self;
}
//ck...place this in init with sytle?
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UIBarButtonItem *searchButton = 
			[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(gotoSearch)];
        self.navigationItem.rightBarButtonItem = searchButton;
        [searchButton release];
        
    }
    return self;
}
- (void)gotoSearch
{ 
 	[self.mySearchBar becomeFirstResponder];


}

- (void)dealloc
{
    [tabBarItem release];
    [super dealloc];
}

- (void)viewDidAppear:(BOOL)animated {
  //  NSLog(@"view did appear");
	if (focusSearchBar == TRUE){
		[self.mySearchBar becomeFirstResponder];
	//	NSLog(@"FOCUS IT");
		//reset it
		focusSearchBar = FALSE;
	}
	//check to see if updates made and cache needs to be deleted
	if ([VariableStore sharedInstance].notesViewNeedsCacheReset==YES){
		//delete cache 'nil' specifies deletes all cache files
		[NSFetchedResultsController deleteCacheWithName:nil];  
		
		//reset the bool to NO
		[VariableStore sharedInstance].notesViewNeedsCacheReset=NO;
		NSLog(@"cache deleted");
	}
	
	
}
- (void)viewDidLoad 
{
	
	
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
        //check to see if updates made and cache needs to be deleted. also check every instance viewdidappear
		if ([VariableStore sharedInstance].notesViewNeedsCacheReset==YES){
			//delete cache 'nil' specifies deletes all cache files
			[NSFetchedResultsController deleteCacheWithName:nil];  
			
			//reset the bool to NO
			[VariableStore sharedInstance].notesViewNeedsCacheReset=NO;
			NSLog(@"cache deleted");
		}
        if (category) {
            request.predicate = [NSPredicate predicateWithFormat:@"%@ in categories", category];
            self.title = category.title;
            cacheName = [NSString stringWithString:category.title];
            sectionName = nil; 
        } else {
			NSLog(@"init notestableviewcontroller");
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
										 //  cacheName:nil];
//ck:cache headache..

        self.fetchedResultsController = frc;
        [sortDescriptor release];
        [request release];
        [frc release];
		
     }
    return self;
}

/*doesn't need. call rotate through the parent tabbarview
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
	return YES;
}
*/


- (void)managedObjectSelected:(NSManagedObject *)managedObject
{ 
    NoteViewController *noteViewController = [[NoteViewController alloc] init];
	noteViewController.managedObjectContext = self.managedObjectContext;
//i hope that passed the correct context along...
	noteViewController.note = (Note *)managedObject;
   // [self.navigationController pushViewController:noteViewController animated:YES];
	[self.navigationController pushViewController:noteViewController animated:NO];

    [noteViewController release];
}

- (UITableViewCellAccessoryType)accessoryTypeForManagedObject:(NSManagedObject *)managedObject
{
	return UITableViewCellAccessoryNone;
}

#pragma mark SearchBarDelegate stuff

//these are UISearchBarDelegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	// Existing code
	NSLog(@"cancel button clicked");
	//[self.view removeFromSuperview]; 
	
//	[self.navigationController dismissModalViewControllerAnimated:YES];
	[self.searchDisplayController setActive:NO];
//need this or crash
//	[self.navigationController popViewControllerAnimated:YES];    

 	
	
	
	
	[self.navigationController dismissModalViewControllerAnimated:NO];
	[self.navigationController popViewControllerAnimated:NO];    


}



@end
