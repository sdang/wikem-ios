//
//  PersonalNotesTableViewController.m
//  TabViewTest
//
//  Created by Sabin Dang on 4/1/11.
//  Copyright 2011 sabindang.com. All rights reserved.
//

#import "PersonalNotesTableViewController.h"
#import "PersonalNote.h"
#import "EditNoteViewController.h"
#import "PersonalNotesViewController.h"


@implementation PersonalNotesTableViewController

@synthesize tabBarItem;
@synthesize managedObjectContext;

- (void)setupTabBarItem
{
    UITabBarItem *item = [[UITabBarItem alloc]
                          initWithTitle:@"Personal Notes"
                          image:[UIImage imageNamed:@"180-stickynote.png"]
                          tag:0];
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
        UIBarButtonItem *addButton  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAdd
                                                                                    target: self
                                                                                    action: @selector(createNewNote)];
        self.navigationItem.rightBarButtonItem = addButton;
        [addButton release];
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem;
        
        
    }
    return self;
}

- (void)createNewNote
{
    EditNoteViewController *editNoteViewController = [[EditNoteViewController alloc] init];
    editNoteViewController.managedObjectContext = self.managedObjectContext;
    [[self navigationController] pushViewController:editNoteViewController animated:YES];
    [editNoteViewController release];
}

- (id)initWithStyle:(UITableViewStyle)style inManagedContext:(NSManagedObjectContext *)context
{
    if ((self = [self initWithStyle:style])) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        request.entity = [NSEntityDescription entityForName:@"PersonalNote" inManagedObjectContext:context];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
        request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        request.predicate = nil;
        request.fetchBatchSize = 20;
        self.managedObjectContext = context;
        
        NSFetchedResultsController *frc = [[NSFetchedResultsController alloc]
                                           initWithFetchRequest:request
                                           managedObjectContext:context
                                           sectionNameKeyPath:nil 
                                           cacheName:@"personalNotes"];
        
        self.fetchedResultsController = frc;
        [sortDescriptor release];
        [request release];
        [frc release];
    }
    return self;
}

- (void)dealloc
{
    [tabBarItem release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


#pragma mark - Table view delegate

- (void)managedObjectSelected:(NSManagedObject *)managedObject
{
    // show note view controller
    PersonalNotesViewController *personalNotesViewController = [[PersonalNotesViewController alloc] init];
    personalNotesViewController.personalNote = (PersonalNote *)managedObject;
    [[self navigationController] pushViewController:personalNotesViewController animated:YES];
    [personalNotesViewController release];
}

- (BOOL)canDeleteManagedObject:(NSManagedObject *)managedObject
{
	return YES;
}

- (void)deleteManagedObject:(NSManagedObject *)managedObject
{
    // delete the personal note
    [self.managedObjectContext deleteObject:managedObject];
    [self.managedObjectContext save:NULL];
}


@end
