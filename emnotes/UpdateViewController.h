//
//  UpdateViewController.h
//  TabViewTest
//
//  Created by Sabin Dang on 4/1/11.
//  Copyright 2011 sabindang.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBXML.h"
#import "AcceptLicense.h"
#import "AboutWikemViewController.h"

@interface UpdateViewController : UIViewController <AcceptLicenseDelegate> {
    AcceptLicense *licenseViewController;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    UIProgressView *progressBar;
    UIButton *updaterButton;
    UILabel *progressText;
    BOOL ranInitialSetup;
    BOOL displayingLicense;
    UILabel *currentDatabaseCreatedLabel;
    UILabel *lastUpdateCheckLabel;
    UILabel *lastUpdatePerformedLabel;
    UILabel *noUpdateLabel;
    UIActivityIndicatorView   *indicator;

}


@property (nonatomic, retain) AcceptLicense *licenseViewController;
@property (nonatomic, retain) UITabBarItem *tabBarItem;
@property (nonatomic, retain) IBOutlet UILabel *noUpdateLabel;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) IBOutlet UILabel *currentDatabaseCreatedLabel;
@property (nonatomic, retain) IBOutlet UILabel *lastUpdateCheckLabel;
@property (nonatomic, retain) IBOutlet UILabel *lastUpdatePerformedLabel;
@property (nonatomic, retain) IBOutlet UIProgressView *progressBar;
@property (nonatomic, retain) IBOutlet UILabel *progressText;
@property (nonatomic, retain) IBOutlet UIButton *updaterButton;

@property (nonatomic, retain) IBOutlet UIImageView *logo;
@property (nonatomic, retain) IBOutlet UIButton *updatecheckbutton;
@property (nonatomic, retain) IBOutlet UILabel *datesLabel1;
@property (nonatomic, retain) IBOutlet UILabel *datesLabel2;
@property (nonatomic, retain) IBOutlet UILabel *datesLabel3;


@property (assign) BOOL ranInitialSetup;
@property (assign) BOOL displayingLicense;
@property (assign) BOOL isOffset;



- (void)userDidAcceptLicense:(BOOL)status;
- (IBAction)clearWikEMData;
- (IBAction)parseXMLDatabaseFile;
- (IBAction)runUpdateCheck:(id)sender;
- (IBAction)displayAboutWikEMView:(id)sender;

- (void)addNoteFromXMLElement:(TBXMLElement *)subElement context:(NSManagedObjectContext *)managedContextIndex;
- (void)updateAvailable:(BOOL)status;
- (NSDictionary *)checkUpdateAvailable;
- (void)disableAllTabBarItems:(BOOL)status;
- (void)updateProgressBar:(float)currentProgress message:(NSString *)messageString;
- (NSDictionary *)parseXMLInfoFileAfterDownload: (NSString*)content;
- (void)animateInNoUpdateText:(NSString *)updateMessage;
- (void)animateOutNoUpdateText;
- (void)autoUpdateCheck;
- (void)parseXMLAfterDownloaded: (NSString *)content;
- (IBAction)grabURLInBackground:(id)sender;
- (IBAction)grabInfoURLInBackground:(id)sender;




-(void)hideDates;

@end
