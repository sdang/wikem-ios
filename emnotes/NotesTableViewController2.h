//
//  NotesTableViewController2.h
//  emnotes
//
//  Created by Busby on 12/10/11.
 //very similar but uses full text search. somehwat redundant but not much code here anyways


#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "Category.h"

@interface NotesTableViewController2 : CoreDataTableViewController {
}

@property (retain) UITabBarItem *tabBarItem;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property BOOL isTyping;
 
- (id)initWithStyle:(UITableViewStyle)style inManagedContext:(NSManagedObjectContext *)context withCategory:(Category *)category;

@end
