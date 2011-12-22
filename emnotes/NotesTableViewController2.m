//
//  NotesTableViewController2.m
//  emnotes
//
//  Created by chris on 12/10/11.

/* Search/Find viewcontroller
  this class should load faster than the other notestablecontroller since it is not responsible to load the entire list. the fetch is limited to ~60 results. while typing the tableview is simply hidden  
  */
#import "NotesTableViewController2.h"
#import "NoteViewController.h"
#import "Note.h"
#import "CategoryTableViewController.h"
#import "VariableStore.h"

@implementation NotesTableViewController2

@synthesize tabBarItem;
@synthesize isTyping;
@synthesize managedObjectContext;
 
- (void)setupTabBarItem
{
    UITabBarItem *item = [[UITabBarItem alloc]
                          initWithTitle:@"Find"
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
		
        self.title = @"Search Full Text";
       // self.searchDisplayController.searchContentsController.view.hidden = YES; 
            }
    return self;
}
 
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
{  	[self.mySearchBar becomeFirstResponder];}

- (void)dealloc
{
    [tabBarItem release];
    [super dealloc];
}

- (void)viewDidAppear:(BOOL)animated {
    //ck, will focus search bar unless text already in searchbar 
    if ([self.mySearchBar.text length] ==0)
    {
        [self.mySearchBar becomeFirstResponder];
        self.mySearchBar.placeholder = @"Press 'Search' after search term";
        self.mySearchBar.translucent = YES;
     }
         
	 //check to see if updates made and cache needs to be deleted
	if ([VariableStore sharedInstance].searchViewNeedsCacheReset==YES){
		[NSFetchedResultsController deleteCacheWithName:nil];  
        [VariableStore sharedInstance].searchViewNeedsCacheReset=NO;
		NSLog(@"cache deleted");
	}
	
}

- (void)viewDidLoad 
{ 
    //the overlay once start searching
    self.searchDisplayController.searchResultsTableView.backgroundColor = [UIColor darkGrayColor];
    self.searchDisplayController.searchResultsTableView.separatorColor = [UIColor blackColor];
    self.searchDisplayController.searchResultsTableView.scrollEnabled = NO;
    //the default tableview just sitting there before the saesrch overlay
    self.tableView.separatorColor = [UIColor blackColor];
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.scrollEnabled = NO;
    
    //  self.searchDisplayController.searchResultsTableView.backgroundColor = [UIColor lightGrayColor];
    //self.imageView.image = [UIImage imageNamed:@"gradientBackground.png"];
	
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
            
            
            NSString *cacheName = @"notes2";
             //check to see if updates made and cache needs to be deleted. also check every instance viewdidappear
            if ([VariableStore sharedInstance].searchViewNeedsCacheReset==YES){
                //delete cache 'nil' specifies deletes all cache files
                [NSFetchedResultsController deleteCacheWithName:cacheName];  
                
                //reset the bool to NO
                [VariableStore sharedInstance].searchViewNeedsCacheReset=NO;
                NSLog(@"cache deleted");
            }
            
            
                    request.predicate = nil;
               // request.predicate = [NSPredicate predicateWithFormat:@"%@ in content", ];
                    [request setFetchLimit:60];
             
            
            request.fetchBatchSize = 30;
            
            NSFetchedResultsController *frc = [[NSFetchedResultsController alloc]
                                               initWithFetchRequest:request
                                               managedObjectContext:context
                                               sectionNameKeyPath:nil
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
}

- (void)managedObjectSelected:(NSManagedObject *)managedObject
{ 
    //no selecting when typing in this view
    if(!isTyping){
        NoteViewController *noteViewController = [[NoteViewController alloc] init];
        noteViewController.managedObjectContext = self.managedObjectContext;
        noteViewController.note = (Note *)managedObject;
        [self.navigationController pushViewController:noteViewController animated:NO];
        noteViewController = nil;
        [noteViewController release];}
}

- (UITableViewCellAccessoryType)accessoryTypeForManagedObject:(NSManagedObject *)managedObject
{
	return UITableViewCellAccessoryNone;
}

#pragma mark SearchBarDelegate stuff

//these are UISearchBarDelegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	 
 	[self.searchDisplayController setActive:NO];
    //need this or crash
    
	[self.navigationController dismissModalViewControllerAnimated:NO];
	[self.navigationController popViewControllerAnimated:NO];        
}

//Typically, you implement this method to perform the text-based search.
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{ //NSLog(@" asdlfkjasfdl;kjasfd l;kajsdf sbTextdidEND");
             self.searchDisplayController.searchResultsTableView.backgroundColor = [UIColor blackColor];
        self.searchDisplayController.searchResultsTableView.separatorColor = [UIColor blackColor];
        
        // self.tableView.scrollEnabled = NO;
        self.searchDisplayController.searchResultsTableView.scrollEnabled = NO;
        self.isTyping = YES;
    
}


//want to return no and not auto refresh when search string changes
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString 
{
//while typing also need to keep color scheme here
    if(isTyping){
        //do nothing... will unlock screen once done searching
    }else{
        self.searchDisplayController.searchResultsTableView.backgroundColor = [UIColor blackColor];
        self.searchDisplayController.searchResultsTableView.separatorColor = [UIColor blackColor];
        
       // self.tableView.scrollEnabled = NO;
        self.searchDisplayController.searchResultsTableView.scrollEnabled = NO;
        
        self.isTyping = YES;
    }
       
   
    return NO;
}
//You should implement this method to begin the search. Use the text property of the search bar to get the text. 
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
   
         //searchResultsTableView is basically an overlay on top of the original tableview
        self.searchDisplayController.searchResultsTableView.backgroundColor = [UIColor whiteColor];
        self.isTyping = NO;
        self.searchDisplayController.searchResultsTableView.scrollEnabled = YES;
        self.searchDisplayController.searchResultsTableView.separatorColor = [UIColor lightGrayColor];
        [self.searchDisplayController.searchResultsTableView reloadData];
    
    
}

//override this method of superclass to get rid of highlighting cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForManagedObject:(NSManagedObject *)managedObject
{   
    static NSString *ReuseIdentifier = @"CoreDataTableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ReuseIdentifier];
    if (cell == nil) {
		UITableViewCellStyle cellStyle = self.subtitleKey ? UITableViewCellStyleSubtitle : UITableViewCellStyleDefault;
        cell = [[[UITableViewCell alloc] initWithStyle:cellStyle reuseIdentifier:ReuseIdentifier] autorelease];
//don't want highlight blue on selection
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
	
	if (self.titleKey) cell.textLabel.text = [managedObject valueForKey:self.titleKey];
	if (self.subtitleKey) cell.detailTextLabel.text = [managedObject valueForKey:self.subtitleKey];
	cell.accessoryType = [self accessoryTypeForManagedObject:managedObject];
	UIImage *thumbnail = [self thumbnailImageForManagedObject:managedObject];
	if (thumbnail) cell.imageView.image = thumbnail;
	
	return cell;
} 
- (NSIndexPath *)tableView :(UITableView *)theTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isTyping){
        return nil;
    }else{
        return indexPath;
    }
        
}
@end
