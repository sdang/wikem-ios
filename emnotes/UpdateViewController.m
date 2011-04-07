//
//  UpdateViewController.m
//  TabViewTest
//
//  Created by Sabin Dang on 4/1/11.
//  Copyright 2011 sabindang.com. All rights reserved.
//

#import "UpdateViewController.h"
#import "Category.h"
#import "Note.h"
#import "TBXML.h"
#import "NSString+HTML.h"
#import "AcceptLicense.h"
#import "AboutWikemViewController.h"

@implementation UpdateViewController
@synthesize currentDatabaseCreatedLabel;
@synthesize lastUpdateCheckLabel;
@synthesize lastUpdatePerformedLabel;
@synthesize tabBarItem, progressBar, progressText;
@synthesize ranInitialSetup, displayingLicense, licenseViewController;
@synthesize noUpdateLabel;
@synthesize persistentStoreCoordinator;
@synthesize updaterButton;

#pragma mark - Progress Bar & Update Button Animation

- (void)animateOutNoUpdateText
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationOptionCurveEaseIn];
    [self.noUpdateLabel setAlpha:0.0];
    [UIView commitAnimations];
}

- (void)animateInNoUpdateText:(NSString *)updateMessage
{
    self.noUpdateLabel.text = updateMessage;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationOptionCurveEaseOut];
    [UIView setAnimationDelegate:self];
    [self.noUpdateLabel setAlpha:1.0];
    [UIView commitAnimations];
    [NSTimer scheduledTimerWithTimeInterval:1.0f
                                     target:self
                                   selector:@selector(animateOutNoUpdateText)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)animateOutUpdaterButton
{
    // alpha = 0 if it's already hidden
    if (self.updaterButton.alpha != 0)
    [UIView transitionWithView:self.updaterButton
                      duration:0.5
                       options:UIViewAnimationCurveLinear
                    animations:^{ self.updaterButton.alpha = 0.0; self.updaterButton.frame = CGRectOffset(self.updaterButton.frame, 0, 100.0); }
                    completion:NULL];
}

- (void)animateOutProgressPackage
{
    // if alpha == 0 that means it's already hidden
    if (self.progressBar.alpha != 0) {
        // we're going to move up the package by 60 pts
        CGRect finalRectBar = CGRectOffset(self.progressBar.frame, 0.0, 60.0);
        CGRect finalRectText = CGRectOffset(self.progressText.frame, 0.0, 60.0);
        
        // actually do the animation
        [UIView transitionWithView:self.progressBar
                          duration:0.5
                           options:UIViewAnimationCurveLinear
                        animations:^{ self.progressBar.frame = finalRectBar; self.progressBar.alpha = 0.0;}
                        completion:NULL];
        [UIView transitionWithView:self.progressText   
                          duration:0.5
                           options:UIViewAnimationCurveLinear
                        animations:^{ self.progressText.frame = finalRectText; }
                        completion:NULL];
        
    }
}


- (void)animateInUpdaterButton
{

    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.progressBar.alpha == 1) {
            // progress bar on screen, animate it out
            [self animateOutProgressPackage];
        }
        
        // alpha = 1 if it's already shown
        if (self.updaterButton.alpha != 1)
            [UIView transitionWithView:self.updaterButton
                              duration:0.5
                               options:UIViewAnimationCurveLinear
                            animations:^{ self.updaterButton.alpha = 1.0; self.updaterButton.frame = CGRectOffset(self.updaterButton.frame, 0, -100.0); }
                            completion:NULL];
    });
}



- (void)animateInProgressPackage
{
    
    // if the updater button is in the way get it out!
    if (self.updaterButton.alpha == 1) {
        [self animateOutUpdaterButton];
    }
    
    // if alpha == 1 that means we're already showing it
    if (self.progressBar.alpha != 1) {
        // we're going to move up the package by 60 pts
        CGRect finalRectBar = CGRectOffset(self.progressBar.frame, 0.0, -60.0);
        CGRect finalRectText = CGRectOffset(self.progressText.frame, 0.0, -60.0);
        
        // make sure we can see the progress bar pkg
        self.progressBar.alpha = 1;
        
        // actually do the animation
        [UIView transitionWithView:self.progressBar
                          duration:0.5
                           options:UIViewAnimationCurveLinear
                        animations:^{ self.progressBar.frame = finalRectBar; }
                        completion:NULL];
        [UIView transitionWithView:self.progressText   
                          duration:0.5
                           options:UIViewAnimationCurveLinear
                        animations:^{ self.progressText.frame = finalRectText; }
                        completion:NULL];
        
    }
    
}


#pragma mark - Accept License Delegate

- (void)userDidAcceptLicense:(BOOL)status {
    if (status) {
        self.displayingLicense = NO;
        [self parseXMLDatabaseFile];
        [self updateAvailable:NO];
    }
}

#pragma mark - Manage About Screen
- (IBAction)displayAboutWikEMView:(id)sender
{
    AboutWikemViewController *about = [[AboutWikemViewController alloc] init];
    [self setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [about setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [self presentModalViewController:about animated:YES];
    [about release];
}


#pragma mark - User Interface Elements

- (void)updateUpdateTimes
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // update the update stats
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd/yy hh:mma"];
        
        NSDate *lastDatabaseGenerationTime = [NSDate dateWithTimeIntervalSince1970:[prefs integerForKey:@"lastDatabaseGenerationTime"]];
        NSDate *lastDatabaseCheck = [NSDate dateWithTimeIntervalSince1970:[prefs integerForKey:@"lastDatabaseCheck"]];
        NSDate *lastDatabaseUpdate = [NSDate dateWithTimeIntervalSince1970:[prefs integerForKey:@"lastDatabaseUpdate"]];
        
        if ([prefs integerForKey:@"lastDatabaseGenerationTime"] != 0) {
            self.currentDatabaseCreatedLabel.text = [dateFormatter stringFromDate:lastDatabaseGenerationTime];
        } else {
            self.currentDatabaseCreatedLabel.text = @"";
        }
        
        if ([prefs integerForKey:@"lastDatabaseCheck"] != 0) {
            self.lastUpdateCheckLabel.text = [dateFormatter stringFromDate:lastDatabaseCheck];
        } else {
            self.lastUpdateCheckLabel.text = @"";
        }
        
        if ([prefs integerForKey:@"lastDatabaseUpdate"] != 0) {
            self.lastUpdatePerformedLabel.text = [dateFormatter stringFromDate:lastDatabaseUpdate];
        } else {
            self.lastUpdatePerformedLabel.text = @"";
        }


        [dateFormatter release];
    });
}

- (void)updateProgressBar:(float)currentProgress message:(NSString *)messageString {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.progressBar.alpha != 1) {
            [self animateInProgressPackage];
        }
        
        self.progressBar.progress = currentProgress;
        self.progressText.text = messageString;
        
        if ([self.progressText.text isEqualToString:@"Done"]) {
            // we're done so hide the progress bar package in 1 second
            [NSTimer scheduledTimerWithTimeInterval:1.0f
                                             target:self
                                           selector:@selector(animateOutProgressPackage)
                                           userInfo:nil
                                            repeats:NO];
        }
    });
}


- (IBAction)runUpdateCheck:(id)sender
{
    NSDictionary *infoFileContents = [self checkUpdateAvailable];
    if ([infoFileContents count] == 2) {
        [self animateInNoUpdateText:@"Update Available"];
        [self updateAvailable:YES];
    } else if ([infoFileContents count] == 1) {
        [self animateInNoUpdateText:@"Database is Up to Date"];
    } else {
        [self animateInNoUpdateText:@"Error Checking for Update"];
    }
}


#pragma mark - XML Processing
- (void)autoUpdateCheck
{
    if (self.ranInitialSetup) {
        dispatch_queue_t updateQueue = dispatch_queue_create("Run Auto Update Check", NULL);
        dispatch_async(updateQueue, ^{
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        if ([prefs boolForKey:@"updateAvailable"]) {
            [self updateAvailable:YES];
            return;
        }
            
        NSTimeInterval nowInEpoch = [[NSDate date] timeIntervalSince1970];
        if (nowInEpoch > ([prefs integerForKey:@"lastDatabaseCheck"] + 7 * 24 * 3600) && ranInitialSetup) {
            NSLog(@"Will perform auto check (last check: %@)", [NSDate dateWithTimeIntervalSince1970:[prefs integerForKey:@"lastDatabaseCheck"]]);
            [self checkUpdateAvailable];
        } else {
            NSLog(@"Will NOT perform auto check (last check: %@)", [NSDate dateWithTimeIntervalSince1970:[prefs integerForKey:@"lastDatabaseCheck"]]);
        }
        });
        dispatch_release(updateQueue);
    }
}

- (NSDictionary *)checkUpdateAvailable
{
    NSDictionary *infoFileContents = [self parseXMLInfoFile];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    
    NSNumber *totalNumberOfNotes = nil;
    NSNumber *infoGenerationTime = nil;
    
    if (infoFileContents) {
        // update last update check time, only update last check if we have data
        [prefs setInteger:[[NSDate date] timeIntervalSince1970] forKey:@"lastDatabaseCheck"];
        totalNumberOfNotes = [infoFileContents objectForKey:@"size"];
        infoGenerationTime = [infoFileContents objectForKey:@"lastUpdate"];
    } else {
        NSLog(@"Error parsing info file");
        return nil;
    }
    
    [prefs synchronize];
    [self updateUpdateTimes];
    
    if (NSOrderedDescending == [infoGenerationTime compare:[NSNumber numberWithInt:[prefs integerForKey:@"lastDatabaseGenerationTime"]]]) {
        [self updateAvailable:YES];
        return infoFileContents;
    } else {
        [self updateAvailable:NO];
        return [NSDictionary dictionaryWithObject:nil forKey:@"size"];
    }
}

- (NSDictionary *)parseXMLInfoFile {
    NSString *infoFile = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"info_url"];

    NSURL *theURL = [NSURL URLWithString:infoFile];
    NSString *content = [NSString stringWithContentsOfURL:theURL encoding:NSUTF8StringEncoding error:NULL];

    
    TBXML *tbxml = [TBXML tbxmlWithXMLString:content]; 
    
    int size = 0;
    int lastUpdate = 0;
    
    if (tbxml.rootXMLElement) {
        TBXMLElement *lastUpdateElement = [TBXML childElementNamed:@"lastupdate" parentElement:tbxml.rootXMLElement];
        TBXMLElement *sizeElement = [TBXML childElementNamed:@"size" parentElement:tbxml.rootXMLElement];
        size = [[TBXML valueOfAttributeNamed:@"num" forElement:sizeElement] intValue];
        lastUpdate = [[TBXML valueOfAttributeNamed:@"epoch" forElement:lastUpdateElement] intValue];
    }

    NSDictionary *infoFileContents = nil;
    if (size && lastUpdate) {
        infoFileContents = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:size], @"size", [NSNumber numberWithInt:lastUpdate], @"lastUpdate", nil];
    } 
    
    return infoFileContents;
}


- (void)addNoteFromXMLElement:(TBXMLElement *)subElement context:(NSManagedObjectContext *)managedObjectContext
{
    NSString *content = [NSString stringWithString:[TBXML textForElement:[TBXML childElementNamed:@"content" parentElement:subElement]]];
    NSSet *categories = [NSSet setWithObject:[Category categoryWithTitle:[TBXML textForElement:[TBXML childElementNamed:@"folder" parentElement:subElement]] inManagedObjectContext:managedObjectContext]];
    if (![[categories anyObject] isKindOfClass:[Category class]]) {
        NSLog(@"Found a note without a category");
        categories = [NSSet setWithObject:[Category categoryWithTitle:@"Uncategorized" inManagedObjectContext:managedObjectContext]];
    }
    
    [Note noteWithName:[TBXML textForElement:[TBXML childElementNamed:@"name" parentElement:subElement]]
                author:[TBXML textForElement:[TBXML childElementNamed:@"author" parentElement:subElement]]
               content:[content stringByDecodingHTMLEntities]
            lastUpdate:[NSDate date]
            categories:categories
inManagedObjectContext:managedObjectContext];
}

- (NSString *)getXMLDatabaseContents
{
    NSString *path;
    NSString *content = nil;
    if (!self.ranInitialSetup) {
        path = [[NSBundle mainBundle] pathForResource:@"database" ofType:@"xml"];
        content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    } else {
        NSString *databaseFile = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"database_url"];
        NSURL *theURL = [NSURL URLWithString:databaseFile];
        content = [NSString stringWithContentsOfURL:theURL encoding:NSUTF8StringEncoding error:NULL];
    }
    
    return content;
}

- (void)parseXMLDatabaseFile {
    
    dispatch_queue_t parseQueue = dispatch_queue_create("Parse XML Queue", NULL);
    dispatch_async(parseQueue, ^{
        [self disableAllTabBarItems:YES];
        
        [self updateProgressBar:0.0 message:@"Downloading WikEM Database"];
        
        NSManagedObjectContext *managedObjectContext = [[[NSManagedObjectContext alloc] init] autorelease];
        [managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
        NSLog(@"Running parse xml");
        
        NSString *content = [self getXMLDatabaseContents];
        
        // not ideal!! But we need a way to count number notes for updating progress bar
        int totalNotes = [[content componentsSeparatedByString:@"<content>"] count]-1;
        
        TBXML *tbxml = [TBXML tbxmlWithXMLString:content];
        
        if (tbxml.rootXMLElement) {
            
            // extract : <root created="1301616061">
            int databaseGenerationTime = [[TBXML valueOfAttributeNamed:@"created" forElement:tbxml.rootXMLElement] intValue];
            
            if (! databaseGenerationTime) {
                [self updateProgressBar:1.0 message:@"Error: Invalid WikEM Data"];
            } else {
                // clear the database
                [self clearWikEMData];
               
                // Parse Categories
                [self updateProgressBar:0.1 message:@"Updating Categories"];
                TBXMLElement *categories = [TBXML childElementNamed:@"categories" parentElement:tbxml.rootXMLElement];
                TBXMLElement *subElement = categories->firstChild;
                do {
                    NSString *title = [NSString stringWithString:[TBXML valueOfAttributeNamed:@"title" forElement:subElement]];
                    [Category categoryWithTitle:title inManagedObjectContext:managedObjectContext];
                } while ((subElement = subElement->nextSibling));
                
                // Parse Notes
               [self updateProgressBar:0.2 message:@"Updating WikEM Notes"];
                TBXMLElement *notes = [TBXML childElementNamed:@"pages" parentElement:tbxml.rootXMLElement];
                subElement = notes->firstChild;
                float i = 0.0;
                do {
                    [self addNoteFromXMLElement:subElement context:managedObjectContext];
                    i++;
                    [self updateProgressBar:(0.8*(i/totalNotes))+0.2 message:@"Updating WikEM Notes"];
                    
                } while ((subElement = subElement->nextSibling));
                [self updateProgressBar:1 message:@"Done"];
                [managedObjectContext save:nil];
                [self disableAllTabBarItems:NO];
                self.ranInitialSetup = YES;
                
                NSUserDefaults *prefsThread = [NSUserDefaults standardUserDefaults];
                [prefsThread setInteger:[[NSDate date] timeIntervalSince1970] forKey:@"lastDatabaseUpdate"];
                [prefsThread setInteger:databaseGenerationTime forKey:@"lastDatabaseGenerationTime"];
                [prefsThread setBool:self.ranInitialSetup forKey:@"ranInitialSetup"];
                [prefsThread synchronize];
                [self updateUpdateTimes];
                [self updateAvailable:NO];
            }
        }
    });
    dispatch_release(parseQueue);
}

- (IBAction)clearWikEMData
{
    // commented out multithreading deleting b/c it crashes parseXMLDatabase
    // dispatch_queue_t deleteQueue = dispatch_queue_create("Delete Queue", NULL);
    // dispatch_async(deleteQueue, ^{
        NSLog(@"Deleting All Notes");
        NSManagedObjectContext *managedObjectContextClear = [[NSManagedObjectContext alloc] init];
        [managedObjectContextClear setPersistentStoreCoordinator:self.persistentStoreCoordinator];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        request.entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:managedObjectContextClear];
        [request setIncludesPropertyValues:NO];
        NSArray *notes = [managedObjectContextClear executeFetchRequest:request error:nil];
        for (Note *note in notes) {
            [managedObjectContextClear deleteObject:note];
        }
        [request release];
        
        NSFetchRequest *requestC = [[NSFetchRequest alloc] init];
        requestC.entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:managedObjectContextClear];
        [requestC setIncludesPropertyValues:NO];
        NSArray *categories = [managedObjectContextClear executeFetchRequest:requestC error:nil];
        for (Category *category in categories) {
            [managedObjectContextClear deleteObject:category];
        }
        
        [requestC release];
        [managedObjectContextClear save:nil];
        [managedObjectContextClear release];
        NSLog(@"Deleted All Notes");
    // });
    // dispatch_release(deleteQueue);
}

#pragma mark - Tab Bar Controls

- (void)setupTabBarItem
{
    UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:@"Update" image:[UIImage imageNamed:@"10-medical.png"] tag:0];
    self.tabBarItem = item;
    [item release];
}

- (void)updateAvailable:(BOOL)status
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        if (status) {
            // show red dot to indicate update available
            [[[[[self tabBarController] tabBar] items] objectAtIndex:3] setBadgeValue:@""];
            
            // show button to allow user to update if it isn't already shown
            [self animateInUpdaterButton];
            [prefs setBool:YES forKey:@"updateAvailable"];
            
        } else {
            [[[[[self tabBarController] tabBar] items] objectAtIndex:3] setBadgeValue:nil];
            [prefs setBool:NO forKey:@"updateAvailable"];
        }
        [prefs synchronize];
    });
    
}

- (void)disableAllTabBarItems:(BOOL)status {
    BOOL x;
    if (status) {
        x = FALSE;
    } else {
        x = TRUE;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[[[self tabBarController] tabBar] items] objectAtIndex:0] setEnabled:x];
        [[[[[self tabBarController] tabBar] items] objectAtIndex:1] setEnabled:x];
        [[[[[self tabBarController] tabBar] items] objectAtIndex:2] setEnabled:x];
    });
    
}



#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setupTabBarItem];
    }
    return self;
}

- (void)dealloc
{
    [progressBar release];
    [persistentStoreCoordinator release];
    [licenseViewController release];
    [tabBarItem release];
    [progressText release];
    [updaterButton release];
    [currentDatabaseCreatedLabel release];
    [lastUpdateCheckLabel release];
    [lastUpdatePerformedLabel release];
    [noUpdateLabel release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.progressBar.alpha = 0.0;
    self.updaterButton.alpha = 0.0;
    self.updaterButton.frame = CGRectOffset(self.updaterButton.frame, 0.0, 100.0);
    self.progressBar.frame = CGRectOffset(self.progressBar.frame, 0.0, 60.0);
    self.progressText.frame = CGRectOffset(self.progressText.frame, 0.0, 60.0);
    self.progressText.text = @"";
    self.noUpdateLabel.text = @"";
    self.noUpdateLabel.alpha = 0.0;
    [self updateUpdateTimes];
    
    // do we need to display the progress bar?
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if ([prefs boolForKey:@"updateAvailable"]) {
        [self animateInUpdaterButton];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    if (!self.ranInitialSetup && !self.displayingLicense) {
        [self disableAllTabBarItems:YES];
        self.licenseViewController = [[AcceptLicense alloc] init];
        if (!ranInitialSetup) {
            UIApplication *app = [UIApplication sharedApplication];
            CGRect finalRect = CGRectMake(0.0,0, self.view.bounds.size.width, self.view.bounds.size.height);
            CGRect hiddenRect = CGRectMake(0.0,self.view.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height - app.statusBarFrame.size.height);
            licenseViewController.view.frame = hiddenRect;
            licenseViewController.delegate = self;
            
            [UIView transitionWithView:licenseViewController.view
                              duration:0.5
                               options:UIViewAnimationOptionTransitionCurlDown
                            animations:^{ licenseViewController.view.frame = finalRect; }
                            completion:NULL];
            
            
            [self.view addSubview:licenseViewController.view];

            self.displayingLicense = YES;
            [self updateAvailable:YES];
        }
    }
    
}

- (void)viewDidUnload
{
    [self setCurrentDatabaseCreatedLabel:nil];
    [self setLastUpdateCheckLabel:nil];
    [self setLastUpdatePerformedLabel:nil];
    [self setNoUpdateLabel:nil];
    [super viewDidUnload];
    self.licenseViewController = nil;
    self.progressBar = nil;
    self.progressText = nil;
    self.updaterButton = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
