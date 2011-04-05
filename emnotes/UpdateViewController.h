//
//  UpdateViewController.h
//  TabViewTest
//
//  Created by Sabin Dang on 4/1/11.
//  Copyright 2011 sabindang.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "TBXML.h"
#include "AcceptLicense.h"

@interface UpdateViewController : UIViewController <AcceptLicenseDelegate> {
    AcceptLicense *licenseViewController;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    BOOL ranInitialSetup;
    BOOL displayingLicense;
}

@property (retain) AcceptLicense *licenseViewController;
@property (retain) UITabBarItem *tabBarItem;
@property (assign) BOOL ranInitialSetup;
@property (assign) BOOL displayingLicense;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)userDidAcceptLicense:(BOOL)status;
- (IBAction)clearWikEMData;
- (IBAction)parseXMLDatabaseFile;
- (void)addNoteFromXMLElement:(TBXMLElement *)subElement context:(NSManagedObjectContext *)managedContextIndex;
- (void)updateAvailable:(BOOL)status;
- (void)disableAllTabBarItems:(BOOL)status;

@end
