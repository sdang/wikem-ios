//
//  CoreDataTableViewController.m
//
//  Created for Stanford CS193p Spring 2010
//

#import "CoreDataTableViewController.h"

@implementation CoreDataTableViewController

@synthesize fetchedResultsController;
@synthesize titleKey, subtitleKey, searchKey;
//
@synthesize mySearchBar;
@synthesize searchBarReturnKey;

 
- (void)createSearchBar
{
	if (self.searchKey.length) {
		if (self.tableView && !self.tableView.tableHeaderView) {
	//	if (self.tableView && self.tableView.tableHeaderView) {

	//		UISearchBar *searchBar = [[[UISearchBar alloc] init] autorelease];
			mySearchBar = [[[UISearchBar alloc] init] autorelease];
			mySearchBar.delegate = self;

			
			
			[[UISearchDisplayController alloc] initWithSearchBar:mySearchBar contentsController:self];
			self.searchDisplayController.searchResultsDelegate = self;
			self.searchDisplayController.searchResultsDataSource = self;
			self.searchDisplayController.delegate = self;
			mySearchBar.frame = CGRectMake(0, 0, 0, 38);
			self.tableView.tableHeaderView = mySearchBar;
			
			//try to change search button to say 'done'
			for (UIView *searchBarSubview in [mySearchBar subviews]) {
				if ([searchBarSubview conformsToProtocol:@protocol(UITextInputTraits)]) {
					@try {
                        if (searchBarReturnKey)
                        {
                             // default is 'search'
                         }
                        else{ //'done' instead of 'search'
 
						[(UITextField *)searchBarSubview setReturnKeyType:UIReturnKeyDone];
                        }
					}
					@catch (NSException * e) {
						// ignore exception
					}
				}
			  }
			
		}
	} else { NSLog(@"er... no tableheader view");
		self.tableView.tableHeaderView = nil;
	}
}

- (void)setSearchKey:(NSString *)aKey
{ //NSLog(@"setserachkey being called");
	
	[searchKey release];
	searchKey = [aKey copy];
	[self createSearchBar];
}

- (NSString *)titleKey
{  
	if (!titleKey) {
		NSArray *sortDescriptors = [self.fetchedResultsController.fetchRequest sortDescriptors];
		if (sortDescriptors.count) {
			return [[sortDescriptors objectAtIndex:0] key];
		} else {
			return nil;
		}
	} else {
		return titleKey;
	}
}

- (void)performFetchForTableView:(UITableView *)tableView
{
	NSError *error = nil;
	@try{
		[self.fetchedResultsController performFetch:&error];
	}@catch (NSException * e) {
		if([[e name] isEqualToString:NSInternalInconsistencyException]){
			[NSFetchedResultsController deleteCacheWithName:nil];  
			
			//[self.tableView reloadData];
			NSLog(@"ck:exceptino thrown in coredatatableviewcontorller, reload data with cleaned cache");
		}
		else { @throw e;}
	}
	if (error) {
		NSLog(@"[CoreDataTableViewController performFetchForTableView:] %@ (%@)", [error localizedDescription], [error localizedFailureReason]);
	}
	[tableView reloadData];
}

- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView
{
	if (tableView == self.tableView) {
		if (self.fetchedResultsController.fetchRequest.predicate != normalPredicate) {
			[NSFetchedResultsController deleteCacheWithName:self.fetchedResultsController.cacheName];
			self.fetchedResultsController.fetchRequest.predicate = normalPredicate;
			[self performFetchForTableView:tableView];
		}
		[currentSearchText release];
		currentSearchText = nil;
	} else if ((tableView == self.searchDisplayController.searchResultsTableView) && self.searchKey && ![currentSearchText isEqual:self.searchDisplayController.searchBar.text]) {
		[currentSearchText release];
		currentSearchText = [self.searchDisplayController.searchBar.text copy];
		NSString *searchPredicateFormat = [NSString stringWithFormat:@"%@ contains[c] %@", self.searchKey, @"%@"];
		NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:searchPredicateFormat, self.searchDisplayController.searchBar.text];
		[NSFetchedResultsController deleteCacheWithName:self.fetchedResultsController.cacheName];
		self.fetchedResultsController.fetchRequest.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:searchPredicate, normalPredicate , nil]];
		[self performFetchForTableView:tableView];
	}
	return self.fetchedResultsController;
}


// UISearchDisplayDelegate
- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
	// reset the fetch controller for the main (non-searching) table view
 	NSLog(@"will end search");
	[self fetchedResultsControllerForTableView:self.tableView];
}
 
 

- (void)setFetchedResultsController:(NSFetchedResultsController *)controller
{
	fetchedResultsController.delegate = nil;
	[fetchedResultsController release];
	fetchedResultsController = [controller retain];
	controller.delegate = self;
	normalPredicate = [self.fetchedResultsController.fetchRequest.predicate retain];
	if (!self.title) self.title = controller.fetchRequest.entity.name;
	if (self.view.window) [self performFetchForTableView:self.tableView];
}

- (UITableViewCellAccessoryType)accessoryTypeForManagedObject:(NSManagedObject *)managedObject
{
	return UITableViewCellAccessoryDisclosureIndicator;
}

- (UIImage *)thumbnailImageForManagedObject:(NSManagedObject *)managedObject
{
	return nil;
}

- (void)configureCell:(UITableViewCell *)cell forManagedObject:(NSManagedObject *)managedObject
{
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForManagedObject:(NSManagedObject *)managedObject
{
    static NSString *ReuseIdentifier = @"CoreDataTableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ReuseIdentifier];
    if (cell == nil) {
		UITableViewCellStyle cellStyle = self.subtitleKey ? UITableViewCellStyleSubtitle : UITableViewCellStyleDefault;
        cell = [[[UITableViewCell alloc] initWithStyle:cellStyle reuseIdentifier:ReuseIdentifier] autorelease];
    }
	
	if (self.titleKey) cell.textLabel.text = [managedObject valueForKey:self.titleKey];
	if (self.subtitleKey) cell.detailTextLabel.text = [managedObject valueForKey:self.subtitleKey];
	cell.accessoryType = [self accessoryTypeForManagedObject:managedObject];
	UIImage *thumbnail = [self thumbnailImageForManagedObject:managedObject];
	if (thumbnail) cell.imageView.image = thumbnail;
	
	return cell;
}

- (void)managedObjectSelected:(NSManagedObject *)managedObject
{
    // Navigation logic may go here. Create and push another view controller.
    // AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
    // [self.navigationController pushViewController:anotherViewController];
    // [anotherViewController release];
}

- (void)deleteManagedObject:(NSManagedObject *)managedObject
{
}

- (BOOL)canDeleteManagedObject:(NSManagedObject *)managedObject
{
	return NO;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSManagedObject *managedObject = [[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath];
	return [self canDeleteManagedObject:managedObject];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSManagedObject *managedObject = [[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath];
	[self deleteManagedObject:managedObject];
}

#pragma mark UIViewController methods

- (void)viewDidLoad
{
	[self createSearchBar];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self performFetchForTableView:self.tableView];
}

#pragma mark UITableViewDataSource methods

//Sample code taken from NSFetchedResultsController Class Reference
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[[self fetchedResultsControllerForTableView:tableView] sections] count];
}

//Sample code taken from NSFetchedResultsController Class Reference
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray *sectionTitles = [NSMutableArray arrayWithArray:[[self fetchedResultsControllerForTableView:tableView] sectionIndexTitles]];
    if ([sectionTitles count]) {
        [sectionTitles insertObject:@"{search}" atIndex:0];
    }
	return [NSArray arrayWithArray:sectionTitles];
}

#pragma mark UITableViewDelegate methods

//Sample code taken from NSFetchedResultsController Class Reference
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[[self fetchedResultsControllerForTableView:tableView] sections] objectAtIndex:section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
	return [self tableView:tableView cellForManagedObject:[[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self managedObjectSelected:[[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath]];
}

//Sample code taken from NSFetchedResultsController Class Reference
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [[[[self fetchedResultsControllerForTableView:tableView] sections] objectAtIndex:section] name];
}

//Sample code taken from NSFetchedResultsController Class Reference
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (index) {
        return [[self fetchedResultsControllerForTableView:tableView] sectionForSectionIndexTitle:title atIndex:index-1];
    } else {
        return 0;
    }

}

#pragma mark NSFetchedResultsControllerDelegate methods

//Sample code taken from NSFetchedResultsControllerDelegate Protocol Reference "Typical Use"
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

//Sample code taken from NSFetchedResultsControllerDelegate Protocol Reference "Typical Use"
- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex
	 forChangeType:(NSFetchedResultsChangeType)type
{	
    switch(type)
	{
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


//Sample code taken from NSFetchedResultsControllerDelegate Protocol Reference "Typical Use"
- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath
	 forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath
{	
    UITableView *tableView = self.tableView;
	
    switch(type)
	{
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeUpdate:
			[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

//Sample code taken from NSFetchedResultsControllerDelegate Protocol Reference "Typical Use"
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}
#pragma mark SearchBarDelegate stuff
/*
//these are UISearchBarDelegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    // Existing code
	NSLog(@"cancel button clicked");
	searchBar.text = @"";
	//[self searchBar:searchBar activate:NO];
	[searchBar setHidden:YES];

	
	[searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
	
	
}*/

//Typically, you implement this method to perform the text-based search.
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{ //NSLog(@" asdlfkjasfdl;kjasfd l;kajsdf sbTextdidEND");
  
}



#pragma mark dealloc

- (void)dealloc
{
	fetchedResultsController.delegate = nil;
	[fetchedResultsController release];
	[searchKey release];
	[titleKey release];
	[currentSearchText release];
	[normalPredicate release];
	[mySearchBar release];
    [super dealloc];
}

@end

