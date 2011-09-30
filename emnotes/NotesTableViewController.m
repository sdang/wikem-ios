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
-(void)viewDidDisappear:(BOOL)animated{
	NSLog(@"viewdid disappear");

}
- (void)viewDidAppear:(BOOL)animated {
	NSLog(@"viewdid appear");
 //ck, will focus search bar if pressed search button in category tab.
	if ([VariableStore sharedInstance].focusSearchBar == TRUE){
		[self.mySearchBar becomeFirstResponder];
 		//reset it
		[VariableStore sharedInstance].focusSearchBar = FALSE;
		NSLog(@"categorytable view set focus to false");

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
	@try{
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
 

        request.entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:context];
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
			self.fetchedResultsController = frc;
			[sortDescriptor release];
			[request release];
			[frc release];
			
			
 	}@catch (NSException * e) {
		if([[e name] isEqualToString:NSInternalInconsistencyException]){
			[NSFetchedResultsController deleteCacheWithName:nil];  
			
			[self.tableView reloadData];
			NSLog(@"ck:request failed when requesting predicate, reload data with cleaned cache");
		}
		else { @throw e;}
	}
		
		
       
		
     }
    return self;
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

	[self.navigationController dismissModalViewControllerAnimated:NO];
	[self.navigationController popViewControllerAnimated:NO];    


}



@end
