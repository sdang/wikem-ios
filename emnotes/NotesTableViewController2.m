//
//  NotesTableViewController2.m
//  emnotes
//
//  Created by Busby on 12/10/11.
//get rid of scrollview and make overlay
//also when click on image link...open imagebrowser?
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
    
   
     //ck, will focus search bar if pressed search button in category tab.
    [self.mySearchBar becomeFirstResponder];
    self.mySearchBar.placeholder = @"Press 'Search' after search term";
   // self.mySearchBar.barStyle = UIBarStyleBlack;
    self.mySearchBar.translucent = YES;
  //  self.mySearchBar.tintColor

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
    //the overlay once start searching
    self.searchDisplayController.searchResultsTableView.backgroundColor = [UIColor darkGrayColor];
    self.searchDisplayController.searchResultsTableView.separatorColor = [UIColor blackColor];

    //the default tableview just sitting there before the saesrch overlay
    self.tableView.separatorColor = [UIColor blackColor];
    self.tableView.backgroundColor = [UIColor blackColor];
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
    
    NSLog(@"cache deleted");
    
}

- (void)managedObjectSelected:(NSManagedObject *)managedObject
{ 
    //no selecting when typing in this view
    if(!isTyping){
    NoteViewController *noteViewController = [[NoteViewController alloc] init];
	noteViewController.managedObjectContext = self.managedObjectContext;
    //i hope that passed the correct context along...
	noteViewController.note = (Note *)managedObject;
    // [self.navigationController pushViewController:noteViewController animated:YES];
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
//while typing also need to keep color scheme here
    if(isTyping){
        //do nothing... will unlock screen once done searching
        
        //make the search screen exclusive
     //   self.searchDisplayController.searchResultsTableView.exclusiveTouch = YES;

    }else{
        self.searchDisplayController.searchResultsTableView.backgroundColor = [UIColor blackColor];
        self.searchDisplayController.searchResultsTableView.separatorColor = [UIColor blackColor];
        
                self.isTyping = YES;
    }
       
   
    return NO;
}
//You should implement this method to begin the search. Use the text property of the search bar to get the text. You can also send becomeFirstResponder to the search bar to begin editing programmatically.
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
   
         //searchResultsTableView is basically an overlay on top of the original tableview
        self.searchDisplayController.searchResultsTableView.backgroundColor = [UIColor whiteColor];
        
        //make table footer... doesnt apear after query..
        UIView *containerView =
        [[[UIView alloc]
          initWithFrame:CGRectMake(0, 0, 300, 60)]
         autorelease];
        UILabel *footerLabel =
        [[[UILabel alloc]
          initWithFrame:CGRectMake(10, 20, 300, 40)]
         autorelease];
        footerLabel.text = NSLocalizedString(@"To find a search term within all WikEM articles, press RETURN/'Search' Key to query ", @"");
        footerLabel.textColor = [UIColor whiteColor];
        footerLabel.shadowColor = [UIColor blackColor];
        footerLabel.shadowOffset = CGSizeMake(0, 1);
        footerLabel.font = [UIFont boldSystemFontOfSize:22];
        footerLabel.backgroundColor = [UIColor clearColor];
        [containerView addSubview:footerLabel];
        self.searchDisplayController.searchResultsTableView.tableFooterView = containerView;       
        
        
        self.isTyping = NO;
    

        [self.searchDisplayController.searchResultsTableView reloadData];
        
        
    
}

//override this method of superclass
- (UITableViewCell *)tableView:(UITableView *)tableView cellForManagedObject:(NSManagedObject *)managedObject
{  //NSLog(@"cellformanagedobj");
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
@end
