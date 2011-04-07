//
//  PersonalNotesTableViewController.h
//  TabViewTest
//
//  Created by Sabin Dang on 4/1/11.
//  Copyright 2011 sabindang.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "PersonalNote.h"
#import "PersonalNotesViewController.h"

@interface PersonalNotesTableViewController : CoreDataTableViewController {
    
}

@property (retain) UITabBarItem *tabBarItem;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (id)initWithStyle:(UITableViewStyle)style inManagedContext:(NSManagedObjectContext *)context;
- (void)createNewNote;

@end
