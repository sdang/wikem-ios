//////
//  emnotesAppDelegate.m
//  emnotes
//
//  Created by Sabin Dang on 4/1/11.
//  Copyright 2011 sabindang.com. All rights reserved.
//

#import "emnotesAppDelegate.h"
#import "CategoryTableViewController.h"
#import "NotesTableViewController.h"
#import "PersonalNotesTableViewController.h"
#import "UpdateViewController.h"
#import "AcceptLicense.h"
#import "Category.h"
#import "Note.h"
//add import now that we alloc a context
#import "NoteViewController.h"
//#import "MyTabBarController.h"

@implementation emnotesAppDelegate


@synthesize window=_window;
@synthesize managedObjectContext=__managedObjectContext;
@synthesize managedObjectModel=__managedObjectModel;
@synthesize persistentStoreCoordinator=__persistentStoreCoordinator;
@synthesize tabBar;
@synthesize uVC;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
 
	
    // is this the first time we've been run?
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    BOOL ranInitialSetup = [prefs boolForKey:@"ranInitialSetup"];
    
    if (!ranInitialSetup)
        NSLog(@"This is a first run");
      
    UINavigationController *categoriesNavCon = [[UINavigationController alloc] init];
    CategoryTableViewController *categoryTableViewController = [[CategoryTableViewController alloc] 
                                                                initWithStyle:UITableViewStylePlain
                                                                inManagedContext:self.managedObjectContext];
    
    categoryTableViewController.managedObjectContext = self.managedObjectContext;
    [categoriesNavCon pushViewController:categoryTableViewController animated:NO];
    [categoryTableViewController release];
		
    UINavigationController *allNotesNavCon = [[UINavigationController alloc] init];
    NotesTableViewController *notesTableViewController = [[NotesTableViewController alloc]
                                                          initWithStyle:UITableViewStylePlain
                                                          inManagedContext:self.managedObjectContext
                                                          withCategory:nil];
	//ck added this setter
    notesTableViewController.managedObjectContext = self.managedObjectContext;
	
    [allNotesNavCon pushViewController:notesTableViewController animated:NO];
    [notesTableViewController release];
    
    UINavigationController *personalNotesNavCon = [[UINavigationController alloc] init];
    PersonalNotesTableViewController *personalNotesTableViewController = [[PersonalNotesTableViewController alloc]
                                                                          initWithStyle:UITableViewStylePlain
                                                                    inManagedContext:self.managedObjectContext];
    
    [personalNotesNavCon pushViewController:personalNotesTableViewController animated:NO];
    [personalNotesTableViewController release];
    
    UpdateViewController *updateViewController = [[UpdateViewController alloc] init];
    updateViewController.persistentStoreCoordinator = self.persistentStoreCoordinator;
    self.uVC = updateViewController;
    
    self.tabBar = [[UITabBarController alloc] init];
  	
    self.tabBar.delegate = self;
    
    tabBar.viewControllers = [NSArray arrayWithObjects:categoriesNavCon, allNotesNavCon, personalNotesNavCon, updateViewController, nil];
 
    [categoriesNavCon release];
    [allNotesNavCon release];
    [personalNotesNavCon release];
    [updateViewController release];
    
    [self.window addSubview:tabBar.view];
    [self.window makeKeyAndVisible];
    
    if (!ranInitialSetup) {
        updateViewController.ranInitialSetup = FALSE;
        [tabBar setSelectedIndex:3];    
    } else {
        updateViewController.ranInitialSetup = TRUE;
    }
    
    return YES;

}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
	NSLog(@"didSelectViewController");

    // if we're a navigation controller, pop back to root
    if ([viewController isKindOfClass:[UINavigationController class]]) {
		NSLog(@"should pop if navigation class");

        [(UINavigationController *)viewController popToRootViewControllerAnimated:NO];
    }
	
	
	
		//NSUInteger indexOfTab = [tabBarController.viewControllers indexOfObject:viewController];
		//NSLog(@"Tab index = %u (%u)", indexOfTab);
	/*if(indexOfTab ==3){ //ie we are in update view. try force portrait only
		tabBar.dontrotate = TRUE;
		
	}else{
		tabBar.dontrotate = FALSE;
	}*/
	
	
}

 

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state;
	 here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    [self.uVC autoUpdateCheck];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)dealloc
{
    [_window release];
    [__managedObjectContext release];
    [__managedObjectModel release];
    [__persistentStoreCoordinator release];
    [uVC release];
    [super dealloc];
}

- (void)awakeFromNib
{
    /*
     Typically you should set up the Core Data stack here, 
	 usually by passing the managed object context to the first view controller.
     self.<#View controller#>.managedObjectContext = self.managedObjectContext;
    */
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"emnotes" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"emnotes.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
       /*
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        
        NSLog(@"Error opening the database. Deleting the file and trying again.");
        
        //if the app did not quit, show the alert to inform the users that the data have been deleted
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Error encountered while reading old database. Please allow all the data to download again. Personal Notes in old version will be deleted." message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
        [alert show];
        
        //delete the sqlite file and try again
        [[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:nil];
        if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
