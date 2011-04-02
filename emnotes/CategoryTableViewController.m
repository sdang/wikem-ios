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


- (id)initWithStyle:(UITableViewStyle)style inManagedContext:(NSManagedObjectContext *)context
{
    if ((self = [self initWithStyle:style])) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        request.entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:context];
        request.sortDescriptors = [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES]];
        request.predicate = nil;
        request.fetchBatchSize = 20;
        
        NSFetchedResultsController *frc = [[NSFetchedResultsController alloc]
                                           initWithFetchRequest:request
                                           managedObjectContext:context
                                           sectionNameKeyPath:nil 
                                           cacheName:@"categories"];
        
        self.fetchedResultsController = frc;
        [frc release];
    }
    return self;
}

- (void)managedObjectSelected:(NSManagedObject *)managedObject
{
    
    NotesTableViewController *noteTableViewController = [[NotesTableViewController alloc] initWithStyle:UITableViewStylePlain 
                                                                                       inManagedContext:[fetchedResultsController managedObjectContext] 
                                                                                           withCategory:(Category *)managedObject];
    [self.navigationController pushViewController:noteTableViewController animated:YES];
    [noteTableViewController release];
}

- (void)setupTabBarItem
{
    UITabBarItem *item = [[UITabBarItem alloc]
                          initWithTitle:@"Categories"
                          image:[UIImage imageNamed:@"33-cabinet.png"]
                          tag:0];
    self.searchKey = @"title";
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
    [tabBarItem dealloc];
    [super dealloc];
}


@end
