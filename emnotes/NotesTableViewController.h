//
//  NotesTableViewController.h
//  TabViewTest
//
//  Created by Sabin Dang on 4/1/11.
//  Copyright 2011 sabindang.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

@interface NotesTableViewController : CoreDataTableViewController {
    
}

@property (retain) UITabBarItem *tabBarItem;

- (id)initWithStyle:(UITableViewStyle)style inManagedContext:(NSManagedObjectContext *)context;

@end
