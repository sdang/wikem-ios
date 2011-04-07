//
//  emnotesAppDelegate.h
//  emnotes
//
//  Created by Sabin Dang on 4/1/11.
//  Copyright 2011 sabindang.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UpdateViewController.h"

@interface emnotesAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
        UITabBarController *tabBar;
        UpdateViewController *uVC;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) UpdateViewController *uVC;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) IBOutlet UITabBarController *tabBar;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
