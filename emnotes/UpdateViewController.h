//
//  UpdateViewController.h
//  TabViewTest
//
//  Created by Sabin Dang on 4/1/11.
//  Copyright 2011 sabindang.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "TBXML.h"

@interface UpdateViewController : UIViewController {
    NSManagedObjectContext *managedObjectContext;
}

@property (retain) UITabBarItem *tabBarItem;
@property (retain) NSManagedObjectContext *managedObjectContext;
- (IBAction)clearWikEMData;
- (IBAction)parseXMLDatabaseFile;
- (void)addNoteFromXMLElement:(TBXMLElement *)subElement;

@end
