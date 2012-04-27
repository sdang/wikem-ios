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
#import "ASIHTTPRequest.h"


// obj c preprocessor can include 'macro' such as this... can use ~like static var or code snippet
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

/*
 *  System Versioning Preprocessor Macros
 *

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)
*/

@interface UpdateViewController : UIViewController <AcceptLicenseDelegate> {
    AcceptLicense *licenseViewController;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    UIProgressView *progressBar;
    UIButton *updaterButton;
    UILabel *progressText;
    BOOL ranInitialSetup;
    BOOL displayingLicense;
    BOOL iOS5;
    UILabel *currentDatabaseCreatedLabel;
    UILabel *lastUpdateCheckLabel;
    UILabel *lastUpdatePerformedLabel;
    UILabel *noUpdateLabel;
    UIActivityIndicatorView   *indicator;
    UIButton *cancelDLButton ;

    //for downloadCancelButton, can't pass object (request) so need to retain it
    ASIHTTPRequest *dbDLRequest;
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
- (IBAction)dlThenParseXMLDatabaseFile;
- (IBAction)runUpdateCheck:(id)sender;
- (IBAction)displayAboutWikEMView:(id)sender;

- (void)addNoteFromXMLElement:(TBXMLElement *)subElement context:(NSManagedObjectContext *)managedContextIndex;
- (void)updateAvailable:(BOOL)status;
//- (NSDictionary *)checkUpdateAvailable;
- (void)disableAllTabBarItems:(BOOL)status;
- (void)updateProgressBar:(float)currentProgress message:(NSString *)messageString;
- (NSDictionary *)parseXMLInfoFileAfterDownload: (NSString*)content;
- (void)animateInNoUpdateText:(NSString *)updateMessage;
- (void)animateOutNoUpdateText;
- (void)autoUpdateCheck;
- (void)parseXMLAfterDownloaded: (NSString *)content;
- (IBAction)grabURLInBackground:(id)sender;
- (IBAction)grabInfoURLInBackground:(id)sender;
- (void)finishUpdateCheck:(NSDictionary*)infoFileContents;
 -(void)hideDates;
-(void)cancelDownload;
 

@end
