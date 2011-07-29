//
//  NotesTableViewController.h
//  TabViewTest
//
//  Created by Sabin Dang on 4/1/11.
//  Copyright 2011 sabindang.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "Category.h"

@interface NotesTableViewController : CoreDataTableViewController {
}

@property (retain) UITabBarItem *tabBarItem;
//ck add a context
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property BOOL focusSearchBar;
- (id)initWithStyle:(UITableViewStyle)style inManagedContext:(NSManagedObjectContext *)context withCategory:(Category *)category;

@end
