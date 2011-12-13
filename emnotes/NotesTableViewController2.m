//
//  NotesTableViewController2.m
//  emnotes
//
//  Created by Busby on 12/10/11.
  

#import "NotesTableViewController2.h"
#import "NoteViewController.h"
#import "Note.h"
#import "CategoryTableViewController.h"
#import "VariableStore.h"

@implementation NotesTableViewController2

@synthesize tabBarItem;
//ck : makes default setters and getters..
@synthesize managedObjectContext;


- (void)setupTabBarItem
{
    UITabBarItem *item = [[UITabBarItem alloc]
                          initWithTitle:@"Full Text"
                          image:[UIImage imageNamed:@"06-magnify.png"]
                          tag:0];
    self.tabBarItem = item;
    [item release];
}

- (id)initWithStyle:(UITableViewStyle)style
{   //set this so searchbar return key no longer says 'DONE'
    self.searchBarReturnKey = YES;

    self = [super initWithStyle:style];
    if (self) {
        [self setupTabBarItem];
        self.searchKey = @"content";
		//searchkey is string of inherited coredatatableviewcontroller...
		
        self.title = @"Search within articles";
        
        
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
	//NSLog(@"viewdid disappear");
    
}
- (void)viewDidAppear:(BOOL)animated {
    //	NSLog(@"viewdid appear");
    //ck, will focus search bar if pressed search button in category tab.
	if ([VariableStore sharedInstance].focusSearchBar == TRUE){
		[self.mySearchBar becomeFirstResponder];
 		//reset it
		[VariableStore sharedInstance].focusSearchBar = FALSE;
		NSLog(@"categorytable view set focus to false");
        
	}
	//check to see if updates made and cache needs to be deleted
	if ([VariableStore sharedInstance].searchViewNeedsCacheReset==YES){
		//delete cache 'nil' specifies deletes all cache files
		[NSFetchedResultsController deleteCacheWithName:nil];  
		
		//reset the bool to NO
		[VariableStore sharedInstance].searchViewNeedsCacheReset=NO;
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
    self.managedObjectContext = nil;
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
            cacheName = @"notes2";

            NSString *sectionName = nil;
            //check to see if updates made and cache needs to be deleted. also check every instance viewdidappear
            if ([VariableStore sharedInstance].searchViewNeedsCacheReset==YES){
                //delete cache 'nil' specifies deletes all cache files
                [NSFetchedResultsController deleteCacheWithName:cacheName];  
                
                //reset the bool to NO
                [VariableStore sharedInstance].searchViewNeedsCacheReset=NO;
                NSLog(@"cache deleted");
            }
            
            
			if (category) {
				request.predicate = [NSPredicate predicateWithFormat:@"%@ in categories", category];
				self.title = category.title;
				cacheName = [NSString stringWithString:category.title];
				sectionName = nil; 
            } else {
				NSLog(@"init notestableviewcontroller2");
				sectionName = @"getFirstLetter";
				cacheName = @"notes2";
				request.predicate = nil;
               // request.predicate = [NSPredicate predicateWithFormat:@"%@ in content", ];

                
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
{ NSLog(@"notestableviewcontroller didreceivemem warning!?!");
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
    noteViewController = nil;
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
//want to return no and not auto refresh when search string changes
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString 
{
    NSLog(@"The shouldreloadtableforsearchstring method has been called!");
    return NO;
}
 
@end
