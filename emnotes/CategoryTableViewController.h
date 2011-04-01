//
//  CategoryTableViewController.h
//  TabViewTest
//
//  Created by Sabin Dang on 4/1/11.
//  Copyright 2011 sabindang.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Category.h"

@interface CategoryTableViewController : UITableViewController {
    Category *category;
}

@property (retain) UITabBarItem *tabBarItem;

@end
