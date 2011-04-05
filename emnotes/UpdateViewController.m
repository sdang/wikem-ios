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

@implementation UpdateViewController
@synthesize tabBarItem, progressBar, progressText;
@synthesize ranInitialSetup, displayingLicense, licenseViewController;
@synthesize persistentStoreCoordinator;


#pragma mark - User Interface Actions

- (void)userDidAcceptLicense:(BOOL)status {
    if (status) {
        self.displayingLicense = NO;
        [self parseXMLDatabaseFile];
        [self updateAvailable:NO];
    }
}

- (void)updateProgressBar:(float)currentProgress message:(NSString *)messageString {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressBar.alpha = 1;
        self.progressBar.progress = currentProgress;
        self.progressText.text = messageString;
    });
}

#pragma mark - XML Processing

- (void)addNoteFromXMLElement:(TBXMLElement *)subElement context:(NSManagedObjectContext *)managedObjectContext
{
    NSString *content = [NSString stringWithString:[TBXML textForElement:[TBXML childElementNamed:@"content" parentElement:subElement]]];
    NSSet *categories = [NSSet setWithObject:[Category categoryWithTitle:[TBXML textForElement:[TBXML childElementNamed:@"folder" parentElement:subElement]] inManagedObjectContext:managedObjectContext]];
    if (![[categories anyObject] isKindOfClass:[Category class]]) {
        NSLog(@"Found a note without a category");
        categories = [NSSet setWithObject:[Category categoryWithTitle:@"Uncategorized" inManagedObjectContext:managedObjectContext]];
    }
    
    // [TBXML textForElement:[TBXML childElementNamed:@"content" parentElement:subElement]];
    [Note noteWithName:[TBXML textForElement:[TBXML childElementNamed:@"name" parentElement:subElement]]
                author:[TBXML textForElement:[TBXML childElementNamed:@"author" parentElement:subElement]]
               content:[content stringByDecodingHTMLEntities]
            lastUpdate:[NSDate date]
            categories:categories
inManagedObjectContext:managedObjectContext];
}


- (void)parseXMLDatabaseFile {
    dispatch_queue_t parseQueue = dispatch_queue_create("Parse XML Queue", NULL);
    dispatch_async(parseQueue, ^{
        [self disableAllTabBarItems:YES];
        
        [self updateProgressBar:0.0 message:@"Downloading WikEM Database"];
        
        NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
        NSLog(@"Running parse xml");
        // NSURL *theURL = [NSURL URLWithString:@"http://dl.android.wikem.org/database.xml"];
        // NSURL *theURL = [NSURL URLWithString:@"file:///database.xml"];
        // TBXML *tbxml = [TBXML tbxmlWithURL:theURL];
        // NSLog(@"%@", [NSString stringWithContentsOfURL:theURL encoding:nil error:nil]);
        
        NSString *path;
        NSString *content;
        if (!self.ranInitialSetup) {
            path = [[NSBundle mainBundle] pathForResource:@"database" ofType:@"xml"];
            content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
        } else {
            NSURL *theURL = [NSURL URLWithString:@"http://dl.android.wikem.org/database.xml"];
            content = [NSString stringWithContentsOfURL:theURL encoding:NSUTF8StringEncoding error:NULL];
        }
        
        // not ideal!!
        int totalNotes = [[content componentsSeparatedByString:@"<content>"] count]-1;
        
        TBXML *tbxml = [TBXML tbxmlWithXMLString:content];
        
        if (tbxml.rootXMLElement) {
           [self updateProgressBar:0.1 message:@"Updating Categories"];
            // Parse Categories
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
                // NSLog(@"%@", [TBXML valueOfAttributeNamed:@"id" forElement:subElement]);
                [self addNoteFromXMLElement:subElement context:managedObjectContext];
                i++;
                [self updateProgressBar:(0.8*(i/totalNotes))+0.2 message:@"Updating WikEM Notes"];
                
            } while ((subElement = subElement->nextSibling));
            [self updateProgressBar:1 message:@"Done"];
            [managedObjectContext save:nil];
            [self disableAllTabBarItems:NO];
            self.ranInitialSetup = YES;
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            [prefs setBool:self.ranInitialSetup forKey:@"ranInitialSetup"];
            [prefs synchronize];
        }
    });
    
}

- (IBAction)clearWikEMData
{
    dispatch_queue_t deleteQueue = dispatch_queue_create("Delete Queue", NULL);
    dispatch_async(deleteQueue, ^{
        [self disableAllTabBarItems:YES];
        NSLog(@"Deleting All Notes");
        NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        request.entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:managedObjectContext];
        [request setIncludesPropertyValues:NO];
        NSArray *notes = [managedObjectContext executeFetchRequest:request error:nil];
        for (Note *note in notes) {
            [managedObjectContext deleteObject:note];
        }
        [request release];
        
        NSFetchRequest *requestC = [[NSFetchRequest alloc] init];
        requestC.entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:managedObjectContext];
        [requestC setIncludesPropertyValues:NO];
        NSArray *categories = [managedObjectContext executeFetchRequest:requestC error:nil];
        for (Category *category in categories) {
            [managedObjectContext deleteObject:category];
        }
        
        [requestC release];
        [managedObjectContext save:nil];
        [managedObjectContext release];
        NSLog(@"Deleted All Notes");
        [self disableAllTabBarItems:NO];
    });
    
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
    if (status) {
        [[[[[self tabBarController] tabBar] items] objectAtIndex:3] setBadgeValue:@""];
    } else {
        [[[[[self tabBarController] tabBar] items] objectAtIndex:3] setBadgeValue:nil];
    }
    
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
    self.progressText.text = @"";
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
    [super viewDidUnload];
    self.licenseViewController = nil;
    self.progressBar = nil;
    self.progressText = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
