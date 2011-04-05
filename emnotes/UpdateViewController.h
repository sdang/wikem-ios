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
    UIProgressView *progressBar;
    UIButton *updaterButton;
    UILabel *progressText;
    BOOL ranInitialSetup;
    BOOL displayingLicense;
}

@property (retain) AcceptLicense *licenseViewController;
@property (retain) UITabBarItem *tabBarItem;
@property (assign) BOOL ranInitialSetup;
@property (assign) BOOL displayingLicense;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (retain) IBOutlet UIProgressView *progressBar;
@property (retain) IBOutlet UILabel *progressText;
@property (retain) IBOutlet UIButton *updaterButton;
- (void)userDidAcceptLicense:(BOOL)status;
- (IBAction)clearWikEMData;
- (IBAction)parseXMLDatabaseFile;
- (IBAction)runUpdateCheck:(id)sender;

- (void)addNoteFromXMLElement:(TBXMLElement *)subElement context:(NSManagedObjectContext *)managedContextIndex;
- (void)updateAvailable:(BOOL)status;
- (NSDictionary *)checkUpdateAvailable;
- (void)disableAllTabBarItems:(BOOL)status;
- (void)updateProgressBar:(float)currentProgress message:(NSString *)messageString;
- (NSDictionary *)parseXMLInfoFile;

@end
